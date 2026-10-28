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
# 단계별 리드타임(영업일): 1단계는 접수 승인일, 이후 단계는 직전 단계 완료일 기준
STAGE_LEAD_DAYS = {"step1": 5, "step2": 7, "step3": 7, "step4": 7, "step5": 7}
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
REVIEW_TEAMS = {
    "품질/수율": ["종합공정1팀", "종합공정2팀", "종합공정담당"],
    "장비": ["장비기술1팀", "장비기술2팀", "장비기술3팀", "Metrology기술팀", "MS장비기술팀", "장비기술담당"],
    "생산성": ["제조운영팀", "제조혁신담당"],
    "Process": ["LS공정기술1팀", "LS공정기술2팀", "LS공정기술3팀", "오염제어기술팀", "MS공정기술팀", "GR기술1팀", "GR기술2팀",
                "EPI기술1팀", "EPI기술2팀", "청주EPI기술팀", "LSwafering기술담당", "MSwafering기술담당", "Growing기술담당", "EPI기술담당"],
    "제조": ["LS제조1팀", "LS제조2팀", "LS제조3팀", "LS제조4팀", "LS제조5팀", "MS제조1팀", "MS제조2팀", "LS제조담당", "MS제조담당"],
    "손익": ["효율혁신팀", "경영관리담당"],
}
DEV_TEAMS = ["결정성장개발팀", "EPI개발팀", "Wafering개발팀", "제품개발팀"]
DEFAULT_TEAMS = [{"name": t, "sector": "", "canApply": True} for t in DEV_TEAMS] + [
    {"name": t, "sector": sector, "canApply": False} for sector, teams in REVIEW_TEAMS.items() for t in teams
]
# v3 에서 임시로 넣었던 예시 팀 목록 → 저장돼 있으면 실제 조직으로 자동 교체
OLD_SAMPLE_TEAMS = {"결정성장개발팀", "EPI개발팀", "Wafering개발팀", "제품개발팀", "품질보증팀", "설비기술팀", "생산관리팀",
                    "공정기술팀", "제조팀", "경영기획팀"}
TITLES = ["팀장", "Pro"]


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


def host_names() -> List[str]:
    """이 PC의 이름 기반 접속 주소 후보 (컴퓨터 이름, 사내 DNS 전체 이름)."""
    names = []
    for n in (socket.gethostname(), socket.getfqdn()):
        n = (n or "").strip()
        if n and n.lower() not in ("localhost",) and not re.match(r"^[\d.]+$", n) and n not in names:
            names.append(n)
    return names


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


# ---------------------------------------------------------------------------
# 안건 → 부문 검토 의견(reviews) → 보완 과제(tasks)
#  - 팀장은 부문별로 '이상 없음' 또는 'Risk 있음 + Risk 목록' 을 작성
#  - 간사(관리자)는 2단계에서 Risk 마다 [과제 등록] 또는 [수용(사유)] 을 결정
#  - 과제는 중요도(상: 이관 전 완료 필수 / 중·하: 조건부 승인 가능)·담당·목표일·상태를 관리
# ---------------------------------------------------------------------------
IMPORTANCE = ["상", "중", "하"]
RISK_ID_RE = re.compile(r"^R(\d+)$")
TASK_ID_RE = re.compile(r"^T(\d+)$")


def empty_reviews() -> Dict[str, Dict[str, Any]]:
    return {sec: {"result": "", "reviewer": "", "risks": []} for sec in SECTORS}


def normalize_review_risk(r: Any) -> Optional[Dict[str, Any]]:
    if not isinstance(r, dict):
        return None
    content, proposal = _text(r.get("content"))[:3000], _text(r.get("proposal"))[:3000]
    decision = r.get("decision") if r.get("decision") in ("task", "accept") else ""
    if not content and not proposal and not decision:
        return None
    return {"id": _s(r.get("id"))[:12], "content": content, "proposal": proposal, "decision": decision,
            "reason": _text(r.get("reason"))[:1000] if decision == "accept" else "",
            "taskId": _s(r.get("taskId"))[:12] if decision == "task" else ""}


TASK_LOG_KINDS = ("progress", "request", "approve", "reject", "reopen")
AUDIT_MAX = 300


def normalize_task_log(v: Any) -> List[Dict[str, Any]]:
    out = []
    for x in v if isinstance(v, list) else []:
        if not isinstance(x, dict):
            continue
        out.append({"at": _s(x.get("at"))[:19], "by": _s(x.get("by"))[:80],
                    "kind": x.get("kind") if x.get("kind") in TASK_LOG_KINDS else "progress",
                    "note": _text(x.get("note"))[:5000],
                    "files": [a for a in (normalize_attachment(f) for f in (x.get("files") or [])) if a]})
    return out[-100:]


def normalize_request(v: Any) -> Optional[Dict[str, Any]]:
    if not isinstance(v, dict) or not _s(v.get("at")):
        return None
    return {"at": _s(v.get("at"))[:19], "by": _s(v.get("by"))[:80], "empId": _s(v.get("empId"))[:20], "note": _text(v.get("note"))[:5000]}


def normalize_audit(v: Any) -> List[Dict[str, str]]:
    return [{"at": _s(x.get("at"))[:19], "by": _s(x.get("by"))[:80], "action": _text(x.get("action"))[:500]}
            for x in (v if isinstance(v, list) else []) if isinstance(x, dict) and _s(x.get("action"))][-AUDIT_MAX:]


def add_audit(item: Dict[str, Any], by: str, *actions: str) -> None:
    """변경 이력(누가·언제·무엇을). 지우지 않고 최근 300건까지 보관."""
    log = item.setdefault("audit", [])
    for a in actions:
        if a:
            log.append({"at": now_str(), "by": by, "action": a[:500]})
    item["audit"] = log[-AUDIT_MAX:]


def task_log(t: Dict[str, Any], by: str, kind: str, note: str = "", files: Optional[List[Dict[str, Any]]] = None) -> None:
    t["log"] = (t["log"] + [{"at": now_str(), "by": by, "kind": kind, "note": note, "files": files or []}])[-100:]


def set_task_done(t: Dict[str, Any], done: bool, by: str, note: str = "") -> None:
    if done:
        task_log(t, by, "approve", note or ("완료 요청 승인" if t["request"] else "완료 처리"))
        t.update(status="완료", doneAt=today_str(), request=None)
    else:
        t.update(status="진행중", doneAt="")
        task_log(t, by, "reopen", note or "완료 해제 (진행중으로 변경)")


def normalize_task(t: Any) -> Optional[Dict[str, Any]]:
    if not isinstance(t, dict) or not TASK_ID_RE.match(_s(t.get("id"))):
        return None
    st = normalize_stage("task", {"target": t.get("target"), "targetOriginal": t.get("targetOriginal"),
                                  "extensions": t.get("extensions"), "done": t.get("status") == "완료", "doneAt": t.get("doneAt")})
    return {
        "id": _s(t.get("id")), "riskId": _s(t.get("riskId"))[:12], "team": _s(t.get("team"))[:40],
        "sector": t.get("sector") if t.get("sector") in SECTORS else SECTORS[0],
        "title": _text(t.get("title"))[:3000], "plan": _text(t.get("plan"))[:3000],
        "importance": t.get("importance") if t.get("importance") in IMPORTANCE else "중",
        "org": _s(t.get("org"))[:60],
        "ownerName": _s(t.get("ownerName"))[:40], "ownerEmpId": _s(t.get("ownerEmpId"))[:20],
        "ownerEmail": (_emails(t.get("ownerEmail")) or [""])[0],
        "target": st["target"], "targetOriginal": st["targetOriginal"], "extensions": st["extensions"],
        "status": "완료" if t.get("status") == "완료" else "진행중",
        "doneAt": st["doneAt"], "createdAt": _s(t.get("createdAt"))[:19] or today_str(),
        "log": normalize_task_log(t.get("log")),
        "request": None if t.get("status") == "완료" else normalize_request(t.get("request")),
    }


def migrate_legacy_risks(raw_risks: List[Any]) -> Tuple[Dict[str, Dict[str, Any]], List[Dict[str, Any]]]:
    """v1~v7 의 Risk 테이블 행 → 부문 검토 의견 + 보완 과제."""
    reviews, tasks, rn = empty_reviews(), [], 0
    for r in (normalize_risk(x) for x in raw_risks or []):
        rv = reviews[r["sector"]]
        if r["reviewer"] and not rv["reviewer"]:
            rv["reviewer"] = r["reviewer"]
        if r["noRisk"]:
            rv["result"] = rv["result"] or "ok"
            continue
        if not r["riskItem"] and not r["planContent"] and r["isTask"] != "O":
            continue  # 빈 행
        rv["result"] = "risk"
        rn += 1
        risk = {"id": f"R{rn:02d}", "content": r["riskItem"] or r["planContent"], "proposal": r["planContent"],
                "decision": "", "reason": "", "taskId": ""}
        if r["isTask"] == "O":
            tid = f"T{len(tasks) + 1:02d}"
            risk.update(decision="task", taskId=tid)
            tasks.append(normalize_task({
                "id": tid, "riskId": risk["id"], "sector": r["sector"], "title": risk["content"], "plan": r["planContent"],
                "importance": r["grade"] or "중", "org": r["org"], "target": r["schedule"], "status": r["status"],
                "doneAt": r["schedule"] if r["status"] == "완료" else "",
            }))
        else:
            risk.update(decision="accept", reason="(기존 데이터 이관: 과제화 X)")
        rv["risks"].append(risk)
    for rv in reviews.values():
        if rv["result"] == "ok" and rv["risks"]:
            rv["result"] = "risk"
    return reviews, tasks


# ---------------------------------------------------------------------------
# 팀 단위 검토 의견 (D단계)
#  - item["reviews"] = {팀 이름: 카드}. 카드가 있는 팀 = 전문(소)위원으로 선정된 팀
#  - 카드: sector, result(ok/risk/""), comment, risks[], done(작성 완료자), history(작성 이력)
#  - 같은 팀 회원이면 직급 상관없이 작성, 누가 저장/완료했는지 history 에 남긴다
# ---------------------------------------------------------------------------
LEGACY_CARD_PREFIX = "(기존) "
PRODUCT_SIZES = ["300mm", "200mm"]
PRODUCT_TYPES = ["PW", "EPI"]
_FIXED = ["제조운영팀", "효율혁신팀"]  # 생산성·손익: 모든 제품 공통
_300_COMMON = ["종합공정2팀", "장비기술1팀", "장비기술2팀", "장비기술3팀", "Metrology기술팀",
               "GR기술2팀", "LS공정기술1팀", "LS공정기술2팀", "LS공정기술3팀", "오염제어기술팀"]
_200_COMMON = ["종합공정1팀", "MS장비기술팀", "Metrology기술팀", "GR기술1팀", "MS공정기술팀", "오염제어기술팀"]
DEFAULT_REVIEW_MATRIX = {
    "300mm PW": _300_COMMON + ["LS제조1팀", "LS제조2팀", "LS제조3팀"] + _FIXED,
    "300mm EPI": _300_COMMON + ["EPI기술1팀", "EPI기술2팀", "LS제조1팀", "LS제조2팀", "LS제조3팀", "LS제조4팀"] + _FIXED,
    "200mm PW": _200_COMMON + ["MS제조1팀", "MS제조2팀"] + _FIXED,
    "200mm EPI": _200_COMMON + ["EPI기술1팀", "EPI기술2팀", "MS제조1팀", "MS제조2팀", "LS제조4팀"] + _FIXED,
}


def matrix_key(size: str, ptype: str) -> str:
    return f"{size} {ptype}" if size in PRODUCT_SIZES and ptype in PRODUCT_TYPES else ""


def normalize_matrix(v: Any) -> Dict[str, List[str]]:
    v = v if isinstance(v, dict) else {}
    out = {}
    for key, default in DEFAULT_REVIEW_MATRIX.items():
        teams = v.get(key) if isinstance(v.get(key), list) else default
        out[key] = list(dict.fromkeys(_s(t)[:40] for t in teams if _s(t)))
    return out


def _done_record(d: Any) -> Optional[Dict[str, str]]:
    if not isinstance(d, dict) or not _s(d.get("at")):
        return None
    return {k: _s(d.get(k))[:40] for k in ("empId", "name", "title", "team", "at")}


def normalize_card(c: Any) -> Dict[str, Any]:
    c = c if isinstance(c, dict) else {}
    risks = [x for x in (normalize_review_risk(x) for x in (c.get("risks") or [])) if x]
    result = c.get("result") if c.get("result") in ("ok", "risk") else ""
    if result == "ok" and any(x["decision"] for x in risks):
        result = "risk"  # 위원회가 결정한 Risk 가 있으면 '이상 없음' 불가
    if result == "ok":
        risks = []
    history = [{k: _s(h.get(k))[:80] for k in ("at", "by", "action")} for h in (c.get("history") or []) if isinstance(h, dict)][-50:]
    return {"sector": c.get("sector") if c.get("sector") in SECTORS else SECTORS[0], "result": result,
            "comment": _text(c.get("comment"))[:2000], "risks": risks, "done": _done_record(c.get("done")), "history": history}


def convert_sector_reviews(by_sector: Dict[str, Any], sector_done: Any) -> Dict[str, Dict[str, Any]]:
    """v8(부문당 1장) → 팀 카드. 내용이 있는 부문만 '(기존) 부문' 카드로 옮긴다."""
    sector_done = sector_done if isinstance(sector_done, dict) else {}
    cards = {}
    for sec in SECTORS:
        rv = by_sector.get(sec) if isinstance(by_sector.get(sec), dict) else {}
        done = sector_done.get(sec) if isinstance(sector_done.get(sec), dict) else None
        if not (rv.get("result") or rv.get("risks") or done):
            continue
        reviewer = _s(rv.get("reviewer"))
        cards[LEGACY_CARD_PREFIX + sec] = normalize_card({
            "sector": sec, "result": rv.get("result"), "risks": rv.get("risks"),
            "comment": f"(검토: {reviewer})" if reviewer else "",
            "done": {**done, "title": ""} if done else None,
            "history": [{"at": done.get("at", ""), "by": f"{done.get('team', '')} {done.get('name', '')}".strip(), "action": "작성 완료(이전 버전)"}] if done else [],
        })
    return cards


def normalize_review_cards(raw: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    v = raw.get("reviews")
    if isinstance(v, dict) and (not v or any(isinstance(x, dict) and "sector" in x for x in v.values())):
        return {_s(team)[:40]: normalize_card(c) for team, c in v.items() if _s(team)}
    if isinstance(v, dict):  # v8 부문 형식
        return convert_sector_reviews(v, raw.get("sectorReviews"))
    by_sector, _ = migrate_legacy_risks(raw.get("risks") or [])  # v1~v7 Risk 테이블
    return convert_sector_reviews(by_sector, raw.get("sectorReviews"))


def card_order(item: Dict[str, Any], settings: Optional[Dict[str, Any]] = None) -> List[str]:
    names = [t["name"] for t in (settings or {}).get("teams", [])]
    return sorted(item["reviews"], key=lambda t: (SECTORS.index(item["reviews"][t]["sector"]),
                                                  names.index(t) if t in names else len(names), t))


def apply_review_matrix(item: Dict[str, Any], settings: Dict[str, Any]) -> None:
    """제품 안건: 검토 팀이 아직 없으면 구경·PW/EPI 매트릭스대로 선정 (기술 안건은 간사가 직접 선정)."""
    if item["category"] != "제품" or item["reviews"]:
        return
    for team in settings["reviewMatrix"].get(matrix_key(item["productSize"], item["productType"]), []):
        sec = team_info(settings, team)["sector"]
        if sec:
            item["reviews"][team] = normalize_card({"sector": sec})


def next_seq_id(prefix: str, ids: List[str]) -> str:
    nums = [int(m.group(1)) for m in (re.match(rf"^{prefix}(\d+)$", i or "") for i in ids) if m]
    return f"{prefix}{(max(nums) + 1) if nums else 1:02d}"


def all_risk_ids(item: Dict[str, Any]) -> List[str]:
    return [r["id"] for c in item["reviews"].values() for r in c["risks"]]


def open_tasks(item: Dict[str, Any], importance: Optional[str] = None) -> List[Dict[str, Any]]:
    return [t for t in item["tasks"] if t["status"] != "완료" and (importance is None or t["importance"] == importance)]


def normalize_attachment(a: Any) -> Optional[Dict[str, Any]]:
    if not isinstance(a, dict) or not _s(a.get("name")):
        return None
    return {
        "name": safe_filename(a.get("name")),
        "size": int(a.get("size") or 0),
        "uploadedAt": _s(a.get("uploadedAt")),
        "by": _s(a.get("by")),
    }


# 2단계(검증소위원회)·4단계(검증위원회)는 1차·2차… 회의를 열 수 있다 (회의록 첨부)
MEETING_STAGES = ("step2", "step4")
MEETING_RESULTS = ("", "통과", "조건부 통과", "재심의", "보류")


def normalize_meeting(v: Any) -> Optional[Dict[str, Any]]:
    if not isinstance(v, dict):
        return None
    try:
        no = int(v.get("no") or 0)
    except (TypeError, ValueError):
        no = 0
    if no < 1:
        return None
    result = _s(v.get("result"))
    return {
        "no": no,
        "date": _date(v.get("date")),
        "result": result if result in MEETING_RESULTS else "",
        "note": _text(v.get("note"))[:2000],
        "minutesText": _text(v.get("minutesText"))[:100000],
        "minutes": [a for a in (normalize_attachment(x) for x in (v.get("minutes") or [])) if a],
        "createdAt": _s(v.get("createdAt"))[:19] or now_str(),
    }


def normalize_meetings(v: Any) -> List[Dict[str, Any]]:
    out: Dict[int, Dict[str, Any]] = {}
    for m in (normalize_meeting(x) for x in (v if isinstance(v, list) else [])):
        if m and m["no"] not in out:
            out[m["no"]] = m
    return [out[k] for k in sorted(out)]


def keep_task_tracking(new: Dict[str, Any], old: Dict[str, Any], by: str) -> None:
    """과제 진행 기록·완료 요청은 서버가 관리. 관리자가 상태를 바꾸면 기록에 남긴다."""
    olds = {t["id"]: t for t in old["tasks"]}
    for t in new["tasks"]:
        o = olds.get(t["id"])
        if not o:
            continue
        t["log"], t["request"] = o["log"], o["request"]
        if t["status"] != o["status"]:
            if t["status"] == "완료":
                task_log(t, by, "approve", "완료 요청 승인" if t["request"] else "완료 처리")
                t["request"] = None
            else:
                task_log(t, by, "reopen", "완료 해제 (진행중으로 변경)")


ITEM_FIELD_LABELS = [("category", "구분"), ("npSp", "NP/SP"), ("productSize", "구경"), ("productType", "PW/EPI"), ("title", "제품/기술명"),
                     ("requester", "요청자"), ("requesterDept", "소속 부서"), ("requesterEmail", "요청자 이메일"), ("proposalDate", "발제일")]


def diff_item(old: Dict[str, Any], new: Dict[str, Any]) -> List[str]:
    """관리자 저장 시 무엇이 바뀌었는지 사람이 읽을 수 있는 문장으로."""
    out: List[str] = []
    for k, label in ITEM_FIELD_LABELS:
        if old.get(k) != new.get(k):
            out.append(f"{label}: {old.get(k) or '(없음)'} → {new.get(k) or '(없음)'}")
    for k, label in (("summary", "주요 내용"), ("note", "비고")):
        if old.get(k) != new.get(k):
            out.append(f"{label} 수정")
    for i, k in enumerate(STAGE_KEYS):
        o, n, name = old["stages"][k], new["stages"][k], f"{i + 1}단계 {STAGE_NAMES[i]}"
        if o["skipped"] != n["skipped"]:
            out.append(f"{name} {'생략(Skip)' if n['skipped'] else '생략 해제'}")
        if o["done"] != n["done"]:
            out.append(f"{name} {'완료 처리 (' + n['doneAt'] + ')' if n['done'] else '완료 해제'}")
        elif n["done"] and o["doneAt"] != n["doneAt"]:
            out.append(f"{name} 완료일 변경 {o['doneAt']} → {n['doneAt']}")
        for e in n["extensions"][len(o["extensions"]):]:
            out.append(f"{name} 목표일 {'연장 ' + e['from'] + ' → ' if e['from'] else '지정 '}{e['to']}" + (f" (사유: {e['reason']})" if e["reason"] else ""))
    added = [t for t in new["reviews"] if t not in old["reviews"]]
    removed = [t for t in old["reviews"] if t not in new["reviews"]]
    if added:
        out.append("검토 팀 선정: " + ", ".join(added))
    if removed:
        out.append("검토 팀 제외: " + ", ".join(removed))
    old_risks = {r["id"]: r for c in old["reviews"].values() for r in c["risks"]}
    for team, c in new["reviews"].items():
        oc = old["reviews"].get(team)
        if oc and (oc["result"], oc["comment"]) != (c["result"], c["comment"]):
            out.append(f"[{team}] 검토 의견 관리자 수정")
        for r in c["risks"]:
            o = old_risks.get(r["id"])
            if not o or o["decision"] == r["decision"]:
                continue
            if r["decision"] == "task":
                out.append(f"Risk {r['id']} → 보완 과제 {r['taskId']} 등록")
            elif r["decision"] == "accept":
                out.append(f"Risk {r['id']} 수용 (사유: {r['reason']})")
            else:
                out.append(f"Risk {r['id']} 결정 취소")
    old_tasks = {t["id"]: t for t in old["tasks"]}
    new_ids = {t["id"] for t in new["tasks"]}
    for tid in old_tasks:
        if tid not in new_ids:
            out.append(f"과제 {tid} 삭제")
    for t in new["tasks"]:
        o = old_tasks.get(t["id"])
        if not o:
            continue
        if o["importance"] != t["importance"]:
            out.append(f"과제 {t['id']} 중요도 {o['importance']} → {t['importance']}")
        if o["status"] != t["status"]:
            out.append(f"과제 {t['id']} {'완료 처리' if t['status'] == '완료' else '진행중으로 변경'}")
        if (o["org"], o["ownerName"], o["ownerEmail"]) != (t["org"], t["ownerName"], t["ownerEmail"]):
            out.append(f"과제 {t['id']} 담당: {t['org'] or '-'} {t['ownerName'] or t['ownerEmail'] or ''}".rstrip())
        if (o["title"], o["plan"]) != (t["title"], t["plan"]):
            out.append(f"과제 {t['id']} 내용/보완 방안 수정")
        for e in t["extensions"][len(o["extensions"]):]:
            out.append(f"과제 {t['id']} 목표일 {'연장 ' + e['from'] + ' → ' if e['from'] else '지정 '}{e['to']}" + (f" (사유: {e['reason']})" if e["reason"] else ""))
        if not t["extensions"] and o["target"] != t["target"]:
            out.append(f"과제 {t['id']} 목표일 {o['target'] or '(없음)'} → {t['target'] or '(없음)'}")
    return out[:30]


def keep_meetings(new: Dict[str, Any], old: Dict[str, Any]) -> None:
    """회의 차수·회의록은 전용 API 로만 바뀐다 (안건 저장·엑셀 업로드로 지워지지 않게)."""
    for k in MEETING_STAGES:
        new["stages"][k]["meetings"] = old["stages"][k]["meetings"]


def normalize_stage(key: str, v: Any) -> Dict[str, Any]:
    """단계: 목표일(target) / 완료일(doneAt) / 연장 이력. 예전 형식의 date 는 완료면 완료일, 아니면 목표일로 옮긴다."""
    v = v if isinstance(v, dict) else {}
    skipped = bool(v.get("skipped")) and key not in ("step1", "step5")
    done = bool(v.get("done")) and not skipped
    target, done_at = _date(v.get("target")), _date(v.get("doneAt"))
    legacy = _date(v.get("date"))
    if legacy and not target and not done_at:
        if done:
            done_at = legacy
        else:
            target = legacy
    exts = []
    for e in v.get("extensions") or []:
        if isinstance(e, dict) and _date(e.get("to")):
            exts.append({"from": _date(e.get("from")), "to": _date(e.get("to")), "reason": _text(e.get("reason"))[:500],
                         "by": _s(e.get("by"))[:40], "at": _s(e.get("at"))[:19]})
    return {
        "done": done, "skipped": skipped,
        "doneAt": done_at if done else "",
        "target": "" if skipped else target,
        "targetAuto": bool(v.get("targetAuto")) and not exts,
        "targetOriginal": _date(v.get("targetOriginal")) or (exts[0]["from"] if exts else ""),
        "extensions": exts,
        "meetings": normalize_meetings(v.get("meetings")) if key in MEETING_STAGES else [],
    }


def add_business_days(start: str, n: int, holidays: Optional[set] = None) -> str:
    """start 다음 날부터 주말·휴일을 빼고 n 영업일째 되는 날."""
    d = dt.date.fromisoformat(start)
    holidays = holidays or set()
    count = 0
    while count < n:
        d += dt.timedelta(days=1)
        if d.weekday() < 5 and d.isoformat() not in holidays:
            count += 1
    return d.isoformat()


def apply_stage_targets(item: Dict[str, Any], holidays: Optional[set] = None) -> None:
    """현재 진행 단계의 목표일을 자동 계산 (프론트엔드 static/app.js applyStageTargets 와 같은 규칙).
    - 1단계: 접수 승인일 + 5 영업일 / 이후: 직전(생략 제외) 단계 완료일 + 7 영업일
    - 관리자가 연장·지정한 목표일(targetAuto=False)은 덮어쓰지 않는다."""
    if not item.get("accepted", True):
        return
    base = item.get("acceptedAt", "")
    for k in STAGE_KEYS:
        st = item["stages"][k]
        if st["skipped"]:
            continue
        if st["done"]:
            base = st["doneAt"] or ""
            continue
        if st["targetAuto"] or not st["target"]:
            if base:
                st["target"], st["targetAuto"] = add_business_days(base, STAGE_LEAD_DAYS[k], holidays), True
            elif st["targetAuto"]:
                st["target"], st["targetAuto"] = "", False
        base = ""  # 이 단계가 끝나야 다음 단계 목표일이 생긴다


def normalize_item(raw: Dict[str, Any]) -> Dict[str, Any]:
    raw = raw if isinstance(raw, dict) else {}
    category = "기술" if raw.get("category") == "기술" else "제품"
    raw_stages = raw.get("stages") if isinstance(raw.get("stages"), dict) else {}
    stages = {k: normalize_stage(k, raw_stages.get(k)) for k in STAGE_KEYS}
    item_id = re.sub(r"[^A-Za-z0-9_\-]", "_", _s(raw.get("id")))[:64] or ("TR-" + secrets.token_hex(4))
    reviews = normalize_review_cards(raw)
    if isinstance(raw.get("reviews"), dict):
        seen, tasks = set(), []
        for t in (normalize_task(x) for x in (raw.get("tasks") or [])):
            if t and t["id"] not in seen:
                seen.add(t["id"])
                tasks.append(t)
        # 결정은 '과제' 인데 과제가 없으면 결정 취소 상태로 되돌린다 (데이터 정합성)
        for rv in reviews.values():
            for r in rv["risks"]:
                if r["decision"] == "task" and r["taskId"] not in seen:
                    r.update(decision="", taskId="")
    else:
        _, tasks = migrate_legacy_risks(raw.get("risks") or [])
    # 같은 Risk ID 가 중복되면 새 번호 부여
    used: List[str] = []
    for rv in reviews.values():
        for r in rv["risks"]:
            if not RISK_ID_RE.match(r["id"]) or r["id"] in used:
                r["id"] = next_seq_id("R", used + [x["id"] for v in reviews.values() for x in v["risks"]])
            used.append(r["id"])
    for t in tasks:  # 과제 출처 팀 (이전 버전 과제는 '(기존) 부문')
        if not t["team"]:
            t["team"] = next((name for name, c in reviews.items() if any(r["taskId"] == t["id"] for r in c["risks"])), "")
    attachments = [a for a in (normalize_attachment(x) for x in (raw.get("attachments") or [])) if a]
    return {
        "id": item_id,
        "category": category,
        "npSp": "" if category == "기술" else ("SP" if _s(raw.get("npSp")).upper() == "SP" else "NP"),
        "productSize": _s(raw.get("productSize")) if _s(raw.get("productSize")) in PRODUCT_SIZES else "",
        "productType": _s(raw.get("productType")).upper() if _s(raw.get("productType")).upper() in PRODUCT_TYPES else "",
        "title": _s(raw.get("title")),
        "requester": _s(raw.get("requester")),
        "requesterDept": _s(raw.get("requesterDept")),
        "requesterEmail": (_emails(raw.get("requesterEmail")) or [""])[0],
        "proposalDate": _date(raw.get("proposalDate")),
        "summary": _text(raw.get("summary")),
        "note": _text(raw.get("note")),
        # 기존 data.js 로 이관된 안건은 이미 접수된 것으로 본다.
        "accepted": bool(raw.get("accepted", True)),
        "acceptedAt": _date(raw.get("acceptedAt")),
        "source": _s(raw.get("source")) or "관리자",
        "stages": stages,
        "reviews": reviews,
        "tasks": tasks,
        "attachments": attachments,
        "notify": raw.get("notify") if isinstance(raw.get("notify"), dict) else None,
        "remindLog": [{k: _s(x.get(k))[:300] for k in ("kind", "key", "to", "at", "by")}
                      for x in (raw.get("remindLog") or []) if isinstance(x, dict)][-200:],
        "applicantEmpId": _s(raw.get("applicantEmpId")),
        "audit": normalize_audit(raw.get("audit")),
        "finalNotify": raw.get("finalNotify") if isinstance(raw.get("finalNotify"), dict) else None,
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
    return {"doneAt": date, "done": True} if done else {"target": date, "skipped": skipped}


def _risk(sector, reviewer, item="", task="X", grade="", plan="", org="", sched="", status="진행중", no_risk=False):
    return {"sector": sector, "reviewer": reviewer, "noRisk": no_risk, "riskItem": item, "isTask": task,
            "grade": grade, "planContent": plan, "org": org, "schedule": sched, "status": status}


def sample_items() -> List[Dict[str, Any]]:
    year = dt.date.today().year
    d = lambda md: f"{year}-{md}"  # noqa: E731
    items = [
        {
            "id": f"TR-{year}-001", "category": "제품", "npSp": "NP", "productSize": "300mm", "productType": "EPI", "accepted": True, "source": "신청",
            "title": "차세대 고방열 SiC 전력반도체 모듈 (Gen-4)",
            "requester": "김민수 수석", "requesterDept": "선행패키지개발팀", "requesterEmail": "minsu.kim@example.com",
            "proposalDate": d("01-15"), "acceptedAt": d("01-16"),
            "summary": "Gen-3 대비 방열 기판을 AMB(Si3N4)로 변경하고 소결 접합(Ag Sintering)을 신규 적용.\n열저항 18% 개선, 신뢰성(TC 1,000cyc) 평가 완료.",
            "note": "검증소위원회 완료 후 전문위원 검토 진행 중. 방열 기판 보이드율 3% 이하 관리 기준 점검 필요.",
            "stages": {"step1": _st(d("01-22"), True),
                       "step2": {**_st(d("02-05"), True), "meetings": [
                           {"no": 1, "date": d("01-29"), "result": "재심의", "note": "열특성 데이터 보완 후 재상정"},
                           {"no": 2, "date": d("02-05"), "result": "통과", "note": "보완 데이터 확인, Risk 과제화"}]},
                       "step3": _st(d("10-20")),
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
            "id": f"TR-{year}-002", "category": "제품", "npSp": "SP", "productSize": "200mm", "productType": "PW", "accepted": True, "source": "신청",
            "title": "전장용 통합 카메라 센서 모듈 파생형 (SP-220)",
            "requester": "이수진 책임", "requesterDept": "전장개발2팀", "requesterEmail": "sujin.lee@example.com",
            "proposalDate": d("02-10"), "acceptedAt": d("02-10"),
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
            "proposalDate": d("04-08"), "acceptedAt": d("04-09"),
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
            "id": f"TR-{year}-004", "category": "제품", "npSp": "NP", "productSize": "300mm", "productType": "PW", "accepted": False, "source": "신청",
            "title": "고전압 BMS용 절연 게이트 드라이버 IC 패키지",
            "requester": "최유나 선임", "requesterDept": "제품개발3팀", "requesterEmail": "yuna.choi@example.com",
            "proposalDate": today_str(),
            "summary": "SOIC-16W → 신규 절연 패키지(Creepage 8mm) 적용.\n검증보고서 및 패키지 도면은 별도 송부 예정.",
            "note": "", "stages": {k: _st() for k in STAGE_KEYS},
            "risks": default_risk_rows(),
        },
        {
            "id": f"TR-{year - 1}-001", "category": "제품", "npSp": "SP", "productSize": "200mm", "productType": "EPI", "accepted": True, "source": "관리자",
            "title": "산업용 IGBT 모듈 62mm 표준형 (2차 파생)",
            "requester": "정해성 수석", "requesterDept": "전력모듈개발팀", "requesterEmail": "haesung.jung@example.com",
            "proposalDate": f"{year - 1}-09-03", "acceptedAt": f"{year - 1}-09-03",
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
        "holidays": [],
        "reviewMatrix": copy.deepcopy(DEFAULT_REVIEW_MATRIX),
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
            teams = normalize_teams(base.get("teams"))
            if not teams or {t["name"] for t in teams} == OLD_SAMPLE_TEAMS:
                teams = copy.deepcopy(DEFAULT_TEAMS)
            base["teams"] = teams
            base["reviewMatrix"] = normalize_matrix(base.get("reviewMatrix"))
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
# ---------------------------------------------------------------------------
# Outlook 연동 진단
#  - 0x80080005(CO_E_SERVER_EXEC_FAILURE): 서버와 Outlook 의 실행 권한(관리자/일반)이 다르거나
#    Outlook 이 시작 중이라 응답하지 못할 때 발생 → 실행 중인 Outlook 에 먼저 붙고, 실패하면 재시도.
# ---------------------------------------------------------------------------
OUTLOOK_LOCK = threading.Lock()  # Outlook COM 호출은 한 번에 하나씩


def is_elevated() -> bool:
    if os.name != "nt":
        return False
    try:
        import ctypes
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except Exception:  # noqa: BLE001
        return False


def pywin32_status() -> Tuple[bool, str]:
    try:
        import pythoncom  # noqa: F401
        import win32com.client  # noqa: F401
        return True, "pywin32 사용"
    except Exception as e:  # noqa: BLE001
        return False, f"pywin32 없음 → PowerShell 사용 ({type(e).__name__}: {e})"


def uac_enabled() -> Optional[bool]:
    """UAC(사용자 계정 컨트롤) 켜짐 여부. 꺼져 있으면 모든 프로그램이 관리자 권한으로 실행된다."""
    if os.name != "nt":
        return None
    try:
        import winreg
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System") as k:
            return bool(winreg.QueryValueEx(k, "EnableLUA")[0])
    except OSError:
        return None


def outlook_running() -> Optional[bool]:
    if os.name != "nt":
        return None
    try:
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq OUTLOOK.EXE", "/NH"], capture_output=True, timeout=10,
                             creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0)).stdout
        return b"OUTLOOK.EXE" in out.upper()
    except (OSError, subprocess.SubprocessError):
        return None


def mail_diagnostics() -> Dict[str, Any]:
    ok, msg = pywin32_status()
    return {
        "platform": "Windows" if os.name == "nt" else sys.platform,
        "python": sys.executable,
        "pywin32": ok,
        "outlookMethod": msg if os.name == "nt" else "Windows가 아니어서 Outlook 사용 불가",
        "elevated": is_elevated(),
        "uac": uac_enabled(),
        "outlookRunning": outlook_running(),
    }


def explain_outlook_error(e: Exception) -> str:
    text = str(e)
    code = ""
    if getattr(e, "args", None) and isinstance(e.args[0], int):  # pywintypes.com_error
        code = hex(e.args[0] & 0xFFFFFFFF)
    if "80080005" in text or code == "0x80080005":
        if outlook_running() is False:
            hint = "Outlook 이 꺼져 있습니다. 서버 PC에서 Outlook 을 먼저 켜 두고 다시 시도하세요."
        elif is_elevated():
            hint = "서버가 관리자 권한으로 실행 중이라 Outlook 에 연결하지 못했습니다."
        else:
            hint = "Outlook 이 관리자 권한으로 실행 중이거나 시작 중입니다. Outlook 을 완전히 종료한 뒤 다시 켜 두고 재시도하세요."
        return f"Outlook 연결 실패(0x80080005). {hint}"
    if "80040154" in text or code == "0x80040154":
        return "클래식 Outlook 이 설치되어 있지 않습니다. ('새 Outlook' 앱은 자동 발송을 지원하지 않습니다 → SMTP 설정 사용)"
    if "8004010f" in text.lower() or code == "0x8004010f":
        return "Outlook 프로필/계정에 접근할 수 없습니다. Outlook 을 한 번 직접 실행해 로그인해 두세요."
    return text


def outlook_mail(to: List[str], cc: List[str], subject: str, html_body: str, display: bool) -> None:
    if os.name != "nt":
        raise RuntimeError("Outlook 연동은 Windows 서버 PC에서만 가능합니다.")
    with OUTLOOK_LOCK:
        try:
            _outlook_direct(to, cc, subject, html_body, display)
            return
        except Exception as first:  # noqa: BLE001
            if is_elevated():
                # 서버가 관리자 권한이면 일반 권한 Outlook 에 붙을 수 없다(0x80080005).
                # → 탐색기(일반 권한)를 통해 별도 작업으로 실행한다.
                try:
                    _outlook_via_explorer(to, cc, subject, html_body, display)
                    return
                except Exception as second:  # noqa: BLE001
                    raise RuntimeError(f"{explain_outlook_error(first)} / 일반 권한 우회 실행도 실패: {second}")
            time.sleep(4)  # Outlook 이 막 켜지는 중이면 잠시 후 한 번 더
            try:
                _outlook_direct(to, cc, subject, html_body, display)
                return
            except Exception as e:  # noqa: BLE001
                raise RuntimeError(explain_outlook_error(e))


def _outlook_direct(to: List[str], cc: List[str], subject: str, html_body: str, display: bool) -> None:
    if pywin32_status()[0]:
        _outlook_pywin32(to, cc, subject, html_body, display)
    else:
        _outlook_powershell(to, cc, subject, html_body, display)


PS_OUTLOOK_JOB = r"""
$ErrorActionPreference = 'Stop'
$res = '{result}'
try {{
  $p = Get-Content -Raw -Encoding UTF8 -LiteralPath '{data}' | ConvertFrom-Json
  $o = $null
  try {{ $o = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application') }} catch {{ $o = $null }}
  if (-not $o) {{ $o = New-Object -ComObject Outlook.Application }}
  $m = $o.CreateItem(0)
  $m.To = $p.to; $m.CC = $p.cc; $m.Subject = $p.subject; $m.HTMLBody = $p.html
  if ($p.display) {{ $m.Display($false) }} else {{ $m.Send() }}
  Set-Content -LiteralPath $res -Value 'OK' -Encoding UTF8
}} catch {{
  Set-Content -LiteralPath $res -Value ('ERR ' + $_.Exception.Message) -Encoding UTF8
}}
"""


def _mail_job_dir() -> Path:
    for base in (os.environ.get("PUBLIC"), tempfile.gettempdir()):
        if base:
            d = Path(base) / "transfer_portal_mail"
            try:
                d.mkdir(parents=True, exist_ok=True)
                return d
            except OSError:
                continue
    raise RuntimeError("메일 작업 폴더를 만들 수 없습니다.")


def _outlook_via_explorer(to: List[str], cc: List[str], subject: str, html_body: str, display: bool) -> None:
    """explorer.exe 로 .cmd 를 열면 탐색기(일반 권한)가 실행하므로, 관리자 권한 서버에서도 Outlook 에 연결된다."""
    d = _mail_job_dir()
    jid = secrets.token_hex(6)
    data, result, ps1, cmd = (d / f"{jid}.json", d / f"{jid}.result.txt", d / f"{jid}.ps1", d / f"{jid}.cmd")
    try:
        data.write_text(json.dumps({"to": "; ".join(to), "cc": "; ".join(cc), "subject": subject, "html": html_body,
                                    "display": display}, ensure_ascii=False), encoding="utf-8")
        ps1.write_text(PS_OUTLOOK_JOB.format(result=str(result).replace("'", "''"), data=str(data).replace("'", "''")),
                       encoding="utf-8-sig")
        # 실행 정책에 막히지 않도록 -File 대신 스크립트 내용을 -Command 로 실행
        loader = f"& ([ScriptBlock]::Create((Get-Content -Raw -Encoding UTF8 -LiteralPath '{ps1}')))"
        with open(cmd, "w", encoding="mbcs" if os.name == "nt" else "utf-8", newline="") as f:
            f.write(f'@echo off\r\nstart "" /min powershell -NoProfile -WindowStyle Hidden -Command "{loader}"\r\n')
        subprocess.Popen(["explorer.exe", str(cmd)])
        deadline = time.time() + 60
        while time.time() < deadline:
            if result.exists():
                time.sleep(0.3)
                text = result.read_text(encoding="utf-8-sig", errors="replace").strip()
                if text == "OK":
                    return
                raise RuntimeError(text[4:] if text.startswith("ERR ") else text)
            time.sleep(0.5)
        raise RuntimeError("60초 안에 응답이 없습니다. (회사 보안 정책으로 PowerShell 실행이 막혔을 수 있습니다)")
    finally:
        for f in (data, result, ps1, cmd):
            try:
                f.unlink()
            except OSError:
                pass


def _outlook_pywin32(to: List[str], cc: List[str], subject: str, html_body: str, display: bool) -> None:
    import pythoncom
    import win32com.client

    pythoncom.CoInitialize()
    try:
        try:  # 이미 켜져 있는 Outlook 에 연결 (새로 띄우는 것보다 권한 문제가 적다)
            outlook = win32com.client.GetActiveObject("Outlook.Application")
        except Exception:  # noqa: BLE001
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


PS_OUTLOOK = (
    "$ErrorActionPreference='Stop'; "
    "$p = Get-Content -Raw -Encoding UTF8 -LiteralPath $env:PORTAL_MAIL_JSON | ConvertFrom-Json; "
    "$o = $null; "
    "try { $o = [Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application') } catch { $o = $null }; "
    "if (-not $o) { $o = New-Object -ComObject Outlook.Application }; "
    "$m = $o.CreateItem(0); "
    "$m.To = $p.to; $m.CC = $p.cc; $m.Subject = $p.subject; $m.HTMLBody = $p.html; "
    "if ($p.display) { $m.Display($false) } else { $m.Send() }"
)


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


def smtp_sender(settings: Dict[str, Any]) -> str:
    cfg = settings.get("smtp") or {}
    for cand in (_s(cfg.get("sender")), _s(cfg.get("username")), *(settings.get("secretaryEmails") or [])):
        if "@" in cand:
            return cand
    return ""


def explain_smtp_error(e: Any, stage: str = "") -> str:
    """SMTP 오류 → 원인과 해결 방법 (한국어)."""
    code, text = None, str(e)
    if isinstance(e, tuple):  # (code, message)
        code, text = e[0], (e[1].decode("utf-8", "replace") if isinstance(e[1], bytes) else str(e[1]))
    elif isinstance(e, smtplib.SMTPResponseException):
        code, text = e.smtp_code, (e.smtp_error.decode("utf-8", "replace") if isinstance(e.smtp_error, bytes) else str(e.smtp_error))
    elif isinstance(e, smtplib.SMTPRecipientsRefused):
        first = next(iter(e.recipients.values()), None)
        if first:
            return explain_smtp_error(first, "rcpt")
    low = text.lower()
    raw = f" [서버 응답: {code} {text.strip()[:160]}]" if code else f" [{type(e).__name__}: {text[:160]}]"
    if isinstance(e, (socket.timeout, TimeoutError)) or "timed out" in low:
        return ("연결 시간 초과 - 서버 PC에서 SMTP 서버로 나가는 연결이 막혀 있습니다. 회사 백신의 '대량 메일 웜 차단' 기능이 "
                "Outlook 외 프로그램(python.exe)의 25번 포트 사용을 막는 경우가 많습니다. IT팀에 '서버 PC의 python.exe 25번 포트 허용'을 요청하세요." + raw)
    if isinstance(e, ConnectionRefusedError) or "refused" in low and code is None:
        return "연결 거부 - 주소나 포트가 틀렸거나 SMTP 서버가 이 포트를 쓰지 않습니다. 주소·포트를 다시 확인하세요." + raw
    if isinstance(e, smtplib.SMTPServerDisconnected):
        return "서버가 연결을 끊었습니다 - 서버 PC IP가 SMTP 서버의 허용 목록에 없을 수 있습니다. IT팀에 서버 PC IP 등록을 요청하세요." + raw
    if isinstance(e, smtplib.SMTPAuthenticationError) or code == 535:
        return ("로그인 실패 - 계정 또는 비밀번호가 틀렸습니다. Exchange 메일이면 계정을 '도메인\\사번' 또는 '메일주소' 형식으로 "
                "바꿔서 시도해 보세요." + raw)
    if isinstance(e, smtplib.SMTPNotSupportedError) or "no suitable authentication" in low or "auth extension not supported" in low:
        return ("이 SMTP 서버는 계정 로그인을 받지 않습니다(또는 지원하지 않는 방식). 계정·비밀번호 칸을 비우고 다시 시도하세요. "
                "STARTTLS 를 켜야 로그인이 열리는 서버도 있습니다." + raw)
    if code == 530 and "starttls" in low:
        return "암호화 연결이 필요합니다 - [STARTTLS] 를 체크하고 다시 시도하세요." + raw
    if code in (530, 550, 554) and ("auth" in low or "5.7.57" in low or "5.7.0" in low and stage != "connect"):
        return "인증 필요 - 이 서버는 계정 로그인 후에만 보낼 수 있습니다. 계정(메일주소 또는 도메인\\사번)과 비밀번호를 입력하세요." + raw
    if stage == "mail" or isinstance(e, smtplib.SMTPSenderRefused) or "5.7.60" in low or "send as" in low:
        return ("발신자 주소 거부 - 발신자 주소를 실제 회사 메일 주소로 입력하세요. 로그인 없이 회사 주소로 보내는 것을 막는 서버면 "
                "그 주소의 계정·비밀번호로 로그인해야 합니다." + raw)
    if stage == "rcpt" or "relay" in low or "5.7.1" in low:
        return ("수신자 거부(릴레이 불가) - 로그인 없이는 이 주소로 보낼 수 없습니다. 계정·비밀번호를 입력하거나, IT팀에 "
                "'서버 PC IP의 SMTP 릴레이 허용'을 요청하세요." + raw)
    if code == 421:
        return "서버가 일시적으로 거부했습니다(연결 수 제한 등). 잠시 후 다시 시도하세요." + raw
    return "SMTP 발송 실패" + raw


def smtp_mail(settings: Dict[str, Any], to: List[str], cc: List[str], subject: str, html_body: str, text_body: str) -> None:
    cfg = settings.get("smtp") or {}
    host = _s(cfg.get("host"))
    if not host:
        raise RuntimeError("SMTP 서버가 설정되지 않았습니다.")
    sender = smtp_sender(settings)
    if not sender:
        raise RuntimeError("SMTP 발신자 주소가 설정되지 않았습니다. (메일 발송 설정의 '발신자 주소'에 회사 메일 주소 입력)")
    msg = EmailMessage()
    msg["From"] = sender
    msg["To"] = ", ".join(to)
    if cc:
        msg["Cc"] = ", ".join(cc)
    msg["Subject"] = subject
    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")
    try:
        with smtplib.SMTP(host, int(cfg.get("port") or 25), timeout=15) as server:
            if cfg.get("useTls"):
                server.starttls()
            if _s(cfg.get("username")) and cfg.get("password"):
                server.login(_s(cfg.get("username")), str(cfg.get("password")))
            server.send_message(msg)
    except Exception as e:  # noqa: BLE001
        raise RuntimeError(explain_smtp_error(e))


def smtp_diagnose(settings: Dict[str, Any], to: List[str]) -> Dict[str, Any]:
    """SMTP 를 단계별로 시험해 어디서 막히는지 알려준다 (실제 테스트 메일 1통 발송)."""
    cfg = settings.get("smtp") or {}
    host, port = _s(cfg.get("host")), int(cfg.get("port") or 25)
    steps: List[Dict[str, Any]] = []

    def add(name: str, ok: bool, detail: str) -> bool:
        steps.append({"step": name, "ok": ok, "detail": detail})
        return ok

    def result() -> Dict[str, Any]:
        return {"ok": all(x["ok"] for x in steps), "steps": steps}

    if not host:
        add("설정 확인", False, "SMTP 호스트가 비어 있습니다.")
        return result()
    sender = smtp_sender(settings)
    if not sender:
        add("설정 확인", False, "발신자 주소가 없습니다. '발신자 주소'에 회사 메일 주소를 입력하세요.")
        return result()
    add("설정 확인", True, f"서버 {host}:{port} · 발신자 {sender} · 수신자 {', '.join(to)} · "
                         f"로그인 {'사용 (' + _s(cfg.get('username')) + ')' if _s(cfg.get('username')) else '안 함'} · STARTTLS {'사용' if cfg.get('useTls') else '안 함'}")
    server = smtplib.SMTP(timeout=10)
    try:
        try:
            code, banner = server.connect(host, port)
        except Exception as e:  # noqa: BLE001
            add("1. 서버 연결", False, explain_smtp_error(e, "connect"))
            return result()
        add("1. 서버 연결", True, f"연결됨 - {code} {banner.decode('utf-8', 'replace')[:120] if isinstance(banner, bytes) else banner}")
        try:
            code, _ = server.ehlo()
            if code != 250:
                server.helo()
        except Exception as e:  # noqa: BLE001
            add("2. 인사(EHLO)", False, explain_smtp_error(e, "ehlo"))
            return result()
        auth = _s(server.esmtp_features.get("auth"))
        add("2. 인사(EHLO)", True, f"STARTTLS 지원: {'예' if server.has_extn('starttls') else '아니오'} · "
                                 f"지원 로그인 방식: {auth or '없음 (이 연결에서는 로그인 불가 → 계정 없이 보내는 서버일 가능성)'}")
        if cfg.get("useTls"):
            try:
                server.starttls()
                server.ehlo()
                auth = _s(server.esmtp_features.get("auth"))
                add("3. STARTTLS", True, f"암호화 연결 성공 · 로그인 방식: {auth or '없음'}")
            except Exception as e:  # noqa: BLE001
                add("3. STARTTLS", False, explain_smtp_error(e, "tls"))
                return result()
        if _s(cfg.get("username")):
            if not cfg.get("password"):
                add("4. 로그인", False, "계정은 입력했는데 비밀번호가 없습니다.")
                return result()
            try:
                server.login(_s(cfg.get("username")), str(cfg.get("password")))
                add("4. 로그인", True, "로그인 성공")
            except Exception as e:  # noqa: BLE001
                hint = ""
                if auth and not re.search(r"\b(LOGIN|PLAIN|CRAM-MD5)\b", auth.upper()):
                    hint = f" (서버가 지원하는 방식이 {auth} 뿐이라 일반 계정 로그인이 불가합니다 → 계정 칸을 비우고 시도하거나 IT팀에 릴레이 허용 요청)"
                add("4. 로그인", False, explain_smtp_error(e, "login") + hint)
                return result()
        else:
            add("4. 로그인", True, "계정 미입력 → 로그인 없이 진행")
        code, resp = server.mail(sender)
        if code != 250:
            add("5. 발신자 확인", False, explain_smtp_error((code, resp), "mail"))
            return result()
        add("5. 발신자 확인", True, f"{code} 발신자 허용")
        for r in to:
            code, resp = server.rcpt(r)
            if code not in (250, 251):
                add("6. 수신자 확인", False, f"{r}: " + explain_smtp_error((code, resp), "rcpt"))
                return result()
        add("6. 수신자 확인", True, "수신자 허용")
        msg = EmailMessage()
        msg["From"], msg["To"], msg["Subject"] = sender, ", ".join(to), "[양산이관 검증위원회] SMTP 진단 테스트"
        msg.set_content(f"SMTP 진단 테스트 메일입니다. ({now_str()})")
        code, resp = server.data(msg.as_bytes())
        if code != 250:
            add("7. 메일 전송", False, explain_smtp_error((code, resp), "data"))
            return result()
        add("7. 메일 전송", True, f"{code} 전송 완료 - 받은편지함을 확인하세요")
    except Exception as e:  # noqa: BLE001
        add("진행 중 오류", False, explain_smtp_error(e))
    finally:
        try:
            server.quit()
        except Exception:  # noqa: BLE001
            server.close()
    return result()


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
    for u in store.users().values():
        if u.get("status") == "approved" and u.get("email"):
            book.setdefault(u["email"].lower(), {"sector": f"{team_info(settings, u.get('team', ''))['sector'] or '-'} · {u.get('team', '')}",
                                                 "name": u.get("name", ""), "title": u.get("title", "")})
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


def build_team_done_mail(item: Dict[str, Any], team: str, user: Dict[str, Any], settings: Dict[str, Any]) -> Dict[str, Any]:
    base = portal_base(settings)
    link = f"{base}#items/{quote(item['id'])}"
    who = f"{user['team']} {user['name']} {user.get('title', '')}".strip()
    rv = item["reviews"][team]
    sector = rv["sector"]
    subject = f"[양산이관 검토완료] {sector} · {team} - {item['title']} ({who})"
    th = 'style="background:#f1f5f9;border:1px solid #cbd5e1;padding:6px 8px;font-size:12.5px;text-align:left;"'
    td = 'style="border:1px solid #cbd5e1;padding:6px 8px;font-size:12.5px;vertical-align:top;"'
    comment = f'<p style="background:#f8fafc;border-left:4px solid #94a3b8;padding:8px 10px;">💬 {_br(rv["comment"])}</p>' if rv["comment"] else ""
    if rv["result"] == "ok":
        table = '<p style="font-size:14px;color:#15803d;font-weight:bold;">✅ 이상 없음</p>' + comment
    else:
        body_rows = "".join(
            f"<tr><td {td}>{i + 1}</td><td {td}>{_br(r['content'])}</td><td {td}>{_br(r['proposal'])}</td></tr>"
            for i, r in enumerate(rv["risks"])
        ) or f'<tr><td {td} colspan="3">작성된 Risk 가 없습니다.</td></tr>'
        table = (
            '<p style="font-size:14px;color:#b91c1c;font-weight:bold;">⚠️ Risk 있음</p>'
            '<table style="border-collapse:collapse;width:100%;max-width:900px;margin:8px 0 16px;">'
            f"<tr><th {th}>#</th><th {th}>예상 Risk</th><th {th}>제안 보완 방안</th></tr>{body_rows}</table>"
        ) + comment
    inner = (
        f"<p><b>{html.escape(who)}</b> 님이 <b>{html.escape(sector)} · {html.escape(team)}</b> 검토 의견을 작성 완료했습니다.</p>"
        + _mail_table([("안건 ID", html.escape(item["id"])), ("구분", html.escape(category_label(item))),
                       ("제품/기술명", f"<b>{html.escape(item['title'])}</b>"), ("현재 단계", html.escape(stage_label(item)))])
        + f'<p style="font-weight:bold;">■ {html.escape(team)} 검토 의견</p>' + table
        + f'<p>▶ 안건 상세 보기: <a href="{html.escape(link)}">{html.escape(link)}</a></p>'
    )
    text = f"{who} 님이 {sector} · {team} 검토 의견을 작성 완료했습니다.\n안건: {item['title']} ({item['id']})\n{link}\n"
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


def notify_team_done(item_id: str, team: str, user: Dict[str, Any]) -> None:
    settings = store.settings()
    try:
        mail = build_team_done_mail(find_item(store.load(), item_id), team, user, settings)
        result = mail_to_secretary(mail["subject"], mail["html"], mail["text"], settings)
    except Exception as e:  # noqa: BLE001
        result = {"status": "failed", "message": str(e)[:300]}
    print(f"[mail] {item_id} {team} 작성 완료 알림: {result['status']} - {result['message']}")


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
    return {"criteria": s["criteria"], "sectors": SECTORS, "teams": s["teams"], "holidays": holiday_list(s),
            "reviewMatrix": s["reviewMatrix"],
            "leadDays": STAGE_LEAD_DAYS}


def holiday_list(s: Dict[str, Any]) -> List[str]:
    return sorted({d for d in (_date(x) for x in (s.get("holidays") or [])) if d})


def holiday_set() -> set:
    return set(holiday_list(store.settings()))


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
        "nameUrls": [f"http://{n}:{PORT}/" for n in host_names()],
        "mailDiag": mail_diagnostics(),
        "holidays": holiday_list(s),
        "reviewMatrix": s["reviewMatrix"],
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
    if isinstance(payload.get("reviewMatrix"), dict):
        s["reviewMatrix"] = normalize_matrix(payload["reviewMatrix"])
    if "holidays" in payload:
        raw = payload["holidays"]
        s["holidays"] = holiday_list({"holidays": raw if isinstance(raw, list) else re.split(r"[\s,;]+", _s(raw))})
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


def _settings_with_form(payload: Dict[str, Any]) -> Dict[str, Any]:
    """[테스트] 버튼: 저장하지 않은 입력값으로도 시험할 수 있게 현재 설정에 덮어쓴다(저장은 안 함)."""
    s = store.settings()
    p = payload.get("smtp")
    if isinstance(p, dict):
        try:
            port = int(p.get("port") or 25)
        except ValueError:
            raise HTTPException(400, "SMTP 포트는 숫자여야 합니다.")
        s["smtp"].update({"host": _s(p.get("host")), "port": port, "useTls": bool(p.get("useTls")),
                          "username": _s(p.get("username")), "sender": _s(p.get("sender"))})
        if p.get("password"):
            s["smtp"]["password"] = str(p["password"])
    return s


def h_mail_test(req: Req):
    payload = req.json()
    s = _settings_with_form(payload)
    to = _emails(payload.get("to")) or _emails(s["secretaryEmails"])
    if not to:
        raise HTTPException(400, "테스트 메일을 받을 주소를 입력하세요. (비우면 간사 이메일로 보냅니다)")
    if payload.get("method") == "smtp":
        diag = smtp_diagnose(s, to)
        diag["message"] = (f"SMTP로 {', '.join(to)} 에 발송했습니다." if diag["ok"]
                           else "SMTP 발송 실패 - 아래 진단 결과를 확인하세요.")
        return diag
    subject = "[양산이관 검증위원회] 메일 발송 테스트"
    body = _mail_wrap("메일 발송 테스트", f"<p>포털 메일 발송 테스트입니다. ({now_str()})</p>")
    try:
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
    if not matrix_key(f.get("productSize", ""), _s(f.get("productType")).upper()):
        raise HTTPException(400, "구경(300mm/200mm)과 PW/EPI 를 선택하세요.")

    def _create(data):
        item = normalize_item({
            "id": next_item_id(data["items"], p_date[:4]), "category": f.get("category", "제품"), "npSp": f.get("npSp", "NP"),
            "title": title[:200], "requester": requester[:100], "requesterDept": dept[:100],
            "requesterEmail": email, "proposalDate": p_date, "summary": (f.get("summary") or "")[:5000],
            "productSize": f.get("productSize", ""), "productType": f.get("productType", ""),
            "accepted": False, "source": "신청", "stages": {}, "reviews": {}, "tasks": [],
            "applicantEmpId": user["empId"] if user else "",
            "notify": {"status": "pending", "message": "알림 메일 발송 대기", "at": now_str()},
        })
        add_audit(item, f"{dept} {requester}".strip(), "양산이관 신청 등록")
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
        for keep in ("attachments", "notify", "createdAt", "source", "applicantEmpId", "remindLog", "audit", "finalNotify"):
            merged[keep] = cur[keep]
        keep_meetings(merged, cur)
        keep_task_tracking(merged, cur, "관리자")
        # 접수 승인일은 서버가 기록 (처음 접수 처리된 날)
        merged["acceptedAt"] = cur["acceptedAt"] or (_date(incoming.get("acceptedAt")) or today_str() if merged["accepted"] else "")
        if not merged["accepted"]:
            merged["acceptedAt"] = ""
        # 카드의 작성 완료·이력은 서버가 관리 (관리자가 내용을 고치면 이력에 남김)
        for team, card in merged["reviews"].items():
            old = cur["reviews"].get(team)
            if old:
                card["done"], card["history"] = old["done"], old["history"]
                if (card["result"], card["comment"], card["risks"]) != (old["result"], old["comment"], old["risks"]):
                    card["history"] = (card["history"] + [{"at": now_str(), "by": "관리자", "action": "관리자 수정"}])[-50:]
            else:
                card["done"], card["history"] = None, [{"at": now_str(), "by": "관리자", "action": "검토 팀 선정"}]
        if merged["accepted"] and not cur["accepted"]:
            apply_review_matrix(merged, store.settings())
        apply_stage_targets(merged, holiday_set())
        if merged["stages"]["step5"]["done"] and not cur["stages"]["step5"]["done"] and open_tasks(merged, "상"):
            raise HTTPException(400, f"중요도 '상' 과제 {len(open_tasks(merged, '상'))}건이 완료되지 않아 최종승인할 수 없습니다.")
        if merged["accepted"] and not cur["accepted"]:
            add_audit(merged, "관리자", "접수 승인")
        add_audit(merged, "관리자", *diff_item(cur, merged))
        final["now"] = merged["stages"]["step5"]["done"] and not cur["stages"]["step5"]["done"]
        merged["rev"] = cur["rev"] + 1
        merged["updatedAt"] = now_str()
        data["items"][data["items"].index(cur)] = merged
        return merged
    final: Dict[str, bool] = {}
    item = store.mutate(_update)
    if final.get("now"):
        threading.Thread(target=notify_final, args=(item_id,), daemon=True).start()
    return item


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
        cur["acceptedAt"] = cur["acceptedAt"] or today_str()
        apply_review_matrix(cur, store.settings())
        apply_stage_targets(cur, holiday_set())
        add_audit(cur, "관리자", "접수 승인" + (f" · 검토 팀 {len(cur['reviews'])}팀 자동 선정" if cur["reviews"] else ""))
        cur["rev"] += 1
        cur["updatedAt"] = now_str()
        return cur
    return store.mutate(_accept)


def h_toggle_task(req: Req):
    def _toggle(data):
        cur = find_item(data, req.params["id"])
        t = next((x for x in cur["tasks"] if x["id"] == req.params["taskId"]), None)
        if not t:
            raise HTTPException(404, "과제를 찾을 수 없습니다.")
        set_task_done(t, t["status"] != "완료", "관리자")
        add_audit(cur, "관리자", f"과제 {t['id']} {'완료 처리' if t['status'] == '완료' else '진행중으로 변경'}")
        cur["rev"] += 1
        cur["updatedAt"] = now_str()
        return cur
    return store.mutate(_toggle)


def h_bulk_replace(req: Req):
    """엑셀(CSV) 업로드 결과 반영: 전달된 목록으로 전체 교체 (같은 ID 의 첨부/이력은 유지)."""
    incoming = req.json().get("items")
    if not isinstance(incoming, list):
        raise HTTPException(400, "items 목록이 필요합니다.")

    hol = holiday_set()

    def _bulk(data):
        cur = {i["id"]: i for i in data["items"]}
        out, seen = [], set()
        for raw in incoming:
            it = normalize_item(raw)
            apply_stage_targets(it, hol)
            if it["id"] in seen:
                it["id"] = it["id"] + "-" + secrets.token_hex(2)
            seen.add(it["id"])
            old = cur.get(it["id"])
            if old:
                for keep in ("attachments", "notify", "createdAt", "source", "applicantEmpId", "remindLog", "audit", "finalNotify"):
                    it[keep] = old[keep]
                keep_meetings(it, old)
                keep_task_tracking(it, old, "관리자")
                add_audit(it, "관리자", "엑셀 일괄 업로드로 갱신")
            else:
                add_audit(it, "관리자", "엑셀 일괄 업로드로 등록")
                it["rev"] = old["rev"] + 1
            it["updatedAt"] = now_str()
            out.append(it)
        data["items"] = out
        return len(out)
    return {"count": store.mutate(_bulk)}


def h_backup(req: Req):
    return FileResp(store.data_path, f"data_backup_{dt.datetime.now():%Y%m%d_%H%M}.json")


# --- 보완 과제: 담당자 진행 입력 · 완료 요청 / 관리자 승인 ------------------
def _find_task(item: Dict[str, Any], task_id: str) -> Dict[str, Any]:
    t = next((x for x in item["tasks"] if x["id"] == task_id), None)
    if not t:
        raise HTTPException(404, "과제를 찾을 수 없습니다.")
    return t


def is_task_owner(user: Optional[Dict[str, Any]], t: Dict[str, Any]) -> bool:
    if not user:
        return False
    if t["ownerEmpId"] and t["ownerEmpId"] == user["empId"]:
        return True
    return bool(t["ownerEmail"] and user.get("email") and t["ownerEmail"].lower() == user["email"].lower())


def user_label(user: Dict[str, Any]) -> str:
    return f"{user.get('team', '')} {user.get('name', '')} {user.get('title', '')}".strip()


def task_files_dir(item_id: str) -> Path:
    return store.item_dir(item_id) / "tasks"


def h_task_progress(req: Req):
    """과제 담당자(또는 관리자): 진행 상황·증빙 입력, 완료 요청."""
    item_id, task_id = req.params["id"], req.params["taskId"]
    user = req.user()
    f, files = req.form()
    note = _text(f.get("note"))[:5000]
    request = _s(f.get("request")) in ("1", "true")
    t0 = _find_task(find_item(store.load(), item_id), task_id)
    owner = is_task_owner(user, t0)
    if not req.is_admin and not owner:
        raise HTTPException(403, "이 과제의 담당자로 지정된 회원만 진행 상황을 입력할 수 있습니다.")
    if t0["status"] == "완료":
        raise HTTPException(400, "이미 완료된 과제입니다.")
    if not note and not files:
        raise HTTPException(400, "진행 내용 또는 증빙 파일을 입력하세요.")
    by = user_label(user) if owner else "관리자"
    saved = save_uploads(task_files_dir(item_id), files, by) if files else []

    def _save(data):
        cur = find_item(data, item_id)
        t = _find_task(cur, task_id)
        if t["status"] == "완료":
            raise HTTPException(400, "이미 완료된 과제입니다.")
        task_log(t, by, "request" if request else "progress", note, saved)
        if request:
            t["request"] = {"at": now_str(), "by": by, "empId": user["empId"] if owner else "", "note": note}
        add_audit(cur, by, f"과제 {task_id} " + ("완료 요청" if request else "진행 상황 입력") + (f" (증빙 {len(saved)}개)" if saved else ""))
        return _touch(cur)
    item = store.mutate(_save)
    if request:
        threading.Thread(target=notify_task_event, args=(item_id, task_id, "request", by, note), daemon=True).start()
    return item


def h_task_decide(req: Req):
    """관리자: 완료 요청 승인 / 반려(사유 필수)."""
    item_id, task_id = req.params["id"], req.params["taskId"]
    p = req.json()
    approve, comment = bool(p.get("approve")), _text(p.get("comment"))[:2000]

    def _decide(data):
        cur = find_item(data, item_id)
        t = _find_task(cur, task_id)
        if t["status"] == "완료":
            raise HTTPException(400, "이미 완료된 과제입니다.")
        if approve:
            set_task_done(t, True, "관리자", ("완료 요청 승인" if t["request"] else "완료 처리") + (f" — {comment}" if comment else ""))
        else:
            if not t["request"]:
                raise HTTPException(400, "완료 요청이 없는 과제입니다.")
            if not comment:
                raise HTTPException(400, "반려 사유를 입력하세요.")
            t["request"] = None
            task_log(t, "관리자", "reject", comment)
        add_audit(cur, "관리자", f"과제 {task_id} 완료 " + ("승인" if approve else f"요청 반려 (사유: {comment})"))
        return _touch(cur)
    item = store.mutate(_decide)
    threading.Thread(target=notify_task_event, args=(item_id, task_id, "approve" if approve else "reject", "관리자", comment), daemon=True).start()
    return item


def h_task_file(req: Req):
    return FileResp(_attachment_path(task_files_dir(req.params["id"]), req.params["name"]))


def notify_task_event(item_id: str, task_id: str, kind: str, by: str, note: str) -> None:
    """완료 요청 → 간사 / 승인·반려 → 담당자(참조 간사)."""
    settings = store.settings()
    try:
        item = find_item(store.load(), item_id)
        t = _find_task(item, task_id)
        link = f"{portal_base(settings)}#items/{quote(item['id'])}"
        sec = _emails(settings.get("secretaryEmails"))
        label = {"request": "완료 요청", "approve": "완료 승인", "reject": "완료 요청 반려"}[kind]
        if kind == "request":
            to, cc = sec, []
        else:
            to, cc = ([t["ownerEmail"]] if t["ownerEmail"] else []), sec
        if not to:
            print(f"[mail] 과제 {item_id}/{task_id} {label}: 받는 사람 없음")
            return
        subject = f"[보완과제 {label}] {task_id} {t['title'][:40]} - {item['title']}"
        inner = (f"<p>보완 과제 <b>{html.escape(task_id)}</b> — <b>{html.escape(label)}</b> ({html.escape(by)})</p>"
                 + _mail_table([("안건", f"<b>{html.escape(item['title'])}</b> ({html.escape(item['id'])})"),
                                ("과제", _br(t["title"])), ("중요도", html.escape(t["importance"])),
                                ("담당", html.escape(f"{t['org']} {t['ownerName']}".strip() or "-")),
                                ("목표일", html.escape(t["target"] or "-")),
                                ("내용" if kind == "request" else "의견", _br(note) or "-")])
                 + f'<p>▶ 안건 상세 보기: <a href="{html.escape(link)}">{html.escape(link)}</a></p>')
        text = f"보완 과제 {task_id} {label} ({by})\n안건: {item['title']} ({item['id']})\n{note}\n{link}\n"
        method = send_mail(settings, to, [c for c in cc if c.lower() not in {x.lower() for x in to}], subject,
                           _mail_wrap(f"보완 과제 {label}", inner), text)
        print(f"[mail] 과제 {item_id}/{task_id} {label}: {method}")
    except Exception as e:  # noqa: BLE001
        print(f"[mail] 과제 {item_id}/{task_id} {kind} 알림 실패: {e}")


# --- 최종승인 알림 (요청자 + 개발팀, 참조 간사) -----------------------------
def final_recipients(item: Dict[str, Any], settings: Dict[str, Any]) -> Tuple[List[str], List[str]]:
    users = store.users()
    teams = {item["requesterDept"]} if item["requesterDept"] else set()
    applicant = users.get(item["applicantEmpId"]) if item["applicantEmpId"] else None
    if applicant and applicant.get("team"):
        teams.add(applicant["team"])
    to: List[str] = [item["requesterEmail"]] if item["requesterEmail"] else []
    to += [u["email"] for u in users.values() if u.get("status") == "approved" and u.get("email") and u.get("team") in teams]
    seen, uniq_to = set(), []
    for e in to:
        if e.lower() not in seen:
            seen.add(e.lower())
            uniq_to.append(e)
    cc = [e for e in _emails(settings.get("secretaryEmails")) if e.lower() not in seen]
    return uniq_to, cc


def build_final_mail(item: Dict[str, Any], settings: Dict[str, Any]) -> Dict[str, Any]:
    link = f"{portal_base(settings)}#items/{quote(item['id'])}"
    rest = open_tasks(item)
    cond = " (조건부 승인)" if rest else ""
    subject = f"[양산이관 최종승인{cond}] {category_label(item)} {item['title']}"
    th = 'style="background:#f1f5f9;border:1px solid #cbd5e1;padding:6px 8px;font-size:12.5px;text-align:left;"'
    td = 'style="border:1px solid #cbd5e1;padding:6px 8px;font-size:12.5px;vertical-align:top;"'
    rest_html = ""
    if rest:
        rows = "".join(f"<tr><td {td}>{html.escape(t['id'])}</td><td {td}>{html.escape(t['importance'])}</td><td {td}>{_br(t['title'])}</td>"
                       f"<td {td}>{html.escape((t['org'] + ' ' + t['ownerName']).strip() or '-')}</td><td {td}>{html.escape(t['target'] or '-')}</td></tr>"
                       for t in rest)
        rest_html = ('<p style="font-weight:bold;color:#b45309;">■ 조건부 승인 — 아래 보완 과제는 양산이관 후에도 계속 추적합니다.</p>'
                     '<table style="border-collapse:collapse;width:100%;max-width:900px;margin:8px 0 16px;">'
                     f"<tr><th {th}>과제</th><th {th}>중요도</th><th {th}>내용</th><th {th}>담당</th><th {th}>목표일</th></tr>{rows}</table>")
    size = f"{item['productSize']} {item['productType']}".strip()
    inner = (f"<p>아래 안건이 양산이관 검증위원회 <b>최종승인{cond}</b> 되었습니다.</p>"
             + _mail_table([("안건 ID", html.escape(item["id"])), ("구분", html.escape(category_label(item) + (f" · {size}" if size else ""))),
                            ("제품/기술명", f"<b>{html.escape(item['title'])}</b>"),
                            ("요청자", html.escape(f"{item['requester']} ({item['requesterDept']})")),
                            ("발제일", html.escape(item["proposalDate"])), ("최종승인일", html.escape(item["stages"]["step5"]["doneAt"] or today_str())),
                            ("보완 과제", html.escape(f"전체 {len(item['tasks'])}건 · 완료 {len(item['tasks']) - len(rest)}건 · 잔여 {len(rest)}건"))])
             + rest_html + f'<p>▶ 안건 상세 보기: <a href="{html.escape(link)}">{html.escape(link)}</a></p>')
    text = f"양산이관 최종승인{cond}: {item['title']} ({item['id']})\n잔여 보완 과제 {len(rest)}건\n{link}\n"
    return {"subject": subject, "html": _mail_wrap(f"양산이관 최종승인{cond}", inner), "text": text}


def notify_final(item_id: str) -> None:
    settings = store.settings()
    try:
        item = find_item(store.load(), item_id)
        to, cc = final_recipients(item, settings)
        if not to:
            result = {"status": "skipped", "message": "요청자 이메일과 개발팀 회원 이메일이 없어 보내지 않았습니다."}
        else:
            mail = build_final_mail(item, settings)
            method = send_mail(settings, to, cc, mail["subject"], mail["html"], mail["text"])
            result = {"status": "sent", "message": f"{method}로 {len(to)}명에게 발송 (" + "; ".join(to) + ")"}
    except Exception as e:  # noqa: BLE001
        result = {"status": "failed", "message": str(e)[:300]}
    print(f"[mail] {item_id} 최종승인 알림: {result['status']} - {result['message']}")

    def _record(data):  # rev 는 올리지 않음 (편집 중인 관리자 화면과 충돌 방지)
        cur = find_item(data, item_id)
        cur["finalNotify"] = {**result, "at": now_str()}
        add_audit(cur, "시스템", f"최종승인 알림 메일 {({'sent': '발송', 'skipped': '생략', 'failed': '실패'})[result['status']]} — {result['message']}")
    try:
        store.mutate(_record)
    except HTTPException:
        pass


# --- 엑셀(xlsx) 현황 보고서 (openpyxl 필요) --------------------------------
LONG_TERM_MONTHS = 3


def add_months(date: str, n: int) -> str:
    d = dt.date.fromisoformat(date)
    y, m = divmod(d.month - 1 + n, 12)
    y, m = d.year + y, m + 1
    last = (dt.date(y + (m == 12), m % 12 + 1, 1) - dt.timedelta(days=1)).day
    return dt.date(y, m, min(d.day, last)).isoformat()


def long_term_months(item: Dict[str, Any], t: Dict[str, Any]) -> int:
    """발제일 + 3개월이 지난 미완료 과제 → 경과 개월 수 (아니면 0)."""
    if t["status"] == "완료" or not item["proposalDate"]:
        return 0
    t0 = today_str()
    if t0 < add_months(item["proposalDate"], LONG_TERM_MONTHS):
        return 0
    m = LONG_TERM_MONTHS
    while m < 240 and t0 >= add_months(item["proposalDate"], m + 1):
        m += 1
    return m


def _days_late(target: str) -> int:
    t0 = today_str()
    return (dt.date.fromisoformat(t0) - dt.date.fromisoformat(target)).days if target and target < t0 else 0


def stage_now(item: Dict[str, Any]) -> Tuple[str, str, int]:
    """(현재 단계명, 목표일, 지연일)."""
    if not item["accepted"]:
        return "접수대기", "", 0
    st = item["stages"]
    if st["step5"]["done"]:
        return "최종승인 완료" + (" (조건부)" if open_tasks(item) else ""), "", 0
    for i, k in enumerate(STAGE_KEYS):
        if not (st[k]["done"] or st[k]["skipped"]):
            return f"{i + 1}. {STAGE_NAMES[i]}", st[k]["target"], _days_late(st[k]["target"])
    return f"5. {STAGE_NAMES[4]}", st["step5"]["target"], _days_late(st["step5"]["target"])


def build_report_xlsx(items: List[Dict[str, Any]]) -> bytes:
    import io
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
    from openpyxl.utils import get_column_letter
    from openpyxl.cell.cell import ILLEGAL_CHARACTERS_RE

    def clean(v):
        # 메일에서 붙여넣은 회의록 등의 제어 문자는 엑셀에 저장할 수 없어 제거
        return ILLEGAL_CHARACTERS_RE.sub("", v) if isinstance(v, str) else v

    def text_cells(row):  # '=' 로 시작하는 글이 수식으로 저장되지 않게
        for c in row:
            if isinstance(c.value, str) and c.value.startswith("="):
                c.data_type = "s"

    wb = Workbook()
    head_fill, head_font = PatternFill("solid", fgColor="1E3A8A"), Font(bold=True, color="FFFFFF")
    red, purple, green, grey = (PatternFill("solid", fgColor=c) for c in ("FEE2E2", "F3E8FF", "DCFCE7", "F1F5F9"))
    thin = Side(style="thin", color="CBD5E1")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)
    wrap = Alignment(wrap_text=True, vertical="top")

    def sheet(ws, title, head, rows, widths, fills=None):
        ws.title = title
        rows = [[clean(v) for v in r] for r in rows]
        ws.append(head)
        for c in ws[1]:
            c.fill, c.font, c.border = head_fill, head_font, border
            c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        for i, r in enumerate(rows):
            ws.append(r)
            text_cells(ws[ws.max_row])
            fill = fills[i] if fills else None
            for c in ws[ws.max_row]:
                c.border, c.alignment = border, wrap
                if fill:
                    c.fill = fill
        for i, w in enumerate(widths, 1):
            ws.column_dimensions[get_column_letter(i)].width = w
        ws.freeze_panes = "A2"
        if rows:
            ws.auto_filter.ref = ws.dimensions

    # 1) 요약
    ws = wb.active
    ws.title = "요약"
    tasks = [(it, t) for it in items for t in it["tasks"]]
    stage_rows = [stage_now(it) for it in items]
    done = [it for it in items if it["accepted"] and it["stages"]["step5"]["done"]]
    kpis = [
        ("전체 안건", len(items)), ("검토 진행중", sum(1 for it in items if it["accepted"] and not it["stages"]["step5"]["done"])),
        ("최종승인", len(done)), ("  └ 조건부 승인", sum(1 for it in done if open_tasks(it))),
        ("접수대기", sum(1 for it in items if not it["accepted"])), ("단계 지연 안건", sum(1 for r in stage_rows if r[2])),
        ("보완 과제 전체", len(tasks)), ("진행 중 과제", sum(1 for _, t in tasks if t["status"] != "완료")),
        ("지연 과제", sum(1 for _, t in tasks if t["status"] != "완료" and _days_late(t["target"]))),
        (f"장기 과제 (발제 +{LONG_TERM_MONTHS}개월)", sum(1 for it, t in tasks if long_term_months(it, t))),
        ("완료 승인 대기", sum(1 for _, t in tasks if t["request"])),
    ]
    ws["A1"] = "양산이관 검증위원회 현황 보고서"
    ws["A1"].font = Font(bold=True, size=15, color="1E3A8A")
    ws["A2"] = f"기준일 {today_str()} · 작성 {now_str()}"
    ws["A2"].font = Font(color="64748B")
    ws.append([])
    ws.append(["구분", "건수"])
    for c in ws[4]:
        c.fill, c.font, c.border = head_fill, head_font, border
    for k, v in kpis:
        ws.append([k, v])
        for c in ws[ws.max_row]:
            c.border = border
    ws.append([])
    ws.append(["현재 단계", "안건 수", "지연"])
    for c in ws[ws.max_row]:
        c.fill, c.font, c.border = head_fill, head_font, border
    names = ["접수대기"] + [f"{i + 1}. {n}" for i, n in enumerate(STAGE_NAMES)] + ["최종승인 완료"]
    for n in names:
        cnt = sum(1 for r in stage_rows if r[0].startswith(n))
        late = sum(1 for r in stage_rows if r[0].startswith(n) and r[2])
        ws.append([n, cnt, late or ""])
        for c in ws[ws.max_row]:
            c.border = border
    ws.column_dimensions["A"].width, ws.column_dimensions["B"].width, ws.column_dimensions["C"].width = 30, 12, 10

    # 2) 안건 목록
    rows, fills = [], []
    for it, (sname, target, late) in zip(items, stage_rows):
        cards = it["reviews"].values()
        risks = [r for c in cards for r in c["risks"]]
        mt = lambda k: " / ".join(f"{m['no']}차 {m['date']} {m['result']}".strip() for m in it["stages"][k]["meetings"])
        rows.append([it["id"], category_label(it), it["productSize"], it["productType"], it["title"], it["requester"], it["requesterDept"],
                     it["proposalDate"], it["acceptedAt"], sname, target, late or "",
                     f"{sum(1 for c in cards if c['done'])}/{len(it['reviews'])}", len(risks), sum(1 for r in risks if not r["decision"]),
                     f"{sum(1 for t in it['tasks'] if t['status'] == '완료')}/{len(it['tasks'])}", len(open_tasks(it, "상")) or "",
                     mt("step2"), mt("step4"), it["stages"]["step5"]["doneAt"]])
        fills.append(red if late else green if it["stages"]["step5"]["done"] else None)
    sheet(wb.create_sheet(), "안건 목록",
          ["안건ID", "구분", "구경", "PW/EPI", "제품/기술명", "요청자", "소속", "발제일", "접수일", "현재 단계", "단계 목표일", "지연일",
           "검토 완료", "Risk", "결정 대기", "과제(완료/전체)", "상 미완료", "검증소위원회 회의", "검증위원회 회의", "최종승인일"],
          rows, [14, 9, 8, 8, 34, 12, 16, 11, 11, 22, 11, 7, 9, 6, 8, 10, 8, 26, 26, 11], fills)

    # 3) 보완 과제
    rows, fills = [], []
    for it, t in tasks:
        late, lt = (_days_late(t["target"]) if t["status"] != "완료" else 0), long_term_months(it, t)
        last = next((x for x in reversed(t["log"]) if x["kind"] in ("progress", "request")), None)
        rows.append([it["id"], it["title"], t["id"], t["team"], t["sector"], t["importance"], t["title"], t["plan"], t["org"],
                     t["ownerName"] or t["ownerEmail"], t["target"], t["targetOriginal"] if t["extensions"] else "", len(t["extensions"]) or "",
                     t["status"], t["doneAt"], late or "", f"{lt}개월+" if lt else "", "요청됨 " + t["request"]["at"][:10] if t["request"] else "",
                     f"{last['at'][:10]} {last['note']}" if last else ""])
        fills.append(red if late else purple if lt else green if t["status"] == "완료" else None)
    sheet(wb.create_sheet(), "보완 과제",
          ["안건ID", "안건명", "과제ID", "검토팀", "부문", "중요도", "과제 내용", "보완 방안", "담당조직", "담당자", "목표일", "원래 목표일", "연장",
           "상태", "완료일", "지연일", "장기", "완료 요청", "최근 진행 내용"],
          rows, [14, 26, 7, 14, 9, 7, 36, 36, 14, 12, 11, 11, 6, 8, 11, 7, 9, 14, 40], fills)

    # 4) 검토 의견
    rows, fills = [], []
    for it in items:
        for team in card_order(it):
            c = it["reviews"][team]
            res = {"ok": "이상 없음", "risk": "Risk 있음"}.get(c["result"], "미작성")
            done_by = f"{c['done']['name']} {c['done'].get('title', '')} ({c['done']['at'][:10]})" if c["done"] else ""
            base = [it["id"], it["title"], c["sector"], team, res, c["comment"], done_by]
            if not c["risks"]:
                rows.append(base + ["", "", "", "", ""])
                fills.append(None if c["done"] else grey)
            for r in c["risks"]:
                dec = {"task": "과제 " + r["taskId"], "accept": "수용"}.get(r["decision"], "결정 대기")
                rows.append(base + [r["id"], r["content"], r["proposal"], dec, r["reason"]])
                fills.append(None)
    sheet(wb.create_sheet(), "검토 의견",
          ["안건ID", "안건명", "부문", "검토팀", "결과", "의견", "작성 완료", "RiskID", "예상 Risk", "제안 보완 방안", "결정", "수용 사유"],
          rows, [14, 26, 9, 16, 10, 30, 22, 7, 36, 32, 10, 24], fills)

    # 5) 회의
    rows = [[it["id"], it["title"], f"{i + 1}단계 {STAGE_NAMES[i]}", f"{m['no']}차", m["date"], m["result"], m["note"], m["minutesText"]]
            for it in items for i, k in enumerate(STAGE_KEYS) if k in MEETING_STAGES for m in it["stages"][k]["meetings"]]
    sheet(wb.create_sheet(), "회의", ["안건ID", "안건명", "단계", "차수", "회의일", "결과", "요약", "회의록"],
          rows, [14, 26, 22, 6, 11, 10, 30, 80])

    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue()


def h_report_xlsx(req: Req):
    if not req.is_admin and not req.user():
        raise HTTPException(403, "로그인한 회원만 보고서를 내려받을 수 있습니다.")
    try:
        import openpyxl  # noqa: F401
    except ImportError:
        raise HTTPException(500, f"[XLSX-1] openpyxl 미설치 (서버 Python: {sys.executable})")
    items = store.load()["items"]
    from urllib.parse import parse_qs
    year = (parse_qs(req.query or "").get("year") or [""])[0]
    if year and year != "ALL":
        items = [it for it in items if (it["proposalDate"] or "")[:4] == year]
    try:
        data = build_report_xlsx(items)
    except Exception as e:  # noqa: BLE001
        traceback.print_exc()
        raise HTTPException(500, f"[XLSX-2] 보고서 생성 오류: {type(e).__name__} - {str(e)[:80]}")
    fname = f"양산이관_현황보고서_{today_str()}.xlsx"
    return Resp(data, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                headers={"Content-Disposition": content_disposition(fname)})


# --- 2단계·4단계 회의 차수 / 회의록 ---------------------------------------
def _stage_name(key: str) -> str:
    i = STAGE_KEYS.index(key)
    return f"{i + 1}단계 {STAGE_NAMES[i]}"


def _meeting_stage(req: Req) -> str:
    key = req.params["stage"]
    if key not in MEETING_STAGES:
        raise HTTPException(404, "회의 차수를 관리하는 단계가 아닙니다.")
    return key


def _find_meeting(cur: Dict[str, Any], key: str, no: str) -> Dict[str, Any]:
    m = next((x for x in cur["stages"][key]["meetings"] if str(x["no"]) == str(no)), None)
    if not m:
        raise HTTPException(404, "회의를 찾을 수 없습니다.")
    return m


def _touch(cur: Dict[str, Any]) -> Dict[str, Any]:
    cur["rev"] += 1
    cur["updatedAt"] = now_str()
    return cur


def minutes_dir(item_id: str) -> Path:
    return store.item_dir(item_id) / "minutes"


def _trash_minutes(item_id: str, names: List[str]) -> None:
    trash = store.backup_dir / "deleted_attachments" / item_id / "minutes"
    for name in names:
        path = minutes_dir(item_id) / safe_filename(name)
        if path.is_file():
            trash.mkdir(parents=True, exist_ok=True)
            shutil.move(str(path), str(unique_path(trash, path.name)))


def _meeting_fields(m: Dict[str, Any], p: Dict[str, Any]) -> None:
    if "date" in p:
        m["date"] = _date(p.get("date"))
    if "result" in p:
        m["result"] = _s(p.get("result")) if _s(p.get("result")) in MEETING_RESULTS else ""
    if "note" in p:
        m["note"] = _text(p.get("note"))[:2000]
    if "minutesText" in p:
        m["minutesText"] = _text(p.get("minutesText"))[:100000]


def h_meeting_add(req: Req):
    key, p = _meeting_stage(req), req.json()

    def _add(data):
        cur = find_item(data, req.params["id"])
        st = cur["stages"][key]
        if st["skipped"]:
            raise HTTPException(400, "생략(Skip)된 단계에는 회의를 추가할 수 없습니다.")
        no = max([m["no"] for m in st["meetings"]], default=0) + 1
        m = normalize_meeting({"no": no, "date": p.get("date") or today_str()})
        _meeting_fields(m, {k: v for k, v in p.items() if k in ("result", "note")})
        st["meetings"].append(m)
        add_audit(cur, "관리자", f"{_stage_name(key)} {no}차 회의 추가")
        return _touch(cur)
    return store.mutate(_add)


def h_meeting_update(req: Req):
    key, p = _meeting_stage(req), req.json()

    def _upd(data):
        cur = find_item(data, req.params["id"])
        m = _find_meeting(cur, key, req.params["no"])
        before = dict(m)
        _meeting_fields(m, p)
        head = f"{_stage_name(key)} {m['no']}차 회의"
        add_audit(cur, "관리자",
                  f"{head} 회의일 {m['date']}" if before["date"] != m["date"] else "",
                  f"{head} 결과: {m['result'] or '(미정)'}" if before["result"] != m["result"] else "",
                  f"{head} 요약 수정" if before["note"] != m["note"] else "",
                  f"{head} 회의록 {'입력' if not before['minutesText'] else '수정'}" if before["minutesText"] != m["minutesText"] else "")
        return _touch(cur)
    return store.mutate(_upd)


def h_meeting_delete(req: Req):
    key, removed = _meeting_stage(req), []

    def _del(data):
        cur = find_item(data, req.params["id"])
        st = cur["stages"][key]
        m = _find_meeting(cur, key, req.params["no"])
        if m["no"] != max(x["no"] for x in st["meetings"]):
            raise HTTPException(400, "마지막 차수 회의부터 삭제할 수 있습니다.")
        st["meetings"].remove(m)
        removed.extend(a["name"] for a in m["minutes"])
        add_audit(cur, "관리자", f"{_stage_name(key)} {m['no']}차 회의 삭제")
        return _touch(cur)
    item = store.mutate(_del)
    _trash_minutes(item["id"], removed)
    return item


def h_minutes_upload(req: Req):
    key, item_id = _meeting_stage(req), req.params["id"]
    _find_meeting(find_item(store.load(), item_id), key, req.params["no"])
    _, files = req.form()
    if not files:
        raise HTTPException(400, "업로드할 회의록 파일이 없습니다.")
    saved = save_uploads(minutes_dir(item_id), files, "관리자")

    def _attach(data):
        cur = find_item(data, item_id)
        _find_meeting(cur, key, req.params["no"])["minutes"].extend(saved)
        return _touch(cur)
    return store.mutate(_attach)


def h_minutes_download(req: Req):
    return FileResp(_attachment_path(minutes_dir(req.params["id"]), req.params["name"]))


def h_minutes_delete(req: Req):
    key, item_id, name = _meeting_stage(req), req.params["id"], req.params["name"]

    def _detach(data):
        cur = find_item(data, item_id)
        m = _find_meeting(cur, key, req.params["no"])
        if not any(a["name"] == name for a in m["minutes"]):
            raise HTTPException(404, "회의록 파일을 찾을 수 없습니다.")
        m["minutes"] = [a for a in m["minutes"] if a["name"] != name]
        return _touch(cur)
    item = store.mutate(_detach)
    _trash_minutes(item_id, [name])
    return item


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
        add_audit(it, "관리자", "첨부파일 추가: " + ", ".join(a["name"] for a in saved))
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
        add_audit(it, "관리자", f"첨부파일 삭제: {path.name}")
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
    title = _s(p.get("title"))
    if title not in TITLES:
        raise HTTPException(400, "직급(팀장 / Pro)을 선택하세요.")
    if len(password) < 4:
        raise HTTPException(400, "비밀번호는 4자 이상이어야 합니다.")

    def _add(users):
        old = users.get(emp_id)
        if old and old.get("status") != "rejected":
            raise HTTPException(409, "이미 가입 신청된 사번입니다." if old.get("status") == "pending" else "이미 가입된 사번입니다.")
        salt = secrets.token_hex(16)
        users[emp_id] = {"empId": emp_id, "name": name, "title": title, "team": team, "email": email,
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


# --- 팀 검토 의견 작성 (같은 팀 회원이면 직급 상관없이, 이력 기록) ---------------
def h_team_review_save(req: Req):
    item_id, team = req.params["id"], req.params["team"]
    user = req.user()
    if not req.is_admin and not (user and user["team"] == team):
        raise HTTPException(403, f"'{team}' 검토 의견은 {team} 회원만 작성할 수 있습니다.")
    p = req.json()
    complete = bool(p.get("complete"))
    # 팀 회원이 아닌 관리자가 작성하면 '관리자 대리 입력'으로 기록 (팀장이 작성하지 않을 때 강제 진행용)
    proxy = not (user and user["team"] == team)
    writer = {"empId": "admin", "name": "관리자", "title": "(대리 입력)", "team": "간사"} if proxy else user
    who = f"{writer['team']} {writer['name']} {writer.get('title', '')}".strip()
    result = p.get("result") if p.get("result") in ("ok", "risk") else ""
    incoming = [x for x in (p.get("risks") or []) if isinstance(x, dict)]

    def _save(data):
        cur = find_item(data, item_id)
        card = cur["reviews"].get(team)
        if not card:
            raise HTTPException(404, f"'{team}' 은(는) 이 안건의 검토 팀으로 선정되지 않았습니다.")
        decided = {r["id"]: r for r in card["risks"] if r["decision"]}
        risks: List[Dict[str, Any]] = []
        for x in incoming:
            rid = _s(x.get("id"))
            if rid in decided:  # 위원회가 결정한 Risk 는 내용 변경·삭제 불가
                risks.append(decided.pop(rid))
                continue
            content, proposal = _text(x.get("content"))[:3000], _text(x.get("proposal"))[:3000]
            if not content and not proposal:
                continue
            if rid not in {r["id"] for r in card["risks"]}:
                rid = next_seq_id("R", all_risk_ids(cur) + [r["id"] for r in risks])
            risks.append({"id": rid, "content": content or proposal, "proposal": proposal, "decision": "", "reason": "", "taskId": ""})
        risks.extend(decided.values())
        if result == "ok" and any(r["decision"] for r in risks):
            raise HTTPException(400, "위원회가 이미 결정한 Risk 가 있어 '이상 없음'으로 바꿀 수 없습니다.")
        if complete and not result:
            raise HTTPException(400, "검토 결과(✅ 이상 없음 / ⚠️ Risk 있음)를 선택하세요.")
        if complete and result == "risk" and not risks:
            raise HTTPException(400, "'Risk 있음'이면 Risk 내용을 1개 이상 입력하세요.")
        comment = _text(p.get("comment"))[:2000]
        if result == "ok" and not comment:
            comment = "특이사항 없음"
        card.update(result=result, risks=[] if result == "ok" else risks, comment=comment)
        card["history"] = (card["history"] + [{"at": now_str(), "by": who, "action": ("관리자 대리 작성 완료" if proxy else "작성 완료") if complete else "임시 저장"}])[-50:]
        if complete:
            card["done"] = {"empId": writer["empId"], "name": writer["name"], "title": writer.get("title", ""),
                            "team": writer["team"], "at": now_str()}
            add_audit(cur, who, f"[{team}] 검토 의견 {'관리자 대리 ' if proxy else ''}작성 완료 — " + ("이상 없음" if result == "ok" else f"Risk {len(card['risks'])}건"))
        cur["rev"] += 1
        cur["updatedAt"] = now_str()
        return cur
    item = store.mutate(_save)
    mail = None
    if complete and proxy:
        mail = "proxy"
    elif complete:
        if _emails(store.settings().get("secretaryEmails")):
            threading.Thread(target=notify_team_done, args=(item_id, team, writer), daemon=True).start()
            mail = "sent"
        else:
            mail = "no_recipient"
    return {"item": item, "mail": mail}


def h_team_review_reopen(req: Req):
    """관리자: '작성 완료' 해제 (재작성 요청)."""
    item_id, team = req.params["id"], req.params["team"]

    def _reopen(data):
        cur = find_item(data, item_id)
        card = cur["reviews"].get(team)
        if not card:
            raise HTTPException(404, "검토 팀을 찾을 수 없습니다.")
        card["done"] = None
        card["history"] = (card["history"] + [{"at": now_str(), "by": "관리자", "action": "작성 완료 해제(재작성 요청)"}])[-50:]
        add_audit(cur, "관리자", f"[{team}] 작성 완료 해제(재작성 요청)")
        cur["rev"] += 1
        return cur
    return store.mutate(_reopen)


# --- 현재 접속자 ------------------------------------------------------------
def _presence_snapshot() -> Dict[str, Any]:
    """현재 접속 인원수만 공개 (같은 회원이 여러 탭을 열어도 1명)."""
    now = time.time()
    with PRESENCE_LOCK:
        for cid in [c for c, v in PRESENCE.items() if v["seen"] < now - PRESENCE_TTL_SEC]:
            PRESENCE.pop(cid, None)
        entries = list(PRESENCE.values())
    members = {v["empId"] for v in entries if v.get("empId")}
    others = sum(1 for v in entries if not v.get("empId"))
    return {"count": len(members) + others}


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


# --- Remind 메일 (부문 검토 미작성 / 보완 과제 진행 확인) -----------------------
def _remind_targets(item: Dict[str, Any], kind: str, sectors: List[str], task_id: str, settings: Dict[str, Any]) -> Dict[str, Any]:
    base = portal_base(settings)
    link = f"{base}#items/{quote(item['id'])}"
    cc = _emails(settings.get("secretaryEmails"))
    info_rows = [("안건 ID", html.escape(item["id"])), ("구분", html.escape(category_label(item))),
                 ("제품/기술명", f"<b>{html.escape(item['title'])}</b>"), ("현재 단계", html.escape(stage_label(item)))]
    if kind == "review":
        teams = [t for t in sectors if t in item["reviews"] and not item["reviews"][t]["done"]]
        if not teams:
            raise HTTPException(400, "Remind 할 미작성 검토 팀이 없습니다.")
        to: List[str] = []
        names: List[str] = []
        for u in store.users().values():
            if u.get("status") == "approved" and u.get("team") in teams and u.get("email"):
                to.append(u["email"])
                names.append(f"{u['team']} {u['name']} {u.get('title', '')}".strip())
        missing = [t for t in teams if t not in {u.get("team") for u in store.users().values() if u.get("status") == "approved"}]
        if missing and not to:
            raise HTTPException(400, f"가입한 회원이 없는 팀입니다: {', '.join(missing)} (해당 팀원이 포털에 가입해야 Remind 를 받을 수 있습니다)")
        sectors = teams
        target = item["stages"]["step1"]["target"]
        delay = (dt.date.today() - dt.date.fromisoformat(target)).days if target and target < today_str() else 0
        subject = (f"[양산이관 Remind] {item['title']} - {'·'.join(sectors)} 검토 의견 작성 요청"
                   + (f" (목표 {target[5:].replace('-', '/')}, +{delay}일 지연)" if delay else (f" (목표 {target[5:].replace('-', '/')})" if target else "")))
        inner = (
            f"<p>안녕하십니까. 양산이관 검증위원회 간사입니다.<br>아래 안건의 <b>{html.escape('·'.join(sectors))}</b> "
            "전문소위원 검토 의견이 아직 작성되지 않아 Remind 드립니다.</p>"
            + (f"<p style='color:#b91c1c'>※ 가입 회원이 없어 메일을 받지 못한 팀: {html.escape(', '.join(missing))}</p>" if missing else "")
            + _mail_table(info_rows + [("1단계 목표일", html.escape(target or "-") + (f' <b style="color:#b91c1c">(+{delay}일 지연)</b>' if delay else "")),
                                       ("작성 방법", "포털 로그인 → 안건 상세 → [3] 우리 팀 줄에서 ✅ 이상 없음 / ⚠️ Risk 있음 선택 후 [✅ 작성 완료]")])
            + f'<p>▶ 바로 작성하기: <a href="{html.escape(link)}">{html.escape(link)}</a></p><p>감사합니다.</p>'
        )
        key = ",".join(sectors)
    else:
        t = next((x for x in item["tasks"] if x["id"] == task_id), None)
        if not t:
            raise HTTPException(404, "과제를 찾을 수 없습니다.")
        if t["status"] == "완료":
            raise HTTPException(400, "이미 완료된 과제입니다.")
        to = _emails(t["ownerEmail"])
        names = [t["ownerName"] or t["ownerEmail"]]
        if not to:
            raise HTTPException(400, f"과제 {t['id']} 의 담당자 이메일이 없습니다. 안건 상세 [4]에서 담당자를 지정하세요.")
        delay = (dt.date.today() - dt.date.fromisoformat(t["target"])).days if t["target"] and t["target"] < today_str() else 0
        subject = (f"[양산이관 Remind] {t['id']} 보완 과제 진행 확인 요청 - {item['title']}"
                   + (f" (목표일 {t['target'][5:].replace('-', '/')}, +{delay}일 지연)" if delay else (f" (목표일 {t['target'][5:].replace('-', '/')})" if t["target"] else "")))
        inner = (
            "<p>안녕하십니까. 양산이관 검증위원회 간사입니다.<br>아래 보완 과제의 진행 상황 확인을 요청드립니다.</p>"
            + _mail_table(info_rows + [
                ("과제", f"<b>{html.escape(t['id'])}</b> ({html.escape(t['sector'])} · 중요도 {html.escape(t['importance'])})"),
                ("과제 내용", _br(t["title"])), ("보완 방안", _br(t["plan"])),
                ("담당", html.escape(" / ".join(x for x in (t["org"], t["ownerName"]) if x) or "-")),
                ("목표일", html.escape(t["target"] or "미지정") + (f' <b style="color:#b91c1c">(+{delay}일 지연)</b>' if delay else ""))])
            + "<p>완료되었으면 간사에게 회신 부탁드리며, 일정 변경이 필요하면 사유와 함께 알려 주세요.</p>"
            + f'<p>▶ 안건 상세: <a href="{html.escape(link)}">{html.escape(link)}</a></p><p>감사합니다.</p>'
        )
        key = t["id"]
    to = _emails(to)
    if not to:
        raise HTTPException(400, "받는 사람이 없습니다. 해당 부문 팀 회원 가입 또는 관리자 모드의 검토자 주소록을 확인하세요.")
    cc = [c for c in cc if c.lower() not in [x.lower() for x in to]]
    return {"to": to, "cc": cc, "names": names, "subject": subject, "key": key,
            "html": _mail_wrap("양산이관 검증위원회 Remind", inner), "text": re.sub(r"<[^>]+>", " ", inner)}


def h_remind(req: Req):
    """관리자: Remind 메일. dryRun 이면 받는 사람·제목만 돌려준다(확인용)."""
    p = req.json()
    kind = "task" if p.get("kind") == "task" else "review"
    item = find_item(store.load(), _s(p.get("itemId")))
    settings = store.settings()
    sectors = p.get("sectors") if isinstance(p.get("sectors"), list) else []
    mail = _remind_targets(item, kind, [_s(x) for x in sectors], _s(p.get("taskId")), settings)
    if p.get("dryRun"):
        return {"to": mail["to"], "cc": mail["cc"], "names": mail["names"], "subject": mail["subject"]}
    try:
        method = send_mail(settings, mail["to"], mail["cc"], mail["subject"], mail["html"], mail["text"])
    except Exception as e:  # noqa: BLE001
        raise HTTPException(500, f"Remind 발송 실패: {e}")

    def _log(data):
        cur = find_item(data, item["id"])
        cur["remindLog"].append({"kind": kind, "key": mail["key"], "to": "; ".join(mail["to"]), "at": now_str(), "by": "관리자"})
        cur["remindLog"] = cur["remindLog"][-200:]
        add_audit(cur, "관리자", f"✉️ Remind 메일 ({'과제 ' + mail['key'] if kind == 'task' else '검토 미작성'}) → {', '.join(mail['names']) or '; '.join(mail['to'])}")
        cur["rev"] += 1
        return cur
    updated = store.mutate(_log)
    return {"ok": True, "message": f"{method}로 {len(mail['to'])}명에게 Remind 메일을 보냈습니다.", "item": updated}


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
route("POST", "/api/items/{id}/tasks/{taskId}/toggle", h_toggle_task, admin=True)
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
route("POST", "/api/items/{id}/review/{team}", h_team_review_save)
route("POST", "/api/items/{id}/review/{team}/reopen", h_team_review_reopen, admin=True)
route("POST", "/api/presence", h_presence)
route("POST", "/api/presence/leave", h_presence_leave)
route("POST", "/api/remind", h_remind, admin=True)
route("POST", "/api/items/{id}/meetings/{stage}", h_meeting_add, admin=True)
route("PUT", "/api/items/{id}/meetings/{stage}/{no}", h_meeting_update, admin=True)
route("DELETE", "/api/items/{id}/meetings/{stage}/{no}", h_meeting_delete, admin=True)
route("POST", "/api/items/{id}/meetings/{stage}/{no}/minutes", h_minutes_upload, admin=True)
route("DELETE", "/api/items/{id}/meetings/{stage}/{no}/minutes/{name}", h_minutes_delete, admin=True)
route("GET", "/api/items/{id}/minutes/{name}", h_minutes_download)
route("POST", "/api/items/{id}/tasks/{taskId}/progress", h_task_progress)
route("POST", "/api/items/{id}/tasks/{taskId}/decide", h_task_decide, admin=True)
route("GET", "/api/items/{id}/taskfiles/{name}", h_task_file)
route("GET", "/api/report.xlsx", h_report_xlsx)

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
    for n in host_names():
        print(f"          http://{n}:{PORT}  (PC 이름 주소 - 다른 PC에서 열리면 이 주소를 써도 됩니다)")
    print(" 종료   : 이 창을 닫거나 Ctrl+C")
    if os.name == "nt":
        print(f" 메일   : Outlook 연동 - {pywin32_status()[1]}")
        if is_elevated():
            print("          (관리자 권한 실행 중 - Outlook 연결이 막히면 일반 권한 작업으로 자동 우회합니다)")
        if outlook_running() is False:
            print(" [안내] Outlook 이 꺼져 있습니다. 자동 메일 발송을 쓰려면 Outlook 을 켜 두세요.")
    print("=" * 64)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n서버를 종료합니다.")
