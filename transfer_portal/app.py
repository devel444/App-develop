"""양산이관 검증위원회 통합 관리 포털 - Python 서버 (표준 라이브러리만 사용, 추가 설치 불필요).

실행: python app.py  (또는 run_server.bat 더블클릭)
접속: http://<서버PC IP>:8000

데이터는 사내 공유폴더(NETWORK_DIR)에 저장하며, 접근할 수 없으면 ./shared_data 로 자동 전환한다.
회사망에서 pip 설치가 막혀도 동작하도록 FastAPI 등 외부 패키지를 쓰지 않는다.
"""
from __future__ import annotations

import copy
import datetime as dt
import mimetypes
import hashlib
import html
import json
import os
import re
import secrets
import shutil
import smtplib
import socket
import subprocess
import sys
import tempfile
import threading
import time
import traceback
from email.message import EmailMessage
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple
from urllib.parse import quote, unquote, urlsplit

# ---------------------------------------------------------------------------
# 기본 설정
# ---------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent
NETWORK_DIR = r"\\10.150.6.49\전사혁신과제관리용_db\(기술혁신)_양산이관_검증위원회"
LOCAL_DIR = BASE_DIR / "shared_data"
HOST = os.environ.get("PORTAL_HOST", "0.0.0.0")
PORT = int(os.environ.get("PORTAL_PORT", "8000"))
MAX_UPLOAD_BYTES = 100 * 1024 * 1024  # 파일당 100MB
MAX_REQUEST_BYTES = 500 * 1024 * 1024  # 요청 1건(여러 파일 합계)
TOKEN_TTL_SEC = 12 * 3600
BACKUP_KEEP_DAYS = 30

STAGE_KEYS = ["step1", "step2", "step3", "step4", "step5"]
STAGE_NAMES = ["전문소위원 검토", "양산이관 검증소위원회", "전문위원 검토", "검증위원회", "최종승인"]
SECTORS = ["품질/수율", "장비", "생산성", "Process", "제조", "손익"]
LEVEL_NAMES = {"sub": "전문소위원", "main": "전문위원"}
LEVEL_DESC = {"sub": "전문소위원(팀장급)", "main": "전문위원(담당/본부장급)"}
EMAIL_RE = re.compile(r"^[^@\s;,<>]+@[^@\s;,<>]+\.[^@\s;,<>]+$")
ID_RE = re.compile(r"^[A-Za-z0-9_\-]{1,64}$")
EMP_ID_RE = re.compile(r"^[A-Za-z0-9_\-]{3,20}$")
USER_TOKEN_TTL_SEC = 7 * 24 * 3600
PRESENCE_TTL_SEC = 60

# 팀 목록 (관리자 모드에서 이름/부문/신청권한 수정 가능)
#  - canApply: 양산이관 신청 가능한 개발팀
#  - sector  : 6대 부문 검토 담당 팀 (해당 부문 Risk 행 작성 권한)
DEFAULT_TEAMS = [
    {"name": "결정성장개발팀", "sector": "", "canApply": True},
    {"name": "EPI개발팀", "sector": "", "canApply": True},
    {"name": "Wafering개발팀", "sector": "", "canApply": True},
    {"name": "제품개발팀", "sector": "", "canApply": True},
    {"name": "품질보증팀", "sector": "품질/수율", "canApply": False},
    {"name": "설비기술팀", "sector": "장비", "canApply": False},
    {"name": "생산관리팀", "sector": "생산성", "canApply": False},
    {"name": "공정기술팀", "sector": "Process", "canApply": False},
    {"name": "제조팀", "sector": "제조", "canApply": False},
    {"name": "경영기획팀", "sector": "손익", "canApply": False},
]


# ---------------------------------------------------------------------------
# 공용 유틸
# ---------------------------------------------------------------------------
class HTTPException(Exception):
    """핸들러에서 던지면 {"detail": ...} JSON 오류 응답으로 바뀐다."""

    def __init__(self, status: int, detail: Any):
        super().__init__(str(detail))
        self.status = status
        self.detail = detail


def now_str() -> str:
    return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def today_str() -> str:
    return dt.date.today().isoformat()


def _s(v: Any) -> str:
    return "" if v is None else str(v).strip()


def _text(v: Any) -> str:
    """여러 줄 텍스트: 줄바꿈은 유지하고 앞뒤 공백만 정리."""
    return "" if v is None else str(v).replace("\r\n", "\n").strip()


def _date(v: Any) -> str:
    """'2026-3-5', '2026.03.05', '2026/03/05' → '2026-03-05'. 형식이 아니면 ''."""
    s = _s(v).replace(".", "-").replace("/", "-")
    m = re.match(r"^(\d{4})-(\d{1,2})-(\d{1,2})", s)
    if not m:
        return ""
    y, mo, d = int(m.group(1)), int(m.group(2)), int(m.group(3))
    try:
        return dt.date(y, mo, d).isoformat()
    except ValueError:
        return ""


def _emails(v: Any) -> List[str]:
    """문자열(; , 줄바꿈 구분) 또는 리스트 → 유효한 이메일 리스트(중복 제거)."""
    parts = v if isinstance(v, list) else re.split(r"[;,\s]+", _s(v))
    out: List[str] = []
    for p in parts:
        p = _s(p)
        if p and EMAIL_RE.match(p) and p.lower() not in [o.lower() for o in out]:
            out.append(p)
    return out


def hash_password(password: str, salt: str) -> str:
    return hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), 120_000).hex()


def safe_filename(name: str) -> str:
    name = _s(name).replace("\\", "/").split("/")[-1]
    name = re.sub(r'[<>:"|?*\x00-\x1f]', "_", name).strip(" .")
    if not name:
        name = "file"
    stem = name.split(".")[0].upper()
    if stem in {"CON", "PRN", "AUX", "NUL"} or re.match(r"^(COM|LPT)\d$", stem):
        name = "_" + name
    if len(name) > 150:
        root, ext = os.path.splitext(name)
        name = root[: 150 - len(ext)] + ext
    return name


def unique_path(folder: Path, name: str) -> Path:
    target = folder / name
    root, ext = os.path.splitext(name)
    n = 2
    while target.exists():
        target = folder / f"{root} ({n}){ext}"
        n += 1
    return target


def lan_ip() -> str:
    """사내망 IP 추정 (패킷은 실제로 전송되지 않음)."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("10.150.6.49", 445))
            return s.getsockname()[0]
    except OSError:
        return "127.0.0.1"


# ---------------------------------------------------------------------------
# 데이터 정규화 (프론트엔드 static/app.js 와 동일한 규칙)
# ---------------------------------------------------------------------------
def normalize_grade(g: Any) -> str:
    s = _s(g).upper()
    if not s:
        return ""
    if s in ("상", "A"):
        return "상"
    if s in ("중", "B", "C"):
        return "중"
    if s in ("하", "D"):
        return "하"
    return "중"


def normalize_risk(r: Dict[str, Any]) -> Dict[str, Any]:
    r = r if isinstance(r, dict) else {}
    no_risk = bool(r.get("noRisk"))
    is_task = (not no_risk) and _s(r.get("isTask")).upper() == "O"
    return {
        "sector": r.get("sector") if r.get("sector") in SECTORS else SECTORS[0],
        "reviewer": _s(r.get("reviewer")),
        "noRisk": no_risk,
        "riskItem": "" if no_risk else _text(r.get("riskItem")),
        "isTask": "O" if is_task else "X",
        "grade": (normalize_grade(r.get("grade")) or "중") if is_task else "",
        "planContent": "" if no_risk else _text(r.get("planContent")),
        "org": _s(r.get("org")),
        "schedule": _date(r.get("schedule")),
        "status": "완료" if _s(r.get("status")) == "완료" else "진행중",
    }


def default_risk_rows() -> List[Dict[str, Any]]:
    return [normalize_risk({"sector": s, "noRisk": False, "isTask": "X"}) for s in SECTORS]


def normalize_attachment(a: Any) -> Optional[Dict[str, Any]]:
    if not isinstance(a, dict) or not _s(a.get("name")):
        return None
    return {
        "name": safe_filename(a.get("name")),
        "size": int(a.get("size") or 0),
        "uploadedAt": _s(a.get("uploadedAt")),
        "by": _s(a.get("by")),
    }


def normalize_sector_reviews(v: Any) -> Dict[str, Dict[str, str]]:
    """부문별 '작성 완료' 기록 {부문: {empId, name, team, at}}."""
    out = {}
    if isinstance(v, dict):
        for sector, r in v.items():
            if sector in SECTORS and isinstance(r, dict):
                out[sector] = {k: _s(r.get(k)) for k in ("empId", "name", "team", "at")}
    return out


def normalize_item(raw: Dict[str, Any]) -> Dict[str, Any]:
    raw = raw if isinstance(raw, dict) else {}
    category = "기술" if raw.get("category") == "기술" else "제품"
    raw_stages = raw.get("stages") if isinstance(raw.get("stages"), dict) else {}
    stages = {}
    for k in STAGE_KEYS:
        v = raw_stages.get(k) if isinstance(raw_stages.get(k), dict) else {}
        skipped = bool(v.get("skipped")) and k != "step1" and k != "step5"
        stages[k] = {
            "date": "" if skipped else _date(v.get("date")),
            "done": bool(v.get("done")) and not skipped,
            "skipped": skipped,
        }
    item_id = re.sub(r"[^A-Za-z0-9_\-]", "_", _s(raw.get("id")))[:64] or ("TR-" + secrets.token_hex(4))
    attachments = [a for a in (normalize_attachment(x) for x in (raw.get("attachments") or [])) if a]
    return {
        "id": item_id,
        "category": category,
        "npSp": "" if category == "기술" else ("SP" if _s(raw.get("npSp")).upper() == "SP" else "NP"),
        "title": _s(raw.get("title")),
        "requester": _s(raw.get("requester")),
        "requesterDept": _s(raw.get("requesterDept")),
        "requesterEmail": (_emails(raw.get("requesterEmail")) or [""])[0],
        "proposalDate": _date(raw.get("proposalDate")),
        "summary": _text(raw.get("summary")),
        "note": _text(raw.get("note")),
        # 기존 data.js 로 이관된 안건은 이미 접수된 것으로 본다.
        "accepted": bool(raw.get("accepted", True)),
        "source": _s(raw.get("source")) or "관리자",
        "stages": stages,
        "risks": [normalize_risk(r) for r in (raw.get("risks") or [])],
        "attachments": attachments,
        "notify": raw.get("notify") if isinstance(raw.get("notify"), dict) else None,
        "sectorReviews": normalize_sector_reviews(raw.get("sectorReviews")),
        "applicantEmpId": _s(raw.get("applicantEmpId")),
        "createdAt": _s(raw.get("createdAt")) or now_str(),
        "updatedAt": _s(raw.get("updatedAt")) or now_str(),
        "rev": int(raw.get("rev") or 1),
    }


def next_item_id(items: List[Dict[str, Any]], year: str) -> str:
    prefix = f"TR-{year}-"
    nums = []
    for it in items:
        m = re.match(rf"^{re.escape(prefix)}(\d+)$", it.get("id", ""))
        if m:
            nums.append(int(m.group(1)))
    return f"{prefix}{(max(nums) + 1) if nums else 1:03d}"


# ---------------------------------------------------------------------------
# 샘플 데이터 / 기본 설정
# ---------------------------------------------------------------------------
def _st(date="", done=False, skipped=False):
    return {"date": date, "done": done, "skipped": skipped}


def _risk(sector, reviewer, item="", task="X", grade="", plan="", org="", sched="", status="진행중", no_risk=False):
    return {"sector": sector, "reviewer": reviewer, "noRisk": no_risk, "riskItem": item, "isTask": task,
            "grade": grade, "planContent": plan, "org": org, "schedule": sched, "status": status}


def sample_items() -> List[Dict[str, Any]]:
    year = dt.date.today().year
    d = lambda md: f"{year}-{md}"  # noqa: E731
    items = [
        {
            "id": f"TR-{year}-001", "category": "제품", "npSp": "NP", "accepted": True, "source": "신청",
            "title": "차세대 고방열 SiC 전력반도체 모듈 (Gen-4)",
            "requester": "김민수 수석", "requesterDept": "선행패키지개발팀", "requesterEmail": "minsu.kim@example.com",
            "proposalDate": d("01-15"),
            "summary": "Gen-3 대비 방열 기판을 AMB(Si3N4)로 변경하고 소결 접합(Ag Sintering)을 신규 적용.\n열저항 18% 개선, 신뢰성(TC 1,000cyc) 평가 완료.",
            "note": "검증소위원회 완료 후 전문위원 검토 진행 중. 방열 기판 보이드율 3% 이하 관리 기준 점검 필요.",
            "stages": {"step1": _st(d("01-22"), True), "step2": _st(d("02-05"), True), "step3": _st(d("11-20")),
                       "step4": _st(), "step5": _st()},
            "risks": [
                _risk("품질/수율", "박품질 팀장", "진공 리플로우 공정 시 대면적 기판 모서리 보이드(Void) 발생률 상승 우려",
                      "O", "상", "플럭스 도포 패턴 최적화 및 프로파일 2단 감압 구간 신설", "패키지기술1팀", d("09-30")),
                _risk("장비", "최설비 팀장", "신규 오토 마운터 노즐 마모에 따른 칩 픽업 에러 가능성",
                      "O", "중", "고경도 세라믹 코팅 노즐 적용 및 비전 보정 주기 단축", "설비기술팀", d("03-20"), "완료"),
                _risk("생산성", "정생산 팀장", "소결 공정 택트타임 증가(+35초)로 라인 CAPA 부족",
                      "O", "중", "소결 프레스 1대 증설 및 2-Head 지그 적용", "생산기술팀", d("12-15")),
                _risk("Process", "오공정 팀장", no_risk=True, org="공정기술팀", status="완료"),
                _risk("제조", "한제조 팀장", "작업자 소결 지그 취급 표준 미비", "O", "하",
                      "작업표준서(SOP) 개정 및 교육 실시", "제조1팀", d("08-31")),
                _risk("손익", "윤손익 팀장", no_risk=True, status="완료"),
            ],
        },
        {
            "id": f"TR-{year}-002", "category": "제품", "npSp": "SP", "accepted": True, "source": "신청",
            "title": "전장용 통합 카메라 센서 모듈 파생형 (SP-220)",
            "requester": "이수진 책임", "requesterDept": "전장개발2팀", "requesterEmail": "sujin.lee@example.com",
            "proposalDate": d("02-10"),
            "summary": "기존 SP-200 대비 렌즈 화각만 변경(120°→100°). 공정/자재 변경 없음.",
            "note": "6대 부문 팀장 검토 결과 특이사항 없음으로 판정되어 패스트트랙(2~4단계 Skip) 승인 완료.",
            "stages": {"step1": _st(d("02-12"), True), "step2": _st(skipped=True), "step3": _st(skipped=True),
                       "step4": _st(skipped=True), "step5": _st(d("02-15"), True)},
            "risks": [_risk(s, "부문팀장", no_risk=True, status="완료") for s in SECTORS],
        },
        {
            "id": f"TR-{year}-003", "category": "기술", "npSp": "", "accepted": True, "source": "관리자",
            "title": "Cu Clip 본딩 신공정 (와이어 본딩 대체)",
            "requester": "박지훈 책임", "requesterDept": "요소기술개발팀", "requesterEmail": "jihoon.park@example.com",
            "proposalDate": d("04-08"),
            "summary": "Al 와이어 본딩을 Cu Clip 솔더링으로 대체하여 전류 용량 40% 향상.\n전 제품군 확대 적용 전 대표 모델 2종으로 선이관.",
            "note": "검증소위원회에서 보완 과제 3건 확정, 소위 전결로 3·4단계 생략. 최종승인 일정 대기.",
            "stages": {"step1": _st(d("04-15"), True), "step2": _st(d("04-29"), True), "step3": _st(skipped=True),
                       "step4": _st(skipped=True), "step5": _st(d("11-10"))},
            "risks": [
                _risk("품질/수율", "박품질 팀장", "Clip 틀어짐(Tilt)에 의한 솔더 두께 편차 → 열충격 신뢰성 저하",
                      "O", "상", "Clip 정렬 지그 개선 및 AOI 틸트 검사 항목 추가", "패키지기술2팀", d("07-31")),
                _risk("장비", "최설비 팀장", "Clip 어태치 장비 신규 도입 필요 (리드타임 4개월)",
                      "O", "중", "장비 2대 발주 완료, 셋업 및 Buy-off", "설비기술팀", d("10-15"), "완료"),
                _risk("생산성", "정생산 팀장", no_risk=True, status="완료"),
                _risk("Process", "오공정 팀장", "솔더 페이스트 보관/해동 관리 기준 부재",
                      "O", "하", "자재 관리 기준서 신규 제정", "공정기술팀", d("12-20")),
                _risk("제조", "한제조 팀장", no_risk=True, status="완료"),
                _risk("손익", "윤손익 팀장", "Cu Clip 단가 상승으로 원가 +3.2%", "X", plan="물량 확대 시 단가 재협상 (과제화 제외)"),
            ],
        },
        {
            "id": f"TR-{year}-004", "category": "제품", "npSp": "NP", "accepted": False, "source": "신청",
            "title": "고전압 BMS용 절연 게이트 드라이버 IC 패키지",
            "requester": "최유나 선임", "requesterDept": "제품개발3팀", "requesterEmail": "yuna.choi@example.com",
            "proposalDate": today_str(),
            "summary": "SOIC-16W → 신규 절연 패키지(Creepage 8mm) 적용.\n검증보고서 및 패키지 도면은 별도 송부 예정.",
            "note": "", "stages": {k: _st() for k in STAGE_KEYS},
            "risks": default_risk_rows(),
        },
        {
            "id": f"TR-{year - 1}-001", "category": "제품", "npSp": "SP", "accepted": True, "source": "관리자",
            "title": "산업용 IGBT 모듈 62mm 표준형 (2차 파생)",
            "requester": "정해성 수석", "requesterDept": "전력모듈개발팀", "requesterEmail": "haesung.jung@example.com",
            "proposalDate": f"{year - 1}-09-03",
            "summary": "칩 공급처 이원화(Fab B 추가). 패키지 구조 동일.",
            "note": "전 단계 정상 진행 완료. 보완 과제 2건 모두 완료 확인 후 최종승인.",
            "stages": {"step1": _st(f"{year - 1}-09-10", True), "step2": _st(f"{year - 1}-09-24", True),
                       "step3": _st(f"{year - 1}-10-08", True), "step4": _st(f"{year - 1}-10-22", True),
                       "step5": _st(f"{year - 1}-11-05", True)},
            "risks": [
                _risk("품질/수율", "박품질 팀장", "Fab B 칩의 Vce(sat) 산포 확대", "O", "중",
                      "입고 검사 Bin 분류 기준 추가", "품질보증팀", f"{year - 1}-10-30", "완료"),
                _risk("장비", "최설비 팀장", no_risk=True, status="완료"),
                _risk("생산성", "정생산 팀장", no_risk=True, status="완료"),
                _risk("Process", "오공정 팀장", "다이 두께 차이(10㎛)로 솔더 레시피 분리 필요", "O", "하",
                      "Fab별 레시피 분리 및 MES 인터락", "공정기술팀", f"{year - 1}-10-20", "완료"),
                _risk("제조", "한제조 팀장", no_risk=True, status="완료"),
                _risk("손익", "윤손익 팀장", no_risk=True, status="완료"),
            ],
        },
    ]
    return [normalize_item(x) for x in items]


DEFAULT_CRITERIA = {
    "purpose": (
        "양산이관 검증위원회는 개발부서(제품개발팀)가 개발한 제품·기술을 기술부서(양산)로 이관하기 전,\n"
        "품질/수율·장비·생산성·Process·제조·손익 6대 부문의 관점에서 양산 Risk를 사전에 식별하고\n"
        "보완 과제를 도출·추적하여 안정적인 양산 진입을 보장하는 것을 목적으로 한다."
    ),
    "np": (
        "• 신규 칩/패키지/자재가 1개 이상 적용된 제품\n"
        "• 필수 제출: 개발 검증보고서(DV/PV), 신뢰성 평가 결과, 공정 FMEA, 패키지 도면\n"
        "• 6대 부문 전체 검토 필수 (패스트트랙 불가 원칙, 위원장 승인 시 예외)\n"
        "• 수율 목표: 파일럿 3Lot 평균 95% 이상"
    ),
    "sp": (
        "• 기존 양산 제품의 파생형(화각/핀맵/마킹/공급처 변경 등)\n"
        "• 필수 제출: 변경점 비교표(4M 변경 내역), 대표 신뢰성 항목 결과\n"
        "• 6대 부문 팀장 서면검토에서 전 부문 '특이사항 없음' 시 패스트트랙(2~4단계 Skip) 가능"
    ),
    "tech": (
        "• 신규 공정·설비·재료 기술의 양산 적용\n"
        "• 필수 제출: 공정 능력(Cpk ≥ 1.33) 데이터, 장비 Buy-off 결과, 적용 대상 제품 목록\n"
        "• 검증소위원회에서 중대 Risk 미결 시 전문위원 검토 및 검증위원회 상정"
    ),
    "checklist": {
        "품질/수율": "• 파일럿 Lot 수율 및 불량 유형 분석\n• 신뢰성 평가(TC/HTRB/H3TRB) 결과\n• 고객 품질 요구사항 충족 여부",
        "장비": "• 신규/개조 장비 필요 여부 및 리드타임\n• 장비 능력(정밀도, 택트) 검증\n• 예비품 및 유지보수 체계",
        "생산성": "• 택트타임 및 라인 CAPA 영향\n• 병목 공정 및 인원 소요\n• 자동화 수준",
        "Process": "• 공정 조건 윈도우 및 Cpk\n• 공정 FMEA 및 관리계획서\n• 레시피/MES 인터락",
        "제조": "• 작업표준서(SOP) 및 교육\n• 자재 관리(보관/유효기간)\n• 작업 안전 및 환경",
        "손익": "• 원가 변동(재료비/가공비)\n• 투자비 및 회수 기간\n• 판가 및 물량 계획 대비 손익",
    },
}


def default_settings(with_password: bool = False) -> Dict[str, Any]:
    salt = secrets.token_hex(16) if with_password else ""
    return {
        "adminPasswordSalt": salt,
        "adminPasswordHash": hash_password("1234", salt) if with_password else "",
        "secretaryEmails": [],
        "leaderEmails": [],
        "portalUrl": "",
        "mail": {"preferOutlook": True},
        "smtp": {"host": "", "port": 25, "useTls": False, "username": "", "password": "", "sender": ""},
        "reviewers": [
            {"sector": "품질/수율", "level": "sub", "name": "박품질", "title": "팀장", "email": "quality.lead@example.com"},
            {"sector": "장비", "level": "sub", "name": "최설비", "title": "팀장", "email": "equip.lead@example.com"},
            {"sector": "생산성", "level": "sub", "name": "정생산", "title": "팀장", "email": "prod.lead@example.com"},
            {"sector": "Process", "level": "sub", "name": "오공정", "title": "팀장", "email": "process.lead@example.com"},
            {"sector": "제조", "level": "sub", "name": "한제조", "title": "팀장", "email": "mfg.lead@example.com"},
            {"sector": "손익", "level": "sub", "name": "윤손익", "title": "팀장", "email": "pl.lead@example.com"},
            {"sector": "품질/수율", "level": "main", "name": "강품질", "title": "담당", "email": "quality.head@example.com"},
            {"sector": "장비", "level": "main", "name": "조설비", "title": "본부장", "email": "equip.head@example.com"},
        ],
        "criteria": copy.deepcopy(DEFAULT_CRITERIA),
        "teams": copy.deepcopy(DEFAULT_TEAMS),
    }


def normalize_teams(v: Any) -> List[Dict[str, Any]]:
    out, seen = [], set()
    for t in v if isinstance(v, list) else []:
        if not isinstance(t, dict):
            continue
        name = _s(t.get("name"))[:40]
        if not name or name in seen:
            continue
        seen.add(name)
        out.append({"name": name, "sector": t.get("sector") if t.get("sector") in SECTORS else "",
                    "canApply": bool(t.get("canApply"))})
    return out


def normalize_reviewers(v: Any) -> List[Dict[str, str]]:
    out = []
    for r in v if isinstance(v, list) else []:
        if not isinstance(r, dict):
            continue
        email = (_emails(r.get("email")) or [""])[0]
        name = _s(r.get("name"))
        if not email and not name:
            continue
        out.append({
            "sector": r.get("sector") if r.get("sector") in SECTORS else SECTORS[0],
            "level": "main" if r.get("level") == "main" else "sub",
            "name": name, "title": _s(r.get("title")), "email": email,
        })
    return out


# ---------------------------------------------------------------------------
# 저장소 (공유폴더 / 로컬 폴백)
# ---------------------------------------------------------------------------
def _writable_dir(path: Path) -> bool:
    try:
        path.mkdir(parents=True, exist_ok=True)
        probe = path / f".write_test_{os.getpid()}"
        probe.write_text("ok", encoding="utf-8")
        probe.unlink()
        return True
    except OSError:
        return False


def resolve_storage_dir() -> Tuple[Path, bool]:
    env = os.environ.get("PORTAL_DATA_DIR")
    if env and _writable_dir(Path(env)):
        return Path(env), True
    if os.name == "nt" and _writable_dir(Path(NETWORK_DIR)):
        return Path(NETWORK_DIR), True
    LOCAL_DIR.mkdir(parents=True, exist_ok=True)
    return LOCAL_DIR, False


class Store:
    def __init__(self, root: Path, is_network: bool):
        self.root = root
        self.is_network = is_network
        self.data_path = root / "data.json"
        self.settings_path = root / "settings.json"
        self.users_path = root / "users.json"
        self.att_dir = root / "attachments"
        self.forms_dir = root / "forms"
        self.backup_dir = root / "backups"
        self.lock = threading.RLock()
        for d in (self.att_dir, self.forms_dir, self.backup_dir):
            d.mkdir(parents=True, exist_ok=True)
        self._init_files()

    # --- 파일 입출력 -------------------------------------------------------
    @staticmethod
    def _read_json(path: Path) -> Any:
        with open(path, encoding="utf-8-sig") as f:
            return json.load(f)

    @staticmethod
    def _write_json(path: Path, obj: Any) -> None:
        tmp = path.with_name(path.name + ".tmp")
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(obj, f, ensure_ascii=False, indent=2)
        os.replace(tmp, path)

    def _init_files(self) -> None:
        with self.lock:
            if not self.settings_path.exists():
                self._write_json(self.settings_path, default_settings(with_password=True))
            if not self.data_path.exists():
                items = self._migrate_legacy_data_js()
                source = "legacy data.js" if items else "sample"
                if not items:
                    items = sample_items()
                self._write_json(self.data_path, {"version": 1, "updatedAt": now_str(), "items": items})
                print(f"[init] data.json 생성 ({source}, {len(items)}건)")

    def _migrate_legacy_data_js(self) -> List[Dict[str, Any]]:
        """기존 HTML 대시보드가 쓰던 data.js(window.__SHARED_DATA__ = [...];)가 있으면 그대로 이관."""
        legacy = self.root / "data.js"
        if not legacy.exists():
            return []
        try:
            text = legacy.read_text(encoding="utf-8-sig")
            start, end = text.index("["), text.rindex("]")
            raw = json.loads(text[start:end + 1])
            return [normalize_item(x) for x in raw if isinstance(x, dict)]
        except (ValueError, OSError) as e:
            print(f"[init] data.js 이관 실패: {e}")
            return []

    def _daily_backup(self) -> None:
        if not self.data_path.exists():
            return
        target = self.backup_dir / f"data_{dt.date.today():%Y%m%d}.json"
        if not target.exists():
            shutil.copy2(self.data_path, target)
            for old in sorted(self.backup_dir.glob("data_*.json"))[:-BACKUP_KEEP_DAYS]:
                old.unlink()

    # --- 안건 데이터 -------------------------------------------------------
    def load(self) -> Dict[str, Any]:
        with self.lock:
            raw = self._read_json(self.data_path)
            if isinstance(raw, list):  # 구버전 형식
                raw = {"version": 1, "items": raw}
            raw["items"] = [normalize_item(x) for x in raw.get("items", [])]
            raw["version"] = int(raw.get("version") or 1)
            return raw

    def mutate(self, fn: Callable[[Dict[str, Any]], Any]) -> Any:
        """data.json 을 읽고 fn(data) 로 수정한 뒤 원자적으로 저장."""
        with self.lock:
            data = self.load()
            result = fn(data)
            self._daily_backup()
            data["version"] += 1
            data["updatedAt"] = now_str()
            self._write_json(self.data_path, data)
            return result

    # --- 설정 --------------------------------------------------------------
    def settings(self) -> Dict[str, Any]:
        with self.lock:
            base = default_settings()
            cur = self._read_json(self.settings_path)
            for k, v in cur.items():
                if isinstance(v, dict) and isinstance(base.get(k), dict):
                    base[k].update(v)
                else:
                    base[k] = v
            for sector in SECTORS:
                base["criteria"].setdefault("checklist", {}).setdefault(sector, "")
            base["teams"] = normalize_teams(base.get("teams")) or copy.deepcopy(DEFAULT_TEAMS)
            return base

    def save_settings(self, s: Dict[str, Any]) -> None:
        with self.lock:
            self._write_json(self.settings_path, s)

    # --- 회원 (users.json: {사번: 사용자}) ----------------------------------
    def users(self) -> Dict[str, Dict[str, Any]]:
        with self.lock:
            if not self.users_path.exists():
                return {}
            data = self._read_json(self.users_path)
            return data if isinstance(data, dict) else {}

    def mutate_users(self, fn: Callable[[Dict[str, Dict[str, Any]]], Any]) -> Any:
        with self.lock:
            users = self.users()
            result = fn(users)
            self._write_json(self.users_path, users)
            return result

    def item_dir(self, item_id: str) -> Path:
        if not ID_RE.match(item_id):
            raise HTTPException(400, "잘못된 안건 ID 입니다.")
        return self.att_dir / item_id


STORAGE_DIR, STORAGE_IS_NETWORK = resolve_storage_dir()
store = Store(STORAGE_DIR, STORAGE_IS_NETWORK)


# ---------------------------------------------------------------------------
# 관리자 인증 (세션 토큰은 서버 메모리에만 보관)
# ---------------------------------------------------------------------------
TOKENS: Dict[str, float] = {}
LOGIN_FAILS: Dict[str, List[float]] = {}


def require_admin(x_admin_token: str) -> str:
    exp = TOKENS.get(x_admin_token)
    if not x_admin_token or not exp or exp < time.time():
        TOKENS.pop(x_admin_token, None)
        raise HTTPException(401, "관리자 인증이 필요합니다.")
    TOKENS[x_admin_token] = time.time() + TOKEN_TTL_SEC
    return x_admin_token


USER_TOKENS: Dict[str, Tuple[str, float]] = {}   # 토큰 → (사번, 만료시각)
PRESENCE: Dict[str, Dict[str, Any]] = {}         # 브라우저 ID → {seen, empId, admin}
PRESENCE_LOCK = threading.Lock()


def team_info(settings: Dict[str, Any], team: str) -> Dict[str, Any]:
    for t in settings["teams"]:
        if t["name"] == team:
            return t
    return {"name": team, "sector": "", "canApply": False}


def public_user(u: Dict[str, Any], settings: Dict[str, Any]) -> Dict[str, Any]:
    t = team_info(settings, u.get("team", ""))
    return {
        "empId": u["empId"], "name": u.get("name", ""), "title": u.get("title", ""), "team": u.get("team", ""),
        "email": u.get("email", ""), "status": u.get("status", "pending"), "createdAt": u.get("createdAt", ""),
        "approvedAt": u.get("approvedAt", ""), "sector": t["sector"], "canApply": t["canApply"],
    }


def current_user(user_token: str) -> Optional[Dict[str, Any]]:
    """승인된 회원이면 공개 정보(팀·부문·신청권한 포함), 아니면 None."""
    entry = USER_TOKENS.get(user_token) if user_token else None
    if not entry or entry[1] < time.time():
        USER_TOKENS.pop(user_token, None)
        return None
    u = store.users().get(entry[0])
    if not u or u.get("status") != "approved":
        USER_TOKENS.pop(user_token, None)
        return None
    USER_TOKENS[user_token] = (entry[0], time.time() + USER_TOKEN_TTL_SEC)
    return public_user(u, store.settings())


def is_admin_token(token: str) -> bool:
    exp = TOKENS.get(token) if token else None
    return bool(exp and exp > time.time())


def find_item(data: Dict[str, Any], item_id: str) -> Dict[str, Any]:
    for it in data["items"]:
        if it["id"] == item_id:
            return it
    raise HTTPException(404, "안건을 찾을 수 없습니다.")


def stage_label(item: Dict[str, Any]) -> str:
    if not item.get("accepted", True):
        return "접수대기"
    st = item["stages"]
    if st["step5"]["done"]:
        return "최종승인 완료"
    for i, k in enumerate(STAGE_KEYS):
        if not (st[k]["done"] or st[k]["skipped"]):
            return f"{i + 1}. {STAGE_NAMES[i]}"
    return f"5. {STAGE_NAMES[4]}"


def category_label(item: Dict[str, Any]) -> str:
    return f"제품({item['npSp']})" if item["category"] == "제품" else "기술"


def portal_base(settings: Dict[str, Any]) -> str:
    url = _s(settings.get("portalUrl"))
    return (url.rstrip("/") + "/") if url else f"http://{lan_ip()}:{PORT}/"


# ---------------------------------------------------------------------------
# 메일 (Outlook 1순위 → SMTP 2순위)
# ---------------------------------------------------------------------------
# pywin32 가 없으면 Windows 기본 PowerShell 로 Outlook COM 을 호출한다.
PS_OUTLOOK = (
    "$ErrorActionPreference='Stop'; "
    "$p = Get-Content -Raw -Encoding UTF8 -LiteralPath $env:PORTAL_MAIL_JSON | ConvertFrom-Json; "
    "$o = New-Object -ComObject Outlook.Application; "
    "$m = $o.CreateItem(0); "
    "$m.To = $p.to; $m.CC = $p.cc; $m.Subject = $p.subject; $m.HTMLBody = $p.html; "
    "if ($p.display) { $m.Display($false) } else { $m.Send() }"
)


def outlook_mail(to: List[str], cc: List[str], subject: str, html_body: str, display: bool) -> None:
    if os.name != "nt":
        raise RuntimeError("Outlook 연동은 Windows 서버 PC에서만 가능합니다.")
    try:
        import pythoncom  # pywin32 (선택 설치)
        import win32com.client
    except ImportError:
        _outlook_powershell(to, cc, subject, html_body, display)
        return

    pythoncom.CoInitialize()
    try:
        outlook = win32com.client.Dispatch("Outlook.Application")
        mail = outlook.CreateItem(0)
        mail.To = "; ".join(to)
        mail.CC = "; ".join(cc)
        mail.Subject = subject
        mail.HTMLBody = html_body
        if display:
            mail.Display(False)
        else:
            mail.Send()
    finally:
        pythoncom.CoUninitialize()


def _outlook_powershell(to: List[str], cc: List[str], subject: str, html_body: str, display: bool) -> None:
    fd, path = tempfile.mkstemp(suffix=".json", prefix="portal_mail_")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"to": "; ".join(to), "cc": "; ".join(cc), "subject": subject, "html": html_body,
                       "display": display}, f, ensure_ascii=False)
        result = subprocess.run(
            ["powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command", PS_OUTLOOK],
            env=dict(os.environ, PORTAL_MAIL_JSON=path), capture_output=True, timeout=90,
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
        if result.returncode != 0:
            err = result.stderr.decode("cp949", "replace").strip().splitlines()
            raise RuntimeError("Outlook(PowerShell) 실패: " + (err[0] if err else f"코드 {result.returncode}"))
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass


def smtp_mail(settings: Dict[str, Any], to: List[str], cc: List[str], subject: str, html_body: str, text_body: str) -> None:
    cfg = settings.get("smtp") or {}
    host = _s(cfg.get("host"))
    if not host:
        raise RuntimeError("SMTP 서버가 설정되지 않았습니다.")
    sender = _s(cfg.get("sender")) or _s(cfg.get("username")) or (settings.get("secretaryEmails") or [""])[0]
    if not sender:
        raise RuntimeError("SMTP 발신자 주소가 설정되지 않았습니다.")
    msg = EmailMessage()
    msg["From"] = sender
    msg["To"] = ", ".join(to)
    if cc:
        msg["Cc"] = ", ".join(cc)
    msg["Subject"] = subject
    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")
    with smtplib.SMTP(host, int(cfg.get("port") or 25), timeout=15) as server:
        if cfg.get("useTls"):
            server.starttls()
        if _s(cfg.get("username")) and cfg.get("password"):
            server.login(_s(cfg.get("username")), str(cfg.get("password")))
        server.send_message(msg)


def send_mail(settings: Dict[str, Any], to: List[str], cc: List[str], subject: str, html_body: str, text_body: str) -> str:
    errors = []
    if (settings.get("mail") or {}).get("preferOutlook", True):
        try:
            outlook_mail(to, cc, subject, html_body, display=False)
            return "Outlook"
        except Exception as e:  # noqa: BLE001 - Outlook 미설치/보안정책 등 모든 실패를 SMTP 로 넘긴다
            errors.append(f"Outlook: {e}")
    try:
        smtp_mail(settings, to, cc, subject, html_body, text_body)
        return "SMTP"
    except Exception as e:  # noqa: BLE001
        errors.append(f"SMTP: {e}")
    raise RuntimeError(" / ".join(errors))


def _mail_table(rows: List[tuple]) -> str:
    tds = "".join(
        f'<tr><th style="background:#f1f5f9;border:1px solid #cbd5e1;padding:7px 10px;text-align:left;width:130px;'
        f'font-size:13px;">{html.escape(k)}</th><td style="border:1px solid #cbd5e1;padding:7px 10px;font-size:13px;">{v}</td></tr>'
        for k, v in rows
    )
    return f'<table style="border-collapse:collapse;width:100%;max-width:760px;margin:8px 0 16px;">{tds}</table>'


def _mail_wrap(title: str, inner: str) -> str:
    return (
        '<div style="font-family:\'Malgun Gothic\',\'맑은 고딕\',sans-serif;color:#0f172a;font-size:13.5px;line-height:1.6;">'
        f'<div style="background:#1e3a8a;color:#fff;padding:12px 16px;font-weight:bold;font-size:15px;max-width:760px;">{html.escape(title)}</div>'
        f'<div style="padding:14px 4px;max-width:760px;">{inner}</div></div>'
    )


def _br(text: str) -> str:
    return html.escape(text or "-").replace("\n", "<br>")


def attachment_links(item: Dict[str, Any], base: str) -> str:
    if not item["attachments"]:
        return "없음"
    return "<br>".join(
        f'<a href="{html.escape(base)}api/items/{quote(item["id"])}/attachments/{quote(a["name"])}">{html.escape(a["name"])}</a>'
        for a in item["attachments"]
    )


def build_new_item_mail(item: Dict[str, Any], settings: Dict[str, Any]) -> Dict[str, Any]:
    base = portal_base(settings)
    link = f"{base}#items/{quote(item['id'])}"
    subject = f"[양산이관 검증위원회] 신규 안건이 등록되었습니다. 확인해주세요. ({item['title']})"
    requester = item["requester"] + (f" ({item['requesterDept']})" if item["requesterDept"] else "")
    rows = [
        ("안건 ID", html.escape(item["id"])),
        ("구분", html.escape(category_label(item))),
        ("제품/기술명", f"<b>{html.escape(item['title'])}</b>"),
        ("요청자", html.escape(requester) + (f" &lt;{html.escape(item['requesterEmail'])}&gt;" if item["requesterEmail"] else "")),
        ("발제일", html.escape(item["proposalDate"])),
        ("주요 내용 / 변경점", _br(item["summary"])),
        ("첨부파일", attachment_links(item, base)),
    ]
    inner = (
        "<p><b>신규 안건이 등록되었습니다. 확인해주세요.</b></p>"
        + _mail_table(rows)
        + f'<p>▶ 시스템 접속: <a href="{html.escape(link)}">{html.escape(link)}</a></p>'
        + '<p style="color:#64748b;font-size:12px;">본 메일은 양산이관 검증위원회 포털에서 자동 발송되었습니다.</p>'
    )
    text = (
        "신규 안건이 등록되었습니다. 확인해주세요.\n\n"
        f"구분: {category_label(item)}\n제품/기술명: {item['title']}\n요청자: {requester}\n발제일: {item['proposalDate']}\n"
        f"주요 내용:\n{item['summary'] or '-'}\n첨부파일: {', '.join(a['name'] for a in item['attachments']) or '없음'}\n\n"
        f"시스템 접속: {link}\n"
    )
    to = _emails(settings.get("secretaryEmails")) + _emails(settings.get("leaderEmails"))
    return {"to": _emails(to), "cc": [], "subject": subject, "html": _mail_wrap("양산이관 검증위원회 신규 안건 알림", inner), "text": text}


def build_review_mail(item: Dict[str, Any], settings: Dict[str, Any], level: str, to: List[str], cc: List[str],
                      summary: str) -> Dict[str, Any]:
    level = "main" if level == "main" else "sub"
    base = portal_base(settings)
    link = f"{base}#items/{quote(item['id'])}"
    subject = f"[양산이관 검토요청] {category_label(item)} {item['title']} - {LEVEL_NAMES[level]} 검토의 건"
    requester = item["requester"] + (f" ({item['requesterDept']})" if item["requesterDept"] else "")

    book = {r["email"].lower(): r for r in normalize_reviewers(settings.get("reviewers"))}
    target_rows = ""
    for email in to:
        r = book.get(email.lower(), {"sector": "-", "name": "", "title": ""})
        target_rows += (
            f'<tr><td style="border:1px solid #cbd5e1;padding:6px 10px;font-size:13px;">{html.escape(r["sector"])}</td>'
            f'<td style="border:1px solid #cbd5e1;padding:6px 10px;font-size:13px;">{html.escape((r["name"] + " " + r["title"]).strip() or email)}</td>'
            f'<td style="border:1px solid #cbd5e1;padding:6px 10px;font-size:13px;">해당 부문 관점의 양산이관 시 예상 Risk 항목, 과제화 여부(O/X)·등급(상/중/하), 보완 방안 회신</td></tr>'
        )
    th = 'style="background:#f1f5f9;border:1px solid #cbd5e1;padding:6px 10px;font-size:13px;text-align:left;"'
    target_table = (
        '<table style="border-collapse:collapse;width:100%;max-width:760px;margin:8px 0 16px;">'
        f'<tr><th {th}>부문</th><th {th}>검토자</th><th {th}>검토 요청 사항</th></tr>{target_rows}</table>'
    )
    info = _mail_table([
        ("안건 ID", html.escape(item["id"])),
        ("구분", html.escape(category_label(item))),
        ("제품/기술명", f"<b>{html.escape(item['title'])}</b>"),
        ("요청자", html.escape(requester)),
        ("발제일", html.escape(item["proposalDate"])),
        ("현재 진행 단계", html.escape(stage_label(item))),
        ("첨부파일", attachment_links(item, base)),
    ])
    inner = (
        f"<p>안녕하십니까.<br>양산이관 검증위원회 간사입니다.<br>아래 안건에 대한 <b>{html.escape(LEVEL_DESC[level])}</b> 검토를 요청드립니다.</p>"
        '<p style="font-weight:bold;margin-top:14px;">■ 양산이관 요약</p>'
        f'<div style="border-left:4px solid #2563eb;background:#eff6ff;padding:10px 12px;max-width:740px;">{_br(summary or item["summary"])}</div>'
        '<p style="font-weight:bold;margin-top:14px;">■ 안건 기본 정보</p>' + info
        + '<p style="font-weight:bold;">■ 6대 부문별 검토 요청</p>' + target_table
        + f'<p>▶ 대시보드 접속(안건 상세): <a href="{html.escape(link)}">{html.escape(link)}</a></p>'
        + "<p>바쁘시겠지만 검토 후 회신 부탁드립니다.<br>감사합니다.</p>"
    )
    text = (
        f"아래 안건에 대한 {LEVEL_DESC[level]} 검토를 요청드립니다.\n\n"
        f"[양산이관 요약]\n{summary or item['summary'] or '-'}\n\n"
        f"구분: {category_label(item)}\n제품/기술명: {item['title']}\n요청자: {requester}\n발제일: {item['proposalDate']}\n"
        f"현재 단계: {stage_label(item)}\n\n대시보드 접속: {link}\n"
    )
    return {"to": to, "cc": cc, "subject": subject,
            "html": _mail_wrap(f"양산이관 {LEVEL_NAMES[level]} 검토 요청", inner), "text": text}


def build_sector_done_mail(item: Dict[str, Any], sector: str, user: Dict[str, Any], settings: Dict[str, Any]) -> Dict[str, Any]:
    base = portal_base(settings)
    link = f"{base}#items/{quote(item['id'])}"
    who = f"{user['team']} {user['name']} {user.get('title', '')}".strip()
    subject = f"[양산이관 검토완료] {sector} 부문 - {item['title']} ({who})"
    rows = [r for r in item["risks"] if r["sector"] == sector]
    th = 'style="background:#f1f5f9;border:1px solid #cbd5e1;padding:6px 8px;font-size:12.5px;text-align:left;"'
    td = 'style="border:1px solid #cbd5e1;padding:6px 8px;font-size:12.5px;vertical-align:top;"'
    body_rows = "".join(
        f"<tr><td {td}>{'특이사항 없음' if r['noRisk'] else '특이사항 있음'}</td><td {td}>{_br(r['riskItem'])}</td>"
        f"<td {td}>{html.escape(r['isTask'])}</td><td {td}>{html.escape(r['grade'] or '-')}</td>"
        f"<td {td}>{_br(r['planContent'])}</td><td {td}>{html.escape(r['org'] or '-')}</td>"
        f"<td {td}>{html.escape(r['schedule'] or '-')}</td></tr>"
        for r in rows
    ) or f'<tr><td {td} colspan="7">작성된 행이 없습니다.</td></tr>'
    table = (
        '<table style="border-collapse:collapse;width:100%;max-width:900px;margin:8px 0 16px;">'
        f"<tr><th {th}>특이사항</th><th {th}>예상 Risk 항목</th><th {th}>과제화</th><th {th}>등급</th>"
        f"<th {th}>보완 방안</th><th {th}>담당조직</th><th {th}>목표 일정</th></tr>{body_rows}</table>"
    )
    inner = (
        f"<p><b>{html.escape(who)}</b> 님이 <b>{html.escape(sector)}</b> 부문 검토를 작성 완료했습니다.</p>"
        + _mail_table([("안건 ID", html.escape(item["id"])), ("구분", html.escape(category_label(item))),
                       ("제품/기술명", f"<b>{html.escape(item['title'])}</b>"), ("현재 단계", html.escape(stage_label(item)))])
        + f'<p style="font-weight:bold;">■ {html.escape(sector)} 부문 검토 내용</p>' + table
        + f'<p>▶ 안건 상세 보기: <a href="{html.escape(link)}">{html.escape(link)}</a></p>'
    )
    text = f"{who} 님이 {sector} 부문 검토를 작성 완료했습니다.\n안건: {item['title']} ({item['id']})\n{link}\n"
    return {"to": _emails(settings.get("secretaryEmails")), "subject": subject,
            "html": _mail_wrap("양산이관 부문 검토 작성 완료", inner), "text": text}


def mail_to_secretary(subject: str, html_body: str, text: str, settings: Dict[str, Any]) -> Dict[str, str]:
    to = _emails(settings.get("secretaryEmails"))
    if not to:
        return {"status": "skipped", "message": "관리자 설정에 간사 이메일이 없습니다."}
    try:
        method = send_mail(settings, to, [], subject, html_body, text)
        return {"status": "sent", "message": f"{method}로 간사에게 발송"}
    except Exception as e:  # noqa: BLE001
        return {"status": "failed", "message": str(e)[:300]}


def notify_sector_done(item_id: str, sector: str, user: Dict[str, Any]) -> None:
    settings = store.settings()
    try:
        mail = build_sector_done_mail(find_item(store.load(), item_id), sector, user, settings)
        result = mail_to_secretary(mail["subject"], mail["html"], mail["text"], settings)
    except Exception as e:  # noqa: BLE001
        result = {"status": "failed", "message": str(e)[:300]}
    print(f"[mail] {item_id} {sector} 작성 완료 알림: {result['status']} - {result['message']}")


def notify_signup(user: Dict[str, Any]) -> None:
    settings = store.settings()
    link = portal_base(settings) + "#admin"
    who = f"{user['team']} {user['name']} {user.get('title', '')}".strip()
    inner = (f"<p><b>{html.escape(who)}</b> (사번 {html.escape(user['empId'])}) 님이 포털 가입을 신청했습니다.</p>"
             f'<p>▶ 관리자 모드에서 승인: <a href="{html.escape(link)}">{html.escape(link)}</a></p>')
    result = mail_to_secretary(f"[양산이관 검증위원회] 가입 승인 요청 ({who})", _mail_wrap("포털 가입 승인 요청", inner),
                               f"{who} (사번 {user['empId']}) 님이 가입을 신청했습니다.\n{link}\n", settings)
    print(f"[mail] 가입 신청 알림 {user['empId']}: {result['status']} - {result['message']}")


def notify_new_item(item_id: str) -> None:
    """신규 신청 알림 메일 (백그라운드). 실패해도 안건 등록에는 영향이 없다."""
    settings = store.settings()
    try:
        item = find_item(store.load(), item_id)
        mail = build_new_item_mail(item, settings)
        if not mail["to"]:
            result = {"status": "skipped", "message": "관리자 설정에 알림 수신자가 없습니다."}
        else:
            method = send_mail(settings, mail["to"], [], mail["subject"], mail["html"], mail["text"])
            result = {"status": "sent", "message": f"{method}로 {len(mail['to'])}명에게 발송"}
    except Exception as e:  # noqa: BLE001
        result = {"status": "failed", "message": str(e)[:300]}
    result["at"] = now_str()
    print(f"[mail] 신규 안건 알림 {item_id}: {result['status']} - {result['message']}")

    def _apply(data):
        for it in data["items"]:
            if it["id"] == item_id:
                it["notify"] = result
    store.mutate(_apply)


def is_local_request(host: str) -> bool:
    if host in ("127.0.0.1", "::1", "localhost"):
        return True
    try:
        return host in socket.gethostbyname_ex(socket.gethostname())[2] or host == lan_ip()
    except OSError:
        return False


# ---------------------------------------------------------------------------
# HTTP 요청 / 응답 (표준 라이브러리 http.server 기반)
# ---------------------------------------------------------------------------
class Req:
    def __init__(self, method: str, path: str, query: str, headers: Any, body: bytes, client_host: str):
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
        self.client_host = client_host
        self.params: Dict[str, str] = {}
        self._form: Optional[Tuple[Dict[str, str], List[Tuple[str, str, bytes]]]] = None

    @property
    def token(self) -> str:
        return self.headers.get("X-Admin-Token", "") or ""

    @property
    def user_token(self) -> str:
        return self.headers.get("X-User-Token", "") or ""

    @property
    def is_admin(self) -> bool:
        return is_admin_token(self.token)

    def user(self) -> Optional[Dict[str, Any]]:
        return current_user(self.user_token)

    def json(self) -> Dict[str, Any]:
        try:
            data = json.loads(self.body.decode("utf-8") or "{}")
        except (ValueError, UnicodeDecodeError):
            raise HTTPException(400, "요청 형식(JSON)이 올바르지 않습니다.")
        if not isinstance(data, dict):
            raise HTTPException(400, "요청 형식(JSON)이 올바르지 않습니다.")
        return data

    def form(self) -> Tuple[Dict[str, str], List[Tuple[str, str, bytes]]]:
        if self._form is None:
            self._form = parse_multipart(self.headers.get("Content-Type", ""), self.body)
        return self._form


class Resp:
    def __init__(self, body: bytes, content_type: str, status: int = 200, headers: Optional[Dict[str, str]] = None):
        self.body = body
        self.content_type = content_type
        self.status = status
        self.headers = headers or {}


class FileResp:
    def __init__(self, path: Path, filename: Optional[str] = None, attachment: bool = True):
        self.path = path
        self.filename = filename or path.name
        self.attachment = attachment


def parse_multipart(content_type: str, body: bytes) -> Tuple[Dict[str, str], List[Tuple[str, str, bytes]]]:
    """multipart/form-data → (일반 필드, [(필드명, 파일명, 내용)]). 한글 파일명(UTF-8)을 그대로 지원."""
    m = re.search(r'boundary="?([^";]+)"?', content_type)
    if not m:
        raise HTTPException(400, "multipart 형식이 아닙니다.")
    boundary = b"--" + m.group(1).encode("latin-1")
    fields: Dict[str, str] = {}
    files: List[Tuple[str, str, bytes]] = []
    for part in body.split(boundary)[1:]:
        if part.startswith(b"--"):
            break
        if part.startswith(b"\r\n"):
            part = part[2:]
        raw_head, _, data = part.partition(b"\r\n\r\n")
        if data.endswith(b"\r\n"):
            data = data[:-2]
        head = raw_head.decode("utf-8", "replace")
        disp = re.search(r"(?im)^content-disposition:(.*)$", head)
        if not disp:
            continue
        name_m = re.search(r'\bname="([^"]*)"', disp.group(1))
        file_m = re.search(r'\bfilename="([^"]*)"', disp.group(1))
        name = name_m.group(1) if name_m else ""
        if file_m:
            if file_m.group(1):
                files.append((name, file_m.group(1), data))
        else:
            fields[name] = data.decode("utf-8", "replace")
    return fields, files


def json_resp(obj: Any, status: int = 200) -> Resp:
    return Resp(json.dumps(obj, ensure_ascii=False).encode("utf-8"), "application/json; charset=utf-8", status)


def content_disposition(filename: str, attachment: bool = True) -> str:
    kind = "attachment" if attachment else "inline"
    ascii_name = re.sub(r"[^A-Za-z0-9._-]", "_", filename) or "download"
    return f"{kind}; filename=\"{ascii_name}\"; filename*=UTF-8''{quote(filename)}"


# ---------------------------------------------------------------------------
# API 핸들러
# ---------------------------------------------------------------------------
def public_settings(s: Dict[str, Any]) -> Dict[str, Any]:
    return {"criteria": s["criteria"], "sectors": SECTORS, "teams": s["teams"]}


def h_bootstrap(req: Req):
    data = store.load()
    return {
        "items": data["items"], "version": data["version"], "settings": public_settings(store.settings()),
        "storage": {"path": str(store.root), "isNetwork": store.is_network}, "today": today_str(),
    }


def h_version(req: Req):
    return {"version": store.load()["version"]}


# --- 관리자 인증 ------------------------------------------------------------
def h_login(req: Req):
    payload = req.json()
    ip = req.client_host
    recent = [t for t in LOGIN_FAILS.get(ip, []) if t > time.time() - 60]
    if len(recent) >= 5:
        raise HTTPException(429, "비밀번호를 여러 번 틀렸습니다. 1분 후 다시 시도하세요.")
    s = store.settings()
    if not secrets.compare_digest(hash_password(_s(payload.get("password")), s["adminPasswordSalt"]), s["adminPasswordHash"]):
        LOGIN_FAILS[ip] = recent + [time.time()]
        raise HTTPException(403, "비밀번호가 일치하지 않습니다.")
    LOGIN_FAILS.pop(ip, None)
    token = secrets.token_urlsafe(24)
    TOKENS[token] = time.time() + TOKEN_TTL_SEC
    return {"token": token}


def h_logout(req: Req):
    TOKENS.pop(req.token, None)
    return {"ok": True}


def h_change_password(req: Req):
    payload = req.json()
    s = store.settings()
    if not secrets.compare_digest(hash_password(_s(payload.get("current")), s["adminPasswordSalt"]), s["adminPasswordHash"]):
        raise HTTPException(403, "현재 비밀번호가 일치하지 않습니다.")
    new = _s(payload.get("new"))
    if len(new) < 4:
        raise HTTPException(400, "새 비밀번호는 4자 이상이어야 합니다.")
    s["adminPasswordSalt"] = secrets.token_hex(16)
    s["adminPasswordHash"] = hash_password(new, s["adminPasswordSalt"])
    store.save_settings(s)
    return {"ok": True}


# --- 설정 ------------------------------------------------------------------
def h_get_settings(req: Optional[Req] = None):
    s = store.settings()
    smtp = dict(s["smtp"])
    smtp["hasPassword"] = bool(smtp.pop("password", ""))
    return {
        "secretaryEmails": s["secretaryEmails"], "leaderEmails": s["leaderEmails"], "portalUrl": s["portalUrl"],
        "mail": s["mail"], "smtp": smtp, "reviewers": normalize_reviewers(s["reviewers"]), "criteria": s["criteria"],
        "suggestedPortalUrl": f"http://{lan_ip()}:{PORT}/",
    }


def h_put_settings(req: Req):
    payload = req.json()
    s = store.settings()
    if "secretaryEmails" in payload:
        s["secretaryEmails"] = _emails(payload["secretaryEmails"])
    if "leaderEmails" in payload:
        s["leaderEmails"] = _emails(payload["leaderEmails"])
    if "portalUrl" in payload:
        s["portalUrl"] = _s(payload["portalUrl"])
    if isinstance(payload.get("mail"), dict):
        s["mail"]["preferOutlook"] = bool(payload["mail"].get("preferOutlook", True))
    if isinstance(payload.get("smtp"), dict):
        p = payload["smtp"]
        try:
            port = int(p.get("port") or 25)
        except ValueError:
            raise HTTPException(400, "SMTP 포트는 숫자여야 합니다.")
        s["smtp"].update({
            "host": _s(p.get("host")), "port": port, "useTls": bool(p.get("useTls")),
            "username": _s(p.get("username")), "sender": _s(p.get("sender")),
        })
        if p.get("clearPassword"):
            s["smtp"]["password"] = ""
        elif p.get("password"):
            s["smtp"]["password"] = str(p["password"])
    if "reviewers" in payload:
        s["reviewers"] = normalize_reviewers(payload["reviewers"])
    if isinstance(payload.get("criteria"), dict):
        c = payload["criteria"]
        for k in ("purpose", "np", "sp", "tech"):
            if k in c:
                s["criteria"][k] = _text(c[k])
        if isinstance(c.get("checklist"), dict):
            for sector in SECTORS:
                if sector in c["checklist"]:
                    s["criteria"]["checklist"][sector] = _text(c["checklist"][sector])
    store.save_settings(s)
    return h_get_settings()


def h_mail_test(req: Req):
    payload = req.json()
    s = store.settings()
    to = _emails(payload.get("to")) or _emails(s["secretaryEmails"])
    if not to:
        raise HTTPException(400, "테스트 메일을 받을 주소를 입력하세요.")
    subject = "[양산이관 검증위원회] 메일 발송 테스트"
    body = _mail_wrap("메일 발송 테스트", f"<p>포털 메일 발송 테스트입니다. ({now_str()})</p>")
    try:
        if payload.get("method") == "smtp":
            smtp_mail(s, to, [], subject, body, "포털 메일 발송 테스트입니다.")
            return {"ok": True, "message": f"SMTP로 {', '.join(to)} 에 발송했습니다."}
        outlook_mail(to, [], subject, body, display=False)
        return {"ok": True, "message": f"Outlook으로 {', '.join(to)} 에 발송했습니다."}
    except Exception as e:  # noqa: BLE001
        raise HTTPException(500, f"발송 실패: {e}")


# --- 안건 ------------------------------------------------------------------
def save_uploads(folder: Path, files: List[Tuple[str, str, bytes]], by: str) -> List[Dict[str, Any]]:
    for _, filename, data in files:
        if len(data) > MAX_UPLOAD_BYTES:
            raise HTTPException(413, f"'{filename}' 파일이 100MB를 초과합니다.")
    saved = []
    folder.mkdir(parents=True, exist_ok=True)
    for _, filename, data in files:
        target = unique_path(folder, safe_filename(filename))
        target.write_bytes(data)
        saved.append({"name": target.name, "size": len(data), "uploadedAt": now_str(), "by": by})
    return saved


def h_apply(req: Req):
    """메뉴 4: 신규 신청 - 신청 권한 팀(개발팀) 회원 또는 관리자만."""
    user = req.user()
    if not req.is_admin and not (user and user["canApply"]):
        raise HTTPException(403, "양산이관 신청은 개발팀(결정성장/EPI/Wafering/제품개발팀) 회원으로 로그인해야 합니다.")
    f, files = req.form()
    title, requester, dept = _s(f.get("title")), _s(f.get("requester")), _s(f.get("requesterDept"))
    email = _s(f.get("requesterEmail"))
    if not title or not requester or not dept:
        raise HTTPException(400, "제품/기술명, 요청자, 소속 부서는 필수입니다.")
    if email and not _emails(email):
        raise HTTPException(400, "요청자 이메일 형식이 올바르지 않습니다.")
    for _, filename, data in files:
        if len(data) > MAX_UPLOAD_BYTES:
            raise HTTPException(413, f"'{filename}' 파일이 100MB를 초과합니다.")
    p_date = _date(f.get("proposalDate")) or today_str()

    def _create(data):
        item = normalize_item({
            "id": next_item_id(data["items"], p_date[:4]), "category": f.get("category", "제품"), "npSp": f.get("npSp", "NP"),
            "title": title[:200], "requester": requester[:100], "requesterDept": dept[:100],
            "requesterEmail": email, "proposalDate": p_date, "summary": (f.get("summary") or "")[:5000],
            "accepted": False, "source": "신청", "stages": {}, "risks": default_risk_rows(),
            "applicantEmpId": user["empId"] if user else "",
            "notify": {"status": "pending", "message": "알림 메일 발송 대기", "at": now_str()},
        })
        data["items"].insert(0, item)
        return item

    item = store.mutate(_create)
    if files:
        saved = save_uploads(store.item_dir(item["id"]), files, requester)

        def _attach(data):
            it = find_item(data, item["id"])
            it["attachments"] = saved
            return it
        item = store.mutate(_attach)
    threading.Thread(target=notify_new_item, args=(item["id"],), daemon=True).start()
    return item


def h_update_item(req: Req):
    item_id = req.params["id"]
    payload = req.json()
    incoming = payload.get("item") or {}

    def _update(data):
        cur = find_item(data, item_id)
        if not payload.get("force") and int(payload.get("rev") or 0) != cur["rev"]:
            raise HTTPException(409, {"message": "다른 사용자가 먼저 이 안건을 수정했습니다.", "item": cur})
        merged = normalize_item({**incoming, "id": item_id})
        for keep in ("attachments", "notify", "createdAt", "source", "sectorReviews", "applicantEmpId"):
            merged[keep] = cur[keep]
        merged["rev"] = cur["rev"] + 1
        merged["updatedAt"] = now_str()
        data["items"][data["items"].index(cur)] = merged
        return merged
    return store.mutate(_update)


def h_delete_item(req: Req):
    item_id = req.params["id"]

    def _delete(data):
        data["items"].remove(find_item(data, item_id))
    store.mutate(_delete)
    folder = store.item_dir(item_id)
    if folder.exists():  # 첨부는 지우지 않고 백업 폴더로 이동
        dest = store.backup_dir / "deleted_attachments" / f"{item_id}_{dt.datetime.now():%Y%m%d%H%M%S}"
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(folder), str(dest))
    return {"ok": True}


def h_accept_item(req: Req):
    def _accept(data):
        cur = find_item(data, req.params["id"])
        cur["accepted"] = True
        cur["rev"] += 1
        cur["updatedAt"] = now_str()
        return cur
    return store.mutate(_accept)


def h_toggle_risk(req: Req):
    idx = int(req.params["idx"])

    def _toggle(data):
        cur = find_item(data, req.params["id"])
        if not 0 <= idx < len(cur["risks"]):
            raise HTTPException(404, "과제를 찾을 수 없습니다.")
        r = cur["risks"][idx]
        r["status"] = "진행중" if r["status"] == "완료" else "완료"
        cur["rev"] += 1
        cur["updatedAt"] = now_str()
        return cur
    return store.mutate(_toggle)


def h_bulk_replace(req: Req):
    """엑셀(CSV) 업로드 결과 반영: 전달된 목록으로 전체 교체 (같은 ID 의 첨부/이력은 유지)."""
    incoming = req.json().get("items")
    if not isinstance(incoming, list):
        raise HTTPException(400, "items 목록이 필요합니다.")

    def _bulk(data):
        cur = {i["id"]: i for i in data["items"]}
        out, seen = [], set()
        for raw in incoming:
            it = normalize_item(raw)
            if it["id"] in seen:
                it["id"] = it["id"] + "-" + secrets.token_hex(2)
            seen.add(it["id"])
            old = cur.get(it["id"])
            if old:
                for keep in ("attachments", "notify", "createdAt", "source", "sectorReviews", "applicantEmpId"):
                    it[keep] = old[keep]
                it["rev"] = old["rev"] + 1
            it["updatedAt"] = now_str()
            out.append(it)
        data["items"] = out
        return len(out)
    return {"count": store.mutate(_bulk)}


def h_backup(req: Req):
    return FileResp(store.data_path, f"data_backup_{dt.datetime.now():%Y%m%d_%H%M}.json")


# --- 첨부파일 --------------------------------------------------------------
def _attachment_path(folder: Path, name: str) -> Path:
    safe = safe_filename(name)
    path = (folder / safe).resolve()
    if safe != name or path.parent != folder.resolve() or not path.is_file():
        raise HTTPException(404, "파일을 찾을 수 없습니다.")
    return path


def h_upload_attachments(req: Req):
    item_id = req.params["id"]
    find_item(store.load(), item_id)
    _, files = req.form()
    if not files:
        raise HTTPException(400, "업로드할 파일이 없습니다.")
    saved = save_uploads(store.item_dir(item_id), files, "관리자")

    def _attach(data):
        it = find_item(data, item_id)
        it["attachments"].extend(saved)
        it["rev"] += 1
        return it
    return store.mutate(_attach)


def h_download_attachment(req: Req):
    return FileResp(_attachment_path(store.item_dir(req.params["id"]), req.params["name"]))


def h_delete_attachment(req: Req):
    item_id = req.params["id"]
    path = _attachment_path(store.item_dir(item_id), req.params["name"])
    trash = store.backup_dir / "deleted_attachments" / item_id
    trash.mkdir(parents=True, exist_ok=True)
    shutil.move(str(path), str(unique_path(trash, path.name)))

    def _detach(data):
        it = find_item(data, item_id)
        it["attachments"] = [a for a in it["attachments"] if a["name"] != path.name]
        it["rev"] += 1
        return it
    return store.mutate(_detach)


# --- 표준 양식 자료실 ------------------------------------------------------
def h_list_forms(req: Optional[Req] = None):
    files = []
    for p in sorted(store.forms_dir.iterdir(), key=lambda x: x.name):
        if p.is_file() and not p.name.startswith("."):
            st = p.stat()
            files.append({"name": p.name, "size": st.st_size,
                          "uploadedAt": dt.datetime.fromtimestamp(st.st_mtime).strftime("%Y-%m-%d %H:%M")})
    return files


def h_download_form(req: Req):
    return FileResp(_attachment_path(store.forms_dir, req.params["name"]))


def h_upload_forms(req: Req):
    _, files = req.form()
    if not files:
        raise HTTPException(400, "업로드할 파일이 없습니다.")
    save_uploads(store.forms_dir, files, "관리자")
    return h_list_forms()


def h_delete_form(req: Req):
    _attachment_path(store.forms_dir, req.params["name"]).unlink()
    return h_list_forms()


# --- 검토 요청 메일 --------------------------------------------------------
def _review_mail(req: Req) -> Dict[str, Any]:
    payload = req.json()
    item = find_item(store.load(), _s(payload.get("itemId")))
    to = _emails(payload.get("to"))
    if not to:
        raise HTTPException(400, "받는 사람을 1명 이상 선택하세요.")
    return build_review_mail(item, store.settings(), _s(payload.get("level")), to, _emails(payload.get("cc")),
                             _text(payload.get("summary")))


def h_review_preview(req: Req):
    return _review_mail(req)


def h_review_eml(req: Req):
    """X-Unsent: 1 헤더가 있는 .eml 초안 → 더블클릭하면 Outlook 새 메일(보내기 버튼 활성) 창으로 열린다."""
    mail = _review_mail(req)
    msg = EmailMessage()
    msg["To"] = "; ".join(mail["to"])
    if mail["cc"]:
        msg["Cc"] = "; ".join(mail["cc"])
    msg["Subject"] = mail["subject"]
    msg["X-Unsent"] = "1"
    msg.set_content(mail["text"])
    msg.add_alternative(mail["html"], subtype="html")
    fname = safe_filename(f"검토요청_{mail['subject'][:60]}.eml")
    return Resp(msg.as_bytes(), "message/rfc822", headers={"Content-Disposition": content_disposition(fname)})


def h_review_outlook(req: Req):
    """서버 PC에서 접속한 경우에만 Outlook 작성창(mail.Display())을 직접 띄운다."""
    if not is_local_request(req.client_host):
        raise HTTPException(409, "서버 PC가 아닌 곳에서 접속했습니다. .eml 초안으로 엽니다.")
    mail = _review_mail(req)
    try:
        outlook_mail(mail["to"], mail["cc"], mail["subject"], mail["html"], display=True)
    except Exception as e:  # noqa: BLE001
        raise HTTPException(409, f"Outlook 연동 실패({e}). .eml 초안으로 엽니다.")
    return {"ok": True}


# --- 회원 (가입 신청 → 관리자 승인) ---------------------------------------
def h_signup(req: Req):
    p = req.json()
    emp_id, name, team = _s(p.get("empId")), _s(p.get("name"))[:30], _s(p.get("team"))
    email, password = (_emails(p.get("email")) or [""])[0], _s(p.get("password"))
    if not EMP_ID_RE.match(emp_id):
        raise HTTPException(400, "사번은 영문/숫자 3~20자로 입력하세요.")
    if not name:
        raise HTTPException(400, "이름을 입력하세요.")
    if team not in [t["name"] for t in store.settings()["teams"]]:
        raise HTTPException(400, "팀을 선택하세요.")
    if not email:
        raise HTTPException(400, "이메일을 올바르게 입력하세요.")
    if len(password) < 4:
        raise HTTPException(400, "비밀번호는 4자 이상이어야 합니다.")

    def _add(users):
        old = users.get(emp_id)
        if old and old.get("status") != "rejected":
            raise HTTPException(409, "이미 가입 신청된 사번입니다." if old.get("status") == "pending" else "이미 가입된 사번입니다.")
        salt = secrets.token_hex(16)
        users[emp_id] = {"empId": emp_id, "name": name, "title": _s(p.get("title"))[:20], "team": team, "email": email,
                         "status": "pending", "pwSalt": salt, "pwHash": hash_password(password, salt),
                         "createdAt": now_str(), "approvedAt": ""}
        return users[emp_id]
    user = store.mutate_users(_add)
    threading.Thread(target=notify_signup, args=(user,), daemon=True).start()
    return {"ok": True, "message": "가입 신청이 접수되었습니다. 관리자 승인 후 로그인할 수 있습니다."}


def h_user_login(req: Req):
    p = req.json()
    ip = req.client_host
    recent = [t for t in LOGIN_FAILS.get(ip, []) if t > time.time() - 60]
    if len(recent) >= 5:
        raise HTTPException(429, "비밀번호를 여러 번 틀렸습니다. 1분 후 다시 시도하세요.")
    u = store.users().get(_s(p.get("empId")))
    if not u or not secrets.compare_digest(hash_password(_s(p.get("password")), u["pwSalt"]), u["pwHash"]):
        LOGIN_FAILS[ip] = recent + [time.time()]
        raise HTTPException(403, "사번 또는 비밀번호가 일치하지 않습니다.")
    if u.get("status") == "pending":
        raise HTTPException(403, "가입 승인 대기 중입니다. 관리자 승인 후 로그인할 수 있습니다.")
    if u.get("status") != "approved":
        raise HTTPException(403, "가입이 반려되었습니다. 관리자에게 문의하세요.")
    LOGIN_FAILS.pop(ip, None)
    token = secrets.token_urlsafe(24)
    USER_TOKENS[token] = (u["empId"], time.time() + USER_TOKEN_TTL_SEC)
    return {"token": token, "user": public_user(u, store.settings())}


def h_user_me(req: Req):
    user = req.user()
    if not user:
        raise HTTPException(401, "로그인이 필요합니다.")
    return user


def h_user_logout(req: Req):
    USER_TOKENS.pop(req.user_token, None)
    return {"ok": True}


def h_user_password(req: Req):
    user = req.user()
    if not user:
        raise HTTPException(401, "로그인이 필요합니다.")
    p = req.json()
    new = _s(p.get("new"))
    if len(new) < 4:
        raise HTTPException(400, "새 비밀번호는 4자 이상이어야 합니다.")

    def _change(users):
        u = users[user["empId"]]
        if not secrets.compare_digest(hash_password(_s(p.get("current")), u["pwSalt"]), u["pwHash"]):
            raise HTTPException(403, "현재 비밀번호가 일치하지 않습니다.")
        u["pwSalt"] = secrets.token_hex(16)
        u["pwHash"] = hash_password(new, u["pwSalt"])
    store.mutate_users(_change)
    return {"ok": True}


def h_admin_users(req: Req):
    settings = store.settings()
    users = sorted(store.users().values(), key=lambda u: (u.get("status") != "pending", u.get("createdAt", "")), reverse=False)
    return [public_user(u, settings) for u in users]


def h_admin_user_action(req: Req):
    emp_id = req.params["empId"]
    p = req.json()
    action = p.get("action")
    teams = [t["name"] for t in store.settings()["teams"]]

    def _act(users):
        u = users.get(emp_id)
        if not u:
            raise HTTPException(404, "회원을 찾을 수 없습니다.")
        if action == "approve":
            u["status"], u["approvedAt"] = "approved", now_str()
        elif action == "reject":
            u["status"] = "rejected"
        elif action == "update":
            if "team" in p:
                if p["team"] not in teams:
                    raise HTTPException(400, "존재하지 않는 팀입니다.")
                u["team"] = p["team"]
            for k, limit in (("name", 30), ("title", 20)):
                if k in p:
                    u[k] = _s(p[k])[:limit]
            if "email" in p:
                u["email"] = (_emails(p["email"]) or [u.get("email", "")])[0]
        elif action == "resetPassword":
            new = _s(p.get("password"))
            if len(new) < 4:
                raise HTTPException(400, "임시 비밀번호는 4자 이상이어야 합니다.")
            u["pwSalt"] = secrets.token_hex(16)
            u["pwHash"] = hash_password(new, u["pwSalt"])
        else:
            raise HTTPException(400, "알 수 없는 작업입니다.")
    store.mutate_users(_act)
    if action in ("reject", "resetPassword"):  # 기존 로그인 세션 종료
        for tok, (eid, _) in list(USER_TOKENS.items()):
            if eid == emp_id:
                USER_TOKENS.pop(tok, None)
    return h_admin_users(req)


def h_admin_user_delete(req: Req):
    emp_id = req.params["empId"]
    store.mutate_users(lambda users: users.pop(emp_id, None))
    for tok, (eid, _) in list(USER_TOKENS.items()):
        if eid == emp_id:
            USER_TOKENS.pop(tok, None)
    return h_admin_users(req)


# --- 부문 검토 작성 (팀장: 자기 부문 행만) ----------------------------------
def h_sector_save(req: Req):
    item_id, sector = req.params["id"], req.params["sector"]
    if sector not in SECTORS:
        raise HTTPException(400, "알 수 없는 부문입니다.")
    user = req.user()
    if not req.is_admin and not (user and user["sector"] == sector):
        raise HTTPException(403, f"{sector} 부문 작성 권한이 없습니다. (본인 팀의 담당 부문만 작성 가능)")
    p = req.json()
    complete = bool(p.get("complete"))
    writer = user or {"empId": "admin", "name": "관리자", "title": "", "team": "간사"}
    rows = []
    for r in p.get("rows") or []:
        r = normalize_risk({**(r if isinstance(r, dict) else {}), "sector": sector})
        if not r["reviewer"]:
            r["reviewer"] = f"{writer['name']} {writer.get('title', '')}".strip()
        rows.append(r)

    def _save(data):
        cur = find_item(data, item_id)
        others = [r for r in cur["risks"] if r["sector"] != sector]
        merged = []
        for sec in SECTORS:  # 부문 순서대로 정리
            merged.extend(rows if sec == sector else [r for r in others if r["sector"] == sec])
        cur["risks"] = merged
        if complete:
            cur["sectorReviews"][sector] = {"empId": writer["empId"], "name": writer["name"], "team": writer["team"], "at": now_str()}
        cur["rev"] += 1
        cur["updatedAt"] = now_str()
        return cur
    item = store.mutate(_save)
    mail = None
    if complete:
        if _emails(store.settings().get("secretaryEmails")):
            threading.Thread(target=notify_sector_done, args=(item_id, sector, writer), daemon=True).start()
            mail = "sent"
        else:
            mail = "no_recipient"
    return {"item": item, "mail": mail}


def h_sector_reopen(req: Req):
    """관리자: 부문 '작성 완료' 표시 해제 (재작성 요청)."""
    item_id, sector = req.params["id"], req.params["sector"]

    def _reopen(data):
        cur = find_item(data, item_id)
        cur["sectorReviews"].pop(sector, None)
        cur["rev"] += 1
        return cur
    return store.mutate(_reopen)


# --- 현재 접속자 ------------------------------------------------------------
def _presence_snapshot() -> Dict[str, Any]:
    now = time.time()
    users, seen_emp, anon, admins = [], set(), 0, 0
    all_users = store.users()
    settings = store.settings()
    with PRESENCE_LOCK:
        for cid in [c for c, v in PRESENCE.items() if v["seen"] < now - PRESENCE_TTL_SEC]:
            PRESENCE.pop(cid, None)
        entries = list(PRESENCE.values())
    for v in entries:
        if v.get("empId") and v["empId"] in all_users:
            if v["empId"] in seen_emp:
                continue
            seen_emp.add(v["empId"])
            u = all_users[v["empId"]]
            users.append({"name": u.get("name", ""), "title": u.get("title", ""), "team": u.get("team", ""),
                          "admin": bool(v.get("admin"))})
        elif v.get("admin"):
            admins += 1
        else:
            anon += 1
    users.sort(key=lambda u: (team_order(settings, u["team"]), u["name"]))
    return {"count": len(users) + admins + anon, "users": users, "admins": admins, "anonymous": anon}


def team_order(settings: Dict[str, Any], team: str) -> int:
    names = [t["name"] for t in settings["teams"]]
    return names.index(team) if team in names else len(names)


def h_presence(req: Req):
    p = req.json()
    cid = _s(p.get("clientId"))[:64]
    user = req.user()
    if cid:
        with PRESENCE_LOCK:
            PRESENCE[cid] = {"seen": time.time(), "empId": user["empId"] if user else "", "admin": req.is_admin}
    snap = _presence_snapshot()
    snap["me"] = user  # 팀 변경 등 관리자 수정 사항을 화면에 바로 반영
    snap["isAdmin"] = req.is_admin
    return snap


def h_presence_leave(req: Req):
    try:
        cid = _s(req.json().get("clientId"))
    except HTTPException:
        cid = ""
    with PRESENCE_LOCK:
        PRESENCE.pop(cid, None)
    return {"ok": True}


def h_put_teams(req: Req):
    teams = normalize_teams(req.json().get("teams"))
    if not teams:
        raise HTTPException(400, "팀을 1개 이상 등록하세요.")
    s = store.settings()
    s["teams"] = teams
    store.save_settings(s)
    return teams


# ---------------------------------------------------------------------------
# 라우팅
# ---------------------------------------------------------------------------
SEG = r"([^/]+)"
ROUTES: List[Tuple[str, "re.Pattern[str]", Callable[[Req], Any], bool, List[str]]] = []


def route(method: str, pattern: str, handler: Callable[[Req], Any], admin: bool = False) -> None:
    names = re.findall(r"\{(\w+)\}", pattern)
    regex = re.compile("^" + re.sub(r"\{\w+\}", SEG, pattern) + "$")
    ROUTES.append((method, regex, handler, admin, names))


route("GET", "/api/bootstrap", h_bootstrap)
route("GET", "/api/version", h_version)
route("POST", "/api/login", h_login)
route("POST", "/api/logout", h_logout)
route("POST", "/api/admin/password", h_change_password, admin=True)
route("GET", "/api/settings", h_get_settings, admin=True)
route("PUT", "/api/settings", h_put_settings, admin=True)
route("POST", "/api/mail/test", h_mail_test, admin=True)
route("POST", "/api/apply", h_apply)
route("POST", "/api/items/bulk", h_bulk_replace, admin=True)
route("PUT", "/api/items/{id}", h_update_item, admin=True)
route("DELETE", "/api/items/{id}", h_delete_item, admin=True)
route("POST", "/api/items/{id}/accept", h_accept_item, admin=True)
route("POST", "/api/items/{id}/risks/{idx}/toggle", h_toggle_risk, admin=True)
route("POST", "/api/items/{id}/attachments", h_upload_attachments, admin=True)
route("GET", "/api/items/{id}/attachments/{name}", h_download_attachment)
route("DELETE", "/api/items/{id}/attachments/{name}", h_delete_attachment, admin=True)
route("GET", "/api/admin/backup", h_backup, admin=True)
route("GET", "/api/forms", h_list_forms)
route("POST", "/api/forms", h_upload_forms, admin=True)
route("GET", "/api/forms/{name}", h_download_form)
route("DELETE", "/api/forms/{name}", h_delete_form, admin=True)
route("POST", "/api/mail/review/preview", h_review_preview, admin=True)
route("POST", "/api/mail/review/eml", h_review_eml, admin=True)
route("POST", "/api/mail/review/outlook", h_review_outlook, admin=True)
route("POST", "/api/users/signup", h_signup)
route("POST", "/api/users/login", h_user_login)
route("GET", "/api/users/me", h_user_me)
route("POST", "/api/users/logout", h_user_logout)
route("POST", "/api/users/password", h_user_password)
route("GET", "/api/admin/users", h_admin_users, admin=True)
route("POST", "/api/admin/users/{empId}", h_admin_user_action, admin=True)
route("DELETE", "/api/admin/users/{empId}", h_admin_user_delete, admin=True)
route("PUT", "/api/admin/teams", h_put_teams, admin=True)
route("POST", "/api/items/{id}/sector/{sector}", h_sector_save)
route("POST", "/api/items/{id}/sector/{sector}/reopen", h_sector_reopen, admin=True)
route("POST", "/api/presence", h_presence)
route("POST", "/api/presence/leave", h_presence_leave)

STATIC_DIR = (BASE_DIR / "static").resolve()


def dispatch(req: Req) -> Any:
    if req.method == "GET" and req.path in ("/", "/index.html"):
        return FileResp(BASE_DIR / "templates" / "index.html", attachment=False)
    if req.method == "GET" and req.path.startswith("/static/"):
        path = (STATIC_DIR / req.path[len("/static/"):]).resolve()
        if path.parent != STATIC_DIR or not path.is_file():
            raise HTTPException(404, "Not Found")
        return FileResp(path, attachment=False)
    path_matched = False
    for method, regex, handler, admin, names in ROUTES:
        m = regex.match(req.path)
        if not m:
            continue
        path_matched = True
        if method != req.method:
            continue
        req.params = {n: unquote(v) for n, v in zip(names, m.groups())}
        if admin:
            require_admin(req.token)
        return handler(req)
    raise HTTPException(405 if path_matched else 404, "Method Not Allowed" if path_matched else "Not Found")


class Handler(BaseHTTPRequestHandler):
    server_version = "TransferPortal/1.0"

    def _handle(self) -> None:
        url = urlsplit(self.path)
        try:
            length = int(self.headers.get("Content-Length") or 0)
            if length > MAX_REQUEST_BYTES:
                raise HTTPException(413, "업로드 용량이 너무 큽니다. (요청당 500MB 이하)")
            body = b""
            while len(body) < length:
                chunk = self.rfile.read(min(1024 * 1024, length - len(body)))
                if not chunk:
                    break
                body += chunk
            req = Req(self.command, url.path, url.query, self.headers, body, self.client_address[0])
            result = dispatch(req)
            if isinstance(result, FileResp):
                self._send_file(result)
                return
            if not isinstance(result, Resp):
                result = json_resp(result)
        except HTTPException as e:
            result = json_resp({"detail": e.detail}, e.status)
        except Exception:  # noqa: BLE001 - 서버가 죽지 않도록 모든 예외를 500 으로 응답
            traceback.print_exc()
            result = json_resp({"detail": "서버 내부 오류가 발생했습니다. 서버 콘솔 로그를 확인하세요."}, 500)
        self._send(result)

    def _send(self, r: Resp) -> None:
        self.send_response(r.status)
        self.send_header("Content-Type", r.content_type)
        self.send_header("Content-Length", str(len(r.body)))
        self.send_header("Cache-Control", "no-store")
        for k, v in r.headers.items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(r.body)

    def _send_file(self, f: FileResp) -> None:
        ctype = mimetypes.guess_type(f.path.name)[0] or "application/octet-stream"
        if ctype.startswith("text/") or ctype in ("application/javascript", "application/json"):
            ctype += "; charset=utf-8"
        size = f.path.stat().st_size
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(size))
        self.send_header("Cache-Control", "no-store")
        if f.attachment:
            self.send_header("Content-Disposition", content_disposition(f.filename))
        self.end_headers()
        with open(f.path, "rb") as fh:
            shutil.copyfileobj(fh, self.wfile, 1024 * 1024)

    do_GET = do_POST = do_PUT = do_DELETE = _handle

    def log_message(self, fmt: str, *args: Any) -> None:  # 콘솔에는 오류 응답만 남긴다
        if len(args) >= 2 and str(args[1])[:1] in ("4", "5"):
            sys.stderr.write(f"[{now_str()}] {self.client_address[0]} {fmt % args}\n")


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    mimetypes.add_type("application/javascript", ".js")
    mimetypes.add_type("text/css", ".css")
    try:
        httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    except OSError as e:
        print(f"[오류] 포트 {PORT} 를 열 수 없습니다: {e}")
        print("       이미 서버가 실행 중인지 확인하거나, 다른 프로그램이 8000 포트를 쓰는지 확인하세요.")
        sys.exit(1)
    httpd.daemon_threads = True
    print("=" * 64)
    print(" 양산이관 검증위원회 통합 관리 포털")
    print(f" 저장소 : {store.root} ({'공유폴더' if store.is_network else '로컬 폴백 - 공유폴더 접근 불가'})")
    print(f" 접속   : http://{lan_ip()}:{PORT}  (이 PC: http://localhost:{PORT})")
    print(" 종료   : 이 창을 닫거나 Ctrl+C")
    print("=" * 64)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n서버를 종료합니다.")
