/* 양산이관 검증위원회 포털 - 프론트엔드 (Vanilla JS, 외부 라이브러리 없음) */
(function () {
  "use strict";

  // =====================================================================
  // 상수
  // =====================================================================
  // 버전 · 업데이트 내역 (사이드바 버전 표시를 누르면 창으로 보여 줌)
  var APP_VERSION = "v19";
  var CHANGELOG = [
    ["v19", "2026-10-30", ["검토 요청 메일 작성창(.eml)에서 한글이 깨지던 문제 수정", "왼쪽 위 제목을 '양산이관 검증위원회 통합 관리 포털'로 변경, 현재 버전 표시", "버전을 누르면 이 업데이트 내역 창이 열림"]],
    ["v18", "2026-10-30", ["검토 요청 메일 작성창을 1~2초 안에 열리도록 개선 (서버 PC에서 .eml 초안으로 바로 열기)", "메일 본문 개편: 전문위원 선정 표(부문·검토자), 검토 요청 사항 한 줄, 작성 기한, 맺음말 변경", "다크 모드에서 보라색 글자를 연하게", "사번 입력 예시 변경"]],
    ["v17", "2026-10-30", ["보완 과제 화면을 안건과 분리: 목록 / 칸반 / 안건별 보기 + 오른쪽 과제 상세 패널", "과제 진행 내용 기록, 완료 처리·완료 요청·승인·반려·완료 해제를 과제 패널에서", "다크 모드 버튼 추가", "속도 개선 (서버 메모리 캐시, 압축 전송, 목록 데이터 경량화)", "패스트트랙: Risk 를 모두 결정하고 중요도 '상' 과제를 완료하면 가능", "입력 예시 문구 변경, 관리자 모드의 검토 요청 메일 카드 삭제"]],
    ["v16", "2026-10-29", ["제품 MS 입력 + 사업계획(엑셀 4개 시트) 업로드 → 사업계획 반영 여부 표시", "GR장비기술팀 추가, 검토 팀 매트릭스에서 부문별 팀 추가", "탭·페이지 이동 시 화면이 좌우로 흔들리던 문제 수정"]],
    ["v15", "2026-10-28", ["장기 안건(발제일 + 3개월) 표시 — 원인 자동 표시 + 관리자 사유 메모", "화면 정리: 목표일 연장 이력·회의 칸 접기, 회원 화면 요약, 조치 목록 탭"]],
    ["v14", "2026-10-28", ["검토 팀 매트릭스 표 정렬 + 팀별 메일 주소록", "검토 팀을 선정하면 메일 받는 사람 자동 체크 (6대 부문별 묶음)", "예전 6대 부문별 검토자 주소록 삭제"]],
    ["v13", "2026-10-28", ["관리자 대리 검토 작성 완료", "'내 할 일' 메뉴 추가 (우리 팀 검토 작성 · 담당 과제 · 신청 안건)", "장기 표시를 세부현황·조치 목록으로", "xlsx 보고서 오류 보완"]],
    ["v12", "2026-10-28", ["과제 담당자 진행 입력·완료 요청 / 관리자 승인", "xlsx 현황 보고서", "최종승인 알림 메일", "안건 변경 이력", "검토 의견 카드 2열 배치, 회의록을 텍스트로"]],
    ["v11", "2026-10-28", ["2단계·4단계 회의 차수(1차·2차…)와 회의록", "장기 과제 표시", "기술 안건도 구경·PW/EPI 선택"]],
    ["v10", "2026-10-28", ["제품 구분(구경·PW/EPI)별 검토 팀 자동 선정", "팀별 검토 의견 (이상 없음 / Risk 있음), 팀원 누구나 작성 + 이력", "검토 팀 선정 + 검토 요청 메일 패널 통합"]],
    ["v9", "2026-10-27", ["조치 중심 대시보드 (지금 조치가 필요한 항목 · 지연 · 향후 2주 일정)", "✉️ Remind 메일"]],
    ["v8", "2026-10-27", ["검토 의견 / Risk 결정(과제 등록·수용) / 보완 과제 분리", "중요도 '상' 과제가 남으면 최종승인 불가, 중·하만 남으면 조건부 승인"]],
    ["v7", "2026-10-27", ["단계별 목표일 자동 지정(영업일), 목표일 연장(사유 필수), 지연 표시", "검토 요청 메일 패널은 관리자 전용"]],
    ["v6", "2026-10-27", ["SMTP 메일 발송 단계별 진단"]],
    ["v5", "2026-10-27", ["Outlook 관리자 권한 실행 우회", "접속 주소 안내, 화면 보완"]],
    ["v4", "2026-10-27", ["Outlook 연결 오류(0x80080005) 처리", "로그인 회원 전용 메뉴, 가입 화면 개선"]],
    ["v3", "2026-10-27", ["회원 가입 · 관리자 승인 · 팀 권한", "현재 접속자 표시", "양산이관 기준 단계 한 줄 안내"]],
    ["v2", "2026-10-27", ["추가 설치 없이 실행 (Python 기본 기능만 사용)"]],
    ["v1", "2026-10-27", ["포털 첫 버전: 대시보드 · 세부현황 · 보완 과제 · 신청 · 기준 · 관리자, 공유폴더 저장"]]
  ];
  var STAGES = [
    { key: "step1", name: "전문소위원 검토" },
    { key: "step2", name: "양산이관 검증소위원회" },
    { key: "step3", name: "전문위원 검토" },
    { key: "step4", name: "검증위원회" },
    { key: "step5", name: "최종승인" }
  ];
  var SECTORS = ["품질/수율", "장비", "생산성", "Process", "제조", "손익"];
  var GRADES = ["상", "중", "하"];
  var GRADE_CLS = { "상": "high", "중": "mid", "하": "low" };
  var LEVELS = { sub: "전문소위원 검토 요청 (팀장급)", main: "전문위원 검토 요청 (담당/본부장급)" };
  var MAX_FILE_BYTES = 100 * 1024 * 1024;
  var POLL_MS = 30000;
  var PRESENCE_MS = 20000;

  var state = {
    items: [], version: 0, criteria: {}, storage: {},
    token: safeSession("get", "portalAdminToken") || "",
    isAdmin: false,
    admin: null,            // 관리자 설정 (주소록 등)
    userToken: safeLocal("get", "portalUserToken") || "",
    user: null,             // 로그인한 회원 {empId, name, title, team, sector, canApply}
    teams: [],
    presence: null,
    clientId: "",
    adminUsers: null,
    holidays: [],
    reviewMatrix: {},
    matrixDraft: null,
    mtgOpen: {},            // 펼친 회의록 ("step2-1": true)
    mtgExpand: {},          // 펼친 회의 칸 ("step2": true)
    taskPanel: null,        // 열린 과제 상세 패널 { itemId, taskId, item(전체), form }
    taskView: safeLocal("get", "portalTaskView") || "list",  // 과제 화면 보기: list / kanban / group
    taskGroupClosed: {},    // 안건별 보기에서 접은 안건
    taskForm: {},           // 진행 입력 중인 내용 (다시 그려도 유지)
    leadDays: { step1: 5, step2: 7, step3: 7, step4: 7, step5: 7 },
    route: "dashboard",
    f: {
      dashYear: "ALL",
      list: { cat: "ALL", year: "ALL", status: "ALL", q: "" },
      task: { grade: "ALL", sector: "ALL", status: "ALL", q: "", mine: false }
    },
    detail: null,           // { id, orig, draft }
    mail: null,             // 검토 요청 메일 패널 상태
    apply: { category: "제품", files: [], result: null, busy: false },
    crit: { tab: "overview", editing: false, forms: null }
  };

  // =====================================================================
  // 유틸
  // =====================================================================
  function $(sel, root) { return (root || document).querySelector(sel); }
  function $all(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
  function esc(s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }
  function clone(o) { return JSON.parse(JSON.stringify(o)); }
  function safeSession(op, key, val) {
    try {
      if (op === "get") return sessionStorage.getItem(key);
      if (op === "set") sessionStorage.setItem(key, val);
      if (op === "del") sessionStorage.removeItem(key);
    } catch (e) { /* 저장소 차단 환경 */ }
    return null;
  }
  // 회원 로그인은 브라우저를 닫아도 유지(localStorage), 관리자 인증은 탭 단위(sessionStorage)
  function safeLocal(op, key, val) {
    try {
      if (op === "get") return localStorage.getItem(key);
      if (op === "set") localStorage.setItem(key, val);
      if (op === "del") localStorage.removeItem(key);
    } catch (e) { /* 저장소 차단 환경 */ }
    return null;
  }
  function pad2(n) { return (n < 10 ? "0" : "") + n; }
  function today() { var d = new Date(); return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate()); }
  function yearOf(d) { return d && d.length >= 4 ? d.slice(0, 4) : ""; }
  function daysBetween(a, b) { return Math.round((Date.parse(b) - Date.parse(a)) / 86400000); }
  function fmtSize(n) {
    if (n < 1024) return n + "B";
    if (n < 1048576) return (n / 1024).toFixed(0) + "KB";
    return (n / 1048576).toFixed(1) + "MB";
  }
  function normDate(v) {
    var s = String(v || "").trim().replace(/[./]/g, "-");
    var m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})/);
    return m ? m[1] + "-" + pad2(+m[2]) + "-" + pad2(+m[3]) : "";
  }
  function normGrade(g) {
    var s = String(g || "").trim().toUpperCase();
    if (!s) return "";
    if (s === "상" || s === "A") return "상";
    if (s === "중" || s === "B" || s === "C") return "중";
    if (s === "하" || s === "D") return "하";
    return "중";
  }
  function parseEmails(text) {
    return String(text || "").split(/[;,\s]+/).map(function (s) { return s.trim(); })
      .filter(function (s, i, arr) { return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(s) && arr.indexOf(s) === i; });
  }
  function uniq(arr) { return arr.filter(function (v, i) { return v && arr.indexOf(v) === i; }); }

  function toast(msg, type) {
    var el = document.createElement("div");
    el.className = "toast " + (type || "");
    el.textContent = msg;
    $("#toastWrap").appendChild(el);
    setTimeout(function () { el.classList.add("out"); }, type === "err" ? 5200 : 3200);
    setTimeout(function () { el.remove(); }, type === "err" ? 5600 : 3600);
  }

  function downloadBlob(blob, filename) {
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url; a.download = filename;
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
  }

  // http://IP 접속(비보안 컨텍스트)에서는 navigator.clipboard 가 없으므로 execCommand 로 폴백
  function execCopy(node) {
    document.body.appendChild(node);
    if (node.select) node.select();
    else { var range = document.createRange(); range.selectNodeContents(node); var sel = window.getSelection(); sel.removeAllRanges(); sel.addRange(range); }
    var ok = false;
    try { ok = document.execCommand("copy"); } catch (e) { ok = false; }
    window.getSelection().removeAllRanges(); node.remove();
    return ok ? Promise.resolve() : Promise.reject(new Error("copy failed"));
  }
  function copyText(text) {
    var fallback = function () {
      var ta = document.createElement("textarea");
      ta.value = text; ta.style.position = "fixed"; ta.style.opacity = "0";
      return execCopy(ta);
    };
    if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(text).catch(fallback);
    return fallback();
  }
  function copyHtml(html, text) {
    var fallback = function () {
      var div = document.createElement("div");
      div.contentEditable = "true"; div.innerHTML = html;
      div.style.position = "fixed"; div.style.left = "-9999px"; div.style.top = "0";
      return execCopy(div);
    };
    if (window.ClipboardItem && navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.write([new ClipboardItem({
        "text/html": new Blob([html], { type: "text/html" }),
        "text/plain": new Blob([text], { type: "text/plain" })
      })]).catch(fallback);
    }
    return fallback();
  }

  // =====================================================================
  // API
  // =====================================================================
  function api(method, url, body, opts) {
    opts = opts || {};
    var headers = {};
    if (state.token) headers["X-Admin-Token"] = state.token;
    if (state.userToken) headers["X-User-Token"] = state.userToken;
    var payload = body;
    if (body && !(body instanceof FormData)) {
      headers["Content-Type"] = "application/json";
      payload = JSON.stringify(body);
    }
    return fetch(url, { method: method, headers: headers, body: payload, cache: "no-store" }).then(function (res) {
      if (!res.ok) {
        return res.text().then(function (t) {
          var detail = null;
          try { detail = JSON.parse(t).detail; } catch (e) { /* 텍스트 응답 */ }
          if (res.status === 401 && state.isAdmin) setAdmin(false, "관리자 세션이 만료되었습니다. 다시 로그인하세요.");
          var msg = typeof detail === "string" ? detail : (detail && detail.message) || ("요청 실패 (" + res.status + ")");
          var err = new Error(msg); err.status = res.status; err.detail = detail;
          throw err;
        });
      }
      if (opts.raw) return res;
      var ct = res.headers.get("content-type") || "";
      return ct.indexOf("json") !== -1 ? res.json() : res.text();
    });
  }
  function fail(e) { toast(e && e.message ? e.message : "오류가 발생했습니다.", "err"); }

  // =====================================================================
  // 도메인 로직
  // =====================================================================
  // ---- 단계 목표일 (영업일 기준, 서버 app.py apply_stage_targets 와 같은 규칙) ----
  var WEEKDAY = ["일", "월", "화", "수", "목", "금", "토"];
  function addBusinessDays(start, n) {
    var d = new Date(start + "T00:00:00Z"), count = 0;
    while (count < n) {
      d.setUTCDate(d.getUTCDate() + 1);
      var iso = d.toISOString().slice(0, 10), wd = d.getUTCDay();
      if (wd !== 0 && wd !== 6 && state.holidays.indexOf(iso) === -1) count++;
    }
    return d.toISOString().slice(0, 10);
  }
  function applyStageTargets(item) {
    if (item.accepted === false) return;
    var base = item.acceptedAt || "";
    STAGES.forEach(function (s) {
      var st = item.stages[s.key];
      if (st.skipped) return;
      if (st.done) { base = st.doneAt || ""; return; }
      if (st.targetAuto || !st.target) {
        if (base) { st.target = addBusinessDays(base, state.leadDays[s.key]); st.targetAuto = true; }
        else if (st.targetAuto) { st.target = ""; st.targetAuto = false; }
      }
      base = "";
    });
  }
  function fmtDay(d) { return d ? d.slice(5).replace("-", "/") + "(" + WEEKDAY[new Date(d + "T00:00:00Z").getUTCDay()] + ")" : ""; }
  // 현재 진행 단계의 지연 일수 (목표일이 지났는데 미완료)
  function stageDelayOf(o) { return o && !o.done && !o.skipped && o.target && o.target < today() ? daysBetween(o.target, today()) : 0; }

  function stageInfo(item) {
    var st = item.stages || {};
    var g = function (k) { return st[k] || {}; };
    var fastTrack = !!(g("step2").skipped && g("step3").skipped && g("step4").skipped);
    var subDecision = !!(!g("step2").skipped && g("step3").skipped && g("step4").skipped);
    var base = { fastTrack: fastTrack, subDecision: subDecision };
    if (item.accepted === false) return Object.assign(base, { phase: "WAIT", col: 0, isDone: false, name: "접수대기" });
    if (g("step5").done) {
      var rest = openTaskCount(item);
      return Object.assign(base, { phase: "DONE", col: 5, isDone: true, conditional: rest > 0, openTasks: rest, name: rest ? "조건부 승인 (잔여 과제 " + rest + ")" : "최종승인 완료" });
    }
    var idx = 0;
    while (idx < 4 && (g(STAGES[idx].key).done || g(STAGES[idx].key).skipped)) idx++;
    var cur = g(STAGES[idx].key), delay = stageDelayOf(cur);
    return Object.assign(base, {
      phase: "ING", col: idx + 1, idx: idx, isDone: false, delay: delay, target: cur.target || "",
      name: (idx + 1) + ". " + STAGES[idx].name + (cur.target ? " (목표 " + fmtDay(cur.target) + ")" : " (목표일 없음)")
    });
  }
  // ---- 보완 과제 / 부문 검토 의견 ----
  function taskDelay(t) { return t.status !== "완료" && t.target && t.target < today() ? daysBetween(t.target, today()) : 0; }
  var LONG_TERM_MONTHS = 3;
  function addMonths(date, n) {
    var p = date.split("-").map(Number), d = new Date(Date.UTC(p[0], p[1] - 1 + n, 1));
    var last = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0)).getUTCDate();
    d.setUTCDate(Math.min(p[2], last));
    return d.toISOString().slice(0, 10);
  }
  // 장기 과제: 안건 발제일 + 3개월이 지났는데 아직 완료되지 않은 과제 → 경과 개월 수 (아니면 0)
  function longTermOf(item, t) {
    if (t.status === "완료" || !item.proposalDate) return 0;
    var t0 = today();
    if (t0 < addMonths(item.proposalDate, LONG_TERM_MONTHS)) return 0;
    var m = LONG_TERM_MONTHS;
    while (m < 240 && t0 >= addMonths(item.proposalDate, m + 1)) m++;
    return m;
  }
  // 장기 안건: 최종승인 전인데 발제일 + 3개월이 지난 안건 → 경과 개월 수
  function longItemOf(item) {
    if ((item.stages.step5 || {}).done || !item.proposalDate) return 0;
    var t0 = today();
    if (t0 < addMonths(item.proposalDate, LONG_TERM_MONTHS)) return 0;
    var m = LONG_TERM_MONTHS;
    while (m < 240 && t0 >= addMonths(item.proposalDate, m + 1)) m++;
    return m;
  }
  // 장기 안건의 원인 (현재 단계 기준 자동 판단)
  function longCause(item) {
    var si = stageInfo(item), hi = openTaskCount(item, "상"), cause;
    if (si.phase === "WAIT") return "접수 승인 대기";
    if (si.idx === 0) {
      var sm = reviewSummary(item);
      cause = sm.pending.length ? "검토 미작성 " + sm.pending.length + "팀" : sm.total ? "1단계 완료 처리 대기" : "검토 팀 미선정";
    } else if (si.idx === 1 || si.idx === 3) {
      var ms = item.stages[STAGES[si.idx].key].meetings || [], lastM = ms[ms.length - 1], und = reviewSummary(item).undecided;
      cause = lastM && lastM.result === "재심의" ? STAGES[si.idx].name + " 재심의(" + lastM.no + "차)"
        : si.idx === 1 && und ? "Risk 결정 대기 " + und + "건" : (si.idx + 1) + "단계 " + STAGES[si.idx].name + " 진행 중";
    } else if (si.idx === 2) cause = "3단계 전문위원 검토 진행 중";
    else cause = hi ? "보완 과제(상) 미완료 " + hi + "건" : "최종승인 대기";
    if (hi && si.idx < 4) cause += " · 상 과제 " + hi + "건 진행";
    return cause;
  }
  function longItemBadge(item) {
    var m = longItemOf(item);
    if (!m) return "";
    return '<span class="badge badge-long" title="발제일(' + esc(item.proposalDate) + ') + ' + LONG_TERM_MONTHS + '개월 경과 · 원인: ' + esc(longCause(item)) + (item.longReason ? " · 사유: " + esc(item.longReason) : "") + '">⏳ 장기 ' + m + "개월</span>";
  }
  // 조건부 승인 후에도 발제일 + 3개월이 지나 남아 있는 과제
  function longTasksAfterApproval(item) {
    return (item.stages.step5 || {}).done ? (item.tasks || []).filter(function (t) { return longTermOf(item, t); }) : [];
  }
  function longBadge(months) {
    return months ? '<span class="badge badge-long" title="안건 발제일로부터 ' + LONG_TERM_MONTHS + '개월이 지난 미완료 과제">⏳ 장기 ' + months + "개월+</span>" : "";
  }
  function tasksOf(items) {
    var arr = [];
    items.forEach(function (item) {
      (item.tasks || []).forEach(function (t) { arr.push({ item: item, task: t, delay: taskDelay(t), long: longTermOf(item, t) }); });
    });
    return arr;
  }
  function allRisks(item) {
    var arr = [];
    cardOrder(item).forEach(function (team) {
      var c = item.reviews[team];
      (c.risks || []).forEach(function (r) { arr.push({ team: team, sector: c.sector, risk: r }); });
    });
    return arr;
  }
  // 선정된 검토 팀 기준 요약 (팀 단위)
  function reviewSummary(item) {
    var teams = Object.keys(item.reviews || {}), risks = allRisks(item);
    var pending = cardOrder(item).filter(function (t) { return !item.reviews[t].done; });
    return {
      total: teams.length, completed: teams.length - pending.length, pending: pending,
      allOk: teams.length > 0 && teams.every(function (t) { return item.reviews[t].result === "ok"; }),
      riskCount: risks.length,
      undecided: risks.filter(function (x) { return !x.risk.decision; }).length
    };
  }
  function shortTeams(list, n) { return list.length > n ? list.slice(0, n).join(" · ") + " 외 " + (list.length - n) + "팀" : list.join(" · "); }
  function openTaskCount(item, imp) {
    return (item.tasks || []).filter(function (t) { return t.status !== "완료" && (!imp || t.importance === imp); }).length;
  }
  function nextSeqId(prefix, ids) {
    var max = 0;
    ids.forEach(function (id) { var m = String(id || "").match(new RegExp("^" + prefix + "(\\d+)$")); if (m) max = Math.max(max, +m[1]); });
    return prefix + pad2(max + 1);
  }
  function findRisk(item, id) {
    var hit = null;
    Object.keys(item.reviews || {}).forEach(function (team) {
      var c = item.reviews[team];
      c.risks.forEach(function (r) { if (r.id === id) hit = { team: team, sector: c.sector, risk: r }; });
    });
    return hit;
  }
  // 카드 표시 순서: 부문 → 팀 목록 순서
  function cardOrder(item) {
    var names = state.teams.map(function (t) { return t.name; });
    return Object.keys(item.reviews || {}).sort(function (a, b) {
      var ca = item.reviews[a], cb = item.reviews[b];
      var sa = SECTORS.indexOf(ca.sector), sb = SECTORS.indexOf(cb.sector);
      if (sa !== sb) return sa - sb;
      var ia = names.indexOf(a), ib = names.indexOf(b);
      return (ia === -1 ? 999 : ia) - (ib === -1 ? 999 : ib) || a.localeCompare(b);
    });
  }
  function teamSector(team) { var t = state.teams.filter(function (x) { return x.name === team; })[0]; return t ? t.sector : ""; }
  function newCard(team) { return { sector: teamSector(team) || SECTORS[0], result: "", comment: "", risks: [], done: null, history: [] }; }
  function findTask(item, id) { return (item.tasks || []).filter(function (t) { return t.id === id; })[0]; }
  function catBadge(item) {
    return item.category === "제품"
      ? '<span class="badge badge-product">제품</span><span class="badge badge-npsp">' + esc(item.npSp || "NP") + "</span>" +
        (item.productSize ? '<span class="badge badge-size">' + esc(item.productSize + " " + item.productType) + "</span>" : "")
      : '<span class="badge badge-tech">기술</span>';
  }
  function catText(item) { return item.category === "제품" ? "제품(" + (item.npSp || "NP") + ")" : "기술"; }
  function statusBadge(si) {
    if (si.phase === "WAIT") return '<span class="badge badge-wait">접수대기</span>';
    if (si.isDone) return si.conditional ? '<span class="badge badge-cond" title="중·하 과제가 남아 있는 상태로 승인">조건부 승인 · 잔여 ' + si.openTasks + "</span>" : '<span class="badge badge-done">최종승인완료</span>';
    return '<span class="badge badge-ing">검토진행중</span>';
  }
  function trackBadges(si) {
    return (si.fastTrack ? '<span class="badge badge-fast">⚡ 패스트트랙</span>' : "") +
      (si.subDecision ? '<span class="badge badge-sub">📌 소위전결</span>' : "") +
      (si.phase === "WAIT" ? '<span class="badge badge-new">🆕 접수대기</span>' : "");
  }
  function miniDots(item) {
    return '<span class="mini-steps">' + STAGES.map(function (s, i) {
      var o = (item.stages || {})[s.key] || {};
      var cls = o.skipped ? "skipped" : o.done ? (i === 4 ? "final-done" : "done") : stageDelayOf(o) ? "delayed" : o.target ? "scheduled" : "";
      var tip = s.name + (o.skipped ? " - 생략" : o.done ? " - 완료 " + (o.doneAt || "") : o.target ? " - 목표 " + o.target + (stageDelayOf(o) ? " (지연 +" + stageDelayOf(o) + "일)" : "") : " - 대기");
      return '<span class="mini-dot ' + cls + '" title="' + esc(tip) + '"></span>';
    }).join("") + "</span>";
  }
  function findItem(id) { return state.items.filter(function (i) { return i.id === id; })[0]; }
  function replaceItem(updated) {
    var idx = state.items.findIndex(function (i) { return i.id === updated.id; });
    if (idx === -1) state.items.unshift(updated); else state.items[idx] = updated;
  }
  function yearOptions(selected) {
    var years = uniq(state.items.map(function (i) { return yearOf(i.proposalDate); })).sort().reverse();
    return '<option value="ALL">전체 연도</option>' + years.map(function (y) {
      return '<option value="' + y + '"' + (selected === y ? " selected" : "") + ">" + y + "년</option>";
    }).join("");
  }
  // ---- 권한 ----
  function isLoggedIn() { return state.isAdmin || !!state.user; }
  var MEMBER_ROUTES = ["items", "tasks", "mywork"];  // 로그인해야 보이는 메뉴
  function canApply() { return state.isAdmin || !!(state.user && state.user.canApply); }
  function userLabel(u) { return (u.team ? u.team + " " : "") + u.name + (u.title ? " " + u.title : ""); }
  // 검토 의견: 같은 팀 회원이면 직급 상관없이 작성 (관리자는 전체)
  function canEditTeam(team) { return state.isAdmin || !!(state.user && state.user.team === team); }
  function emptyReviews() { return {}; }

  // =====================================================================
  // 데이터 로드 / 실시간 갱신
  // =====================================================================
  function loadAll() {
    return api("GET", "/api/bootstrap").then(function (d) {
      state.items = d.items; state.version = d.version;
      state.criteria = d.settings.criteria; state.storage = d.storage; state.teams = d.settings.teams || [];
      state.holidays = d.settings.holidays || []; state.reviewMatrix = d.settings.reviewMatrix || {}; if (d.settings.leadDays) state.leadDays = d.settings.leadDays;
      updateNavBadges();
    });
  }
  function updateNavBadges() {
    var delayed = tasksOf(state.items).filter(function (t) { return t.delay > 0; }).length;
    $("#navDelayBadge").textContent = delayed > 0 ? delayed : "";
    var w = myWork(), n = w.reviews.length + w.tasks.filter(function (x) { return x.mine; }).length;
    $("#navMyBadge").textContent = n > 0 ? n : "";
  }
  function poll() {
    api("GET", "/api/version").then(function (v) {
      if (v.version === state.version) return;
      return loadAll().then(function () {
        var editing = document.activeElement && $("#view").contains(document.activeElement) &&
          /INPUT|TEXTAREA|SELECT/.test(document.activeElement.tagName);
        if (state.detail || editing || ["apply", "admin", "criteria", "account"].indexOf(state.route) !== -1) {
          if (state.detail) toast("다른 사용자가 데이터를 갱신했습니다. (저장 시 충돌 여부를 확인합니다)");
          return;
        }
        var y = window.scrollY; render(false); window.scrollTo(0, y);
      });
    }).catch(function () { /* 서버 일시 중단 - 다음 주기에 재시도 */ });
  }

  // =====================================================================
  // 현재 접속자 (20초마다 heartbeat, 60초 응답 없으면 퇴장 처리)
  // =====================================================================
  function newClientId() { return "c" + Date.now().toString(36) + Math.random().toString(36).slice(2, 10); }
  function presencePing() {
    return api("POST", "/api/presence", { clientId: state.clientId }).then(function (p) {
      state.presence = p;
      var me = p.me || null;
      if (state.userToken && !me) {  // 승인 취소/삭제 등으로 세션이 끊김
        setUser(null, null, "로그인 세션이 종료되었습니다. 다시 로그인하세요.");
      } else if (me && JSON.stringify(me) !== JSON.stringify(state.user)) {
        state.user = me; updateNav();
        if (!state.detail) render(false);
      }
      renderPresence();
    }).catch(function () { /* 서버 일시 중단 */ });
  }
  function renderPresence() {
    var p = state.presence, box = $("#presenceBox");
    if (!box || !p) return;
    var u = state.user;
    var me = u ? '<div class="pres-me"><span class="pres-team">' + esc(u.team) + "</span>" + esc(u.name) + (u.title ? " " + esc(u.title) : "") + "</div>"
      : state.isAdmin ? '<div class="pres-me">관리자 모드</div>'
      : '<div class="pres-me muted-light">로그인하지 않음</div>';
    box.innerHTML = '<div class="pres-head"><span class="pres-dot"></span>현재 접속 <b>' + p.count + "</b>명</div>" + me;
  }

  // =====================================================================
  // 회원 / 관리자 상태
  // =====================================================================
  function setUser(token, user, msg) {
    state.userToken = token || ""; state.user = user || null;
    if (token) safeLocal("set", "portalUserToken", token); else safeLocal("del", "portalUserToken");
    updateNav();
    if (msg) toast(msg, user ? "ok" : "");
    if (!isLoggedIn() && state.detail) closeDetail(true);
    if (state.detail) renderDetail();
    render(false);
    presencePing();
  }
  function updateThemeButton() {
    var dark = document.documentElement.getAttribute("data-theme") === "dark";
    $("#themeIco").textContent = dark ? "☀️" : "🌙";
    $("#themeLabel").textContent = dark ? "라이트 모드" : "다크 모드";
  }
  function updateNav() {
    var u = state.user;
    $("#navApply").style.display = canApply() ? "" : "none";
    $("#navItems").style.display = isLoggedIn() ? "" : "none";
    $("#navMywork").style.display = isLoggedIn() ? "" : "none";
    if (state.items) updateNavBadges();
    $("#navTasks").style.display = isLoggedIn() ? "" : "none";
    $("#navAccountLabel").textContent = u ? u.name + (u.title ? " " + u.title : "") : "로그인 / 가입";
    var tb = $("#navAccountBadge");
    tb.textContent = u ? u.team : "";
    tb.style.display = u ? "" : "none";
    renderPresence();
    if (state.route === "apply" && !canApply() && !state.apply.result) render(false);
  }
  function setAdmin(on, msg) {
    state.isAdmin = on;
    if (!on) { state.token = ""; state.admin = null; safeSession("del", "portalAdminToken"); }
    var b = $("#adminBadge");
    b.textContent = on ? "인증됨" : "잠김";
    b.classList.toggle("on", on);
    $(".nav-link[data-route=admin] .nav-ico").textContent = on ? "🔓" : "🔒";
    if (msg) toast(msg, on ? "ok" : "");
    if (!on) state.adminUsers = null;
    updateNav();
    if (state.detail) renderDetail();
    render(false);
    presencePing();
  }
  function loadAdminSettings() {
    return api("GET", "/api/settings").then(function (s) { state.admin = s; return s; });
  }

  // =====================================================================
  // 라우터
  // =====================================================================
  var VIEWS = {
    dashboard: renderDashboard, mywork: renderMywork, items: renderItems, tasks: renderTasks,
    apply: renderApply, criteria: renderCriteria, admin: renderAdmin, account: renderAccount
  };
  function onHash() {
    var parts = location.hash.replace(/^#\/?/, "").split("/");
    var route = VIEWS[parts[0]] ? parts[0] : "dashboard";
    var changed = route !== state.route;
    state.route = route;
    if (changed && route === "admin") state.adminUsers = null;
    if (changed && state.taskPanel) { state.taskPanel = null; renderTaskPanel(); }  // 다른 메뉴로 가면 과제 패널은 닫는다  // 들어올 때마다 최신 가입 신청을 다시 불러온다
    $all(".nav-link").forEach(function (a) { a.classList.toggle("active", a.getAttribute("data-route") === route); });
    render(true);
    if (changed) { window.scrollTo(0, 0); if (state.clientId) presencePing(); if (state.version) poll(); }  // 메뉴 이동 시 최신 데이터 확인
    if (route === "items" && parts[1] && isLoggedIn()) openDetail(decodeURIComponent(parts[1]));
    if (route === "tasks" && parts[1] && parts[2] && isLoggedIn()) openTaskPanel(decodeURIComponent(parts[1]), decodeURIComponent(parts[2]));
  }
  function go(route) {
    if (location.hash === "#" + route) onHash(); else location.hash = route;
  }
  function render(animate) {
    var view = $("#view");
    view.classList.toggle("account-view", state.route === "account");
    if (MEMBER_ROUTES.indexOf(state.route) !== -1 && !isLoggedIn()) renderLoginRequired();
    else if (state.route === "account") keepInputs(ACCOUNT_INPUTS, VIEWS.account);
    else VIEWS[state.route]();
    if (animate) { view.classList.remove("enter"); void view.offsetWidth; view.classList.add("enter"); }
  }
  function setView(html) { $("#view").innerHTML = html; }
  function renderLoginRequired() {
    var name = state.route === "tasks" ? "🛠️ 보완 과제 현황" : state.route === "mywork" ? "✅ 내 할 일" : "📋 양산이관 세부현황";
    setView('<div class="page-head"><div><h2>' + name + "</h2></div></div>" +
      '<div class="card success-box"><div class="big">🔒</div><h3 style="font-size:18px">로그인 후 볼 수 있습니다</h3>' +
      "<p>사번으로 로그인하세요. 아직 회원이 아니면 [가입 신청] 후 관리자 승인을 받으면 됩니다.</p>" +
      '<div style="display:flex;gap:8px;margin-top:8px"><button class="btn btn-primary" data-action="nav" data-route="account">👤 로그인 / 가입</button></div></div>');
  }

  // =====================================================================
  // 메뉴 1: 대시보드
  // =====================================================================
  // 지금 조치가 필요한 항목 (심각도 → 경과일 순)
  //  sev 0: 단계 지연·과제 지연 / 1: 검토 미작성·결정 대기 Risk·완료 승인 대기 / 2: 접수 대기·장기 과제 / 3: 과제 목표일 미지정
  function actionItems(items) {
    var out = [], t0 = today();
    items.forEach(function (it) {
      var si = stageInfo(it), sm = reviewSummary(it), lm = longItemOf(it), lt = longTasksAfterApproval(it);
      if (lm) out.push({ kind: "long", sev: 2, item: it, label: "⏳ 장기 안건", text: "원인: " + longCause(it) + (it.longReason ? " / 사유: " + it.longReason : "") + " · 발제 " + it.proposalDate, days: lm, unit: "개월+ 경과" });
      if (lt.length) out.push({ kind: "long", sev: 2, item: it, label: "🛠 장기 과제", text: "조건부 승인 후 미완료 " + lt.length + "건 — " + lt.map(function (t) { return t.id + "(" + t.importance + ")"; }).join(", "), days: longTermOf(it, lt[0]), unit: "개월+ 경과" });
      if (si.phase === "WAIT") {
        out.push({ kind: "wait", sev: 2, item: it, label: "🆕 접수 대기", text: "접수 승인 대기 (신청 " + (it.proposalDate || "-") + ")",
          days: it.proposalDate ? Math.max(0, daysBetween(it.proposalDate, t0)) : 0, unit: "일 경과" });
        return;
      }
      if (si.delay) out.push({ kind: "stage", sev: 0, item: it, label: "🚨 단계 지연", text: si.name.replace(/ \(.*\)$/, "") + " · 목표 " + fmtDay(si.target), days: si.delay, unit: "일 지연" });
      if (si.phase === "ING" && si.idx === 0 && !sm.total) {
        out.push({ kind: "decide", sev: 1, item: it, label: "👥 팀 미선정", text: "전문(소)위원(검토 팀) 선정 필요", days: 0, unit: "" });
      }
      if (si.phase === "ING" && si.idx === 0 && sm.pending.length) {
        out.push({ kind: "review", sev: 1, item: it, label: "⏳ 검토 미작성", text: shortTeams(sm.pending, 4) + " (" + sm.completed + "/" + sm.total + " 완료)", sectors: sm.pending,
          days: it.acceptedAt ? Math.max(0, daysBetween(it.acceptedAt, t0)) : 0, unit: "일 경과", remindKey: sm.pending.join(",") });
      }
      if (sm.undecided && si.phase === "ING") {
        out.push({ kind: "decide", sev: 1, item: it, label: "🗳 결정 대기", text: "Risk " + sm.undecided + "건 — 과제 등록/수용 결정 필요", days: 0, unit: "" });
      }
      (it.tasks || []).forEach(function (t) {
        if (t.status === "완료") return;
        var d = taskDelay(t);
        if (t.request) out.push({ kind: "approve", sev: 1, item: it, task: t, label: "🙋 완료 승인 대기", text: t.id + " " + t.title + " · 요청 " + t.request.by, days: daysBetween(t.request.at.slice(0, 10), t0), unit: "일 경과" });
        if (d) out.push({ kind: "task", sev: 0, item: it, task: t, label: "🚨 과제 지연", text: t.id + " " + t.title + (t.org || t.ownerName ? " · " + (t.ownerName || t.org) : ""), days: d, unit: "일 지연", remindKey: t.id });
        else if (!t.target) out.push({ kind: "notarget", sev: 3, item: it, task: t, label: "📅 목표일 미지정", text: t.id + " " + t.title, days: 0, unit: "" });
      });
    });
    return out.sort(function (a, b) { return a.sev - b.sev || b.days - a.days; });
  }
  function remindInfo(item, key) {
    var logs = (item.remindLog || []).filter(function (l) { return l.key === key; });
    return logs.length ? '<span class="remind-log" title="' + esc(logs.map(function (l) { return l.at + " → " + l.to; }).join("\n")) + '">✉️ ' + logs.length + "회 · " + esc(logs[logs.length - 1].at.slice(5, 10)) + "</span>" : "";
  }
  function remindBtn(a) {
    if (!state.isAdmin) return "";
    if (a.kind === "review") return '<button class="btn btn-amber btn-sm" data-action="remind" data-kind="review" data-id="' + esc(a.item.id) + '" data-sectors="' + esc(a.sectors.join(",")) + '">✉️ Remind</button>';
    if (a.kind === "task") return a.task.ownerEmail
      ? '<button class="btn btn-amber btn-sm" data-action="remind" data-kind="task" data-id="' + esc(a.item.id) + '" data-task="' + esc(a.task.id) + '">✉️ Remind</button>'
      : '<button class="btn btn-secondary btn-sm" disabled title="안건 상세 [4]에서 담당자(이메일)를 지정하면 Remind 할 수 있습니다">담당자 미지정</button>';
    return "";
  }
  // 향후 2주(달력 14일) 안의 목표일: 현재 단계 + 진행 중 과제
  function upcoming(items) {
    var t0 = today(), end = new Date(t0 + "T00:00:00Z");
    end.setUTCDate(end.getUTCDate() + 14);
    var t14 = end.toISOString().slice(0, 10), out = [];
    items.forEach(function (it) {
      var si = stageInfo(it);
      if (si.phase === "ING" && si.target && si.target >= t0 && si.target <= t14) out.push({ date: si.target, item: it, kind: "stage", text: si.name.replace(/ \(.*\)$/, "") });
      (it.tasks || []).forEach(function (t) {
        if (t.status !== "완료" && t.target && t.target >= t0 && t.target <= t14) out.push({ date: t.target, item: it, kind: "task", text: t.id + " " + t.title + " (" + t.importance + ")" });
      });
    });
    return out.sort(function (a, b) { return a.date.localeCompare(b.date); });
  }

  function renderDashboard() {
    var y = state.f.dashYear, member = isLoggedIn();
    var items = state.items.filter(function (i) { return y === "ALL" || yearOf(i.proposalDate) === y; });
    var prod = items.filter(function (i) { return i.category === "제품"; });
    var np = prod.filter(function (i) { return i.npSp === "NP"; }).length, sp = prod.length - np;
    var tech = items.length - prod.length;

    var wait = 0, ing = 0, done = 0, cond = 0, cols = [0, 0, 0, 0, 0, 0], colDelay = [0, 0, 0, 0, 0, 0], stageDelayed = [], maxStageDelay = 0;
    items.forEach(function (i) {
      var s = stageInfo(i);
      if (s.phase === "WAIT") wait++; else if (s.isDone) { done++; if (s.conditional) cond++; } else ing++;
      cols[s.col]++;
      if (s.delay) { colDelay[s.col]++; stageDelayed.push(i); maxStageDelay = Math.max(maxStageDelay, s.delay); }
    });
    var tasks = tasksOf(items);
    var openTasks = tasks.filter(function (t) { return t.task.status !== "완료"; });
    var delayedTasks = tasks.filter(function (t) { return t.delay > 0; });
    var maxTaskDelay = delayedTasks.reduce(function (m, t) { return Math.max(m, t.delay); }, 0);
    var longItems = items.filter(function (i) { return longItemOf(i); });
    var actions = actionItems(items);
    var pendingReview = actions.filter(function (a) { return a.kind === "review"; });
    var pendingSectors = pendingReview.reduce(function (n, a) { return n + a.sectors.length; }, 0);
    var undecided = actions.filter(function (a) { return a.kind === "decide"; });

    // 파이프라인 (단계별 현재 위치, 지연 건수 빨간색)
    var funnelDefs = [{ name: "접수대기", cls: "wait" }].concat(STAGES.map(function (s, i) { return { name: (i + 1) + ". " + s.name, cls: i === 4 ? "final" : "" }; }));
    var maxCol = Math.max.apply(null, [1].concat(cols));
    var funnel = funnelDefs.map(function (fd, i) {
      var cnt = cols[i], h = cnt ? Math.max(Math.round(cnt / maxCol * 100), 10) : 3;
      var extra = i === 0 ? "신규 신청" : i === 5 ? "승인 " + done + (cond ? " (조건부 " + cond + ")" : "") + " · 대기 " + (cnt - done) : "";
      return '<div class="funnel-col ' + fd.cls + '" title="' + esc(fd.name + " " + cnt + "건") + '"><div class="funnel-val">' + cnt + "건" +
        (colDelay[i] ? ' <span class="funnel-delay">🚨' + colDelay[i] + "</span>" : "") + "</div>" +
        '<div class="funnel-bar-wrap"><div class="funnel-bar" style="height:' + h + '%">' +
        (colDelay[i] ? '<div class="funnel-bar-delay" style="height:' + Math.round(colDelay[i] / cnt * 100) + '%"></div>' : "") + "</div></div>" +
        '<div class="funnel-name">' + esc(fd.name) + '</div><div class="funnel-extra">' + extra + "</div></div>";
    }).join("");

    // 조치 필요 목록
    var ACT_TABS = [["all", "전체", null], ["delay", "🚨 지연", ["stage", "task"]], ["review", "⏳ 검토", ["review", "decide"]], ["approve", "🙋 승인", ["approve", "wait"]], ["long", "⏳ 장기", ["long"]]];
    var tab = ACT_TABS.find(function (t) { return t[0] === state.actTab; }) || ACT_TABS[0];
    var tabList = tab[2] ? actions.filter(function (a) { return tab[2].indexOf(a.kind) !== -1; }) : actions;
    var actionHtml = !member ? "" : '<div class="card"><div class="card-title">📌 지금 조치가 필요한 항목 <span class="card-sub">늦은 순 · 행을 누르면 상세로 이동</span>' +
      '<span class="badge badge-gray">' + actions.length + "건</span></div>" +
      '<div class="act-tabs">' + ACT_TABS.map(function (t) {
        var n = t[2] ? actions.filter(function (a) { return t[2].indexOf(a.kind) !== -1; }).length : actions.length;
        return '<button class="chip-btn ' + (t === tab ? "active" : "") + '" data-action="actTab" data-tab="' + t[0] + '">' + t[1] + " " + n + "</button>";
      }).join("") + "</div>" +
      (tabList.length ? '<div class="table-wrap"><table class="action-table"><tbody>' + tabList.slice(0, state.showAllActions ? 999 : 8).map(function (a) {
        var rowAct = a.task ? 'data-action="taskOpen" data-id="' + esc(a.item.id) + '" data-task="' + esc(a.task.id) + '"' : 'data-action="openDetail" data-id="' + esc(a.item.id) + '"';
        return '<tr class="row-link sev' + a.sev + '" ' + rowAct + '><td style="width:120px"><span class="act-label k-' + a.kind + '">' + a.label + "</span></td>" +
          '<td style="width:260px"><b>' + esc(a.item.title) + '</b><div class="muted" style="font-size:11px">' + esc(a.item.id) + "</div></td>" +
          '<td class="pre">' + esc(a.text) + "</td>" +
          '<td style="width:90px;text-align:right">' + (a.days ? '<b class="' + (a.unit === "일 지연" ? "txt-delay" : "") + '">' + (a.unit === "일 지연" ? "+" : "") + a.days + "</b>" + '<span class="muted" style="font-size:11px">' + a.unit + "</span>" : "") + "</td>" +
          '<td style="width:180px;text-align:right">' + (a.remindKey ? remindInfo(a.item, a.remindKey) + " " : "") + remindBtn(a) + "</td></tr>";
      }).join("") + "</tbody></table></div>" +
        (tabList.length > 8 ? '<button class="btn btn-secondary btn-sm" data-action="toggleActions">' + (state.showAllActions ? "접기" : "나머지 " + (tabList.length - 8) + "건 더 보기") + "</button>" : "")
        : '<div class="empty-state" style="padding:20px">🎉 지금 조치가 필요한 항목이 없습니다.</div>') + "</div>";

    // 회원: 내 할 일 요약 → [✅ 내 할 일] 메뉴로
    var w = myWork(), mineCnt = w.tasks.filter(function (x) { return x.mine; }).length;
    var mineHtml = state.user && (w.reviews.length || w.tasks.length) ? '<div class="banner info my-banner"><span>✅ <b>' + esc(state.user.team) + "</b> 할 일 — 검토 의견 작성 <b>" + w.reviews.length + "건</b> · 내 담당 과제 <b>" + mineCnt +
      "건</b> · 팀 과제 " + (w.tasks.length - mineCnt) + "건</span>" + '<button class="btn btn-primary btn-sm" data-action="nav" data-route="mywork">내 할 일 보기 →</button></div>' : "";

    // 향후 2주 일정
    var up = member ? upcoming(items) : [];
    var upHtml = !member ? "" : '<div class="card"><div class="card-title">📅 향후 2주 일정 <span class="card-sub">현재 단계 목표일 · 진행 중 과제 목표일</span></div>' +
      (up.length ? '<div class="up-list">' + up.map(function (u) {
        var dd = daysBetween(today(), u.date);
        return '<div class="up-row" data-action="openDetail" data-id="' + esc(u.item.id) + '"><span class="up-date' + (dd <= 3 ? " soon" : "") + '">' + fmtDay(u.date) + "<small>" + (dd === 0 ? "오늘" : "D-" + dd) + "</small></span>" +
          '<span class="up-kind ' + u.kind + '">' + (u.kind === "stage" ? "단계" : "과제") + '</span><span class="up-text"><b>' + esc(u.item.title) + "</b> · " + esc(u.text) + "</span></div>";
      }).join("") + "</div>" : '<div class="empty-state" style="padding:20px">2주 안에 도래하는 목표일이 없습니다.</div>') + "</div>";

    setView(
      '<div class="page-head"><div><h2>📊 대시보드</h2><p>' + (member ? "지금 무엇이 늦어지고 있고, 누구에게 연락해야 하는지 한눈에 봅니다" : "로그인하면 조치 필요 목록과 일정을 볼 수 있습니다") + "</p></div>" +
      '<div class="page-actions"><span class="filter-label">기준연도</span><select class="select" data-filter="dashYear">' + yearOptions(y) + "</select>" +
      (member ? '<button class="btn btn-excel" data-action="reportXlsx">📊 현황 보고서(xlsx)</button>' : "") +
      '<button class="btn btn-secondary" data-action="refresh">🔄 최신 데이터</button></div></div>' +

      '<section class="kpi-grid kpi4">' +
      '<div class="kpi-card" data-action="kpiGo" data-go="all"><div class="kpi-label"><span>📁 전체 안건</span><span class="badge badge-product">' + (y === "ALL" ? "전체 연도" : y + "년") + "</span></div>" +
      '<div class="kpi-value">' + items.length + '건</div><div class="kpi-sub"><span class="kpi-pill">진행 ' + ing + '</span><span class="kpi-pill" style="background:#dcfce7;color:#15803d">승인 ' + done +
      (cond ? " (조건부 " + cond + ")" : "") + '</span><span class="kpi-pill" style="background:#ede9fe;color:#6d28d9">접수대기 ' + wait + "</span></div>" +
      '<div class="kpi-hint">제품 NP ' + np + " · SP " + sp + " · 기술 " + tech + "</div></div>" +

      '<div class="kpi-card delay ' + (stageDelayed.length ? "has-delay" : "") + '" data-action="kpiGo" data-go="stageDelay"><div class="kpi-label"><span>🚨 지연 안건</span><span class="badge" style="background:#fee2e2;color:#b91c1c">단계 목표일 경과</span></div>' +
      '<div class="kpi-value">' + stageDelayed.length + '건</div><div class="kpi-sub">' + (maxStageDelay ? '<span class="kpi-pill" style="color:#b91c1c">최장 +' + maxStageDelay + "일</span>" : '<span class="kpi-pill">지연 없음</span>') +
      '<span class="kpi-pill long" data-action="kpiGo" data-go="taskLong" title="최종승인 전, 발제일 + ' + LONG_TERM_MONTHS + '개월이 지난 안건">⏳ 장기 안건 ' + longItems.length + "</span></div>" +
      '<div class="kpi-hint">클릭 → 세부현황(단계 지연)</div></div>' +

      '<div class="kpi-card delay ' + (delayedTasks.length ? "has-delay" : "") + '" data-action="kpiGo" data-go="taskDelay"><div class="kpi-label"><span>🚨 지연 과제</span><span class="badge" style="background:#fee2e2;color:#b91c1c">과제 목표일 경과</span></div>' +
      '<div class="kpi-value">' + delayedTasks.length + '건</div><div class="kpi-sub"><span class="kpi-pill">진행 중 과제 ' + openTasks.length + "</span>" +
      (maxTaskDelay ? '<span class="kpi-pill" style="color:#b91c1c">최장 +' + maxTaskDelay + "일</span>" : "") +
"</div>" +
      '<div class="kpi-hint">클릭 → 보완 과제 현황(지연)</div></div>' +

      '<div class="kpi-card wait-card" data-action="kpiGo" data-go="actions"><div class="kpi-label"><span>⏳ 조치 대기</span><span class="badge badge-wait">회신·결정 필요</span></div>' +
      '<div class="kpi-value">' + (pendingSectors + undecided.length) + '건</div><div class="kpi-sub"><span class="kpi-pill">검토 미작성 ' + pendingSectors + "팀</span>" +
      '<span class="kpi-pill">결정 대기·미선정 ' + undecided.length + "</span></div>" +
      '<div class="kpi-hint">' + (member ? "클릭 → 아래 조치 필요 목록" : "로그인 후 상세 확인") + "</div></div></section>" +

      mineHtml + actionHtml +

      '<section class="charts-grid">' +
      '<div class="card chart-card"><div class="chart-head"><div><div class="card-title">단계별 진행 현황</div>' +
      '<div class="card-sub">현재 머물러 있는 단계 기준 · 🚨 = 그 단계에서 목표일이 지난 안건</div></div></div><div class="chart-body"><div class="funnel">' + funnel + "</div></div></div>" +
      upHtml + "</section>"
    );
  }

  // =====================================================================
  // 메뉴: 내 할 일 (우리 팀 검토 의견 작성 / 보완 과제 / 내가 신청한 안건)
  // =====================================================================
  function myWork() {
    var u = state.user, out = { reviews: [], done: [], tasks: [], applied: [] };
    if (!u) return out;
    state.items.forEach(function (it) {
      var c = it.reviews && it.reviews[u.team], s1 = it.stages.step1;
      if (c && it.accepted !== false) {
        if (!c.done && !s1.done && !s1.skipped) out.reviews.push({ item: it, card: c, due: s1.target, late: stageDelayOf(s1) });
        else if (c.done) out.done.push({ item: it, card: c });
      }
      (it.tasks || []).forEach(function (t) {
        if (t.status === "완료") return;
        var mine = isTaskOwner(t), team = t.org === u.team || t.team === u.team;
        if (mine || team) out.tasks.push({ item: it, task: t, mine: mine, delay: taskDelay(t), long: longTermOf(it, t) });
      });
      if (u.empId && it.applicantEmpId === u.empId) out.applied.push(it);
    });
    out.reviews.sort(function (a, b) { return (a.due || "9999").localeCompare(b.due || "9999"); });
    out.tasks.sort(function (a, b) { return (b.mine - a.mine) || (b.delay - a.delay) || (a.task.target || "9999").localeCompare(b.task.target || "9999"); });
    out.done.sort(function (a, b) { return (b.card.done.at || "").localeCompare(a.card.done.at || ""); });
    return out;
  }
  function dueHtml(date, late) {
    if (!date) return '<span class="muted">기한 미정</span>';
    var dd = daysBetween(today(), date);
    return "<b>" + fmtDay(date) + "</b> " + (late ? '<span class="badge badge-delay">🚨 +' + late + "일 지연</span>" : '<span class="badge ' + (dd <= 2 ? "badge-wait" : "badge-gray") + '">' + (dd === 0 ? "오늘까지" : "D-" + dd) + "</span>");
  }
  function renderMywork() {
    var u = state.user;
    if (!u) {
      setView('<div class="page-head"><div><h2>✅ 내 할 일</h2></div></div>' +
        '<div class="card success-box"><div class="big">🔒</div><h3 style="font-size:18px">회원으로 로그인하면 우리 팀의 할 일이 보입니다</h3>' +
        "<p>관리자(간사)의 할 일은 대시보드의 <b>📌 지금 조치가 필요한 항목</b>에 모여 있습니다.</p>" +
        '<div style="display:flex;gap:8px;margin-top:8px"><button class="btn btn-primary" data-action="nav" data-route="dashboard">📊 대시보드로</button>' +
        '<button class="btn btn-secondary" data-action="nav" data-route="account">👤 회원 로그인</button></div></div>');
      return;
    }
    var w = myWork(), mineCnt = w.tasks.filter(function (x) { return x.mine; }).length;
    var rv = w.reviews.length ? '<div class="table-wrap"><table class="action-table"><tbody>' + w.reviews.map(function (x) {
      var c = x.card;
      return '<tr class="row-link' + (x.late ? " sev0" : "") + '" data-action="openDetail" data-id="' + esc(x.item.id) + '">' +
        '<td style="width:150px">' + catBadge(x.item) + '</td><td><b>' + esc(x.item.title) + '</b><div class="muted" style="font-size:11px">' + esc(x.item.id) + " · 요청 " + esc(x.item.requester) + "</div></td>" +
        '<td style="width:150px">' + (c.result ? '<span class="badge badge-ing">✏️ 임시 저장됨</span>' : '<span class="badge badge-wait">⬜ 미작성</span>') + "</td>" +
        '<td style="width:230px">' + dueHtml(x.due, x.late) + "</td>" +
        '<td style="width:110px;text-align:right"><button class="btn btn-primary btn-sm">✍️ 작성하기</button></td></tr>';
    }).join("") + "</tbody></table></div>" : '<div class="empty-state" style="padding:18px">🎉 작성할 검토 의견이 없습니다.</div>';
    var tk = w.tasks.length ? '<div class="table-wrap"><table class="action-table"><tbody>' + w.tasks.map(function (x) {
      var t = x.task;
      return '<tr class="row-link' + (x.delay ? " sev0" : "") + '"' + taskOpenAttr(x) + '><td style="width:90px"><b>' + esc(t.id) + '</b> <span class="grade-chip ' + GRADE_CLS[t.importance] + '">' + t.importance + "</span>" +
        '<div style="margin-top:3px">' + (x.mine ? '<span class="badge badge-mine">👤 내 담당</span>' : '<span class="badge badge-gray">팀 과제</span>') + "</div></td>" +
        '<td><b>' + esc(t.title) + '</b><div class="muted" style="font-size:12px">📁 ' + esc(x.item.title) + "</div>" + (lastLogOf(t) ? lastProgressHtml(t) : "") +
        '<div class="muted" style="font-size:11.5px">담당: ' + esc((t.org || "-") + " " + (t.ownerName || t.ownerEmail || "")) + "</div></td>" +
        '<td style="width:230px">' + dueHtml(t.target, x.delay) + (x.long ? "<div>" + longBadge(x.long) + "</div>" : "") + "</td>" +
        '<td style="width:170px;text-align:right">' + taskStateBadge(t, x.delay) + ' <button class="btn btn-xs ' + (x.mine && !t.request ? "btn-amber" : "btn-secondary") + '">' + (x.mine && !t.request ? "✍️ 진행 입력" : "📒 보기") + "</button></td></tr>";
    }).join("") + "</tbody></table></div>" : '<div class="empty-state" style="padding:18px">진행 중인 우리 팀 보완 과제가 없습니다.</div>';
    var ap = w.applied.length ? '<div class="table-wrap"><table class="action-table"><tbody>' + w.applied.map(function (it) {
      var si = stageInfo(it), sm = reviewSummary(it);
      return '<tr class="row-link" data-action="openDetail" data-id="' + esc(it.id) + '"><td style="width:150px">' + catBadge(it) + "</td>" +
        "<td><b>" + esc(it.title) + '</b><div class="muted" style="font-size:11px">' + esc(it.id) + " · 신청 " + esc(it.proposalDate) + "</div></td>" +
        '<td style="width:320px">' + statusBadge(si) + " " + esc(si.name) + (si.delay ? ' <span class="badge badge-delay">+' + si.delay + "일</span>" : "") + "</td>" +
        '<td style="width:150px" class="muted">' + (sm.total ? "검토 " + sm.completed + "/" + sm.total : "") + (it.tasks.length ? " · 과제 " + it.tasks.filter(function (t) { return t.status === "완료"; }).length + "/" + it.tasks.length : "") + "</td></tr>";
    }).join("") + "</tbody></table></div>" : "";
    var dn = w.done.slice(0, 8).map(function (x) {
      return '<span class="done-chip" data-action="openDetail" data-id="' + esc(x.item.id) + '">✓ ' + esc(x.item.title) + ' <span class="muted">' + esc(x.card.done.name) + " " + esc((x.card.done.at || "").slice(5, 10)) + "</span></span>";
    }).join("");
    setView(
      '<div class="page-head"><div><h2>✅ 내 할 일</h2><p><b>' + esc(u.team) + "</b> " + esc(u.name) + " " + esc(u.title || "") +
      " — 우리 팀이 검토 팀으로 선정된 안건과 담당 보완 과제를 기한 순으로 모았습니다</p></div>" +
      '<div class="page-actions"><span class="badge badge-wait">검토 작성 ' + w.reviews.length + '건</span><span class="badge badge-mine">내 담당 과제 ' + mineCnt + "건</span></div></div>" +
      '<div class="card"><div class="card-title">📝 검토 의견 작성 <span class="card-sub">기한 = 1단계 전문소위원 검토 목표일 (접수 승인일 + ' + state.leadDays.step1 + "영업일) · 팀원 누구나 작성 가능</span>" +
      '<span class="badge badge-gray">' + w.reviews.length + "건</span></div>" + rv +
      (dn ? '<div class="done-list"><span class="filter-label">최근 작성 완료</span>' + dn + "</div>" : "") + "</div>" +
      '<div class="card"><div class="card-title">🛠 보완 과제 <span class="card-sub">내가 담당자인 과제 + 우리 팀(담당조직/검토팀) 과제 · [✍️ 진행 입력]으로 진행 상황·완료 요청</span>' +
      '<span class="badge badge-gray">' + w.tasks.length + "건</span></div>" + tk + "</div>" +
      (ap ? '<div class="card"><div class="card-title">📦 내가 신청한 안건 <span class="card-sub">진행 단계 확인</span></div>' + ap + "</div>" : "")
    );
  }

  // =====================================================================
  // 메뉴 2: 양산이관 세부현황
  // =====================================================================
  function filteredItems() {
    var f = state.f.list, q = f.q.trim().toLowerCase();
    return state.items.filter(function (i) {
      if (f.cat === "제품" && i.category !== "제품") return false;
      if (f.cat === "제품-NP" && !(i.category === "제품" && i.npSp === "NP")) return false;
      if (f.cat === "제품-SP" && !(i.category === "제품" && i.npSp === "SP")) return false;
      if (f.cat === "기술" && i.category !== "기술") return false;
      if (f.year !== "ALL" && yearOf(i.proposalDate) !== f.year) return false;
      if (f.status === "DELAY") { if (!stageInfo(i).delay) return false; }
      else if (f.status === "LONG") { if (!longItemOf(i)) return false; }
      else if (f.status === "LONGTASK") { if (!longTasksAfterApproval(i).length) return false; }
      else if (f.status !== "ALL" && stageInfo(i).phase !== f.status) return false;
      if (q && (i.title + " " + i.requester + " " + i.requesterDept + " " + i.id).toLowerCase().indexOf(q) === -1) return false;
      return true;
    }).sort(function (a, b) { return (b.proposalDate || "").localeCompare(a.proposalDate || "") || b.id.localeCompare(a.id); });
  }

  function renderItems() {
    var f = state.f.list;
    var cats = [["ALL", "전체"], ["제품", "제품(전체)"], ["제품-NP", "제품[NP]"], ["제품-SP", "제품[SP]"], ["기술", "기술"]];
    setView(
      '<div class="page-head"><div><h2>📋 양산이관 세부현황</h2><p>행을 클릭하면 상세 현황(단계 관리·Risk 검토·메일 발송)이 열립니다</p></div>' +
      '<div class="page-actions">' +
      '<button class="btn btn-excel" data-action="reportXlsx">📊 현황 보고서(xlsx)</button>' +
      '<button class="btn btn-excel" data-action="csvSummary">📥 엑셀(요약 목록)</button>' +
      '<button class="btn btn-excel" data-action="csvRisk">📥 엑셀(Risk 상세표)</button>' +
      (state.isAdmin ? '<button class="btn btn-upload" data-action="csvUpload">📤 엑셀 일괄 업로드</button>' : "") +
      (canApply() ? '<button class="btn btn-primary" data-action="nav" data-route="apply">📝 신규 신청</button>' : "") + "</div></div>" +
      '<div class="card"><div class="toolbar"><div class="filter-group"><span class="filter-label">구분</span>' +
      cats.map(function (c) {
        return '<button class="chip-btn ' + (f.cat === c[0] ? "active" : "") + '" data-action="listCat" data-cat="' + c[0] + '">' + c[1] + "</button>";
      }).join("") +
      '</div><div class="filter-group"><span class="filter-label">발제연도</span><select class="select" data-filter="list.year">' + yearOptions(f.year) + "</select>" +
      '<span class="filter-label">상태</span><select class="select" data-filter="list.status">' +
      [["ALL", "전체"], ["WAIT", "접수대기"], ["ING", "검토진행중"], ["DELAY", "🚨 단계 지연"], ["LONG", "⏳ 장기 안건(발제 +" + LONG_TERM_MONTHS + "개월)"], ["DONE", "최종승인완료"], ["LONGTASK", "🛠 장기 과제(조건부 승인 후)"]].map(function (o) {
        return '<option value="' + o[0] + '"' + (f.status === o[0] ? " selected" : "") + ">" + o[1] + "</option>";
      }).join("") + "</select>" +
      '<input class="input" style="width:200px" placeholder="제품/기술명, 요청자 검색" data-filter="list.q" value="' + esc(f.q) + '" /></div></div>' +
      '<div class="card-sub">검색 결과 <b id="itemsCount">0</b>건</div>' +
      '<div class="table-wrap"><table><thead><tr><th style="width:52px">번호</th><th style="width:110px">구분</th><th>제품 / 기술명</th>' +
      '<th style="width:150px">요청자</th><th style="width:100px">발제일</th><th style="width:270px">현재 진행 단계</th>' +
      '<th style="width:180px">보완 과제 (중요도)</th><th style="width:60px">첨부</th><th style="width:105px">상태</th></tr></thead>' +
      '<tbody id="itemsBody"></tbody></table></div></div>'
    );
    renderItemsTable();
  }

  function renderItemsTable() {
    var list = filteredItems();
    $("#itemsCount").textContent = list.length;
    var body = $("#itemsBody");
    if (!list.length) { body.innerHTML = '<tr><td colspan="9" class="empty-state">조건에 해당하는 안건이 없습니다.</td></tr>'; return; }
    body.innerHTML = list.map(function (item, idx) {
      var si = stageInfo(item);
      var tasks = tasksOf([item]);
      var gc = { "상": 0, "중": 0, "하": 0 }, dn = 0, dl = 0;
      tasks.forEach(function (t) { gc[t.task.importance || "중"]++; if (t.task.status === "완료") dn++; if (t.delay) dl++; });
      var lgCnt = tasks.filter(function (t) { return t.long; }).length, hiOpen = openTaskCount(item, "상");
      var rsum = reviewSummary(item);
      return '<tr class="row-link" data-action="openDetail" data-id="' + esc(item.id) + '">' +
        '<td class="muted" style="font-weight:700">' + (list.length - idx) + "</td><td>" + catBadge(item) + "</td>" +
        '<td><div style="font-weight:700">' + esc(item.title) + trackBadges(si) + " " + longItemBadge(item) + '</div><div class="muted" style="font-size:11px">' + esc(item.id) +
        (longItemOf(item) ? ' · <span class="long-cause">원인: ' + esc(longCause(item)) + (item.longReason ? " / " + esc(item.longReason) : "") + "</span>" : "") + "</div></td>" +
        "<td>" + esc(item.requester) + (item.requesterDept ? '<div class="muted" style="font-size:11px">' + esc(item.requesterDept) + "</div>" : "") + "</td>" +
        '<td style="font-weight:600">' + esc(item.proposalDate || "-") + "</td>" +
        '<td><div style="display:flex;align-items:center;flex-wrap:wrap;gap:3px">' + miniDots(item) + '<span style="font-size:12px;font-weight:700">' + esc(si.name) + "</span>" +
        (si.delay ? '<span class="badge badge-delay">🚨 +' + si.delay + "일</span>" : "") +
        (si.phase === "ING" && MEETING_STAGES.indexOf(STAGES[si.idx].key) !== -1 && (item.stages[STAGES[si.idx].key].meetings || []).length ? '<span class="badge badge-mtg">🗓 ' + meetingLabel(item.stages[STAGES[si.idx].key]) + "</span>" : "") + "</div></td>" +
        "<td>" + (tasks.length ? '<span class="task-sum" title="' + esc(GRADES.map(function (g) { return g + ":" + gc[g]; }).join(" · ") + (dl ? " · 지연 " + dl : "") + (lgCnt ? " · 장기 과제 " + lgCnt : "")) + '">과제 ' + dn + "/" + tasks.length + "</span>" +
          (hiOpen ? ' <span class="grade-chip ' + GRADE_CLS["상"] + '" title="중요도 상 미완료">상 ' + hiOpen + "</span>" : "") +
          (dl ? ' <span class="badge badge-delay" title="목표일 지난 과제">🚨' + dl + "</span>" : "") +
          (lgCnt && longTasksAfterApproval(item).length ? ' <span class="badge badge-long" title="조건부 승인 후 발제일 + ' + LONG_TERM_MONTHS + '개월이 지난 미완료 과제">🛠 장기 과제 ' + lgCnt + "</span>" : "") : '<span class="muted" style="font-size:12px">없음</span>') +
          (rsum.undecided ? '<div><span class="badge badge-wait" title="2단계에서 과제 등록/수용 결정 필요">결정 대기 Risk ' + rsum.undecided + "</span></div>" : "") +
          (item.accepted !== false && !stageInfo(item).isDone && (!rsum.total || rsum.completed < rsum.total) ? '<div class="muted" style="font-size:11px">' + (rsum.total ? "검토 " + rsum.completed + "/" + rsum.total : "검토 팀 미선정") + "</div>" : "") + "</td>" +
        "<td>" + (item.attachments.length ? '<span title="' + esc(item.attachments.map(function (a) { return a.name; }).join("\n")) + '">📎 ' + item.attachments.length + "</span>" : '<span class="muted">-</span>') + "</td>" +
        "<td>" + statusBadge(si) + "</td></tr>";
    }).join("");
  }

  // =====================================================================
  // 메뉴 3: 보완 과제 현황
  // =====================================================================
  function filteredTasks() {
    var f = state.f.task, q = f.q.trim().toLowerCase();
    return tasksOf(state.items).filter(function (x) {
      var t = x.task;
      if (f.grade !== "ALL" && t.importance !== f.grade) return false;
      if (f.sector !== "ALL" && t.sector !== f.sector) return false;
      if (f.status === "DELAY" && !x.delay) return false;
      if (f.status === "REQ" && !t.request) return false;
      if (f.mine && !isTaskOwner(t)) return false;
      if ((f.status === "진행중" || f.status === "완료") && t.status !== f.status) return false;
      if (q && [t.id, t.title, t.plan, t.org, t.ownerName, x.item.title].join(" ").toLowerCase().indexOf(q) === -1) return false;
      return true;
    }).sort(function (a, b) {
      // 지연(지연일 큰 순) → 진행중(목표일 빠른 순, 미정은 뒤) → 완료(최근 순)
      var ra = a.delay ? 0 : a.task.status === "완료" ? 2 : 1, rb = b.delay ? 0 : b.task.status === "완료" ? 2 : 1;
      if (ra !== rb) return ra - rb;
      if (ra === 0) return b.delay - a.delay;
      if (ra === 1) return (a.task.target || "9999").localeCompare(b.task.target || "9999");
      return (b.task.doneAt || "").localeCompare(a.task.doneAt || "");
    });
  }

  var TASK_VIEWS = [["list", "📋 목록"], ["kanban", "🗂 칸반"], ["group", "📁 안건별"]];
  function renderTasks() {
    var f = state.f.task, all = tasksOf(state.items), view = state.taskView || "list";
    var n = function (fn) { return all.filter(fn).length; };
    setView(
      '<div class="page-head"><div><h2>🛠️ 보완 과제 현황</h2><p>Risk 에서 등록된 보완 과제를 안건과 따로 관리합니다 · 행(카드)을 누르면 오른쪽에 과제 상세가 열립니다</p></div>' +
      '<div class="page-actions"><span class="badge badge-ing">진행 ' + n(function (x) { return x.task.status !== "완료"; }) + "</span>" +
      '<span class="badge badge-req">🙋 완료 요청 ' + n(function (x) { return x.task.request; }) + "</span>" +
      '<span class="badge badge-delay">🚨 지연 ' + n(function (x) { return x.delay; }) + "</span>" +
      '<span class="badge badge-done">완료 ' + n(function (x) { return x.task.status === "완료"; }) + "</span>" +
      '<span class="seg">' + TASK_VIEWS.map(function (v) { return '<button class="seg-btn' + (view === v[0] ? " on" : "") + '" data-action="taskView" data-view="' + v[0] + '">' + v[1] + "</button>"; }).join("") + "</span>" +
      '<button class="btn btn-excel" data-action="reportXlsx">📊 현황 보고서(xlsx)</button></div></div>' +
      '<div class="card"><div class="toolbar"><div class="filter-group"><span class="filter-label">중요도</span>' +
      [["ALL", "전체"], ["상", "상 (이관 전 필수)"], ["중", "중"], ["하", "하"]].map(function (g) {
        return '<button class="chip-btn ' + (f.grade === g[0] ? "active" : "") + '" data-action="taskGrade" data-grade="' + g[0] + '">' + g[1] + "</button>";
      }).join("") +
      '<span class="filter-label" style="margin-left:8px">상태</span>' +
      [["ALL", "전체"], ["DELAY", "🚨 지연과제만"], ["REQ", "🙋 완료 요청"], ["진행중", "진행중"], ["완료", "완료"]].map(function (s) {
        return '<button class="chip-btn ' + (s[0] === "DELAY" ? "danger " : "") + (f.status === s[0] ? "active" : "") + '" data-action="taskStatus" data-status="' + s[0] + '">' + s[1] + "</button>";
      }).join("") +
      (state.user ? '<button class="chip-btn mine ' + (f.mine ? "active" : "") + '" data-action="taskMine" style="margin-left:8px">👤 내 과제 ' + n(function (x) { return isTaskOwner(x.task); }) + "</button>" : "") +
      '</div><div class="filter-group"><span class="filter-label">부문</span><select class="select" data-filter="task.sector">' +
      ['<option value="ALL">전체 부문</option>'].concat(SECTORS.map(function (s) {
        return '<option value="' + esc(s) + '"' + (f.sector === s ? " selected" : "") + ">" + esc(s) + "</option>";
      })).join("") + "</select>" +
      '<input class="input" style="width:200px" placeholder="과제ID, 내용, 담당, 안건 검색" data-filter="task.q" value="' + esc(f.q) + '" />' +
      '<button class="btn btn-secondary btn-sm" data-action="taskReset">초기화</button></div></div>' +
      '<div class="card-sub">검색 결과 <b id="tasksCount">0</b>건</div><div id="taskViewBox"></div></div>'
    );
    renderTasksTable();
  }
  function taskStateBadge(t, delay) {
    if (t.status === "완료") return '<span class="badge badge-done">✅ 완료</span>';
    if (t.request) return '<span class="badge badge-req">🙋 완료 요청</span>';
    return delay ? '<span class="badge badge-delay">🚨 지연 +' + delay + "일</span>" : '<span class="badge badge-ing">⏳ 진행중</span>';
  }
  function lastLogOf(t) {
    return t.lastLog || (t.log || []).slice().reverse().find(function (x) { return x.kind === "progress" || x.kind === "request"; }) || null;
  }
  function lastProgressHtml(t) {
    var l = lastLogOf(t);
    return l ? '<div class="tk-last" title="' + esc(l.by + " " + l.at) + '"><span class="muted">' + esc((l.at || "").slice(5, 10)) + "</span> " + esc(l.note || "(증빙 파일)") + "</div>" : '<span class="muted">-</span>';
  }
  function taskOpenAttr(x) { return ' data-action="taskOpen" data-id="' + esc(x.item.id) + '" data-task="' + esc(x.task.id) + '"'; }
  function taskSelected(x) { var tp = state.taskPanel; return !!(tp && tp.itemId === x.item.id && tp.taskId === x.task.id); }
  function ownerText(t) { return esc((t.org || "-") + (t.ownerName || t.ownerEmail ? " · " + (t.ownerName || t.ownerEmail).replace(t.org + " ", "") : "")); }
  function taskCard(x) {
    var t = x.task;
    return '<div class="tk-card' + (x.delay ? " delay" : "") + (taskSelected(x) ? " sel" : "") + '"' + taskOpenAttr(x) + ">" +
      '<div class="tk-top"><b>' + esc(t.id) + '</b><span class="grade-chip ' + GRADE_CLS[t.importance] + '">' + t.importance + "</span>" + taskStateBadge(t, x.delay) + "</div>" +
      '<div class="tk-title">' + esc(t.title || "-") + "</div>" +
      '<div class="tk-meta">📁 ' + esc(x.item.title) + "</div>" +
      '<div class="tk-meta">👤 ' + ownerText(t) + " · 📅 " + esc(t.target ? fmtDay(t.target) : "미정") + "</div>" +
      (lastLogOf(t) ? lastProgressHtml(t) : "") + "</div>";
  }
  function renderTasksTable() {
    var box = $("#taskViewBox");
    if (!box) return;
    var list = filteredTasks(), view = state.taskView || "list";
    $("#tasksCount").textContent = list.length;
    if (!list.length) { box.innerHTML = '<div class="empty-state" style="padding:24px">조건에 해당하는 보완 과제가 없습니다.</div>'; return; }
    if (view === "kanban") {
      var cols = [["ing", "⏳ 진행중", function (x) { return x.task.status !== "완료" && !x.task.request; }],
        ["req", "🙋 완료 요청 (승인 대기)", function (x) { return !!x.task.request; }],
        ["done", "✅ 완료", function (x) { return x.task.status === "완료"; }]];
      box.innerHTML = '<div class="kanban">' + cols.map(function (c) {
        var cards = list.filter(c[2]);
        return '<div class="kb-col kb-' + c[0] + '"><div class="kb-head">' + c[1] + ' <span class="badge badge-gray">' + cards.length + "</span></div>" +
          (cards.length ? cards.map(taskCard).join("") : '<div class="muted kb-empty">없음</div>') + "</div>";
      }).join("") + "</div>";
      return;
    }
    if (view === "group") {
      var groups = [], byId = {};
      list.forEach(function (x) {
        if (!byId[x.item.id]) { byId[x.item.id] = { item: x.item, list: [] }; groups.push(byId[x.item.id]); }
        byId[x.item.id].list.push(x);
      });
      box.innerHTML = groups.map(function (g) {
        var closed = !!state.taskGroupClosed[g.item.id], open = g.list.filter(function (x) { return x.task.status !== "완료"; }).length;
        var dl = g.list.filter(function (x) { return x.delay; }).length;
        return '<div class="tg"><div class="tg-head" data-action="taskGroupToggle" data-id="' + esc(g.item.id) + '"><span class="tg-caret">' + (closed ? "▶" : "▼") + "</span>" +
          catBadge(g.item) + "<b>" + esc(g.item.title) + '</b><span class="muted">' + esc(g.item.id) + "</span>" + longItemBadge(g.item) +
          '<span class="tg-cnt">과제 ' + g.list.length + " · 진행 " + open + (dl ? ' · <b class="txt-delay">🚨 지연 ' + dl + "</b>" : "") + "</span></div>" +
          (closed ? "" : '<div class="tg-body">' + g.list.map(taskCard).join("") + "</div>") + "</div>";
      }).join("");
      return;
    }
    box.innerHTML = '<div class="table-wrap"><table class="task-list"><thead><tr><th style="width:90px">과제</th><th style="width:210px">안건</th><th>과제 내용 / 보완 방안</th>' +
      '<th style="width:240px">최근 진행 내용</th><th style="width:150px">담당</th><th style="width:110px">목표일</th><th style="width:120px">상태</th></tr></thead><tbody>' +
      list.map(function (x) {
        var t = x.task;
        return '<tr class="row-link' + (x.delay ? " row-delay" : "") + (taskSelected(x) ? " row-sel" : "") + '"' + taskOpenAttr(x) + ">" +
          "<td><b>" + esc(t.id) + '</b> <span class="grade-chip ' + GRADE_CLS[t.importance] + '">' + t.importance + "</span></td>" +
          '<td><div style="font-weight:700;font-size:12.5px">' + esc(x.item.title) + '</div><div class="muted" style="font-size:11px">' + esc(x.item.id) + " · " + esc(t.team || t.sector) + "</div></td>" +
          '<td><div class="pre" style="font-weight:700">' + esc(t.title || "-") + '</div><div class="pre muted" style="font-size:12px;margin-top:2px">💡 ' + esc(t.plan || "-") + "</div></td>" +
          "<td>" + lastProgressHtml(t) + "</td>" +
          '<td style="font-size:12.5px">' + ownerText(t) + "</td>" +
          '<td style="font-weight:600">' + esc(t.target ? fmtDay(t.target) : "미정") + (t.extensions.length ? ' <span class="badge badge-ext">연장 ' + t.extensions.length + "</span>" : "") +
          (t.status === "완료" && t.doneAt ? '<div class="muted" style="font-size:11px">완료 ' + esc(t.doneAt) + "</div>" : "") + "</td>" +
          "<td>" + taskStateBadge(t, x.delay) + "</td></tr>";
      }).join("") + "</tbody></table></div>";
  }

  // =====================================================================
  // 메뉴 4: 양산이관 신청
  // =====================================================================
  function renderApply() {
    var a = state.apply;
    if (a.result) {
      var it = a.result;
      setView(
        '<div class="page-head"><div><h2>📝 양산이관 신청</h2></div></div>' +
        '<div class="card success-box"><div class="big">🚀</div><h3 style="font-size:19px">양산이관 신청이 등록되었습니다</h3>' +
        "<p>안건 번호 <b>" + esc(it.id) + "</b> · " + esc(it.title) + "</p>" +
        '<p class="muted">현재 상태: <span class="badge badge-wait">접수대기</span> — 간사/팀장에게 알림 메일이 자동 발송됩니다.</p>' +
        (it.attachments.length ? "<p>첨부파일 " + it.attachments.length + "건 저장 완료</p>" : "") +
        '<div style="display:flex;gap:8px;margin-top:8px"><button class="btn btn-primary" data-action="applyNew">+ 새 신청 작성</button>' +
        '<button class="btn btn-secondary" data-action="openDetail" data-id="' + esc(it.id) + '">신청 내용 보기</button></div></div>'
      );
      return;
    }
    if (!canApply()) {
      setView(
        '<div class="page-head"><div><h2>📝 양산이관 신청</h2></div></div>' +
        '<div class="card success-box"><div class="big">🔒</div><h3 style="font-size:18px">개발팀 회원만 신청할 수 있습니다</h3>' +
        "<p>결정성장개발팀 · EPI개발팀 · Wafering개발팀 · 제품개발팀 회원으로 로그인하면 신청 화면이 열립니다.</p>" +
        (state.user ? '<p class="muted">현재 로그인: ' + esc(userLabel(state.user)) + " (신청 권한 없음)</p>" : "") +
        '<div style="display:flex;gap:8px;margin-top:8px"><button class="btn btn-primary" data-action="nav" data-route="account">👤 로그인 / 가입</button></div></div>'
      );
      return;
    }
    var me = state.user || {};
    var isProd = a.category === "제품";
    setView(
      '<div class="page-head"><div><h2>📝 양산이관 신청</h2><p>개발팀(결정성장·EPI·Wafering·제품개발팀) 접수 화면 · 요청자 정보는 로그인 정보로 자동 입력됩니다</p></div></div>' +
      '<div class="apply-layout"><div class="card"><div class="form-grid">' +
      '<div class="field full"><span class="lbl">구분 <span class="req">*</span></span><div class="level-toggle">' +
      '<div class="radio-card ' + (isProd ? "selected" : "") + '" data-action="applyCat" data-cat="제품">📦 제품 (Product)</div>' +
      '<div class="radio-card ' + (!isProd ? "selected" : "") + '" data-action="applyCat" data-cat="기술">⚙️ 기술 (Technology)</div></div></div>' +
      '<div class="field"><label for="apNpSp">NP / SP ' + (isProd ? "" : '<span class="muted">(기술 선택 시 해당 없음)</span>') + "</label>" +
      '<select id="apNpSp" class="select" ' + (isProd ? "" : "disabled") + ">" +
      (isProd ? '<option value="NP">NP (New Product, 신제품)</option><option value="SP">SP (Standard Product, 파생/표준제품)</option>' : '<option value="">해당 없음</option>') +
      "</select></div>" +
      '<div class="field"><label for="apSize">구경 · PW/EPI <span class="req">*</span> <span class="muted">(' + (isProd ? "검토 팀 자동 선정 기준" : "검토 팀 선정 참고") + ")</span></label>" +
        '<div style="display:flex;gap:6px"><select id="apSize" class="select" style="flex:1"><option value="">구경 선택</option><option value="300mm">300mm</option><option value="200mm">200mm</option></select>' +
        '<select id="apType" class="select" style="flex:1"><option value="">PW / EPI</option><option value="PW">PW</option><option value="EPI">EPI</option></select></div></div>' +
      '<div class="field"><label for="apDate">발제일</label><input id="apDate" type="date" class="input" value="' + today() + '" /></div>' +
      '<div class="field"><label for="apMs">제품 MS <span class="muted">(사업계획 반영 여부 확인용 · 여러 개는 , 로 구분)</span></label><input id="apMs" class="input" maxlength="300" placeholder="예) 12Q000, 08Q000" /></div>' +
      '<div class="field full"><label for="apTitle">제품 / 기술명 <span class="req">*</span></label><input id="apTitle" class="input" maxlength="200" placeholder="예) 0000 고객 0000제품, 0000 기술 도입 등" /></div>' +
      '<div class="field"><label for="apReq">요청자 성명 <span class="req">*</span></label><input id="apReq" class="input" maxlength="100" placeholder="예) 홍길동 Pro" value="' + esc(me.name ? me.name + (me.title ? " " + me.title : "") : "") + '" /></div>' +
      '<div class="field"><label for="apDept">소속 부서 <span class="req">*</span></label><input id="apDept" class="input" maxlength="100" placeholder="예) 제품개발팀" value="' + esc(me.team || "") + '" /></div>' +
      '<div class="field full"><label for="apEmail">요청자 이메일 <span class="muted">(선택 · 검토 요청 메일 참조로 자동 포함)</span></label><input id="apEmail" type="email" class="input" placeholder="name@sk.com" value="' + esc(me.email || "") + '" /></div>' +
      '<div class="field full"><label for="apSummary">양산이관 주요 내용 및 변경점 요약</label><textarea id="apSummary" class="textarea" style="min-height:140px" maxlength="5000" placeholder="변경 내역(4M), 개발 검증 결과, 양산 적용 계획 등을 요약해 주세요."></textarea></div>' +
      '<div class="field full"><span class="lbl">첨부파일 (검증보고서, 도면 등 · 파일당 100MB 이하)</span>' +
      '<div class="dropzone" data-action="applyPick" data-drop="apply"><b>📎 파일을 끌어다 놓거나 클릭해서 선택</b>여러 개를 한 번에 올릴 수 있습니다</div>' +
      '<input id="apFiles" type="file" multiple style="display:none" />' +
      '<div class="file-list" id="apFileList"></div></div>' +
      '</div><div style="display:flex;justify-content:flex-end;margin-top:6px"><button class="btn btn-primary btn-lg" data-action="applySubmit" ' + (a.busy ? "disabled" : "") + ">" +
      (a.busy ? "⏳ 등록 중..." : "🚀 양산이관 신청 등록") + "</button></div></div>" +
      '<div class="card"><div class="card-title">신청 후 진행 절차</div><ol class="steps-guide">' +
      "<li><span>1</span><span>신청 즉시 <b>접수대기</b> 상태로 등록되고, 간사·팀장에게 알림 메일이 자동 발송됩니다.</span></li>" +
      "<li><span>2</span><span>간사가 접수 후 6대 부문 <b>전문소위원(팀장) 서면검토</b>를 요청합니다.</span></li>" +
      "<li><span>3</span><span>선정 팀이 모두 이상 없음이거나, Risk 를 모두 결정(과제 등록·수용)하고 중요도 <b>상</b> 과제를 완료하면 <b>⚡ 패스트트랙</b>으로 2~4단계를 생략합니다.</span></li>" +
      "<li><span>4</span><span>특이사항이 있으면 <b>검증소위원회</b>에서 보완 과제를 확정하고, 중대 안건은 전문위원·검증위원회로 상정됩니다.</span></li>" +
      "<li><span>5</span><span><b>최종승인</b> 후 양산이관이 완료됩니다. 진행 현황은 [양산이관 세부현황]에서 확인하세요.</span></li>" +
      '</ol><button class="btn btn-secondary btn-sm" data-action="nav" data-route="criteria">📖 양산이관 기준 보기</button></div></div>'
    );
    $("#apFiles").onchange = function () { addApplyFiles(this.files); this.value = ""; };
    renderApplyFiles();
  }
  function renderApplyFiles() {
    var box = $("#apFileList");
    if (!box) return;
    box.innerHTML = state.apply.files.map(function (f, i) {
      return '<span class="file-chip">📄 ' + esc(f.name) + ' <span class="muted">' + fmtSize(f.size) + '</span><button class="x" data-action="applyRemoveFile" data-idx="' + i + '" title="제거">✕</button></span>';
    }).join("");
  }
  function addApplyFiles(fileList) {
    Array.prototype.forEach.call(fileList, function (f) {
      if (f.size > MAX_FILE_BYTES) { toast("'" + f.name + "' 파일이 100MB를 초과합니다.", "err"); return; }
      if (!state.apply.files.some(function (x) { return x.name === f.name && x.size === f.size; })) state.apply.files.push(f);
    });
    renderApplyFiles();
  }
  function submitApply() {
    var title = $("#apTitle").value.trim(), req = $("#apReq").value.trim(), dept = $("#apDept").value.trim(), email = $("#apEmail").value.trim();
    if (!title || !req || !dept) { toast("제품/기술명, 요청자 성명, 소속 부서는 필수입니다.", "err"); return; }
    if (email && !parseEmails(email).length) { toast("이메일 형식을 확인하세요.", "err"); return; }
    var fd = new FormData();
    fd.append("category", state.apply.category);
    fd.append("npSp", state.apply.category === "제품" ? $("#apNpSp").value : "");
    if (!$("#apSize").value || !$("#apType").value) { toast("구경(300mm/200mm)과 PW/EPI 를 선택하세요.", "err"); return; }
    fd.append("productSize", $("#apSize").value); fd.append("productType", $("#apType").value);
    fd.append("title", title); fd.append("requester", req); fd.append("requesterDept", dept);
    fd.append("requesterEmail", email); fd.append("proposalDate", $("#apDate").value || today());
    fd.append("summary", $("#apSummary").value);
    fd.append("ms", $("#apMs").value.trim());
    state.apply.files.forEach(function (f) { fd.append("files", f, f.name); });
    var btn = $("[data-action=applySubmit]");
    btn.disabled = true; btn.textContent = "⏳ 등록 중...";
    api("POST", "/api/apply", fd).then(function (item) {
      replaceItem(item);
      state.apply = { category: "제품", files: [], result: item, busy: false };
      updateNavBadges();
      renderApply();
      toast("신청이 등록되었습니다. (" + item.id + ")", "ok");
    }).catch(function (e) { btn.disabled = false; btn.textContent = "🚀 양산이관 신청 등록"; fail(e); });
  }

  // =====================================================================
  // 로그인 / 가입 (아이디 = 사번, 관리자 승인 후 사용)
  // =====================================================================
  // 팀 선택 목록: 개발팀(신청) / 6대 부문별 검토팀으로 묶어서 표시
  function teamOptions(selected) {
    var groups = [{ label: "개발팀 (양산이관 신청)", list: state.teams.filter(function (t) { return t.canApply; }) }]
      .concat(SECTORS.map(function (sec) {
        return { label: sec + " 부문 (검토 의견 작성)", list: state.teams.filter(function (t) { return !t.canApply && t.sector === sec; }) };
      }))
      .concat([{ label: "기타 (열람)", list: state.teams.filter(function (t) { return !t.canApply && !t.sector; }) }]);
    return '<option value="">팀 선택</option>' + groups.filter(function (g) { return g.list.length; }).map(function (g) {
      return '<optgroup label="' + esc(g.label) + '">' + g.list.map(function (t) {
        return '<option value="' + esc(t.name) + '"' + (selected === t.name ? " selected" : "") + ">" + esc(t.name) + "</option>";
      }).join("") + "</optgroup>";
    }).join("");
  }
  function renderAccount() {
    var u = state.user;
    if (u) {
      var perms = [];
      if (u.canApply) perms.push("📝 양산이관 신청");
      if (u.sector) perms.push("🖊 " + u.sector + " 부문 Risk 검토 작성 · 작성 완료 메일 발송");
      perms.push("📊 전체 현황 열람");
      setView(
        '<div class="page-head"><div><h2>👤 내 정보</h2><p>로그인 상태는 이 브라우저에서 7일간 유지됩니다</p></div>' +
        '<div class="page-actions"><button class="btn btn-secondary" data-action="userLogout">로그아웃</button></div></div>' +
        '<div class="admin-grid"><div class="card"><div class="card-title">기본 정보</div><div class="kv">' +
        "<b>사번</b><span>" + esc(u.empId) + "</span><b>이름</b><span>" + esc(u.name) + " " + esc(u.title) + "</span>" +
        "<b>팀</b><span>" + esc(u.team) + "</span><b>이메일</b><span>" + esc(u.email) + "</span>" +
        "<b>권한</b><span>" + perms.map(esc).join("<br>") + "</span></div>" +
        '<div class="card-sub">팀 변경이 필요하면 관리자(간사)에게 요청하세요.</div></div>' +
        '<div class="card"><div class="card-title">🔑 비밀번호 변경</div>' +
        '<div class="field"><label>현재 비밀번호</label><input id="upCur" type="password" class="input" autocomplete="current-password" /></div>' +
        '<div class="field"><label>새 비밀번호 (4자 이상)</label><input id="upNew" type="password" class="input" autocomplete="new-password" /></div>' +
        '<div class="field"><label>새 비밀번호 확인</label><input id="upNew2" type="password" class="input" autocomplete="new-password" /></div>' +
        '<div style="display:flex;justify-content:flex-end"><button class="btn btn-primary btn-sm" data-action="userChangePw">변경</button></div></div></div>'
      );
      return;
    }
    setView(
      '<div class="page-head"><div><h2>👤 로그인 / 가입</h2><p>아이디는 사번입니다 · 가입 신청 후 관리자(간사) 승인이 끝나면 로그인할 수 있습니다</p></div></div>' +
      '<div class="account-col"><div class="card login-card"><div class="card-title">🔐 로그인</div>' +
      '<div class="field"><label>사번</label><input id="loginEmp" class="input" autocomplete="username" placeholder="예) 250000" /></div>' +
      '<div class="field"><label>비밀번호</label><input id="loginPw" type="password" class="input" autocomplete="current-password" /></div>' +
      '<button class="btn btn-primary btn-lg" data-action="userLogin">로그인</button>' +
      '<div class="login-foot"><span class="card-sub">비밀번호를 잊었으면 관리자에게 임시 비밀번호 발급을 요청하세요.</span>' +
      '<button class="btn btn-secondary btn-sm" data-action="toggleSignup">' + (state.showSignup ? "▲ 가입 신청 닫기" : "📝 가입 신청") + "</button></div></div>" +
      '<div class="card signup-card' + (state.showSignup ? " open" : "") + '" id="signupCard"><div class="card-title">📝 가입 신청 <span class="card-sub">관리자 승인 후 로그인할 수 있습니다</span></div><div class="info-grid" style="grid-template-columns:1fr 1fr">' +
      '<div class="field"><label>사번 <span class="req">*</span></label><input id="suEmp" class="input" maxlength="20" placeholder="예) 250000" /></div>' +
      '<div class="field"><label>이름 <span class="req">*</span></label><input id="suName" class="input" maxlength="30" /></div>' +
      '<div class="field"><label>직급 <span class="req">*</span></label><select id="suTitle" class="select"><option value="">직급 선택</option><option value="팀장">팀장</option><option value="Pro">Pro</option></select></div>' +
      '<div class="field"><label>팀 <span class="req">*</span></label><select id="suTeam" class="select">' + teamOptions("") + "</select></div>" +
      '<div class="field span2"><label>이메일 <span class="req">*</span> <span class="muted">(작성 완료·검토 요청 메일에 사용)</span></label><input id="suEmail" type="email" class="input" placeholder="name@company.com" /></div>' +
      '<div class="field"><label>비밀번호 <span class="req">*</span></label><input id="suPw" type="password" class="input" autocomplete="new-password" /></div>' +
      '<div class="field"><label>비밀번호 확인 <span class="req">*</span></label><input id="suPw2" type="password" class="input" autocomplete="new-password" /></div>' +
      '</div><button class="btn btn-teal" data-action="userSignup">가입 신청</button>' +
      '<div class="card-sub">· 개발팀(결정성장/EPI/Wafering/제품개발팀): 양산이관 신청 가능<br>· 6대 부문 검토팀: 담당 부문 Risk 검토 의견 작성 및 작성 완료 처리</div></div></div>'
    );

  }

  // =====================================================================
  // 메뉴 5: 양산이관 기준
  // =====================================================================
  function renderCriteria() {
    var c = state.crit, tabs = [["overview", "양산이관 개요 및 Procedure"], ["standard", "제품(NP/SP) 및 기술별 이관 기준"], ["forms", "표준 양식 다운로드"]];
    var body = c.tab === "overview" ? criteriaOverview() : c.tab === "standard" ? criteriaStandard() : criteriaForms();
    setView(
      '<div class="page-head"><div><h2>📖 양산이관 기준</h2><p>프로세스 안내 및 표준 양식 자료실</p></div></div>' +
      '<div class="card"><div class="tabs">' + tabs.map(function (t) {
        return '<button class="tab-btn ' + (c.tab === t[0] ? "active" : "") + '" data-action="critTab" data-tab="' + t[0] + '">' + t[1] + "</button>";
      }).join("") + '</div><div class="crit-body">' + body + "</div></div>"
    );
    if (c.tab === "forms" && c.forms === null) loadForms();
  }
  // 1~5단계를 한 줄로: 각 단계 카드(주관·검토자·주요 활동·결과) + 생략(Skip) 경로는 아래 띠로 표시
  var PROCESS_STEPS = [
    { no: "접수", cls: "start", title: "양산이관 신청", who: "개발팀 (신청) → 간사 (접수)",
      act: ["양산이관 신청서·검증보고서 등록", "간사 접수 승인 (접수대기 → 접수)"], out: "6대 부문 검토 요청" },
    { no: "1단계", title: "전문소위원 검토", who: "6대 부문 팀장 (서면검토)",
      act: ["부문별 ✅ 이상 없음 / ⚠️ Risk 있음 작성", "Risk 내용과 제안 보완 방안"], out: "부문별 [작성 완료] → 간사 메일" },
    { no: "2단계", title: "양산이관 검증소위원회", who: "간사 주관 · 부문 팀장 참석",
      act: ["Risk 별 [과제 등록] 또는 [수용(사유)] 결정", "과제 중요도(상·중·하)·담당·목표일 지정"], out: "소위 전결 또는 상정" },
    { no: "3단계", title: "전문위원 검토", who: "담당 · 본부장급",
      act: ["미결·중대 Risk 검토", "보완 방안 적정성 확인"], out: "검증위원회 상정" },
    { no: "4단계", title: "검증위원회", who: "위원장 · 전문위원",
      act: ["양산이관 가부 심의·의결"], out: "최종승인 요청" },
    { no: "5단계", cls: "final", title: "최종승인", who: "위원장",
      act: ["중요도 '상' 과제 완료 확인 (미완료 시 승인 불가)", "중·하 과제 잔여 시 조건부 승인"], out: "양산이관 완료" }
  ];
  function criteriaOverview() {
    var line = PROCESS_STEPS.map(function (st, i) {
      return (i ? '<div class="pl-arrow">▶</div>' : "") +
        '<div class="pl-card ' + (st.cls || "") + '"><span class="pl-no">' + st.no + "</span><h4>" + st.title + "</h4>" +
        '<div class="pl-who">👤 ' + st.who + "</div><ul>" + st.act.map(function (a) { return "<li>" + a + "</li>"; }).join("") + "</ul>" +
        '<div class="pl-out">→ ' + st.out + "</div></div>";
    }).join("");
    var skip = function (cls, icon, title, from, to, cond, span) {
      return '<div class="pl-skip ' + cls + '" style="grid-column:' + span + '"><b>' + icon + " " + title + "</b>" +
        "<span>" + cond + "</span><span class=\"pl-skip-path\">" + from + " ➜ " + to + "</span></div>";
    };
    var rows = PROCESS_STEPS.map(function (st) {
      return "<tr><td><span class=\"pl-no sm " + (st.cls || "") + '">' + st.no + "</span></td><td><b>" + st.title + "</b></td><td>" + st.who + "</td><td>" +
        st.act.join("<br>") + "</td><td>" + st.out + "</td></tr>";
    }).join("");
    return '<div class="section"><div class="section-title">🎯 목적</div><div class="pre" style="font-size:13px">' + esc(state.criteria.purpose || "") + "</div></div>" +
      '<div class="section"><div class="section-title">🔀 양산이관 검증 프로세스 (접수 → 1~5단계)</div>' +
      '<div class="pl-wrap"><div class="pl-line">' + line + "</div>" +
      '<div class="pl-skips">' +
      skip("fast", "⚡", "패스트트랙", "1단계 완료", "5단계 최종승인", "모두 이상 없음, 또는 Risk 결정 + '상' 과제 완료", "3 / span 9") +
      skip("sub", "📌", "소위 전결", "2단계 완료", "5단계 최종승인", "2단계에서 전결 처리 (중대 안건 없음)", "5 / span 7") +
      "</div></div>" +
      '<div class="card-sub">⚡ 패스트트랙: 2·3·4단계 생략 &nbsp;|&nbsp; 📌 소위 전결: 3·4단계 생략 &nbsp;|&nbsp; 그 외에는 1→2→3→4→5단계를 순서대로 진행합니다.</div></div>' +
      '<div class="section"><div class="section-title">📋 단계별 정리</div><div class="table-wrap"><table class="pl-table"><thead><tr>' +
      '<th style="width:70px">단계</th><th style="width:170px">명칭</th><th style="width:190px">주관 / 검토자</th><th>주요 활동</th><th style="width:200px">결과 / 다음 단계</th></tr></thead><tbody>' + rows + "</tbody></table></div></div>" +
      '<div class="banner info">💡 포털에서는 각 단계에 일정(날짜)을 입력하면 \'일정 수립됨\', [완료 처리]를 눌러야 \'완료됨\'이 됩니다. 1단계 부문 검토는 각 부문 팀장이 로그인해 직접 작성합니다.</div>';
  }
  function criteriaStandard() {
    var c = state.criteria, ed = state.crit.editing && state.isAdmin;
    var block = function (key, title, val) {
      return '<div class="crit-card"><h4>' + title + "</h4>" + (ed
        ? '<textarea class="textarea" style="min-height:150px" data-crit="' + key + '">' + esc(val) + "</textarea>"
        : '<div class="pre">' + esc(val || "-") + "</div>") + "</div>";
    };
    var cl = c.checklist || {};
    return '<div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px"><div class="card-sub">' +
      (state.isAdmin ? "관리자 모드: 내용을 직접 수정할 수 있습니다." : "기준 수정은 관리자 모드에서 가능합니다.") + "</div>" +
      (state.isAdmin ? (ed ? '<div style="display:flex;gap:6px"><button class="btn btn-secondary btn-sm" data-action="critCancel">취소</button><button class="btn btn-primary btn-sm" data-action="critSave">💾 기준 저장</button></div>'
        : '<button class="btn btn-secondary btn-sm" data-action="critEdit">✏️ 기준 수정</button>') : "") + "</div>" +
      '<div class="section-title">📦 구분별 이관 기준</div><div class="crit-grid">' +
      block("np", "제품 [NP] 신제품", c.np) + block("sp", "제품 [SP] 파생/표준제품", c.sp) + block("tech", "기술 (신규 공정/기술)", c.tech) + "</div>" +
      '<div class="section-title">✅ 6대 부문 중점 체크리스트</div><div class="check-grid">' +
      SECTORS.map(function (s) { return block("checklist." + s, s, cl[s]); }).join("") + "</div>";
  }
  function criteriaForms() {
    var forms = state.crit.forms;
    var rows = forms === null ? '<tr><td colspan="4" class="empty-state">불러오는 중…</td></tr>'
      : !forms.length ? '<tr><td colspan="4" class="empty-state">등록된 표준 양식이 없습니다.' + (state.isAdmin ? " [양식 업로드]로 추가하세요." : "") + "</td></tr>"
      : forms.map(function (f) {
        return '<tr><td><a href="/api/forms/' + encodeURIComponent(f.name) + '" download>📄 ' + esc(f.name) + "</a></td><td>" + fmtSize(f.size) + "</td><td>" + esc(f.uploadedAt) + "</td>" +
          '<td style="text-align:right"><a class="btn btn-excel btn-sm" href="/api/forms/' + encodeURIComponent(f.name) + '" download>다운로드</a>' +
          (state.isAdmin ? ' <button class="btn btn-danger btn-sm" data-action="formDelete" data-name="' + esc(f.name) + '">삭제</button>' : "") + "</td></tr>";
      }).join("");
    return '<div style="display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap"><div class="card-sub">신청서·체크리스트 등 표준 양식을 내려받아 사용하세요.</div>' +
      (state.isAdmin ? '<button class="btn btn-upload btn-sm" data-action="formPick">📤 양식 업로드</button><input id="formFiles" type="file" multiple style="display:none" />' : "") + "</div>" +
      '<div class="table-wrap"><table><thead><tr><th>파일명</th><th style="width:90px">크기</th><th style="width:150px">등록일</th><th style="width:170px"></th></tr></thead><tbody>' + rows + "</tbody></table></div>";
  }
  function loadForms() {
    api("GET", "/api/forms").then(function (f) { state.crit.forms = f; if (state.route === "criteria") renderCriteria(); }).catch(fail);
  }
  function saveCriteria() {
    var c = clone(state.criteria); c.checklist = c.checklist || {};
    $all("[data-crit]").forEach(function (ta) {
      var k = ta.getAttribute("data-crit");
      if (k.indexOf("checklist.") === 0) c.checklist[k.slice(10)] = ta.value; else c[k] = ta.value;
    });
    api("PUT", "/api/settings", { criteria: c }).then(function (s) {
      state.criteria = s.criteria; state.admin = s; state.crit.editing = false;
      renderCriteria(); toast("양산이관 기준을 저장했습니다.", "ok");
    }).catch(fail);
  }

  // =====================================================================
  // 메뉴 6: 관리자 모드
  // =====================================================================
  function renderAdmin() {
    if (!state.isAdmin) {
      setView(
        '<div class="page-head"><div><h2>🔒 관리자 모드</h2><p>안건 수정·삭제·단계 처리·메일 발송·설정 변경은 관리자 인증 후 가능합니다</p></div></div>' +
        '<div class="card login-box"><div class="big">🔒</div><h3>관리자 비밀번호</h3>' +
        '<input id="adminPw" type="password" class="input" style="text-align:center;font-size:15px" placeholder="비밀번호 입력" autocomplete="current-password" />' +
        '<button class="btn btn-primary btn-lg" data-action="login">🔓 관리자 모드 활성화</button>' +
        '<p class="muted" style="font-size:12px">인증은 브라우저 탭을 닫을 때까지 유지됩니다. (초기 비밀번호는 설치 안내서 참고)</p></div>'
      );
      setTimeout(function () { var el = $("#adminPw"); if (el) el.focus(); }, 50);
      return;
    }
    if (!state.admin) {
      setView('<div class="card empty-state">설정을 불러오는 중…</div>');
      loadAdminSettings().then(renderAdmin).catch(fail);
      return;
    }
    var s = state.admin, smtp = s.smtp;
    var pending = state.items.filter(function (i) { return i.accepted === false; });

    setView(
      '<div class="page-head"><div><h2>🔓 관리자 모드</h2><p>메일 주소록 · 시스템 설정 · 안건 일괄 관리</p></div>' +
      '<div class="page-actions"><button class="btn btn-secondary" data-action="logout">🔒 관리자 모드 종료</button></div></div>' +
      '<div class="admin-grid">' +

      // 접수 대기
      '<div class="card full"><div class="card-title">🆕 접수 대기 안건 <span class="badge badge-wait">' + pending.length + "건</span></div>" +
      (pending.length ? '<div class="table-wrap"><table><thead><tr><th>ID</th><th>구분</th><th>제품/기술명</th><th>요청자</th><th>발제일</th><th>알림메일</th><th style="width:230px"></th></tr></thead><tbody>' +
        pending.map(function (i) {
          var n = i.notify || {};
          var nb = n.status === "sent" ? '<span class="badge badge-done" title="' + esc(n.message) + '">발송</span>'
            : n.status === "failed" ? '<span class="badge" style="background:#fee2e2;color:#b91c1c" title="' + esc(n.message) + '">실패</span>'
            : n.status === "skipped" ? '<span class="badge badge-gray" title="' + esc(n.message) + '">수신자 없음</span>' : '<span class="badge badge-gray">대기</span>';
          return "<tr><td>" + esc(i.id) + "</td><td>" + catBadge(i) + '</td><td style="font-weight:700">' + esc(i.title) + "</td><td>" + esc(i.requester) +
            " <span class='muted'>" + esc(i.requesterDept) + "</span></td><td>" + esc(i.proposalDate) + "</td><td>" + nb + "</td>" +
            '<td style="text-align:right"><button class="btn btn-secondary btn-sm" data-action="openDetail" data-id="' + esc(i.id) + '">상세</button> ' +
            '<button class="btn btn-primary btn-sm" data-action="acceptItem" data-id="' + esc(i.id) + '">✓ 접수 승인</button> ' +
            '<button class="btn btn-danger btn-sm" data-action="deleteItem" data-id="' + esc(i.id) + '">삭제</button></td></tr>';
        }).join("") + "</tbody></table></div>" : '<div class="muted">접수 대기 중인 신규 신청이 없습니다.</div>') + "</div>" +

      // 회원 관리
      '<div class="card full"><div class="card-title">👥 회원 관리 (가입 승인) <span id="userCounts" class="card-sub"></span></div>' +
      '<div class="table-wrap" style="max-height:440px;overflow:auto"><table><thead><tr><th style="width:90px">상태</th><th style="width:100px">사번</th><th style="width:150px">이름 / 직급</th>' +
      '<th style="width:190px">팀</th><th>권한</th><th style="width:180px">이메일</th><th style="width:130px">신청일</th><th style="width:250px"></th></tr></thead><tbody id="userBody"></tbody></table></div></div>' +

      // 팀 관리
      '<div class="card full"><div class="card-title">🏢 팀 관리 <span class="card-sub">신청 가능 = 양산이관 신청 메뉴 표시 · 검토 부문 = 해당 부문 Risk 행 작성 권한</span></div>' +
      '<div class="team-grid"><div class="team-head"><span>팀 이름</span><span>검토 부문</span><span>신청</span><span></span></div>' +
      '<div class="team-head"><span>팀 이름</span><span>검토 부문</span><span>신청</span><span></span></div><div class="team-rows" id="teamBody"></div></div>' +
      '<div style="display:flex;justify-content:space-between;gap:6px"><button class="btn btn-secondary btn-sm" data-action="teamAdd">+ 팀 추가</button>' +
      '<button class="btn btn-primary btn-sm" data-action="teamSave">💾 팀 목록 저장</button></div></div>' +

      // 알림 수신자
      '<div class="card"><div class="card-title">📨 신규 신청 알림 수신자</div>' +
      '<div class="field"><label>담당자(간사) 이메일 <span class="muted">(여러 명은 ; 또는 줄바꿈 구분)</span></label><textarea id="stSecretary" class="textarea" style="min-height:60px">' + esc(s.secretaryEmails.join("; ")) + "</textarea></div>" +
      '<div class="field"><label>팀장 이메일</label><textarea id="stLeader" class="textarea" style="min-height:60px">' + esc(s.leaderEmails.join("; ")) + "</textarea></div>" +
      '<div class="field"><label>포털 접속 주소 <span class="muted">(메일 본문 링크 · 비우면 자동: ' + esc(s.suggestedPortalUrl) + ")</span></label>" +
      '<input id="stPortalUrl" class="input" value="' + esc(s.portalUrl) + '" placeholder="' + esc(s.suggestedPortalUrl) + '" />' +
      '<div class="card-sub">메일 속 링크 주소만 바꾸는 칸입니다. 이름 주소를 쓰려면 먼저 다른 PC에서 아래 주소가 열리는지 확인하세요: ' +
      (s.nameUrls || []).map(function (u) { return '<button class="btn btn-secondary btn-sm" data-action="usePortalUrl" data-url="' + esc(u) + '">' + esc(u) + "</button>"; }).join(" ") +
      "</div></div>" +
      '<div style="display:flex;justify-content:flex-end"><button class="btn btn-primary btn-sm" data-action="saveRecipients">💾 저장</button></div></div>' +

      // 메일 발송 설정
      '<div class="card"><div class="card-title">⚙️ 메일 발송 설정</div>' + mailDiagHtml(s.mailDiag) +
      '<label class="check-line"><input type="checkbox" id="stPreferOutlook" ' + (s.mail.preferOutlook ? "checked" : "") + " /> 서버 PC Outlook 자동 발송 우선 사용 (실패 시 SMTP)</label>" +
      '<label class="check-line"><input type="checkbox" id="stFastDraft" ' + (s.mail.fastDraft !== false ? "checked" : "") + " /> 검토 요청 메일 작성창을 .eml 초안으로 빠르게 열기 (권장 · .eml 이 Outlook 이 아닌 프로그램으로 열리면 해제)</label>" +
      '<div class="info-grid" style="grid-template-columns:2fr 1fr"><div class="field"><label>SMTP 호스트</label><input id="stSmtpHost" class="input" value="' + esc(smtp.host) + '" placeholder="mail.company.com" /></div>' +
      '<div class="field"><label>포트</label><input id="stSmtpPort" type="number" class="input" value="' + esc(smtp.port) + '" /></div>' +
      '<div class="field"><label>계정 (선택)</label><input id="stSmtpUser" class="input" value="' + esc(smtp.username) + '" autocomplete="off" /></div>' +
      '<div class="field"><label>비밀번호 ' + (smtp.hasPassword ? '<span class="badge badge-done">저장됨</span>' : "") + '</label><input id="stSmtpPw" type="password" class="input" placeholder="' + (smtp.hasPassword ? "변경 시에만 입력" : "") + '" autocomplete="new-password" /></div>' +
      '<div class="field"><label>발신자 주소</label><input id="stSmtpSender" class="input" value="' + esc(smtp.sender) + '" placeholder="회사 메일 주소 (예: name@company.com)" /></div>' +
      '<div class="field"><label>&nbsp;</label><label class="check-line"><input type="checkbox" id="stSmtpTls" ' + (smtp.useTls ? "checked" : "") + " /> STARTTLS</label></div></div>" +
      '<div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center"><input id="stTestTo" class="input" style="flex:1;min-width:160px" placeholder="테스트 수신 주소 (비우면 간사)" />' +
      '<button class="btn btn-secondary btn-sm" data-action="mailTest" data-method="outlook">Outlook 테스트</button>' +
      '<button class="btn btn-secondary btn-sm" data-action="mailTest" data-method="smtp">🔍 SMTP 테스트 (단계별 진단)</button>' +
      '<button class="btn btn-primary btn-sm" data-action="saveMailCfg">💾 저장</button></div>' +
      '<div class="card-sub">테스트는 저장하지 않은 입력값으로도 바로 시험합니다. 성공하면 [💾 저장]을 누르세요.</div><div id="smtpDiag"></div></div>' +

      // 일괄 관리
      '<div class="card full"><div class="card-title">🗂 전체 안건 일괄 관리 <span class="card-sub">저장소: ' + esc(state.storage.path) + "</span></div>" +
      '<div style="display:flex;gap:6px;flex-wrap:wrap"><button class="btn btn-teal btn-sm" data-action="backupJson">💾 data.json 백업 다운로드</button>' +
      '<button class="btn btn-excel btn-sm" data-action="csvSummaryAll">📥 전체 요약 엑셀</button><button class="btn btn-excel btn-sm" data-action="csvRiskAll">📥 전체 Risk 상세 엑셀</button>' +
      '<button class="btn btn-upload btn-sm" data-action="csvUpload">📤 엑셀 일괄 업로드</button></div>' +
      '<div class="table-wrap" style="max-height:420px;overflow:auto"><table><thead><tr><th>ID</th><th>구분</th><th>제품/기술명</th><th>발제일</th><th>상태</th><th style="width:150px"></th></tr></thead><tbody>' +
      state.items.map(function (i) {
        var si = stageInfo(i);
        return "<tr><td>" + esc(i.id) + "</td><td>" + catBadge(i) + '</td><td style="font-weight:700">' + esc(i.title) + trackBadges(si) + "</td><td>" + esc(i.proposalDate) + "</td><td>" + statusBadge(si) + "</td>" +
          '<td style="text-align:right"><button class="btn btn-secondary btn-sm" data-action="openDetail" data-id="' + esc(i.id) + '">상세</button> ' +
          '<button class="btn btn-danger btn-sm" data-action="deleteItem" data-id="' + esc(i.id) + '">삭제</button></td></tr>';
      }).join("") + "</tbody></table></div></div>" +

      // 검토 팀 매트릭스
      '<div class="card full"><div class="card-title">🧩 제품 구분별 검토 팀 · 메일 주소록 <span class="card-sub">체크 = 접수 승인 시 제품 안건에 자동 선정 · 주소록 = 검토 팀으로 선정되면 검토 요청 메일 받는 사람에 자동 체크 (Remind 도 이 주소로)</span></div>' +
      '<div class="table-wrap" id="matrixBody"></div><div style="display:flex;justify-content:flex-end;gap:6px">' +
      '<button class="btn btn-primary btn-sm" data-action="matrixSave">💾 매트릭스 · 주소록 저장</button></div></div>' +

      // 사업계획 (제품 MS 반영 여부)
      '<div class="card full"><div class="card-title">📊 사업계획 (제품 MS 반영 여부) <span class="card-sub">엑셀 1개 파일 · 시트 4개(300mm PW / 300mm EPI / 200mm PW / 200mm EPI) · 시트마다 MS 시작 칸부터 아래로 읽어 안건의 제품 MS 와 비교</span></div>' +
      '<div id="bizBody"><div class="muted">불러오는 중…</div></div></div>' +

      // 휴일 (영업일 계산)
      '<div class="card"><div class="card-title">📅 휴일 (영업일 계산에서 제외) <span class="card-sub">' + s.holidays.length + "일 등록</span></div>" +
      '<div class="card-sub">주말은 자동 제외됩니다. 공휴일·회사 휴무일을 YYYY-MM-DD 형식으로 한 줄에 하나씩(또는 쉼표로) 입력하세요.</div>' +
      '<textarea id="stHolidays" class="textarea" style="min-height:110px;font-family:monospace" placeholder="2026-12-25&#10;2027-01-01">' + esc(s.holidays.join("\n")) + "</textarea>" +
      '<div style="display:flex;justify-content:flex-end"><button class="btn btn-primary btn-sm" data-action="saveHolidays">💾 저장</button></div></div>' +

      // 비밀번호
      '<div class="card"><div class="card-title">🔑 관리자 비밀번호 변경</div>' +
      '<div class="field"><label>현재 비밀번호</label><input id="pwCur" type="password" class="input" autocomplete="current-password" /></div>' +
      '<div class="field"><label>새 비밀번호 (4자 이상)</label><input id="pwNew" type="password" class="input" autocomplete="new-password" /></div>' +
      '<div class="field"><label>새 비밀번호 확인</label><input id="pwNew2" type="password" class="input" autocomplete="new-password" /></div>' +
      '<div style="display:flex;justify-content:flex-end"><button class="btn btn-primary btn-sm" data-action="changePw">변경</button></div></div>' +

      '<div class="card"><div class="card-title">ℹ️ 시스템 정보</div><div class="kv">' +
      "<b>저장소</b><span>" + esc(state.storage.path) + "</span>" +
      "<b>연동 상태</b><span>" + (state.storage.isNetwork ? "✅ 사내 공유폴더" : "⚠️ 로컬 폴백 (공유폴더 접근 불가)") + "</span>" +
      "<b>데이터 버전</b><span>v" + state.version + " · 안건 " + state.items.length + "건</span>" +
      "<b>자동 백업</b><span>backups/data_YYYYMMDD.json (최근 30일)</span>" +
      "<b>단계 리드타임</b><span>1단계 접수 승인일 +" + state.leadDays.step1 + " · 2~5단계 앞 단계 완료일 +7 (영업일)</span>" +
      "<b>접속 주소</b><span>" + esc(s.suggestedPortalUrl) + (s.nameUrls || []).map(function (u) { return "<br>" + esc(u) + " (PC 이름)"; }).join("") + "</span></div></div>" +
      "</div>"
    );
    if (!state.teamDraft) state.teamDraft = clone(state.teams);
    if (!state.matrixDraft) state.matrixDraft = clone(s.reviewMatrix || state.reviewMatrix);
    if (!state.teamEmailsDraft) {
      state.teamEmailsDraft = {};
      Object.keys(s.teamEmails || {}).forEach(function (t) { state.teamEmailsDraft[t] = s.teamEmails[t].join("; "); });
    }
    renderMatrix();
    renderBizplan();
    if (!state.bizplan) api("GET", "/api/admin/bizplan").then(function (b) { state.bizplan = b; renderBizplan(); }).catch(function () { });
    renderTeamRows();
    if (state.adminUsers) renderUserRows();
    else api("GET", "/api/admin/users").then(function (list) { state.adminUsers = list; renderUserRows(); }).catch(fail);
  }

  function mailDiagHtml(d) {
    if (!d) return "";
    var yn = function (v, yes, no) { return v === true ? yes : v === false ? no : "확인 불가"; };
    var priv = !d.elevated ? "✅ 일반 권한"
      : d.uac === false ? "관리자 권한 (이 PC는 UAC가 꺼져 있어 모든 프로그램이 관리자 권한 → 정상)"
      : "⚠️ 관리자 권한 → Outlook 연결이 막히면 일반 권한 작업으로 자동 우회합니다";
    return '<div class="kv" style="font-size:12px"><b>Outlook 연동</b><span>' + (d.pywin32 ? "✅ " : "⚠️ ") + esc(d.outlookMethod) + "</span>" +
      "<b>Outlook 실행</b><span>" + yn(d.outlookRunning, "✅ 켜져 있음", "⚠️ 꺼져 있음 → 서버 PC에서 Outlook을 켜 두세요") + "</span>" +
      "<b>서버 실행 권한</b><span>" + esc(priv) + "</span>" +
      '<b>Python</b><span style="word-break:break-all">' + esc(d.python) + "</span></div>" +
      '<div class="card-sub">Outlook 2016/2019/365 데스크톱 버전 모두 지원합니다. 서버 PC에서 <b>Outlook을 켜 둔 상태</b>여야 자동 발송됩니다.</div>';
  }
  // ---- 관리자: 제품 구분별 검토 팀 매트릭스 ----
  var MATRIX_KEYS = ["300mm PW", "300mm EPI", "200mm PW", "200mm EPI"];
  function renderMatrix() {
    var box = $("#matrixBody");
    if (!box) return;
    var mx = state.matrixDraft, te = state.teamEmailsDraft || {};
    box.innerHTML = '<table class="matrix-table"><colgroup><col style="width:90px"><col style="width:150px">' + MATRIX_KEYS.map(function () { return '<col style="width:86px">'; }).join("") + "<col></colgroup>" +
      '<thead><tr><th>부문</th><th class="mx-team">검토 팀</th>' + MATRIX_KEYS.map(function (k) { return "<th>" + k + "</th>"; }).join("") +
      '<th class="mx-mail">📒 메일 주소록 <span class="muted">(여러 명은 ; 로 구분)</span></th></tr></thead><tbody>' + SECTORS.map(function (sec) {
        var teams = state.teams.filter(function (t) { return t.sector === sec; });
        var addRow = '<tr class="mx-add' + (teams.length ? "" : " mx-first") + '">' + (teams.length ? "" : '<td class="mx-sec">' + esc(sec) + "</td>") +
          '<td colspan="' + (MATRIX_KEYS.length + 2) + '"><button class="link-btn" data-action="mxAddTeam" data-sector="' + esc(sec) + '">+ ' + esc(sec) + " 팀 추가</button></td></tr>";
        return teams.map(function (t, i) {
          return '<tr class="' + (i === 0 ? "mx-first" : "") + '">' + (i === 0 ? '<td rowspan="' + (teams.length + 1) + '" class="mx-sec">' + esc(sec) + "</td>" : "") +
            '<td class="mx-team">' + esc(t.name) + "</td>" +
            MATRIX_KEYS.map(function (k) {
              return '<td class="mx-cell"><input type="checkbox" data-mx-key="' + k + '" data-mx-team="' + esc(t.name) + '"' + ((mx[k] || []).indexOf(t.name) !== -1 ? " checked" : "") + " /></td>";
            }).join("") +
            '<td class="mx-mail"><input class="input" data-te-team="' + esc(t.name) + '" value="' + esc(te[t.name] || "") + '" placeholder="팀장 메일 (예: name@company.com; name2@company.com)" /></td></tr>';
        }).join("") + addRow;
      }).join("") + '</tbody><tfoot><tr><td colspan="2"><b>선정 팀 수</b></td>' + MATRIX_KEYS.map(function (k) { return "<td><b>" + (mx[k] || []).length + "</b></td>"; }).join("") +
      '<td class="mx-mail muted">주소 입력 팀 ' + Object.keys(te).filter(function (k) { return (te[k] || "").trim(); }).length + "개</td></tr></tfoot></table>";
  }
  function renderBizplan() {
    var box = $("#bizBody");
    if (!box) return;
    var b = state.bizplan;
    if (!b) return;
    var sheets = b.sheets || [], st = b.itemStatus;
    box.innerHTML = '<div class="biz-head">' + (b.fileName ? '<span>📄 <b>' + esc(b.fileName) + '</b> <span class="muted">업로드 ' + esc(b.uploadedAt) + "</span></span>" : '<span class="muted">등록된 사업계획이 없습니다.</span>') +
      '<button class="btn btn-upload btn-sm" data-action="bizPick">📤 사업계획 업로드 (.xlsx)</button><input id="bizFile" type="file" accept=".xlsx,.xlsm" style="display:none" /></div>' +
      (b.fileName ? '<table class="biz-table"><thead><tr><th style="width:110px">구분</th><th style="width:200px">시트</th><th style="width:100px">MS 시작 칸</th><th style="width:90px">읽은 MS</th><th>예시 (앞 3개)</th></tr></thead><tbody>' +
        MATRIX_KEYS.map(function (k) {
          var c = (b.config || {})[k] || {}, err = (b.errors || {})[k];
          return "<tr><td><b>" + k + "</b></td><td><select class=\"select\" data-bz-key=\"" + k + '" data-bz-f="sheet"><option value="">(시트 선택)</option>' +
            sheets.map(function (n) { return '<option value="' + esc(n) + '"' + (c.sheet === n ? " selected" : "") + ">" + esc(n) + "</option>"; }).join("") + "</select></td>" +
            '<td><input class="input" data-bz-key="' + k + '" data-bz-f="cell" value="' + esc(c.cell || "") + '" /></td>' +
            "<td><b>" + ((b.counts || {})[k] || 0) + "</b>개</td>" +
            "<td>" + (err ? '<span class="biz out">' + esc(err) + "</span>" : '<span class="muted">' + esc(((b.samples || {})[k] || []).join(", ")) + "</span>") + "</td></tr>";
        }).join("") + "</tbody></table>" +
        '<div class="biz-foot"><span class="card-sub">시트 이름에 300/200 과 PW/EPI 가 들어 있으면 자동으로 찾습니다. 다르면 시트·시작 칸을 고친 뒤 [다시 읽기].</span>' +
        '<button class="btn btn-secondary btn-sm" data-action="bizReparse">🔄 이 설정으로 다시 읽기</button></div>' +
        (st ? '<div class="biz-result">안건 확인 결과: ' + [["in", "✅ 반영"], ["partial", "◐ 일부"], ["other", "⚠️ 다른 구분"], ["out", "❌ 미반영"], ["noms", "MS 미입력"], ["notype", "구경 미지정"]].map(function (x) {
          return x[1] + " <b>" + (st[x[0]] || 0) + "</b>";
        }).join(" · ") + "</div>" : "")
        : '<div class="card-sub">한 파일에 4개 시트로 넣어 업로드하세요. 기본 시작 칸: 300mm PW = C6, 300mm EPI = D4, 200mm PW = C4, 200mm EPI = A6 (업로드 후 바꿀 수 있음)</div>');
    var inp = $("#bizFile");
    if (inp) inp.onchange = function () {
      if (!this.files.length) return;
      var fd = new FormData(); fd.append("file", this.files[0], this.files[0].name);
      toast("사업계획을 읽는 중…");
      api("POST", "/api/admin/bizplan", fd).then(bizDone).catch(fail);
      this.value = "";
    };
  }
  function bizDone(b) {
    state.bizplan = b; renderBizplan();
    loadAll().then(function () { if (state.detail) renderDetail(); });
    var total = Object.keys(b.counts || {}).reduce(function (n, k) { return n + b.counts[k]; }, 0);
    toast("사업계획 MS " + total + "개를 읽고 안건 반영 여부를 다시 확인했습니다.", "ok");
  }
  function renderUserRows() {
    var body = $("#userBody");
    if (!body) return;
    var list = state.adminUsers || [];
    var pending = list.filter(function (u) { return u.status === "pending"; }).length;
    $("#userCounts").innerHTML = "전체 " + list.length + "명" + (pending ? ' · <span class="badge badge-wait">승인 대기 ' + pending + "명</span>" : "");
    if (!list.length) { body.innerHTML = '<tr><td colspan="8" class="empty-state">가입 신청한 회원이 없습니다. [👤 로그인 / 가입] 메뉴에서 가입 신청할 수 있습니다.</td></tr>'; return; }
    var ST = { pending: '<span class="badge badge-wait">승인 대기</span>', approved: '<span class="badge badge-done">승인</span>', rejected: '<span class="badge" style="background:#fee2e2;color:#b91c1c">반려</span>' };
    body.innerHTML = list.map(function (u) {
      var perm = [u.canApply ? "📝 신청" : "", u.sector ? "🖊 " + u.sector + " 검토" : ""].filter(Boolean).join(" · ") || '<span class="muted">열람</span>';
      var teamSel = '<select class="select" data-user-team="' + esc(u.empId) + '">' + state.teams.map(function (t) {
        return '<option value="' + esc(t.name) + '"' + (u.team === t.name ? " selected" : "") + ">" + esc(t.name) + "</option>";
      }).join("") + (state.teams.some(function (t) { return t.name === u.team; }) ? "" : '<option selected value="' + esc(u.team) + '">' + esc(u.team) + " (삭제된 팀)</option>") + "</select>";
      return '<tr class="' + (u.status === "pending" ? "row-pending" : "") + '"><td>' + (ST[u.status] || esc(u.status)) + "</td><td>" + esc(u.empId) + "</td>" +
        '<td style="font-weight:700">' + esc(u.name) + ' <span class="muted">' + esc(u.title) + "</span></td><td>" + teamSel + "</td><td>" + perm + "</td>" +
        '<td style="font-size:12px">' + esc(u.email) + '</td><td style="font-size:12px">' + esc(u.createdAt) + "</td>" +
        '<td style="text-align:right">' +
        (u.status !== "approved" ? '<button class="btn btn-primary btn-sm" data-action="userApprove" data-emp="' + esc(u.empId) + '">✓ 승인</button> ' : "") +
        (u.status === "pending" ? '<button class="btn btn-secondary btn-sm" data-action="userReject" data-emp="' + esc(u.empId) + '">반려</button> ' : "") +
        (u.status === "approved" ? '<button class="btn btn-secondary btn-sm" data-action="userResetPw" data-emp="' + esc(u.empId) + '">비번 초기화</button> ' : "") +
        '<button class="btn btn-danger btn-sm" data-action="userDelete" data-emp="' + esc(u.empId) + '">삭제</button></td></tr>';
    }).join("");
  }
  function renderTeamRows() {
    var body = $("#teamBody");
    if (!body) return;
    body.innerHTML = state.teamDraft.map(function (t, i) {
      return '<div class="team-row"><input class="input" data-team="' + i + '" data-teamf="name" value="' + esc(t.name) + '" placeholder="팀 이름" />' +
        '<select class="select" data-team="' + i + '" data-teamf="sector"><option value="">(없음)</option>' + SECTORS.map(function (s) {
          return '<option value="' + esc(s) + '"' + (t.sector === s ? " selected" : "") + ">" + esc(s) + "</option>";
        }).join("") + "</select>" +
        '<label class="check-line" title="양산이관 신청 가능"><input type="checkbox" data-team="' + i + '" data-teamf="canApply"' + (t.canApply ? " checked" : "") + " />신청</label>" +
        '<button class="btn btn-danger btn-sm" data-action="teamDel" data-idx="' + i + '" title="삭제">✕</button></div>';
    }).join("");
  }
  function userAction(empId, body, msg) {
    return api("POST", "/api/admin/users/" + encodeURIComponent(empId), body).then(function (list) {
      state.adminUsers = list; renderUserRows(); if (msg) toast(msg, "ok");
    }).catch(fail);
  }



  // =====================================================================
  // 상세 모달
  // =====================================================================
  // 다른 사람이 방금 작성한 내용이 보이도록, 열기 전에 서버 버전을 확인해 필요하면 새로 불러온다.
  // 목록 데이터는 가볍게(이력·진행 기록·회의록 본문 제외) 받고, 상세 창을 열 때 그 안건 전체를 받는다.
  function openDetail(id) {
    fetchFull(id).then(function () { openDetailNow(id); });
  }
  function fetchFull(id) {
    return api("GET", "/api/items/" + encodeURIComponent(id)).then(function (full) { replaceItem(full); return full; })
      .catch(function () { return findItem(id); /* 오프라인이면 캐시로 */ });
  }
  function openDetailNow(id) {
    if (state.taskPanel) closeTaskPanel(true);
    var item = findItem(id);
    if (!item) { toast("안건을 찾을 수 없습니다: " + id, "err"); return; }
    state.detail = { id: id, orig: clone(item), draft: clone(item), ext: null, taskExt: null, acceptFor: null };
    initMail(item, "detail");
    renderDetail();
    $("#detailModal").classList.add("open");
    $("#detailModal").setAttribute("aria-hidden", "false");
    if (state.isAdmin && !state.adminUsers) api("GET", "/api/admin/users").then(function (list) { state.adminUsers = list; if (state.detail) { renderTaskBox(); renderMailPanel(); } }).catch(function () { });
    if (state.isAdmin && !state.admin) loadAdminSettings().then(function () { if (state.detail) { initMail(findItem(id) || item, "detail"); renderMailPanel(); } }).catch(fail);
  }
  function isDirty() { return state.detail && JSON.stringify(state.detail.draft) !== JSON.stringify(state.detail.orig); }
  function closeDetail(force) {
    if (!state.detail) return;
    if (!force && isDirty() && !confirm("저장하지 않은 변경사항이 있습니다. 닫으시겠습니까?")) return;
    state.detail = null;
    $("#detailModal").classList.remove("open");
    $("#detailModal").setAttribute("aria-hidden", "true");
    if (/^#items\//.test(location.hash)) history.replaceState(null, "", "#items");
    if (state.mail && state.mail.host === "detail") state.mail = null;
    render(false);
  }
  // 서버가 바꾼 필드(첨부/접수/rev)를 draft·orig 양쪽에 반영해 '미저장' 오판을 막는다.
  function syncServerFields(updated) {
    replaceItem(updated);
    if (!state.detail || state.detail.id !== updated.id) return;
    ["rev", "attachments", "accepted", "notify", "updatedAt", "audit", "finalNotify"].forEach(function (k) {
      state.detail.draft[k] = clone(updated[k]);
      state.detail.orig[k] = clone(updated[k]);
    });
  }

  function renderDetail() {
    var d = state.detail.draft, si = stageInfo(d), admin = state.isAdmin, dis = admin ? "" : "disabled";
    if (!state.detail.collapsed) state.detail.collapsed = { info: !admin, note: !admin };
    var col = state.detail.collapsed;
    var secBtn = function (k) { return '<button class="btn btn-secondary btn-xs" data-action="secToggle" data-sec="' + k + '">' + (col[k] ? "펼치기 ▼" : "접기 ▲") + "</button>"; };
    var myTeam = !admin && state.user && d.reviews[state.user.team] ? state.user.team : "";
    var roleBanner = admin ? ""
      : myTeam ? '<div class="banner info"><span>🖊 <b>' + esc(myTeam) + "</b> 이(가) 검토 팀으로 선정되었습니다. 아래 [3]의 " + esc(myTeam) +
        " 줄에서 <b>✅ 이상 없음</b> 또는 <b>⚠️ Risk 있음</b>을 고르고 <b>[✅ 작성 완료]</b>를 누르면 간사에게 메일이 발송됩니다. (작성 이력이 남습니다)</span></div>"
      : '<div class="banner warn"><span>🔒 열람 모드입니다. ' + (state.user ? "우리 팀(" + esc(state.user.team) + ")은 이 안건의 검토 팀으로 선정되지 않았습니다." : "검토 의견 작성은 로그인 후, 전체 수정은 [관리자 모드]에서 가능합니다.") + "</span>" +
        (state.user ? "" : '<button class="btn btn-secondary btn-sm" data-action="nav" data-route="account">👤 로그인</button>') + "</div>";
    $("#detailHeader").innerHTML =
      '<div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap"><h3>' + esc(d.title || "(제목 없음)") + "</h3>" + catBadge(d) + trackBadges(si) + longItemBadge(d) +
      '<span class="muted" style="font-size:12.5px">' + esc(d.id) + " · 요청자 " + esc(d.requester) + " · 발제일 " + esc(d.proposalDate) + "</span></div>" +
      '<div style="display:flex;gap:8px"><button class="btn btn-excel btn-sm" data-action="csvSingle">📥 이 안건만 엑셀 저장</button>' +
      '<button class="btn btn-secondary btn-sm" data-action="closeDetail">✕ 닫기</button></div>';

    var notify = d.notify ? '<div class="banner ' + (d.notify.status === "failed" ? "warn" : "info") + '"><span>📨 신규 신청 알림 메일: ' +
      ({ sent: "발송 완료", failed: "발송 실패", skipped: "발송 안 함", pending: "발송 대기" }[d.notify.status] || d.notify.status) +
      " — " + esc(d.notify.message || "") + ' <span class="muted">(' + esc(d.notify.at || "") + ")</span></span></div>" : "";

    $("#detailBody").innerHTML =
      (d.accepted === false ? '<div class="banner wait"><span>🆕 접수대기 안건입니다. 내용을 확인한 뒤 접수 승인하세요.</span>' +
        (admin ? '<button class="btn btn-primary btn-sm" data-action="acceptItem" data-id="' + esc(d.id) + '">✓ 접수 승인</button>' : "") + "</div>" : "") +
      notify +
      (longItemOf(d) ? '<div class="banner long"><span>⏳ <b>장기 안건</b> — 발제일 + ' + longItemOf(d) + "개월 경과 · 원인: <b>" + esc(longCause(d)) + "</b>" +
        (admin ? "" : d.longReason ? " · 사유: " + esc(d.longReason) : "") + "</span>" +
        (admin ? '<input class="input long-reason" data-dfield="longReason" value="' + esc(d.longReason || "") + '" placeholder="장기 사유 메모 (예: 고객 승인 일정, 설비 입고 대기) — 저장 시 반영" />' : "") + "</div>" : "") +
      (d.finalNotify ? '<div class="banner ' + (d.finalNotify.status === "failed" ? "warn" : "info") + '"><span>🏁 최종승인 알림 메일: ' +
        ({ sent: "발송 완료", failed: "발송 실패", skipped: "발송 안 함" }[d.finalNotify.status] || d.finalNotify.status) + " — " + esc(d.finalNotify.message || "") +
        ' <span class="muted">(' + esc(d.finalNotify.at || "") + ")</span></span></div>" : "") +
      roleBanner +

      '<div class="section' + (col.info ? " collapsed" : "") + '" data-sec-body="info"><div class="section-head"><div class="section-title">📌 기본 정보' +
      (col.info ? ' <span class="muted sec-peek">' + esc(d.requester + " · " + (d.requesterDept || "") + " · 발제 " + d.proposalDate) + "</span>" : "") + "</div>" + secBtn("info") + '</div><div class="info-grid sec-body">' +
      '<div class="field"><label>구분</label><select class="select" data-dfield="category" ' + dis + '><option value="제품"' + (d.category === "제품" ? " selected" : "") + '>제품</option><option value="기술"' + (d.category === "기술" ? " selected" : "") + ">기술</option></select></div>" +
      '<div class="field"><label>NP / SP</label><select class="select" data-dfield="npSp" ' + (admin && d.category === "제품" ? "" : "disabled") + ">" +
      (d.category === "제품" ? '<option value="NP"' + (d.npSp === "NP" ? " selected" : "") + '>NP</option><option value="SP"' + (d.npSp === "SP" ? " selected" : "") + ">SP</option>" : '<option value="">해당없음</option>') + "</select></div>" +
      ('<div class="field"><label>구경 · PW/EPI</label><div style="display:flex;gap:4px">' +
        '<select class="select" data-dfield="productSize" ' + dis + '><option value="">구경</option>' + ["300mm", "200mm"].map(function (v) { return '<option value="' + v + '"' + (d.productSize === v ? " selected" : "") + ">" + v + "</option>"; }).join("") + "</select>" +
        '<select class="select" data-dfield="productType" ' + dis + '><option value="">PW/EPI</option>' + ["PW", "EPI"].map(function (v) { return '<option value="' + v + '"' + (d.productType === v ? " selected" : "") + ">" + v + "</option>"; }).join("") + "</select></div></div>") +
      '<div class="field span2"><label>제품 / 기술명</label><input class="input" data-dfield="title" value="' + esc(d.title) + '" ' + dis + " /></div>" +
      '<div class="field"><label>요청자</label><input class="input" data-dfield="requester" value="' + esc(d.requester) + '" ' + dis + " /></div>" +
      '<div class="field"><label>소속 부서</label><input class="input" data-dfield="requesterDept" value="' + esc(d.requesterDept) + '" ' + dis + " /></div>" +
      '<div class="field"><label>요청자 이메일</label><input class="input" data-dfield="requesterEmail" value="' + esc(d.requesterEmail) + '" ' + dis + " /></div>" +
      '<div class="field"><label>발제일</label><input type="date" class="input" data-dfield="proposalDate" value="' + esc(d.proposalDate) + '" ' + dis + " /></div>" +
      '<div class="field"><label>제품 MS</label><input class="input" data-dfield="ms" value="' + esc(d.ms || "") + '" placeholder="여러 개는 , 로 구분" ' + dis + " /></div>" +
      '<div class="field"><span class="lbl">사업계획 반영 여부</span><div id="bizBox">' + bizBadge(d) + "</div></div>" +
      '<div class="field span4"><label>양산이관 주요 내용 및 변경점</label><textarea class="textarea" data-dfield="summary" ' + dis + ">" + esc(d.summary) + "</textarea></div>" +
      '<div class="field span4"><span class="lbl">첨부파일</span><div id="attBox"></div></div></div></div>' +

      '<div class="section' + (col.note ? " collapsed" : "") + '" data-sec-body="note"><div class="section-head"><div class="section-title"><span class="section-num">1</span>비고란 (Note)' +
      (col.note && d.note ? ' <span class="muted sec-peek">' + esc(d.note.split("\n")[0].slice(0, 50)) + (d.note.length > 50 ? "…" : "") + "</span>" : "") + "</div>" + secBtn("note") + "</div>" +
      '<textarea class="textarea note sec-body" data-dfield="note" placeholder="회의 요약 및 특이사항 기록..." ' + dis + ">" + esc(d.note) + "</textarea></div>" +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">2</span>5단계 진행 현황 및 전결(Skip) 제어</div>' +
      '<span id="stageBadge"></span></div><div class="stepper" id="stepperBox"></div><div id="extHistory"></div><div id="meetingBox" class="mtg-grid"></div>' +
      '<div class="card-sub">목표일은 자동 지정됩니다 (1단계: 접수 승인일 + ' + state.leadDays.step1 + '영업일, 이후: 앞 단계 완료일 + 7영업일, 주말·휴일 제외) · 목표일 변경은 관리자가 [⏰ 연장]으로만 · ⚡/📌 버튼은 다시 누르면 원복됩니다</div></div>' +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">3</span>전문소위원 검토 의견 — 선정된 검토 팀</div>' +
      '<span id="reviewSummary"></span></div>' +
      '<div class="card-sub">선정된 팀이 ✅ 이상 없음(의견 선택) / ⚠️ Risk 있음을 작성합니다. Risk 는 2단계 검증소위원회에서 간사가 <b>[🛠 과제 등록]</b> 또는 <b>[✔ 수용]</b>으로 결정합니다.</div>' +
      '<div class="review-grid" id="reviewGrid"></div></div>' +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">4</span>🛠 보완 과제</div><span id="taskSummary"></span></div>' +
      '<div class="card-sub">중요도 <b>상</b> = 양산이관 전 완료 필수(미완료 시 최종승인 불가) · <b>중·하</b> = 남아 있어도 조건부 승인 가능 · 목표일 변경은 [⏰ 연장](사유 필수)</div>' +
      '<div id="taskBox"></div></div>' +

      '<div class="section"><div id="auditBox"></div></div>' +

      (admin ? '<div class="section admin-section"><div class="section-head"><div class="section-title"><span class="section-num">5</span>전문(소)위원 선정 · 검토 요청 메일 <span class="badge badge-gray">관리자 전용</span></div>' +
        '<span class="card-sub">메일 본문은 저장된 안건 내용 기준으로 작성됩니다</span></div><div id="teamPick"></div><div id="mailHost-detail"></div></div>' : "");

    $("#detailFooter").innerHTML =
      (admin ? '<button class="btn btn-danger" data-action="deleteItem" data-id="' + esc(d.id) + '">🗑 이 안건 삭제</button>' : "<span></span>") +
      '<div style="display:flex;gap:8px;margin-left:auto"><button class="btn btn-secondary" data-action="closeDetail">닫기</button>' +
      (admin ? '<button class="btn btn-primary" data-action="detailSave">💾 저장 (공유폴더 즉시 반영)</button>' : "") +
      (myTeam ? '<button class="btn btn-teal" data-action="teamSave">💾 임시 저장</button><button class="btn btn-primary" data-action="teamComplete">✅ ' + esc(myTeam) + " 작성 완료 (간사에게 메일)</button>" : "") + "</div>";

    renderAttachments(); renderStepper(); renderMeetings(); renderAudit(); renderTeamPick(); renderMailPanel(); renderReviews(); renderTaskBox();
  }

  // 사업계획(관리자 업로드) 대비 제품 MS 반영 여부 — 서버가 계산해 안건에 기록
  function bizBadge(d) {
    var orig = state.detail && state.detail.orig, bp = d.bizPlan;
    if (orig && (orig.ms || "") !== (d.ms || "") || orig && (orig.productSize !== d.productSize || orig.productType !== d.productType)) return '<span class="biz none">💾 저장하면 다시 확인합니다</span>';
    if (!bp) bp = { status: "noplan" };  // 사업계획을 한 번도 올리지 않았으면 확인 기록이 없음
    var key = esc(bp.key || "");
    return {
      "in": '<span class="biz in">✅ 반영 <small>' + key + " 사업계획</small></span>",
      partial: '<span class="biz part" title="미반영 MS: ' + esc((bp.missing || []).join(", ")) + '">◐ 일부 반영 <small>미반영 ' + esc((bp.missing || []).join(", ")) + "</small></span>",
      other: '<span class="biz part">⚠️ 미반영 <small>' + esc((bp.others || []).join(", ")) + " 사업계획에 있음</small></span>",
      out: '<span class="biz out">❌ 미반영 <small>' + key + " 사업계획에 없음</small></span>",
      noms: '<span class="biz none">MS 미입력</span>',
      notype: '<span class="biz none">구경·PW/EPI 미지정</span>',
      noplan: '<span class="biz none">사업계획 미등록' + (state.isAdmin ? " (관리자 모드에서 업로드)" : "") + "</span>"
    }[bp.status] || "";
  }
  function renderAttachments() {
    var d = state.detail.draft, box = $("#attBox");
    box.innerHTML = '<div class="file-list"' + (state.isAdmin ? ' data-drop="detail" title="파일을 끌어다 놓으면 바로 업로드됩니다"' : "") + ">" + (d.attachments.length ? d.attachments.map(function (a) {
      var url = "/api/items/" + encodeURIComponent(d.id) + "/attachments/" + encodeURIComponent(a.name);
      return '<span class="file-chip">📄 <a href="' + url + '" download title="' + esc((a.uploadedAt || "") + " · " + (a.by || "")) + '">' + esc(a.name) + '</a><span class="muted">' + fmtSize(a.size) + "</span>" +
        (state.isAdmin ? '<button class="x" data-action="attDelete" data-name="' + esc(a.name) + '" title="삭제">✕</button>' : "") + "</span>";
    }).join("") : '<span class="muted">첨부파일 없음</span>') +
      (state.isAdmin ? '<button class="btn btn-upload btn-sm" data-action="attPick">📤 파일 추가 (드래그 가능)</button><input id="attFiles" type="file" multiple style="display:none" />' : "") + "</div>";
    var inp = $("#attFiles");
    if (inp) inp.onchange = function () { uploadAttachments(this.files); };
  }

  function renderStepper() {
    var d = state.detail.draft, st = d.stages, admin = state.isAdmin, dis = admin ? "" : " disabled";
    var fastOn = st.step2.skipped && st.step3.skipped && st.step4.skipped;
    var subOn = !st.step2.skipped && st.step3.skipped && st.step4.skipped;
    var ext = state.detail.ext, curInfo = stageInfo(d), curKey = curInfo.phase === "ING" ? STAGES[curInfo.idx].key : "";
    $("#stepperBox").innerHTML = STAGES.map(function (s, i) {
      var o = st[s.key], delay = stageDelayOf(o);
      var cls = "step-box" + (o.skipped ? " skipped" : o.done ? " completed" : delay ? " delayed" : o.target ? " scheduled" : "") + (i === 4 ? " final" : "");
      var label = o.skipped ? "🚫 생략(Skip)" : o.done ? "✓ 완료" : delay ? "🚨 지연" : o.target ? "⏳ 진행중" : "대기";
      var info = "";
      if (!o.skipped) {
        info = '<div class="step-dates">' +
          (o.target ? '<div><span class="lbl">목표</span><b>' + fmtDay(o.target) + "</b>" + (delay ? ' <span class="badge badge-delay">+' + delay + "일</span>" : "") + "</div>" : "") +
          (o.extensions.length ? '<div><button class="ext-chip" data-action="extHistToggle" title="원래 목표 ' + esc(o.targetOriginal) + ' · 눌러서 변경 이력 보기">⏰ 연장 ' + o.extensions.length + "회 " + (state.detail.showExt ? "▲" : "▼") + "</button></div>" : "") +
          (o.done ? '<div><span class="lbl">완료</span>' + (admin ? '<input type="date" class="input mini" data-stage-done="' + s.key + '" value="' + esc(o.doneAt) + '" />' : "<b>" + fmtDay(o.doneAt) + "</b>") + "</div>" : "") +
          (o.meetings && o.meetings.length ? '<div><span class="badge badge-mtg" title="' + esc(o.meetings.map(function (m) { return m.no + "차 " + (m.date || "-") + " " + (m.result || "결과 미입력"); }).join("\n")) + '">🗓 ' + meetingLabel(o) + "</span></div>" : "") +
          (!o.target && !o.done ? '<div class="muted">' + (d.accepted === false ? "접수 승인 후 목표일 자동 지정" : i === 0 ? "접수 승인일 + " + state.leadDays[s.key] + "영업일" : "앞 단계 완료 시 +" + state.leadDays[s.key] + "영업일") + "</div>" : "") +
          "</div>";
      }
      var doneBtn = '<button class="step-btn ' + (o.done ? "on" : "") + '" data-action="stDone" data-step="' + s.key + '"' + (admin && !o.skipped ? "" : " disabled") + ">" +
        (o.done ? (i === 4 ? "✓ 최종승인 완료 (해제)" : "✓ 완료됨 (해제)") : (i === 4 ? "최종승인 완료 처리" : "완료 처리")) + "</button>";
      var extBtn = admin && s.key === curKey ? '<button class="step-btn ext" data-action="stExtOpen" data-step="' + s.key + '">' + (o.target ? "⏰ 목표일 연장" : "📅 목표일 지정") + "</button>" : "";
      var skipBtn = '<button class="step-btn skip ' + (o.skipped ? "on" : "") + '" data-action="stSkip" data-step="' + s.key + '"' + dis + ">" + (o.skipped ? "생략됨 (클릭 시 원복)" : "이 단계 생략(Skip)") + "</button>";
      var extra = "";
      if (i === 0) extra = '<button class="step-btn fast ' + (fastOn ? "on" : "") + '" data-action="stFast"' + dis + ">" + (fastOn ? "⚡ 패스트트랙 해제 (원복)" : "⚡ 패스트트랙 (2~4단계 Skip)") + "</button>";
      if (i === 1) extra = '<button class="step-btn subd ' + (subOn ? "on" : "") + '" data-action="stSub"' + (admin && !st.step2.skipped ? "" : " disabled") + ">" + (subOn ? "📌 소위 전결 해제 (원복)" : "📌 소위 전결 (3·4단계 Skip)") + "</button>";
      var form = ext && ext.key === s.key ? '<div class="ext-form"><div class="lbl">' + (o.target ? "새 목표일" : "목표일") + '</div><input type="date" class="input mini" data-ext="date" value="' + esc(ext.date) + '" />' +
        '<textarea class="textarea" data-ext="reason" placeholder="' + (o.target ? "연장 사유 (필수)" : "사유 (선택)") + '">' + esc(ext.reason) + "</textarea>" +
        '<div class="ext-btns"><button class="btn btn-secondary btn-sm" data-action="stExtCancel">취소</button><button class="btn btn-primary btn-sm" data-action="stExtApply">적용</button></div></div>' : "";
      return '<div class="' + cls + '"><div><div class="step-top"><span class="step-index">' + (i + 1) + '단계</span><span class="step-status">' + label + "</span></div>" +
        '<div class="step-name">' + s.name + "</div></div>" + info + form +
        '<div class="step-btns">' + doneBtn + (form ? "" : extBtn) + (i >= 1 && i <= 3 ? skipBtn : "") + extra + "</div></div>";
    }).join("");
    var si = stageInfo(d);
    $("#stageBadge").innerHTML = statusBadge(si) + ' <span class="badge badge-gray">현재: ' + esc(si.name) + "</span>" +
      (si.delay ? ' <span class="badge badge-delay">🚨 지연 +' + si.delay + "일</span>" : "") +
      (d.acceptedAt ? ' <span class="badge badge-gray">접수 ' + esc(d.acceptedAt) + "</span>" : "");
    // 연장 이력
    var hist = [];
    STAGES.forEach(function (s, i) {
      st[s.key].extensions.forEach(function (e) { hist.push({ no: i + 1, name: s.name, e: e }); });
    });
    $("#extHistory").innerHTML = hist.length && state.detail.showExt ? '<div class="ext-hist"><div class="lbl">⏰ 목표일 변경 이력 <button class="link-btn" data-action="extHistToggle">접기 ▲</button></div>' + hist.map(function (h) {
      return "<div><b>" + h.no + "단계 " + esc(h.name) + "</b> " + (h.e.from ? esc(h.e.from) + " → " : "지정 ") + "<b>" + esc(h.e.to) + "</b> · " + esc(h.e.reason || "-") +
        ' <span class="muted">(' + esc(h.e.by) + " " + esc(h.e.at) + ")</span></div>";
    }).join("") + "</div>" : "";
  }


  // ---- 변경 이력 (누가·언제·무엇을) ----
  function renderAudit() {
    var box = $("#auditBox");
    if (!box) return;
    var d = state.detail.draft, list = (d.audit || []).slice().reverse(), open = !!state.detail.showAudit;
    box.innerHTML = '<div class="section-head"><div class="section-title">🕘 변경 이력 <span class="badge badge-gray">' + list.length + "건</span></div>" +
      '<button class="btn btn-secondary btn-sm" data-action="auditToggle">' + (open ? "접기 ▲" : "펼치기 ▼") + "</button></div>" +
      (!open ? "" : list.length ? '<div class="audit-list">' + list.map(function (a) {
        return '<div class="audit-row"><span class="audit-at">' + esc(a.at) + '</span><span class="audit-by">' + esc(a.by) + '</span><span class="audit-act">' + esc(a.action) + "</span></div>";
      }).join("") + "</div>" : '<div class="muted">기록된 변경 이력이 없습니다. (v12 설치 이후 변경부터 기록됩니다)</div>');
  }

  // ---- 2단계(검증소위원회)·4단계(검증위원회) 회의 차수 · 회의록 ----
  var MEETING_STAGES = ["step2", "step4"];
  var MEETING_RESULTS = ["통과", "조건부 통과", "재심의", "보류"];
  function meetingLabel(st) {
    var ms = st.meetings || [], last = ms[ms.length - 1];
    return ms.length ? (ms.length > 1 ? ms.length + "차 회의" : "1차 회의") + (last.result ? " · " + last.result : "") : "";
  }
  function renderMeetings() {
    var box = $("#meetingBox");
    if (!box) return;
    var d = state.detail.draft, admin = state.isAdmin, base = "/api/items/" + encodeURIComponent(d.id);
    box.innerHTML = MEETING_STAGES.map(function (key) {
      var idx = STAGES.findIndex(function (s) { return s.key === key; }), st = d.stages[key], ms = st.meetings || [];
      if (st.skipped || (!ms.length && (!admin || d.accepted === false))) return "";  // 생략 단계 · 기록 없는 회의는 숨김
      var lastM = ms[ms.length - 1], open = !!state.mtgExpand[key];
      var head = '<div class="mtg-head' + (ms.length ? " clickable" : "") + '"' + (ms.length ? ' data-action="mtgExpand" data-stage="' + key + '"' : "") + ">" +
        "<b>🗓 " + (idx + 1) + "단계 " + esc(STAGES[idx].name) + " 회의</b>" +
        (ms.length ? '<span class="muted">' + ms.length + "회 · 최근: " + lastM.no + "차 " + esc(lastM.date ? fmtDay(lastM.date) : "-") + (lastM.result ? " " + esc(lastM.result) : "") + (open ? " ▲" : " ▼") + "</span>" : '<span class="muted">기록 없음</span>') +
        (admin && d.accepted !== false ? '<button class="btn btn-secondary btn-xs" data-action="mtgAdd" data-stage="' + key + '">+ ' + (ms.length + 1) + "차 회의 추가</button>" : "") + "</div>";
      if (!ms.length || !open) return '<div class="mtg-card compact">' + head + "</div>";
      var rows = ms.length ? ms.map(function (m, i) {
        var a = ' data-stage="' + key + '" data-no="' + m.no + '"';
        // 예전(v11) 파일 회의록은 열람만 유지
        var files = m.minutes.map(function (f) {
          return '<span class="file-chip">📄 <a href="' + base + "/minutes/" + encodeURIComponent(f.name) + '" download>' + esc(f.name) + "</a>" +
            (admin ? '<button class="x" data-action="mtgFileDel"' + a + ' data-name="' + esc(f.name) + '" title="삭제">✕</button>' : "") + "</span>";
        }).join("");
        var open = !!state.mtgOpen[key + "-" + m.no], hasText = !!(m.minutesText || "").trim();
        var resCls = { "통과": "ok", "조건부 통과": "ok", "재심의": "re", "보류": "hold" }[m.result] || "";
        var toggle = (admin || hasText)
          ? '<button class="btn btn-xs ' + (open ? "btn-primary" : "btn-secondary") + '" data-action="mtgToggle"' + a + ">📝 회의록" + (hasText ? " ✓" : "") + (open ? " ▲" : " ▼") + "</button>"
          : '<span class="muted" style="font-size:11.5px">회의록 없음</span>';
        var minutesBox = !open ? "" : admin
          ? '<textarea class="textarea mtg-text" data-mtg="minutesText"' + a + ' placeholder="메일 본문의 회의록을 그대로 붙여넣으세요. (입력 칸 밖을 누르면 자동 저장)">' + esc(m.minutesText || "") + "</textarea>"
          : '<div class="mtg-text-view">' + esc(m.minutesText || "") + "</div>";
        return '<div class="mtg-row ' + resCls + '"><span class="mtg-no">' + m.no + "차</span>" +
          (admin
            ? '<input type="date" class="input mini" data-mtg="date"' + a + ' value="' + esc(m.date) + '" />' +
              '<select class="select mini" data-mtg="result"' + a + '><option value="">결과 선택</option>' + MEETING_RESULTS.map(function (r) { return '<option' + (m.result === r ? " selected" : "") + ">" + r + "</option>"; }).join("") + "</select>" +
              '<input class="input mtg-note" data-mtg="note"' + a + ' value="' + esc(m.note) + '" placeholder="한 줄 요약 / 재심의 사유" />'
            : '<b>' + esc(m.date ? fmtDay(m.date) : "-") + "</b>" + (m.result ? '<span class="mtg-res ' + resCls + '">' + esc(m.result) + "</span>" : "") +
              (m.note ? '<span class="mtg-note-text">' + esc(m.note) + "</span>" : "")) +
          '<div class="mtg-files">' + toggle + files +
          (admin && i === ms.length - 1 ? '<button class="link-btn" data-action="mtgDel"' + a + ">차수 삭제</button>" : "") + "</div>" + minutesBox + "</div>";
      }).join("") : '<div class="muted" style="padding:6px 2px">' + (admin ? "회의를 열면 [+ 1차 회의 추가]로 기록하고 [📝 회의록]에 메일 본문 회의록을 붙여넣으세요." : "기록된 회의가 없습니다.") + "</div>";
      var last = lastM;
      var hint = admin && last && last.result === "재심의" && !st.done ? '<div class="card-sub">↻ 재심의 결정 → [+ ' + (ms.length + 1) + "차 회의 추가] 후, 필요하면 위 단계의 [⏰ 목표일 연장]으로 일정을 조정하세요.</div>" : "";
      return '<div class="mtg-card">' + head + rows + hint + "</div>";
    }).join("");
    box.style.display = box.innerHTML ? "" : "none";
  }
  // 회의 API 는 즉시 저장된다 → 서버 값으로 회의·rev 만 맞춘다 (작성 중인 다른 수정은 그대로)
  function meetingApi(method, path, body, okMsg) {
    var id = state.detail.id;
    return api(method, "/api/items/" + encodeURIComponent(id) + "/meetings/" + path, body).then(function (updated) {
      replaceItem(updated);
      if (state.detail && state.detail.id === id) {
        [state.detail.draft, state.detail.orig].forEach(function (o) {
          o.rev = updated.rev; o.updatedAt = updated.updatedAt;
          MEETING_STAGES.forEach(function (k) { o.stages[k].meetings = clone(updated.stages[k].meetings); });
        });
        renderStepper(); renderMeetings();
      }
      if (okMsg) toast(okMsg, "ok");
    }).catch(fail);
  }
  function meetingField(el) {
    var p = {};
    p[el.getAttribute("data-mtg")] = el.value;
    meetingApi("PUT", el.getAttribute("data-stage") + "/" + el.getAttribute("data-no"), p, el.getAttribute("data-mtg") === "minutesText" ? "회의록을 저장했습니다." : "회의 정보를 저장했습니다.");
  }

  // ---- [3] 전문소위원 검토 의견: 부문별로 묶고 팀마다 한 줄 ----
  function renderReviews() {
    var d = state.detail.draft, grid = $("#reviewGrid"), admin = state.isAdmin;
    if (!grid) return;
    var order = cardOrder(d);
    if (!order.length) {
      grid.innerHTML = '<div class="empty-state" style="padding:18px">검토 팀이 아직 선정되지 않았습니다.' +
        (admin ? " 아래 [5] 전문(소)위원 선정에서 팀을 선택하세요." : " (간사가 선정합니다)") + "</div>";
    } else {
      // 한 줄에 2개씩: 품질/수율·생산성 / 장비·Process / 제조·손익
      grid.innerHTML = REVIEW_LAYOUT.map(function (sec) {
        var teams = order.filter(function (t) { return d.reviews[t].sector === sec; });
        if (!teams.length) return "";
        var doneCnt = teams.filter(function (t) { return d.reviews[t].done; }).length;
        return '<div class="rv-sector"><div class="rv-sector-head"><b>' + esc(sec) + '</b><span class="muted">' + teams.length + "팀 · 완료 " + doneCnt + "</span></div>" +
          teams.map(function (team) { return reviewRow(d, team); }).join("") + "</div>";
      }).join("");
    }
    var sm = reviewSummary(d);
    $("#reviewSummary").innerHTML = '<span class="badge badge-gray">작성 완료 ' + sm.completed + "/" + sm.total + "</span>" +
      (sm.riskCount ? ' <span class="badge badge-gray">Risk ' + sm.riskCount + "건</span>" : "") +
      (sm.undecided ? ' <span class="badge badge-wait">결정 대기 ' + sm.undecided + "건</span>" : "");
  }
  var REVIEW_LAYOUT = ["품질/수율", "생산성", "장비", "Process", "제조", "손익"];
  function reviewRow(d, team) {
    var c = d.reviews[team], admin = state.isAdmin, edit = canEditTeam(team), mine = edit && !admin;
    var tAttr = ' data-team="' + esc(team) + '"';
    var toggle = edit
      ? '<span class="rv-mini">' +
        '<button class="rv-opt ok sm' + (c.result === "ok" ? " on" : "") + '" data-action="rvResult"' + tAttr + ' data-val="ok">✅ 이상 없음</button>' +
        '<button class="rv-opt risk sm' + (c.result === "risk" ? " on" : "") + '" data-action="rvResult"' + tAttr + ' data-val="risk">⚠️ Risk 있음</button></span>'
      : (c.result === "ok" ? '<span class="rv-chip ok">✅ 이상 없음</span>' : c.result === "risk" ? '<span class="rv-chip risk">⚠️ Risk ' + c.risks.length + "건</span>" : '<span class="rv-chip none">⬜ 미작성</span>');
    var hist = c.history && c.history.length ? '<span class="rv-hist" title="' + esc(c.history.map(function (h) { return h.at + "  " + h.by + "  " + h.action; }).join("\n")) + '">🕘 이력 ' + c.history.length + "</span>" : "";
    var status = c.done
      ? '<span class="rv-done">✓ 완료 · ' + esc(c.done.name) + (c.done.title ? " " + esc(c.done.title) : "") + " " + esc((c.done.at || "").slice(5, 16)) +
        (admin ? ' <button class="x" data-action="teamReopen"' + tAttr + ' title="작성 완료 해제(재작성 요청)">✕</button>' : "") + "</span>"
      : '<span class="rv-pending">⏳ 미작성</span>' +
        (admin && d.accepted !== false ? " " + remindInfo(d, team) + ' <button class="btn btn-amber btn-xs" data-action="remind" data-kind="review" data-id="' + esc(d.id) + '" data-sectors="' + esc(team) + '">✉️ Remind</button>' : "");
    var body = "";
    if (c.result === "risk") {
      body = c.risks.map(function (r) { return riskHtml(team, r, edit); }).join("") +
        (edit ? '<button class="btn btn-secondary btn-sm" data-action="riskAdd"' + tAttr + '>+ Risk 추가</button>' : "");
    }
    if (c.result) {
      body += edit
        ? '<textarea class="textarea sm" data-rv-team="' + esc(team) + '" data-rvf="comment" placeholder="' + (c.result === "ok" ? "의견 (선택) · 비워 두면 '특이사항 없음'으로 저장됩니다" : "종합 의견 (선택)") + '">' + esc(c.comment) + "</textarea>"
        : (c.comment ? '<div class="rv-comment">💬 ' + esc(c.comment) + "</div>" : "");
    }
    var actions = mine ? '<div class="rv-actions"><button class="btn btn-teal btn-sm" data-action="teamSave">💾 임시 저장</button>' +
      '<button class="btn btn-primary btn-sm" data-action="teamComplete">✅ 작성 완료</button></div>'
      : admin && !c.done && c.result && d.accepted !== false ? '<div class="rv-actions"><button class="btn btn-primary btn-sm" data-action="teamProxy"' + tAttr + ' title="팀장이 작성하지 않을 때 관리자가 대신 작성 완료 처리 (이력에 대리 입력으로 남음)">✅ 대리 작성 완료</button></div>' : "";
    return '<div class="rv-row ' + (c.result || "none") + (mine ? " mine" : "") + '"><div class="rv-line"><span class="rv-team">' + esc(team) + "</span>" + toggle +
      '<span class="rv-status">' + status + hist + "</span></div>" + (body || actions ? '<div class="rv-body">' + body + actions + "</div>" : "") + "</div>";
  }
  function riskHtml(team, r, edit) {
    var admin = state.isAdmin, d = state.detail.draft, locked = !!r.decision, acc = state.detail.acceptFor;
    var content = edit && !locked
      ? '<textarea class="textarea" data-risk-id="' + esc(r.id) + '" data-rkf="content" placeholder="예상되는 Risk">' + esc(r.content) + "</textarea>" +
        '<textarea class="textarea sm" data-risk-id="' + esc(r.id) + '" data-rkf="proposal" placeholder="제안 보완 방안 (선택)">' + esc(r.proposal) + "</textarea>"
      : '<div class="rv-risk-text">' + esc(r.content || "-") + "</div>" + (r.proposal ? '<div class="rv-risk-prop">💡 ' + esc(r.proposal) + "</div>" : "");
    var dec;
    if (r.decision === "task") {
      var t = findTask(d, r.taskId) || {};
      dec = '<span class="dec task">🛠 과제 ' + esc(r.taskId) + " · 중요도 " + esc(t.importance || "-") + " · " + esc(t.status || "-") + "</span>" +
        (admin ? '<button class="link-btn" data-action="riskUndecide" data-risk-id="' + esc(r.id) + '">결정 취소</button>' : "");
    } else if (r.decision === "accept") {
      dec = '<span class="dec accept" title="' + esc(r.reason) + '">✔ 수용 — ' + esc(r.reason) + "</span>" +
        (admin ? '<button class="link-btn" data-action="riskUndecide" data-risk-id="' + esc(r.id) + '">결정 취소</button>' : "");
    } else if (admin && acc && acc.id === r.id) {
      dec = '<div class="accept-form"><input class="input" data-accept="reason" placeholder="수용 사유 (필수) 예) 현 수준 관리 가능" value="' + esc(acc.reason) + '" />' +
        '<button class="btn btn-secondary btn-sm" data-action="riskAcceptCancel">취소</button><button class="btn btn-primary btn-sm" data-action="riskAcceptOk">수용 확정</button></div>';
    } else if (admin) {
      dec = '<span class="dec none">결정 대기</span><button class="btn btn-primary btn-sm" data-action="riskToTask" data-risk-id="' + esc(r.id) + '">🛠 과제 등록</button>' +
        '<button class="btn btn-secondary btn-sm" data-action="riskAccept" data-risk-id="' + esc(r.id) + '">✔ 수용</button>';
    } else {
      dec = '<span class="dec none">위원회 결정 대기</span>';
    }
    return '<div class="rv-risk' + (locked ? " locked" : "") + '"><div class="rv-risk-top"><span class="rv-risk-no">' + esc(r.id) + "</span>" +
      (edit && !locked ? '<button class="x" data-action="riskDel" data-risk-id="' + esc(r.id) + '" title="삭제">✕</button>' : "") + "</div>" +
      content + '<div class="rv-dec">' + dec + "</div></div>";
  }

  // ---- [5] 전문(소)위원(검토 팀) 선정 ----
  function renderTeamPick() {
    var box = $("#teamPick");
    if (!box || !state.detail) return;
    var d = state.detail.draft, key = d.productSize && d.productType ? d.productSize + " " + d.productType : "";
    var matrix = (state.reviewMatrix || {})[key] || [];
    box.innerHTML = '<div class="pick-head"><span class="filter-label">검토 팀 선정 · ' + Object.keys(d.reviews).length + "팀</span>" +
      '<span class="badge badge-gray">구경 · PW/EPI: ' + esc(key || "미지정") + "</span>" +
      (d.category === "기술" ? '<span class="badge badge-tech">기술 안건: 공정에 맞게 직접 선정</span>' : "") +
      (matrix.length ? '<button class="btn btn-secondary btn-sm" data-action="pickMatrix">' + esc(key) + (d.category === "기술" ? " 기본 팀 불러오기 (참고, " : " 기본 팀 적용 (") + matrix.length + "팀)</button>" : "") + "</div>" +
      '<div class="pick-grid">' + SECTORS.map(function (sec) {
        var teams = state.teams.filter(function (t) { return t.sector === sec; });
        Object.keys(d.reviews).forEach(function (t) { if (d.reviews[t].sector === sec && !teams.some(function (x) { return x.name === t; })) teams.push({ name: t }); });
        return '<div class="pick-sector"><h5>' + esc(sec) + "</h5>" + teams.map(function (t) {
          var c = d.reviews[t.name];
          return '<label class="pick-team' + (c ? " on" : "") + (c && c.done ? " done" : "") + '"><input type="checkbox" data-pick-team="' + esc(t.name) + '"' + (c ? " checked" : "") + " />" +
            esc(t.name) + (c && c.done ? " ✓" : "") + (matrix.indexOf(t.name) !== -1 ? ' <span class="pick-def" title="제품 구분 기본 팀">기본</span>' : "") + "</label>";
        }).join("") + "</div>";
      }).join("") + "</div>" +
      '<div class="card-sub">선택하면 [3]에 해당 팀 줄이 바로 생깁니다. 선정 변경 후 [💾 저장]을 눌러야 반영됩니다. 위원회가 결정한 Risk 가 있는 팀은 해제할 수 없습니다.</div>';
  }
  function pickTeam(team, on) {
    var d = state.detail.draft, c = d.reviews[team];
    if (on && !c) {
      d.reviews[team] = newCard(team);
      autoSelectTeams([team]);
    } else if (!on && c) {
      if (c.risks.some(function (r) { return r.decision; })) { toast(team + " 은(는) 위원회가 결정한 Risk 가 있어 해제할 수 없습니다.", "err"); renderTeamPick(); return; }
      if ((c.result || c.done) && !confirm(team + " 이(가) 이미 작성한 검토 의견이 있습니다. 선정을 해제하면 의견이 삭제됩니다. 계속할까요?")) { renderTeamPick(); return; }
      delete d.reviews[team];
      autoSelectTeams([team], false);
    }
    renderTeamPick(); renderReviews(); renderMailPanel();
  }
  // 선정 팀의 팀장(가입 회원)을 메일 받는 사람으로 자동 선택
  function teamEmails(team) { return ((state.admin && state.admin.teamEmails) || {})[team] || []; }
  // 선정한 팀의 주소록 메일을 받는 사람으로 자동 체크 (해제하면 체크도 해제)
  function autoSelectTeams(teams, on) {
    if (!state.mail) return;
    teams.forEach(function (t) { teamEmails(t).forEach(function (e) { state.mail.selected[e] = on !== false; }); });
    state.mail.preview = null;
  }

  // ---- [4] 보완 과제 표 ----
  function memberOptions(t) {
    var users = (state.adminUsers || []).filter(function (u) { return u.status === "approved"; });
    return '<option value="">회원 선택</option>' + users.map(function (u) {
      return '<option value="' + esc(u.empId) + '"' + (t.ownerEmpId === u.empId ? " selected" : "") + ">" + esc(u.team + " " + u.name + " " + u.title) + "</option>";
    }).join("");
  }
  function renderTaskBox() {
    var d = state.detail.draft, box = $("#taskBox"), admin = state.isAdmin;
    if (!box) return;
    var tasks = d.tasks || [], saved = {};
    (state.detail.orig.tasks || []).forEach(function (t) { saved[t.id] = true; });
    var open = tasks.filter(function (t) { return t.status !== "완료"; });
    $("#taskSummary").innerHTML = tasks.length ? '<span class="badge badge-gray">과제 ' + tasks.length + "건</span> " +
      '<span class="badge badge-ing">진행 ' + open.length + "</span> " +
      (openTaskCount(d, "상") ? '<span class="badge badge-delay">상 미완료 ' + openTaskCount(d, "상") + "</span> " : "") +
      '<span class="badge badge-done">완료 ' + (tasks.length - open.length) + "</span>" : "";
    if (!tasks.length) { box.innerHTML = '<div class="empty-state" style="padding:18px">등록된 보완 과제가 없습니다.' + (admin ? " [3]의 Risk 에서 [🛠 과제 등록]을 누르면 여기에 추가됩니다." : "") + "</div>"; return; }
    var newOnes = tasks.filter(function (t) { return !saved[t.id]; });
    box.innerHTML = '<div class="card-sub">📋 등록된 과제의 진행 내용·완료 처리·목표일 연장은 <b>[🛠 보완 과제 현황]</b>에서 관리합니다. 행의 [관리 →]를 누르면 바로 열립니다.</div>' +
      '<div class="table-wrap"><table class="task-table"><thead><tr><th style="width:62px">과제</th><th style="width:60px">중요도</th><th>과제 내용</th><th style="width:200px">최근 진행 내용</th>' +
      '<th style="width:170px">담당</th><th style="width:110px">목표일</th><th style="width:150px">상태</th></tr></thead><tbody>' +
      tasks.filter(function (t) { return saved[t.id]; }).map(function (t) {
        var delay = taskDelay(t);
        return '<tr class="' + (delay ? "row-delay" : "") + '"><td><b>' + esc(t.id) + "</b></td>" +
          '<td><span class="grade-chip ' + GRADE_CLS[t.importance] + '">' + t.importance + "</span></td>" +
          '<td><div class="pre" style="font-weight:700">' + esc(t.title) + '</div><div class="pre muted" style="font-size:12px">💡 ' + esc(t.plan || "-") + "</div></td>" +
          "<td>" + lastProgressHtml(t) + "</td>" +
          '<td style="font-size:12.5px">' + ownerText(t) + "</td>" +
          "<td>" + esc(t.target ? fmtDay(t.target) : "미정") + (longTermOf(d, t) ? "<div>" + longBadge(longTermOf(d, t)) + "</div>" : "") + "</td>" +
          "<td>" + taskStateBadge(t, delay) + ' <button class="btn btn-secondary btn-xs" data-action="taskOpen" data-id="' + esc(d.id) + '" data-task="' + esc(t.id) + '">관리 →</button></td></tr>';
      }).join("") +
      newOnes.map(function (t) {
        var a = function (f) { return ' data-task-id="' + esc(t.id) + '" data-tkf="' + f + '"'; };
        return '<tr class="row-new"><td><b>' + esc(t.id) + '</b><div class="badge badge-wait">새 과제</div></td>' +
          '<td><select class="select"' + a("importance") + ">" + GRADES.map(function (g) { return '<option value="' + g + '"' + (t.importance === g ? " selected" : "") + ">" + g + "</option>"; }).join("") + "</select></td>" +
          '<td><textarea class="textarea sm"' + a("title") + ">" + esc(t.title) + '</textarea><textarea class="textarea sm"' + a("plan") + ' placeholder="보완 방안">' + esc(t.plan) + "</textarea></td>" +
          '<td class="muted" style="font-size:12px">저장 후 과제 화면에서 진행 내용을 기록합니다</td>' +
          '<td><input class="input"' + a("org") + ' placeholder="담당조직" value="' + esc(t.org) + '" /><select class="select" data-task-owner="' + esc(t.id) + '">' + memberOptions(t) + "</select>" +
          '<input class="input"' + a("ownerEmail") + ' placeholder="담당자 이메일" value="' + esc(t.ownerEmail) + '" /></td>' +
          '<td><input type="date" class="input mini"' + a("target") + ' value="' + esc(t.target) + '" /></td>' +
          '<td class="muted" style="font-size:12px">💾 저장하면 등록됩니다</td></tr>';
      }).join("") + "</tbody></table></div>";
  }

  // ---- 보완 과제 상세 패널 (오른쪽): 과제 정보 · 진행 내용 · 완료 처리 ----
  var TASK_LOG_LABEL = { progress: "📝 진행", request: "🙋 완료 요청", approve: "✅ 완료", reject: "↩ 반려", reopen: "↺ 완료 해제" };
  function isTaskOwner(t) {
    var u = state.user;
    if (!u) return false;
    return !!((t.ownerEmpId && t.ownerEmpId === u.empId) || (t.ownerEmail && u.email && t.ownerEmail.toLowerCase() === u.email.toLowerCase()));
  }
  function trackKey(item, t) { return item.id + "/" + t.id; }
  function taskLogHtml(item, t) {
    var base = "/api/items/" + encodeURIComponent(item.id) + "/taskfiles/";
    var log = (t.log || []).slice().reverse();
    return log.length ? '<div class="tl-list">' + log.map(function (x) {
      return '<div class="tl-item k-' + x.kind + '"><div class="tl-head"><span class="tl-kind">' + (TASK_LOG_LABEL[x.kind] || x.kind) + "</span><b>" + esc(x.by) + '</b><span class="muted">' + esc(x.at) + "</span></div>" +
        (x.note ? '<div class="tl-note">' + esc(x.note) + "</div>" : "") +
        (x.files && x.files.length ? '<div class="tl-files">' + x.files.map(function (f) { return '<span class="file-chip">📎 <a href="' + base + encodeURIComponent(f.name) + '" download>' + esc(f.name) + "</a></span>"; }).join("") + "</div>" : "") + "</div>";
    }).join("") + "</div>" : '<div class="muted" style="padding:6px 0">아직 진행 기록이 없습니다.</div>';
  }
  function ensureTaskPanel() {
    var p = $("#taskPanel");
    if (!p) {
      var bg = document.createElement("div"); bg.id = "taskPanelBg"; bg.className = "task-panel-bg"; bg.setAttribute("data-action", "taskClose");
      p = document.createElement("aside"); p.id = "taskPanel"; p.className = "task-panel";
      document.body.appendChild(bg); document.body.appendChild(p);
    }
    return p;
  }
  function openTaskPanel(itemId, taskId) {
    if (state.detail) closeDetail(true);
    state.taskPanel = { itemId: itemId, taskId: taskId, item: findItem(itemId), form: null, loading: true };
    renderTaskPanel(); if (state.route === "tasks") renderTasksTable();
    if (state.isAdmin && !state.adminUsers) api("GET", "/api/admin/users").then(function (l) { state.adminUsers = l; renderTaskPanel(); }).catch(function () { });
    fetchFull(itemId).then(function (full) {
      var tp = state.taskPanel;
      if (!tp || tp.itemId !== itemId) return;
      tp.item = full || findItem(itemId); tp.loading = false; renderTaskPanel();
    });
  }
  function tpTask() { var tp = state.taskPanel; return tp && tp.item ? (tp.item.tasks || []).find(function (t) { return t.id === tp.taskId; }) : null; }
  function tpDirty() {
    var tp = state.taskPanel, t = tpTask();
    if (!tp || !tp.form || !t) return false;
    return ["title", "plan", "importance", "org", "ownerEmpId", "ownerEmail", "target"].some(function (k) { return (tp.form[k] || "") !== (t[k] || ""); });
  }
  function closeTaskPanel(force) {
    if (!force && tpDirty() && !confirm("저장하지 않은 과제 정보 변경이 있습니다. 닫을까요?")) return;
    state.taskPanel = null; renderTaskPanel();
    if (state.route === "tasks") renderTasksTable();
  }
  function renderTaskPanel() {
    var box = ensureTaskPanel(), bg = $("#taskPanelBg"), tp = state.taskPanel;
    box.classList.toggle("open", !!tp); bg.classList.toggle("open", !!tp);
    if (!tp) { box.innerHTML = ""; return; }
    var it = tp.item, t = tpTask(), admin = state.isAdmin;
    if (!t) { box.innerHTML = '<div class="tp-head"><h3>과제를 찾을 수 없습니다</h3><button class="btn btn-secondary btn-sm" data-action="taskClose">✕</button></div>'; return; }
    if (!tp.form) tp.form = { title: t.title, plan: t.plan, importance: t.importance, org: t.org, ownerEmpId: t.ownerEmpId, ownerEmail: t.ownerEmail, target: t.target, reason: "" };
    var f = tp.form, delay = taskDelay(t), k = trackKey(it, t), lt = longTermOf(it, t), done = t.status === "완료";
    var a = ' data-id="' + esc(it.id) + '" data-task="' + esc(t.id) + '"';
    var info;
    if (admin) {
      var users = (state.adminUsers || []).filter(function (u) { return u.status === "approved"; });
      var targetChanged = t.target && f.target && f.target !== t.target;
      info = '<div class="tp-form">' +
        '<label>과제 내용</label><textarea class="textarea sm" data-tpf="title">' + esc(f.title) + "</textarea>" +
        '<label>보완 방안</label><textarea class="textarea sm" data-tpf="plan">' + esc(f.plan) + "</textarea>" +
        '<div class="tp-grid"><div><label>중요도</label><select class="select" data-tpf="importance">' + GRADES.map(function (g) { return "<option" + (f.importance === g ? " selected" : "") + ">" + g + "</option>"; }).join("") + "</select></div>" +
        '<div><label>담당조직</label><input class="input" data-tpf="org" value="' + esc(f.org) + '" /></div>' +
        '<div><label>담당자 (회원)</label><select class="select" data-tpf="ownerEmpId"><option value="">회원 선택 안 함</option>' + users.map(function (u) {
          return '<option value="' + esc(u.empId) + '"' + (f.ownerEmpId === u.empId ? " selected" : "") + ">" + esc(u.team + " " + u.name + " " + u.title) + "</option>";
        }).join("") + "</select></div>" +
        '<div><label>담당자 이메일 ' + (f.ownerEmpId ? '<span class="muted">(회원 메일 사용)</span>' : "") + '</label><input class="input" data-tpf="ownerEmail" value="' + esc(f.ownerEmpId ? (users.find(function (u) { return u.empId === f.ownerEmpId; }) || {}).email || f.ownerEmail : f.ownerEmail) + '"' + (f.ownerEmpId ? " disabled" : "") + " /></div>" +
        '<div><label>목표일</label><input type="date" class="input" data-tpf="target" value="' + esc(f.target) + '" /></div>' +
        (targetChanged ? '<div><label>연장 사유 <span class="req">*</span></label><input class="input" data-tpf="reason" value="' + esc(f.reason) + '" placeholder="목표일 변경 사유" /></div>' : "<div></div>") + "</div>" +
        '<div class="tp-btns"><button class="btn btn-primary btn-sm" data-action="taskSave"' + (tpDirty() ? "" : " disabled") + ">💾 과제 정보 저장</button>" +
        (t.ownerEmail && !done ? '<button class="btn btn-amber btn-sm" data-action="remind" data-kind="task"' + a + ">✉️ Remind</button>" + remindInfo(it, t.id) : "") + "</div></div>";
    } else {
      info = '<div class="tp-view"><div class="pre" style="font-weight:700">⚠️ ' + esc(t.title) + '</div><div class="pre muted">💡 ' + esc(t.plan || "-") + "</div>" +
        '<div class="tp-kv"><span>담당</span><b>' + ownerText(t) + "</b><span>목표일</span><b>" + esc(t.target ? fmtDay(t.target) : "미정") + "</b></div></div>";
    }
    var ext = t.extensions.length ? '<div class="tp-ext"><b>⏰ 목표일 변경 이력</b>' + t.extensions.map(function (e) {
      return "<div>" + esc(e.from) + " → <b>" + esc(e.to) + "</b> · " + esc(e.reason || "-") + ' <span class="muted">(' + esc(e.at) + ")</span></div>";
    }).join("") + "</div>" : "";
    var canWrite = !done && (isTaskOwner(t) || admin);
    var prog = '<div class="tp-sec"><h4>📝 진행 내용</h4>' +
      (canWrite ? '<textarea class="textarea" data-tp-note="' + esc(k) + '" placeholder="진행 내용을 적어 주세요. (메일 본문 붙여넣기 가능)">' + esc(state.taskForm[k] || "") + "</textarea>" +
        '<div class="tp-btns"><input type="file" multiple data-tp-files="' + esc(k) + '" />' +
        '<button class="btn btn-teal btn-sm" data-action="taskProgress"' + a + ">💾 진행 내용 저장</button>" +
        (!admin && !t.request ? '<button class="btn btn-primary btn-sm" data-action="taskProgress" data-request="1"' + a + ">🙋 완료 요청</button>" : "") + "</div>" : "") +
      (admin && !done ? '<div class="tp-btns admin"><input class="input" data-tp-comment="' + esc(k) + '" value="' + esc(state.taskForm[k + "#c"] || "") + '" placeholder="' + (t.request ? "의견 (반려 시 사유 필수)" : "완료 의견 (선택)") + '" />' +
        '<button class="btn btn-primary btn-sm" data-action="taskDecide" data-approve="1"' + a + ">" + (t.request ? "✅ 완료 승인" : "✅ 완료 처리") + "</button>" +
        (t.request ? '<button class="btn btn-danger btn-sm" data-action="taskDecide"' + a + ">↩ 반려</button>" : "") + "</div>" : "") +
      (admin && done ? '<div class="tp-btns"><button class="btn btn-secondary btn-sm" data-action="taskReopen"' + a + ">↺ 완료 해제 (진행중으로)</button></div>" : "") +
      (t.request && !admin ? '<div class="muted">🙋 완료 요청을 보냈습니다. 간사 승인 대기 중입니다.</div>' : "") +
      (!canWrite && !admin && !done ? '<div class="muted">진행 내용은 이 과제의 담당자(회원)와 관리자가 입력할 수 있습니다.</div>' : "") +
      (tp.loading ? '<div class="muted">기록을 불러오는 중…</div>' : taskLogHtml(it, t)) + "</div>";
    box.innerHTML = '<div class="tp-head"><div><div class="tp-id"><b>' + esc(t.id) + '</b><span class="grade-chip ' + GRADE_CLS[t.importance] + '">' + t.importance + "</span>" + taskStateBadge(t, delay) + longBadge(lt) + "</div>" +
      "<h3>" + esc(t.title || "-") + '</h3></div><button class="btn btn-secondary btn-sm" data-action="taskClose">✕ 닫기</button></div>' +
      '<div class="tp-body"><div class="tp-src">📁 출처 안건: <b>' + esc(it.title) + '</b> <span class="muted">' + esc(it.id) + " · " + esc(t.team || t.sector) + (t.riskId ? " · " + esc(t.riskId) : "") + "</span>" +
      '<button class="link-btn" data-action="openDetail" data-id="' + esc(it.id) + '">안건 보기</button></div>' +
      '<div class="tp-sec"><h4>📌 과제 정보</h4>' + info + ext + "</div>" + prog + "</div>";
  }
  function rerenderTasks() {
    renderTaskPanel();
    if (state.detail) renderTaskBox();
    else if (state.route === "tasks") renderTasksTable();
    else if (state.route === "dashboard") renderDashboard();
    else if (state.route === "mywork") renderMywork();
  }
  // 서버 응답(안건 전체)으로 과제 패널·상세 창을 맞춘다
  function syncTaskTracking(updated) {
    replaceItem(updated); updateNavBadges();
    if (state.taskPanel && state.taskPanel.itemId === updated.id) { state.taskPanel.item = updated; state.taskPanel.form = null; }
    if (!state.detail || state.detail.id !== updated.id) return;
    [state.detail.draft, state.detail.orig].forEach(function (o) {
      o.rev = updated.rev; o.updatedAt = updated.updatedAt; o.audit = clone(updated.audit);
      updated.tasks.forEach(function (ut) {
        var i = (o.tasks || []).findIndex(function (x) { return x.id === ut.id; });
        if (i !== -1) o.tasks[i] = clone(ut);
      });
    });
  }

  // ---- 회원: 우리 팀 검토 의견 저장 (팀장·Pro 상관없이, 서버가 이력 기록) ----
  function saveTeam(complete) {
    var team = state.user && state.user.team, d = state.detail.draft, c = d.reviews[team];
    if (!c) return;
    if (complete) {
      if (!c.result) { toast("✅ 이상 없음 또는 ⚠️ Risk 있음을 선택하세요.", "err"); return; }
      if (c.result === "risk" && !c.risks.some(function (r) { return (r.content || "").trim(); })) { toast("Risk 내용을 1개 이상 입력하세요.", "err"); return; }
      if (!confirm(team + " 검토 의견을 작성 완료하고 간사에게 메일을 보낼까요?")) return;
    }
    api("POST", "/api/items/" + encodeURIComponent(d.id) + "/review/" + encodeURIComponent(team), {
      result: c.result, comment: c.comment, complete: complete,
      risks: c.risks.map(function (r) { return { id: r.id, content: r.content, proposal: r.proposal }; })
    }).then(function (r) {
      replaceItem(r.item); updateNavBadges();
      state.detail.orig = clone(r.item); state.detail.draft = clone(r.item);
      renderDetail();
      if (!complete) toast("임시 저장했습니다.", "ok");
      else if (r.mail === "sent") toast("작성 완료! 간사에게 메일을 발송합니다.", "ok");
      else toast("작성 완료 처리했습니다. (간사 메일 주소가 설정되지 않아 메일은 보내지 않았습니다)", "ok");
    }).catch(fail);
  }

  // ---- 관리자 대리 작성 완료: 이 팀 줄만 서버에 저장 (다른 수정 중인 내용은 유지) ----
  function saveTeamProxy(team) {
    var d = state.detail.draft, c = d.reviews[team];
    if (!c) return;
    if (!c.result) { toast("✅ 이상 없음 또는 ⚠️ Risk 있음을 선택하세요.", "err"); return; }
    if (c.result === "risk" && !c.risks.some(function (r) { return (r.content || "").trim(); })) { toast("Risk 내용을 1개 이상 입력하세요.", "err"); return; }
    api("POST", "/api/items/" + encodeURIComponent(d.id) + "/review/" + encodeURIComponent(team), {
      result: c.result, comment: c.comment, complete: true,
      risks: c.risks.map(function (r) { return { id: r.id, content: r.content, proposal: r.proposal }; })
    }).then(function (r) {
      replaceItem(r.item); updateNavBadges();
      if (state.detail && state.detail.id === r.item.id) {
        [state.detail.draft, state.detail.orig].forEach(function (o) {
          o.rev = r.item.rev; o.updatedAt = r.item.updatedAt; o.audit = clone(r.item.audit);
          o.reviews[team] = clone(r.item.reviews[team]);
        });
        renderReviews(); renderTeamPick(); renderAudit();
      }
      toast(team + " 검토 의견을 관리자 대리로 작성 완료했습니다.", "ok");
    }).catch(fail);
  }

  // ---- 검토 의견 / 과제 편집 이벤트 ----
  function onReviewField(el) {
    var d = state.detail.draft;
    if (el.hasAttribute("data-rv-team")) {
      var team = el.getAttribute("data-rv-team");
      if (canEditTeam(team) && d.reviews[team]) d.reviews[team][el.getAttribute("data-rvf")] = el.value;
      return true;
    }
    if (el.hasAttribute("data-risk-id") && el.hasAttribute("data-rkf")) {
      var hit = findRisk(d, el.getAttribute("data-risk-id"));
      if (hit && canEditTeam(hit.team) && !hit.risk.decision) hit.risk[el.getAttribute("data-rkf")] = el.value;
      return true;
    }
    if (el.hasAttribute("data-pick-team")) { if (state.isAdmin) pickTeam(el.getAttribute("data-pick-team"), el.checked); return true; }
    if (el.hasAttribute("data-accept")) { if (state.detail.acceptFor) state.detail.acceptFor.reason = el.value; return true; }
    if (el.hasAttribute("data-task-ext")) { if (state.detail.taskExt) state.detail.taskExt[el.getAttribute("data-task-ext")] = el.value; return true; }
    if (!state.isAdmin) return false;
    if (el.hasAttribute("data-task-owner")) {
      var t0 = findTask(d, el.getAttribute("data-task-owner"));
      var u = (state.adminUsers || []).filter(function (x) { return x.empId === el.value; })[0];
      if (t0) {
        t0.ownerEmpId = u ? u.empId : ""; t0.ownerName = u ? u.team + " " + u.name + " " + u.title : "";
        if (u) { t0.ownerEmail = u.email; if (!t0.org) t0.org = u.team; }
        renderTaskBox();
      }
      return true;
    }
    if (el.hasAttribute("data-task-id") && el.hasAttribute("data-tkf")) {
      var t = findTask(d, el.getAttribute("data-task-id")), f = el.getAttribute("data-tkf");
      if (!t) return true;
      t[f] = el.value;
      if (f === "ownerEmail") { t.ownerEmpId = ""; t.ownerName = ""; }
      if (f === "status") { t.doneAt = el.value === "완료" ? (t.doneAt || today()) : ""; renderTaskBox(); renderReviews(); }
      if (f === "importance") { renderTaskBox(); renderReviews(); }
      return true;
    }
    return false;
  }


  // 단계 진행 규칙: 완료(또는 생략 경로) 처리 전에 확인. false 면 처리하지 않는다.
  // 패스트트랙 조건: 선정 팀이 모두 이상 없음, 또는 Risk 가 모두 결정(과제 등록/수용)되고 중요도 '상' 과제가 모두 완료
  //  (중·하 과제는 등록·수용 결정만으로 충분). 막히면 이유 문구, 가능하면 "".
  function fastTrackBlock(d) {
    var sm = reviewSummary(d);
    if (!sm.total) return "검토 팀이 선정되지 않았습니다.";
    if (sm.allOk) return "";
    if (sm.pending.length) return "작성 완료되지 않은 팀이 있습니다 (" + shortTeams(sm.pending, 4) + ").";
    if (sm.undecided) return "결정 대기 Risk " + sm.undecided + "건이 있습니다. [3]에서 [과제 등록] 또는 [수용]으로 결정하세요.";
    var hi = openTaskCount(d, "상");
    if (hi) return "중요도 '상' 과제 " + hi + "건이 아직 완료되지 않았습니다.";
    return "";
  }
  function stageGate(action, key) {
    var d = state.detail.draft, st = d.stages, sm = reviewSummary(d);
    var marking = (action === "stDone" && !st[key].done) ||
      (action === "stFast" && !(st.step2.skipped && st.step3.skipped && st.step4.skipped)) ||
      (action === "stSub" && !(!st.step2.skipped && st.step3.skipped && st.step4.skipped));
    if (!marking) return true;
    if (action === "stFast") {
      var why = fastTrackBlock(d);
      if (why) { toast("⚡ 패스트트랙 불가 — " + why, "err"); return false; }
    }
    if ((action === "stDone" && key === "step1") || action === "stFast") {
      if (!sm.total && !confirm("검토 팀이 선정되지 않았습니다. 그래도 1단계를 완료 처리할까요?")) return false;
      if (sm.total && sm.pending.length && !confirm(sm.total + "개 팀 중 " + sm.pending.length + "개 팀(" + shortTeams(sm.pending, 5) + ")이 아직 작성 완료되지 않았습니다.\n그래도 1단계를 완료 처리할까요?")) return false;
    }
    if ((action === "stDone" && key === "step2") || action === "stSub") {
      if (sm.undecided) { toast("결정 대기 Risk " + sm.undecided + "건이 있습니다. [3]에서 모두 [과제 등록] 또는 [수용]으로 결정한 뒤 2단계를 완료하세요.", "err"); return false; }
    }
    if (action === "stDone" && key === "step5") {
      var hi = openTaskCount(d, "상"), rest = openTaskCount(d);
      if (hi) { toast("중요도 '상' 과제 " + hi + "건이 완료되지 않아 최종승인할 수 없습니다.", "err"); return false; }
      if (rest && !confirm("미완료 과제(중·하) " + rest + "건이 남아 있습니다.\n조건부 승인으로 최종승인할까요? (남은 과제는 계속 추적됩니다)")) return false;
    }
    return true;
  }
  function stageAction(action, key) {
    if (!stageGate(action, key)) return;
    var d = state.detail.draft, st = d.stages, o = st[key];
    var mark = function (k) { st[k].done = true; st[k].skipped = false; if (!st[k].doneAt) st[k].doneAt = today(); };
    var skip = function (k) { st[k].skipped = true; st[k].done = false; st[k].doneAt = ""; st[k].target = ""; st[k].targetAuto = false; };
    if (action === "stDone") { if (o.done) { o.done = false; o.doneAt = ""; } else mark(key); }
    if (action === "stSkip") { if (o.skipped) o.skipped = false; else skip(key); }
    if (action === "stFast") {
      if (st.step2.skipped && st.step3.skipped && st.step4.skipped) ["step2", "step3", "step4"].forEach(function (k) { st[k].skipped = false; });
      else { mark("step1"); ["step2", "step3", "step4"].forEach(skip); }
    }
    if (action === "stSub") {
      if (!st.step2.skipped && st.step3.skipped && st.step4.skipped) ["step3", "step4"].forEach(function (k) { st[k].skipped = false; });
      else { mark("step2"); ["step3", "step4"].forEach(skip); }
    }
    state.detail.ext = null;
    // 단계를 처리하면 접수된 것으로 본다 (접수일 = 오늘, 저장 시 서버가 확정)
    if (d.accepted === false) {
      d.accepted = true; d.acceptedAt = today(); applyStageTargets(d);
      toast("단계 처리로 접수 승인 상태로 바뀝니다. (저장 시 반영)"); renderDetail(); return;
    }
    applyStageTargets(d);
    renderStepper();
  }
  function applyExtension() {
    var d = state.detail.draft, ext = state.detail.ext, o = d.stages[ext.key];
    if (!ext.date) { toast("날짜를 선택하세요.", "err"); return; }
    if (o.target && ext.date === o.target) { toast("현재 목표일과 같은 날짜입니다.", "err"); return; }
    if (o.target && !ext.reason.trim()) { toast("연장 사유를 입력하세요.", "err"); return; }
    if (!o.targetOriginal) o.targetOriginal = o.target || ext.date;
    o.extensions.push({ from: o.target || "", to: ext.date, reason: ext.reason.trim(), by: state.user ? state.user.name : "관리자", at: today() });
    o.target = ext.date; o.targetAuto = false;
    state.detail.ext = null;
    renderStepper();
    toast("목표일을 변경했습니다. [💾 저장]을 눌러야 반영됩니다.");
  }


  function saveDetail(force) {
    var d = state.detail.draft;
    if (!d.title.trim()) { toast("제품/기술명을 입력하세요.", "err"); return; }
    api("PUT", "/api/items/" + encodeURIComponent(d.id), { item: d, rev: d.rev, force: !!force }).then(function (updated) {
      replaceItem(updated); updateNavBadges();
      toast("저장했습니다. 공유폴더 data.json 에 반영되었습니다.", "ok");
      closeDetail(true);
    }).catch(function (e) {
      if (e.status === 409 && e.detail && e.detail.item) {
        if (confirm("다른 사용자가 먼저 이 안건을 수정했습니다.\n\n[확인] 내 변경 내용으로 덮어쓰기\n[취소] 저장 취소 (최신 내용 확인)")) saveDetail(true);
        else { replaceItem(e.detail.item); closeDetail(true); openDetail(e.detail.item.id); toast("최신 내용을 불러왔습니다."); }
        return;
      }
      fail(e);
    });
  }

  function uploadAttachments(files) {
    if (!files.length || !state.detail) return;
    var id = state.detail.id, fd = new FormData();
    Array.prototype.forEach.call(files, function (f) { fd.append("files", f, f.name); });
    toast("업로드 중… (" + files.length + "개)");
    api("POST", "/api/items/" + encodeURIComponent(id) + "/attachments", fd).then(function (updated) {
      syncServerFields(updated); if (state.detail) renderAttachments(); toast("첨부파일을 저장했습니다.", "ok");
    }).catch(fail);
  }

  // =====================================================================
  // 검토 요청 메일 패널 (상세 모달 / 관리자 모드 공용)
  // =====================================================================
  function initMail(item, host) {
    var sec = state.admin ? state.admin.secretaryEmails : [];
    state.mail = {
      host: host, itemId: item.id, level: "sub", selected: {}, autoSel: true,
      extra: "", cc: uniq(sec.concat(item.requesterEmail ? [item.requesterEmail] : [])).join("; "),
      summary: item.summary || item.note || "", preview: null
    };
  }
  function mailRecipients() {
    var m = state.mail;
    return uniq(Object.keys(m.selected).filter(function (k) { return m.selected[k]; }).concat(parseEmails(m.extra)));
  }
  function mailPayload() {
    var m = state.mail;
    return { itemId: m.itemId, level: m.level, to: mailRecipients(), cc: parseEmails(m.cc), summary: m.summary };
  }
  function renderMailPanel() {
    var m = state.mail;
    if (!m) return;
    var box = $("#mailHost-" + m.host);
    if (!box) return;
    if (!state.isAdmin) { box.innerHTML = '<div class="banner warn">🔒 검토 요청 메일 발송은 관리자 모드에서 사용할 수 있습니다.</div>'; return; }
    if (!state.admin) { box.innerHTML = '<div class="muted">주소록을 불러오는 중…</div>'; return; }
    var item = m.host === "detail" && state.detail ? state.detail.draft : (findItem(m.itemId) || { reviews: {} });
    if (m.autoSel) { autoSelectTeams(Object.keys(item.reviews)); m.autoSel = false; }
    // 받는 사람: 6대 부문 × 선정된 검토 팀의 주소록 (관리자 모드 > 검토 팀 주소록)
    var groups = SECTORS.map(function (sec) {
      var teams = cardOrder(item).filter(function (t) { return item.reviews[t].sector === sec; });
      return '<div class="recipient-sector"><h5>' + esc(sec) + (teams.length ? ' <span class="muted" style="font-weight:600">' + teams.length + "팀</span>" : "") + "</h5>" +
        (teams.length ? teams.map(function (team) {
          var emails = teamEmails(team);
          return '<div class="rc-team"><b>' + esc(team) + "</b>" + (emails.length ? emails.map(function (e) {
            return '<label><input type="checkbox" data-mail-email="' + esc(e) + '"' + (m.selected[e] ? " checked" : "") + ' /><span class="muted">' + esc(e) + "</span></label>";
          }).join("") : '<span class="rc-none">주소록 미등록</span>') + "</div>";
        }).join("") : '<span class="muted" style="font-size:11.5px">선정 팀 없음</span>') + "</div>";
    }).join("");
    var to = mailRecipients();
    box.innerHTML = '<div class="mail-panel"><div style="display:flex;flex-direction:column;gap:10px">' +
      '<div class="level-toggle">' + Object.keys(LEVELS).map(function (k) {
        return '<div class="radio-card ' + (m.level === k ? "selected" : "") + '" data-action="mailLevel" data-level="' + k + '">' + (k === "sub" ? "👥 " : "🏢 ") + LEVELS[k] + "</div>";
      }).join("") + "</div>" +
      '<div style="display:flex;justify-content:space-between;align-items:center"><span class="filter-label">받는 사람 (' + "6대 부문 · 선정 팀 주소록" + ') · 선택 <b id="mailCount">' + to.length + "</b>명</span>" +
      '<span style="display:flex;gap:4px"><button class="btn btn-secondary btn-sm" data-action="mailAll">전체 선택</button><button class="btn btn-secondary btn-sm" data-action="mailNone">해제</button></span></div>' +
      '<div class="recipient-grid">' + groups + "</div>" +
      '<div class="field"><label>추가 받는 사람 <span class="muted">(; 구분)</span></label><input class="input" data-mf="extra" value="' + esc(m.extra) + '" /></div>' +
      '<div class="field"><label>참조(CC) <span class="muted">— 간사 및 요청자 자동 입력</span></label><input class="input" data-mf="cc" value="' + esc(m.cc) + '" /></div>' +
      '<div class="field"><label>양산이관 핵심 요약 (메일 본문)</label><textarea class="textarea" style="min-height:110px" data-mf="summary">' + esc(m.summary) + "</textarea></div></div>" +
      '<div class="mail-actions"><button class="btn btn-primary btn-lg" data-action="mailOpen">✉️ 검토 요청 메일 작성창 열기</button>' +
      '<div class="card-sub">서버 PC에서는 Outlook 작성창이 바로 열리고, 다른 PC에서는 .eml 초안이 내려받아집니다 (열면 Outlook에서 [보내기]만 누르면 됩니다).</div>' +
      '<div class="row"><button class="btn btn-secondary btn-sm" data-action="mailEml">📄 .eml 초안 받기</button><button class="btn btn-secondary btn-sm" data-action="mailMailto">📧 mailto로 열기</button>' +
      '<button class="btn btn-secondary btn-sm" data-action="mailPreview">👁 미리보기</button></div>' +
      '<div class="row"><button class="btn btn-teal btn-sm" data-action="mailCopyTo">📋 수신자 일괄 복사</button><button class="btn btn-teal btn-sm" data-action="mailCopyBody">📋 메일 본문(서식 포함) 복사</button></div>' +
      '<div id="mailPreviewBox">' + mailPreviewHtml() + "</div></div></div>";
  }
  function mailPreviewHtml() {
    var p = state.mail && state.mail.preview;
    if (!p) return '<div class="mail-preview muted">[미리보기]를 누르면 제목과 본문이 표시됩니다.</div>';
    return '<div class="mail-preview"><div class="subj">제목: ' + esc(p.subject) + '</div><div class="muted" style="margin-bottom:6px">받는 사람: ' + esc(p.to.join("; ")) +
      "<br>참조: " + esc(p.cc.join("; ") || "-") + "</div>" + p.html + "</div>";
  }
  function fetchPreview() {
    if (!mailRecipients().length) return Promise.reject(new Error("받는 사람을 1명 이상 선택하세요."));
    return api("POST", "/api/mail/review/preview", mailPayload()).then(function (p) {
      state.mail.preview = p;
      var box = $("#mailPreviewBox"); if (box) box.innerHTML = mailPreviewHtml();
      return p;
    });
  }
  function downloadEml() {
    if (!mailRecipients().length) { toast("받는 사람을 1명 이상 선택하세요.", "err"); return Promise.resolve(); }
    return api("POST", "/api/mail/review/eml", mailPayload(), { raw: true }).then(function (res) {
      return res.blob().then(function (b) {
        var item = findItem(state.mail.itemId);
        downloadBlob(b, "검토요청_" + (item ? item.title : "안건").replace(/[\\/:*?"<>|]/g, "_").slice(0, 60) + ".eml");
        toast("메일 초안(.eml)을 내려받았습니다. 파일을 열면 Outlook 작성창이 뜹니다.", "ok");
      });
    }).catch(fail);
  }
  function mailAction(action, el) {
    var m = state.mail;
    if (action === "mailLevel") { m.level = el.getAttribute("data-level"); m.preview = null; renderMailPanel(); return; }
    if (action === "mailAll" || action === "mailNone") {
      $all("#mailHost-" + m.host + " [data-mail-email]").forEach(function (cb) { m.selected[cb.getAttribute("data-mail-email")] = action === "mailAll"; });
      m.preview = null; renderMailPanel(); return;
    }
    if (action === "mailOpen") {
      if (!mailRecipients().length) { toast("받는 사람을 1명 이상 선택하세요.", "err"); return; }
      toast("Outlook 작성창을 여는 중…");
      api("POST", "/api/mail/review/outlook", mailPayload()).then(function () {
        toast("Outlook 메일 작성창을 열었습니다. [보내기]만 누르세요.", "ok");
      }).catch(function (e) { if (e.status === 409) downloadEml(); else fail(e); });
      return;
    }
    if (action === "mailEml") { downloadEml(); return; }
    if (action === "mailPreview") { fetchPreview().catch(fail); return; }
    if (action === "mailMailto") {
      fetchPreview().then(function (p) {
        var body = p.text.length > 1500 ? p.text.slice(0, 1500) + "\n…(이하 생략, 대시보드에서 확인)" : p.text;
        location.href = "mailto:" + p.to.map(encodeURIComponent).join(",") + "?cc=" + p.cc.map(encodeURIComponent).join(",") +
          "&subject=" + encodeURIComponent(p.subject) + "&body=" + encodeURIComponent(body);
      }).catch(fail);
      return;
    }
    if (action === "mailCopyTo") {
      var to = mailRecipients();
      if (!to.length) { toast("받는 사람을 선택하세요.", "err"); return; }
      copyText(to.join("; ")).then(function () { toast("수신자 " + to.length + "명을 복사했습니다.", "ok"); }, function () { toast("복사에 실패했습니다.", "err"); });
      return;
    }
    if (action === "mailCopyBody") {
      var p = m.preview;
      var doCopy = function (pv) {
        return copyHtml(pv.html, pv.text).then(function () { toast("서식 포함 본문을 복사했습니다. 웹메일 본문에 붙여넣으세요.", "ok"); }, function () { toast("복사에 실패했습니다.", "err"); });
      };
      if (p) doCopy(p); else fetchPreview().then(doCopy).catch(fail);
    }
  }

  // =====================================================================
  // 엑셀(CSV) 내보내기 / 업로드
  // =====================================================================
  function csvCell(v) {
    var s = String(v == null ? "" : v);
    return /[",\r\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
  }
  function downloadCsv(name, rows) {
    var csv = "﻿" + rows.map(function (r) { return r.map(csvCell).join(","); }).join("\r\n");
    downloadBlob(new Blob([csv], { type: "text/csv;charset=utf-8" }), name);
  }
  var OX = function (b) { return b ? "O" : "X"; };
  function exportSummary(list) {
    var head = ["ID", "구분", "NP/SP", "제품구분", "제품/기술명", "접수상태", "패스트트랙", "소위전결", "요청자", "소속부서", "요청자이메일", "발제일"];
    STAGES.forEach(function (s, i) { var n = i + 1; head.push(n + "단계 목표일", n + "단계 완료일", n + "단계 완료", n + "단계 생략", n + "단계 연장횟수"); });
    head.push("진행상태", "현재단계", "단계지연일수", "접수일", "주요내용", "비고", "검증소위원회 회의", "검증위원회 회의", "장기과제수");
    var rows = [head];
    list.forEach(function (i) {
      var si = stageInfo(i), st = i.stages;
      var row = [i.id, i.category, i.npSp, i.productSize ? i.productSize + " " + i.productType : "", i.title, i.accepted === false ? "접수대기" : "접수", OX(si.fastTrack), OX(si.subDecision), i.requester, i.requesterDept, i.requesterEmail, i.proposalDate];
      STAGES.forEach(function (s) { var o = st[s.key]; row.push(o.target, o.doneAt, OX(o.done), OX(o.skipped), o.extensions.length || ""); });
      var mtg = function (k) { return (st[k].meetings || []).map(function (m) { return m.no + "차 " + (m.date || "-") + (m.result ? " " + m.result : ""); }).join(" / "); };
      row.push(si.phase === "WAIT" ? "접수대기" : si.isDone ? "최종승인완료" : "검토진행중", si.name, si.delay || "", i.acceptedAt || "", i.summary, i.note,
        mtg("step2"), mtg("step4"), (i.tasks || []).filter(function (t) { return longTermOf(i, t); }).length || "");
      rows.push(row);
    });
    downloadCsv("양산이관_요약목록_" + today() + ".csv", rows);
  }
  var RISK_HEAD = ["부문", "검토팀", "검토결과", "의견(Comment)", "작성완료", "RiskID", "예상Risk", "제안보완방안", "결정", "수용사유",
    "과제ID", "중요도", "과제보완방안", "담당조직", "담당자", "담당자이메일", "목표일", "연장횟수", "과제상태", "완료일", "지연일수"];
  // 안건 1건 → 검토 팀·Risk·과제를 한 줄씩 (Risk 가 없는 팀도 1줄)
  function reviewRows(item) {
    var rows = [];
    cardOrder(item).forEach(function (team) {
      var c = item.reviews[team];
      var base = [c.sector, team, c.result === "ok" ? "이상 없음" : c.result === "risk" ? "Risk 있음" : "미작성", c.comment,
        c.done ? c.done.name + " " + (c.done.title || "") + " " + c.done.at : ""];
      if (!c.risks.length) { rows.push(base.concat(RISK_HEAD.slice(5).map(function () { return ""; }))); return; }
      c.risks.forEach(function (r) {
        var t = r.decision === "task" ? findTask(item, r.taskId) : null;
        rows.push(base.concat([r.id, r.content, r.proposal, r.decision === "task" ? "과제" : r.decision === "accept" ? "수용" : "결정 대기", r.reason,
          t ? t.id : "", t ? t.importance : "", t ? t.plan : "", t ? t.org : "", t ? t.ownerName : "", t ? t.ownerEmail : "",
          t ? t.target : "", t && t.extensions.length ? t.extensions.length : "", t ? t.status : "", t ? t.doneAt : "", t && taskDelay(t) ? taskDelay(t) : ""]));
      });
    });
    if (!rows.length) rows.push(RISK_HEAD.map(function () { return ""; }));
    return rows;
  }
  function exportRisk(list) {
    var rows = [["ID", "구분", "NP/SP", "제품구분", "제품/기술명", "요청자", "발제일"].concat(RISK_HEAD).concat(["비고"])];
    list.forEach(function (i) {
      var base = [i.id, i.category, i.npSp, i.productSize ? i.productSize + " " + i.productType : "", i.title, i.requester, i.proposalDate];
      reviewRows(i).forEach(function (r) { rows.push(base.concat(r).concat([i.note])); });
    });
    downloadCsv("양산이관_검토의견_과제_" + today() + ".csv", rows);
  }
  function exportSingle() {
    var d = state.detail.draft;
    var rows = [["ID", d.id], ["구분", catText(d)], ["제품/기술명", d.title], ["요청자", d.requester + " " + d.requesterDept], ["발제일", d.proposalDate],
      ["진행상태", stageInfo(d).name], ["주요내용", d.summary], ["비고", d.note], [], RISK_HEAD];
    reviewRows(d).forEach(function (r) { rows.push(r); });
    downloadCsv("양산이관_상세_" + d.title.replace(/[\\/:*?"<>|]/g, "_").slice(0, 60) + ".csv", rows);
  }

  function parseCsv(text) {
    var rows = [], row = [], cur = "", q = false;
    text = text.replace(/^﻿/, "");
    for (var i = 0; i < text.length; i++) {
      var ch = text[i], nx = text[i + 1];
      if (q) {
        if (ch === '"' && nx === '"') { cur += '"'; i++; } else if (ch === '"') q = false; else cur += ch;
      } else if (ch === '"') q = true;
      else if (ch === ",") { row.push(cur); cur = ""; }
      else if (ch === "\r" || ch === "\n") { if (ch === "\r" && nx === "\n") i++; row.push(cur); rows.push(row); row = []; cur = ""; }
      else cur += ch;
    }
    if (cur || row.length) { row.push(cur); rows.push(row); }
    return rows.filter(function (r) { return r.some(function (c) { return c.trim() !== ""; }); });
  }
  function decodeCsv(buf) {
    // UTF-8 로 엄격 해석 → 실패하면 EUC-KR(엑셀 기본 저장 형식)
    try { return new TextDecoder("utf-8", { fatal: true }).decode(buf); } catch (e) { return new TextDecoder("euc-kr").decode(buf); }
  }
  function buildImport(rows, merge) {
    var col = {};
    rows[0].forEach(function (h, i) { col[h.replace(/\s+/g, "")] = i; });
    var get = function (row, names) {
      for (var i = 0; i < names.length; i++) { var k = col[names[i].replace(/\s+/g, "")]; if (k !== undefined && row[k] !== undefined) return row[k].trim(); }
      return "";
    };
    // 위험 상세 형식: new = 검토결과/결정 열(현재), legacy = 특이사항/과제화 열(예전) → 서버가 자동 변환
    var riskFmt = col["검토결과"] !== undefined ? "new" : ["부문", "Risk항목", "예상Risk항목", "과제화"].some(function (k) { return col[k] !== undefined; }) ? "legacy" : "";
    var hasRisk = !!riskFmt;
    var map = {}, order = [], byKey = {};
    var put = function (it) { map[it.id] = it; order.push(it.id); byKey[it.category + "||" + it.title] = it.id; };
    if (merge) state.items.forEach(function (it) { var c = clone(it); c._reset = true; put(c); });
    var count = 0;
    for (var r = 1; r < rows.length; r++) {
      var row = rows[r];
      var title = get(row, ["제품/기술명", "제품명", "기술명", "명칭", "안건명"]);
      if (!title) continue;
      var cat = get(row, ["구분"]) === "기술" ? "기술" : "제품";
      var npSp = cat === "제품" ? (get(row, ["NP/SP", "NPSP"]).toUpperCase() === "SP" ? "SP" : "NP") : "";
      var id = get(row, ["ID", "안건ID"]);
      var t = (id && map[id]) || map[byKey[cat + "||" + title]];
      if (!t) {
        t = { id: id || ("TR-IMP-" + Date.now() + "-" + r), category: cat, npSp: npSp, title: title, requester: "", requesterDept: "", requesterEmail: "",
          proposalDate: "", summary: "", note: "", accepted: true, stages: {}, reviews: emptyReviews(), tasks: [], attachments: [] };
        STAGES.forEach(function (s) { t.stages[s.key] = { target: "", doneAt: "", done: false, skipped: false, targetAuto: false, targetOriginal: "", extensions: [] }; });
        put(t);
      }
      t.category = cat; t.npSp = npSp; t.title = title;
      var setIf = function (field, names, fn) { var v = get(row, names); if (v) t[field] = fn ? fn(v) : v; };
      setIf("requester", ["요청자", "담당자"]); setIf("requesterDept", ["소속부서", "소속"]); setIf("requesterEmail", ["요청자이메일", "이메일"]);
      setIf("proposalDate", ["발제일", "등록일"], normDate);
      var pk = get(row, ["제품구분"]).toUpperCase().replace(/\s+/g, "");
      var pm = pk.match(/^(300MM|200MM)(PW|EPI)$/);
      if (pm) { t.productSize = pm[1].toLowerCase(); t.productType = pm[2]; } setIf("summary", ["주요내용", "주요내용및변경점"]); setIf("note", ["비고", "비고(Note)"]);
      if (!t.proposalDate) t.proposalDate = today();
      var acc = get(row, ["접수상태"]);
      if (acc) t.accepted = acc !== "접수대기";
      var accAt = normDate(get(row, ["접수일"]));
      if (accAt) t.acceptedAt = accAt;
      if (hasRisk && t._reset !== false) {  // 이 파일에 처음 나온 안건이면 검토 의견을 파일 내용으로 교체
        if (riskFmt === "new") { t.reviews = emptyReviews(); t.tasks = []; delete t.risks; }
        else { t.risks = []; delete t.reviews; delete t.tasks; }
        t._reset = false;
      }
      STAGES.forEach(function (s, si) {
        var n = si + 1, o = t.stages[s.key];
        var tv = get(row, [n + "단계목표일"]), dav = get(row, [n + "단계완료일"]), legacy = get(row, [n + "단계일정", n + "단계"]);
        var dn = get(row, [n + "단계완료"]).toUpperCase(), sk = get(row, [n + "단계생략"]).toUpperCase();
        if (dn) o.done = dn === "O" || dn === "완료" || dn === "TRUE";
        if (sk) o.skipped = sk === "O" || sk === "생략" || sk === "TRUE";
        if (tv) { o.target = normDate(tv); o.targetAuto = false; }
        if (dav) o.doneAt = normDate(dav);
        if (legacy && !tv && !dav) { if (o.done) o.doneAt = normDate(legacy); else { o.target = normDate(legacy); o.targetAuto = false; } }
      });
      var ft = get(row, ["패스트트랙"]).toUpperCase();
      if (ft === "O") { t.stages.step1.done = true; ["step2", "step3", "step4"].forEach(function (k) { t.stages[k].skipped = true; t.stages[k].done = false; }); }
      if (riskFmt === "new") {
        var sec = get(row, ["부문"]);
        if (SECTORS.indexOf(sec) !== -1) {
          var team = get(row, ["검토팀"]) || ("(기존) " + sec);
          if (!t.reviews[team]) t.reviews[team] = { sector: sec, result: "", comment: "", risks: [], done: null, history: [] };
          var rv = t.reviews[team], res = get(row, ["검토결과"]), cm = get(row, ["의견(Comment)", "의견", "Comment"]);
          if (res.indexOf("없음") !== -1) rv.result = rv.result || "ok";
          else if (res.indexOf("Risk") !== -1 || res.indexOf("있음") !== -1) rv.result = "risk";
          if (cm) rv.comment = cm;
          var content = get(row, ["예상Risk", "Risk내용"]);
          if (content) {
            rv.result = "risk";
            var ids = allRisks(t).map(function (x) { return x.risk.id; });
            var rid = get(row, ["RiskID"]);
            if (!rid || ids.indexOf(rid) !== -1) rid = nextSeqId("R", ids);
            var risk = { id: rid, content: content, proposal: get(row, ["제안보완방안"]), decision: "", reason: "", taskId: "" };
            var dec = get(row, ["결정"]);
            if (dec.indexOf("과제") !== -1) {
              var tids = t.tasks.map(function (x) { return x.id; }), tid = get(row, ["과제ID"]);
              if (!/^T\d+$/.test(tid) || tids.indexOf(tid) !== -1) tid = nextSeqId("T", tids);
              var imp = get(row, ["중요도"]);
              t.tasks.push({ id: tid, riskId: rid, sector: sec, team: team, title: content, plan: get(row, ["과제보완방안"]) || risk.proposal,
                importance: GRADES.indexOf(imp) !== -1 ? imp : "중", org: get(row, ["담당조직"]), ownerName: get(row, ["담당자"]), ownerEmpId: "",
                ownerEmail: get(row, ["담당자이메일"]), target: normDate(get(row, ["목표일"])), targetOriginal: "", extensions: [],
                status: get(row, ["과제상태"]) === "완료" ? "완료" : "진행중", doneAt: normDate(get(row, ["완료일"])), createdAt: today() });
              risk.decision = "task"; risk.taskId = tid;
            } else if (dec.indexOf("수용") !== -1) {
              risk.decision = "accept"; risk.reason = get(row, ["수용사유"]) || "(엑셀 업로드)";
            }
            rv.risks.push(risk);
          }
        }
      } else if (riskFmt === "legacy") {
        var sec = get(row, ["부문"]), rItem = get(row, ["Risk항목", "예상Risk항목"]), rev = get(row, ["검토팀장", "팀장"]);
        if (sec || rItem || rev) {
          var nr = get(row, ["특이사항여부", "특이사항"]);
          var noRisk = nr.indexOf("없음") !== -1;
          var isT = !noRisk && get(row, ["과제화"]).toUpperCase() === "O";
          t.risks.push({
            sector: SECTORS.indexOf(sec) !== -1 ? sec : SECTORS[0], reviewer: rev, noRisk: noRisk,
            riskItem: noRisk ? "" : rItem, isTask: isT ? "O" : "X", grade: isT ? (normGrade(get(row, ["등급", "Risk등급"])) || "중") : "",
            planContent: noRisk ? "" : get(row, ["보완방안", "Risk보완방안내용"]), org: get(row, ["담당조직"]),
            schedule: normDate(get(row, ["일정", "목표일정"])), status: get(row, ["과제상태", "상태"]) === "완료" ? "완료" : "진행중"
          });
        }
      }
      count++;
    }
    return { count: count, items: order.map(function (k) { var it = map[k]; delete it._reset; return it; }) };
  }
  function handleCsvFile(file) {
    var reader = new FileReader();
    reader.onload = function () {
      var rows = parseCsv(decodeCsv(reader.result));
      if (rows.length < 2) { toast("업로드할 데이터 행이 없습니다.", "err"); return; }
      var merge = confirm("엑셀 파일 (" + file.name + ", " + (rows.length - 1) + "행)을 불러왔습니다.\n\n" +
        "[확인] 기존 데이터에 추가/병합 (같은 ID 또는 같은 구분+명칭은 업데이트)\n[취소] 기존 데이터를 모두 지우고 파일 내용으로 교체");
      if (!merge && !confirm("⚠️ 기존 안건 " + state.items.length + "건이 모두 교체됩니다. 계속할까요?\n(교체 전 데이터는 backups 폴더에 자동 백업됩니다)")) return;
      var res = buildImport(rows, merge);
      if (!res.count) { toast("반영할 데이터를 찾지 못했습니다. 헤더에 '구분', '제품/기술명' 컬럼이 있는지 확인하세요.", "err"); return; }
      api("POST", "/api/items/bulk", { items: res.items }).then(function (r) {
        return loadAll().then(function () { render(false); toast("엑셀 업로드 완료: " + res.count + "개 행 → 안건 " + r.count + "건 저장", "ok"); });
      }).catch(fail);
    };
    reader.readAsArrayBuffer(file);
  }
  function pickFile(accept, multiple, cb) {
    var inp = document.createElement("input");
    inp.type = "file"; inp.accept = accept || ""; inp.multiple = !!multiple;
    inp.onchange = function () { if (inp.files.length) cb(inp.files); };
    inp.click();
  }

  // =====================================================================
  // 이벤트 위임
  // =====================================================================
  var ACTIONS = {
    nav: function (el) { closeDetail(true); go(el.getAttribute("data-route")); },
    refresh: function () { loadAll().then(function () { render(false); toast("최신 데이터로 업데이트되었습니다.", "ok"); }).catch(fail); },
    // 대시보드 연동
    kpiGo: function (el) {
      var g = el.getAttribute("data-go");
      if (g === "all") { state.f.list = { cat: "ALL", year: state.f.dashYear, status: "ALL", q: "" }; go("items"); }
      if (g === "stageDelay") { state.f.list = { cat: "ALL", year: "ALL", status: "DELAY", q: "" }; go("items"); }
      if (g === "taskDelay") { state.f.task = { grade: "ALL", sector: "ALL", status: "DELAY", q: "" }; go("tasks"); }
      if (g === "taskLong") { state.f.list = { cat: "ALL", year: "ALL", status: "LONG", q: "" }; go("items"); }
      if (g === "actions") { var c = $(".action-table"); if (c) c.scrollIntoView({ behavior: "smooth", block: "center" }); else if (!isLoggedIn()) go("account"); }
    },
    actTab: function (el) { state.actTab = el.getAttribute("data-tab"); state.showAllActions = false; renderDashboard(); },
    toggleActions: function () { state.showAllActions = !state.showAllActions; renderDashboard(); },
    remind: function (el) {
      var body = { itemId: el.getAttribute("data-id"), kind: el.getAttribute("data-kind"), taskId: el.getAttribute("data-task") || "",
        sectors: (el.getAttribute("data-sectors") || "").split(",").filter(Boolean) };
      api("POST", "/api/remind", Object.assign({ dryRun: true }, body)).then(function (pv) {
        if (!confirm("Remind 메일을 보낼까요?\n\n제목: " + pv.subject + "\n받는 사람: " + pv.names.join(", ") + "\n  (" + pv.to.join("; ") + ")" +
          (pv.cc.length ? "\n참조: " + pv.cc.join("; ") : ""))) return;
        el.disabled = true;
        return api("POST", "/api/remind", body).then(function (r) {
          replaceItem(r.item);
          if (state.detail && state.detail.id === r.item.id) { state.detail.draft.remindLog = clone(r.item.remindLog); state.detail.orig.remindLog = clone(r.item.remindLog); state.detail.draft.rev = r.item.rev; state.detail.orig.rev = r.item.rev; renderReviews(); renderTaskBox(); }
          else render(false);
          if (state.taskPanel && state.taskPanel.itemId === r.item.id) { state.taskPanel.item = r.item; renderTaskPanel(); }
          toast(r.message, "ok");
        });
      }).catch(function (e) { el.disabled = false; fail(e); });
    },
    // 목록
    listCat: function (el) { state.f.list.cat = el.getAttribute("data-cat"); renderItems(); },
    taskGrade: function (el) { state.f.task.grade = el.getAttribute("data-grade"); renderTasks(); },
    taskStatus: function (el) { state.f.task.status = el.getAttribute("data-status"); renderTasks(); },
    taskReset: function () { state.f.task = { grade: "ALL", sector: "ALL", status: "ALL", q: "", mine: false }; renderTasks(); },
    taskMine: function () { state.f.task.mine = !state.f.task.mine; renderTasks(); },
    showChangelog: function () {
      var m = $("#infoModal");
      if (!m) {
        m = document.createElement("div"); m.id = "infoModal"; m.className = "modal-backdrop";
        m.innerHTML = '<div class="modal-window changelog-window" role="dialog" aria-modal="true"><div class="modal-header"><h3>📋 업데이트 내역</h3>' +
          '<button class="btn btn-secondary btn-sm" data-action="closeChangelog">✕ 닫기</button></div><div class="modal-body" id="infoBody"></div></div>';
        m.addEventListener("mousedown", function (e) { if (e.target === m) ACTIONS.closeChangelog(); });
        document.body.appendChild(m);
      }
      $("#infoBody").innerHTML = '<div class="cl-now">현재 버전 <b>' + APP_VERSION + "</b></div>" + CHANGELOG.map(function (c, i) {
        return '<div class="cl-ver' + (i === 0 ? " latest" : "") + '"><div class="cl-head"><b>' + c[0] + '</b><span class="muted">' + c[1] + "</span>" + (i === 0 ? '<span class="badge badge-new">최신</span>' : "") + "</div>" +
          "<ul>" + c[2].map(function (x) { return "<li>" + esc(x) + "</li>"; }).join("") + "</ul></div>";
      }).join("");
      m.classList.add("open");
    },
    closeChangelog: function () { var m = $("#infoModal"); if (m) m.classList.remove("open"); },
    toggleTheme: function () {
      var dark = document.documentElement.getAttribute("data-theme") !== "dark";
      if (dark) document.documentElement.setAttribute("data-theme", "dark"); else document.documentElement.removeAttribute("data-theme");
      safeLocal(dark ? "set" : "del", "portalTheme", "dark");
      updateThemeButton();
    },
    taskView: function (el) { state.taskView = el.getAttribute("data-view"); safeLocal("set", "portalTaskView", state.taskView); renderTasks(); },
    taskGroupToggle: function (el) { var id = el.getAttribute("data-id"); state.taskGroupClosed[id] = !state.taskGroupClosed[id]; renderTasksTable(); },
    taskOpen: function (el, e) {
      if (e && e.target.closest("a")) return;
      var id = el.getAttribute("data-id"), tid = el.getAttribute("data-task");
      if (state.detail && isDirty() && !confirm("안건 창에 저장하지 않은 변경이 있습니다. 과제 화면으로 이동할까요?")) return;
      if (state.detail) closeDetail(true);
      if (state.route !== "tasks" && state.route !== "mywork" && state.route !== "dashboard") { location.hash = "tasks/" + encodeURIComponent(id) + "/" + encodeURIComponent(tid); return; }
      openTaskPanel(id, tid);
    },
    taskClose: function () { closeTaskPanel(false); },
    taskSave: function () {
      var tp = state.taskPanel, t = tpTask(), f = tp && tp.form;
      if (!t || !f) return;
      if (t.target && f.target && f.target !== t.target && !(f.reason || "").trim()) { toast("목표일을 바꾸려면 연장 사유를 입력하세요.", "err"); return; }
      api("PUT", "/api/items/" + encodeURIComponent(tp.itemId) + "/tasks/" + encodeURIComponent(t.id),
        { title: f.title, plan: f.plan, importance: f.importance, org: f.org, ownerEmpId: f.ownerEmpId, ownerEmail: f.ownerEmail, target: f.target, reason: f.reason })
        .then(function (updated) { syncTaskTracking(updated); rerenderTasks(); toast("과제 정보를 저장했습니다.", "ok"); }).catch(fail);
    },
    taskReopen: function (el) {
      if (!confirm("완료를 해제하고 진행중으로 되돌릴까요?")) return;
      api("POST", "/api/items/" + encodeURIComponent(el.getAttribute("data-id")) + "/tasks/" + encodeURIComponent(el.getAttribute("data-task")) + "/reopen")
        .then(function (updated) { syncTaskTracking(updated); rerenderTasks(); toast("진행중으로 되돌렸습니다.", "ok"); }).catch(fail);
    },
    taskProgress: function (el) {
      var id = el.getAttribute("data-id"), tid = el.getAttribute("data-task"), k = id + "/" + tid, req = el.getAttribute("data-request") === "1";
      var note = (state.taskForm[k] || "").trim(), inp = document.querySelector('[data-tp-files="' + k + '"]'), files = inp ? inp.files : [];
      if (!note && !files.length) { toast("진행 내용 또는 증빙 파일을 입력하세요.", "err"); return; }
      if (req && !confirm("과제 " + tid + " 완료를 요청할까요?\n간사(관리자)가 확인 후 승인하면 완료 처리됩니다.")) return;
      var fd = new FormData();
      fd.append("note", note); if (req) fd.append("request", "1");
      Array.prototype.forEach.call(files, function (f) { fd.append("files", f, f.name); });
      el.disabled = true;
      api("POST", "/api/items/" + encodeURIComponent(id) + "/tasks/" + encodeURIComponent(tid) + "/progress", fd).then(function (updated) {
        delete state.taskForm[k];
        syncTaskTracking(updated); rerenderTasks();
        toast(req ? "완료를 요청했습니다. 간사에게 메일이 발송됩니다." : "진행 상황을 저장했습니다.", "ok");
      }).catch(function (e) { el.disabled = false; fail(e); });
    },
    taskDecide: function (el) {
      var id = el.getAttribute("data-id"), tid = el.getAttribute("data-task"), k = id + "/" + tid, approve = el.getAttribute("data-approve") === "1";
      var comment = (state.taskForm[k + "#c"] || "").trim();
      if (!approve && !comment) { toast("반려 사유를 입력하세요.", "err"); return; }
      if (!confirm("과제 " + tid + (approve ? " 을(를) 완료 승인할까요?" : " 완료 요청을 반려할까요?") + "\n담당자에게 메일이 발송됩니다.")) return;
      el.disabled = true;
      api("POST", "/api/items/" + encodeURIComponent(id) + "/tasks/" + encodeURIComponent(tid) + "/decide", { approve: approve, comment: comment }).then(function (updated) {
        delete state.taskForm[k + "#c"];
        syncTaskTracking(updated); rerenderTasks();
        toast(approve ? "완료 승인했습니다." : "반려했습니다.", "ok");
      }).catch(function (e) { el.disabled = false; fail(e); });
    },
    reportXlsx: function () {
      var y = state.route === "dashboard" ? state.f.dashYear : state.route === "items" ? state.f.list.year : "ALL";
      toast("보고서를 만드는 중…");
      api("GET", "/api/report.xlsx?year=" + encodeURIComponent(y || "ALL"), undefined, { raw: true }).then(function (res) { return res.blob(); })
        .then(function (b) { downloadBlob(b, "양산이관_현황보고서_" + today() + ".xlsx"); toast("보고서를 내려받았습니다.", "ok"); }).catch(fail);
    },
    extHistToggle: function () { state.detail.showExt = !state.detail.showExt; renderStepper(); },
    secToggle: function (el) {
      var k = el.getAttribute("data-sec"), c = state.detail.collapsed;
      c[k] = !c[k];
      var sec = document.querySelector('#detailBody [data-sec-body="' + k + '"]');
      if (sec) sec.classList.toggle("collapsed", c[k]);
      el.textContent = c[k] ? "펼치기 ▼" : "접기 ▲";
    },
    bizPick: function () { $("#bizFile").click(); },
    bizReparse: function () {
      var cfg = {};
      $all("[data-bz-key]").forEach(function (el) {
        var k = el.getAttribute("data-bz-key");
        (cfg[k] = cfg[k] || {})[el.getAttribute("data-bz-f")] = el.value.trim();
      });
      api("PUT", "/api/admin/bizplan", { config: cfg }).then(bizDone).catch(fail);
    },
    mxAddTeam: function (el) {
      var sec = el.getAttribute("data-sector"), name = (prompt(sec + " 부문에 추가할 팀 이름을 입력하세요.") || "").trim();
      if (!name) return;
      if (state.teams.some(function (t) { return t.name === name; })) { toast("이미 있는 팀입니다: " + name, "err"); return; }
      var list = state.teams.slice(), last = -1;
      list.forEach(function (t, i) { if (t.sector === sec) last = i; });
      list.splice(last === -1 ? list.length : last + 1, 0, { name: name, sector: sec, canApply: false });
      api("PUT", "/api/admin/teams", { teams: list }).then(function (teams) {
        state.teams = teams; state.teamDraft = null; renderAdmin();
        toast(sec + " 부문에 '" + name + "' 팀을 추가했습니다. 매트릭스 체크·주소록 입력 후 [💾 저장]을 누르세요.", "ok");
      }).catch(fail);
    },
    auditToggle: function () { state.detail.showAudit = !state.detail.showAudit; renderAudit(); },
    taskToggle: function (el) {
      el.disabled = true;
      api("POST", "/api/items/" + encodeURIComponent(el.getAttribute("data-id")) + "/tasks/" + encodeURIComponent(el.getAttribute("data-task")) + "/toggle")
        .then(function (updated) { replaceItem(updated); updateNavBadges(); renderTasksTable(); toast("과제 상태를 변경했습니다.", "ok"); })
        .catch(function (e) { el.disabled = false; fail(e); });
    },
    openDetail: function (el) { openDetail(el.getAttribute("data-id")); },
    // 신청
    applyCat: function (el) { state.apply.category = el.getAttribute("data-cat"); keepApplyInputs(renderApply); },
    applyPick: function () { $("#apFiles").click(); },
    applyRemoveFile: function (el) { state.apply.files.splice(+el.getAttribute("data-idx"), 1); renderApplyFiles(); },
    applySubmit: submitApply,
    applyNew: function () { state.apply.result = null; renderApply(); },
    // 기준
    critTab: function (el) { state.crit.tab = el.getAttribute("data-tab"); state.crit.editing = false; renderCriteria(); },
    critEdit: function () { state.crit.editing = true; renderCriteria(); },
    critCancel: function () { state.crit.editing = false; renderCriteria(); },
    critSave: saveCriteria,
    formPick: function () {
      pickFile("", true, function (files) {
        var fd = new FormData(); Array.prototype.forEach.call(files, function (f) { fd.append("files", f, f.name); });
        api("POST", "/api/forms", fd).then(function (list) { state.crit.forms = list; renderCriteria(); toast("양식을 등록했습니다.", "ok"); }).catch(fail);
      });
    },
    formDelete: function (el) {
      var name = el.getAttribute("data-name");
      if (!confirm("'" + name + "' 양식을 삭제할까요?")) return;
      api("DELETE", "/api/forms/" + encodeURIComponent(name)).then(function (list) { state.crit.forms = list; renderCriteria(); }).catch(fail);
    },
    // 관리자
    login: function () {
      var pw = $("#adminPw").value;
      if (!pw) { toast("비밀번호를 입력하세요.", "err"); return; }
      api("POST", "/api/login", { password: pw }).then(function (r) {
        state.token = r.token; safeSession("set", "portalAdminToken", r.token);
        return loadAdminSettings().then(function () { setAdmin(true, "관리자 모드가 활성화되었습니다."); });
      }).catch(fail);
    },
    logout: function () { api("POST", "/api/logout").catch(function () { }); setAdmin(false, "관리자 모드를 종료했습니다."); },
    // 회원
    userLogin: function () {
      var emp = $("#loginEmp").value.trim(), pw = $("#loginPw").value;
      if (!emp || !pw) { toast("사번과 비밀번호를 입력하세요.", "err"); return; }
      api("POST", "/api/users/login", { empId: emp, password: pw }).then(function (r) {
        setUser(r.token, r.user, userLabel(r.user) + "님 환영합니다.");
      }).catch(fail);
    },
    toggleSignup: function (el) {
      state.showSignup = !state.showSignup;
      var card = $("#signupCard");
      card.classList.toggle("open", state.showSignup);
      el.textContent = state.showSignup ? "▲ 가입 신청 닫기" : "📝 가입 신청";
      if (state.showSignup) setTimeout(function () {
        card.scrollIntoView({ behavior: "smooth", block: "start" });
        if (!card.contains(document.activeElement)) $("#suEmp").focus();  // 이미 입력 중이면 커서를 빼앗지 않음
      }, 60);
    },
    userLogout: function () {
      api("POST", "/api/users/logout").catch(function () { });
      setUser(null, null, "로그아웃했습니다.");
    },
    userSignup: function () {
      var v = function (id) { return $("#" + id).value.trim(); };
      if (!v("suEmp") || !v("suName") || !v("suTitle") || !v("suTeam") || !v("suEmail") || !$("#suPw").value) { toast("필수 항목(*)을 모두 입력하세요.", "err"); return; }
      if ($("#suPw").value !== $("#suPw2").value) { toast("비밀번호 확인이 일치하지 않습니다.", "err"); return; }
      api("POST", "/api/users/signup", { empId: v("suEmp"), name: v("suName"), title: v("suTitle"), team: v("suTeam"), email: v("suEmail"), password: $("#suPw").value })
        .then(function (r) {
          toast(r.message, "ok");
          state.showSignup = false; renderAccount();
        }).catch(fail);
    },
    userChangePw: function () {
      if ($("#upNew").value !== $("#upNew2").value) { toast("새 비밀번호가 서로 다릅니다.", "err"); return; }
      api("POST", "/api/users/password", { current: $("#upCur").value, new: $("#upNew").value }).then(function () {
        ["#upCur", "#upNew", "#upNew2"].forEach(function (id) { $(id).value = ""; });
        toast("비밀번호를 변경했습니다.", "ok");
      }).catch(fail);
    },
    saveRecipients: function () {
      api("PUT", "/api/settings", { secretaryEmails: $("#stSecretary").value, leaderEmails: $("#stLeader").value, portalUrl: $("#stPortalUrl").value })
        .then(function (s) { state.admin = s; renderAdmin(); toast("알림 수신자를 저장했습니다.", "ok"); }).catch(fail);
    },
    saveMailCfg: function () {
      api("PUT", "/api/settings", {
        mail: { preferOutlook: $("#stPreferOutlook").checked, fastDraft: $("#stFastDraft").checked },
        smtp: { host: $("#stSmtpHost").value, port: $("#stSmtpPort").value, username: $("#stSmtpUser").value, password: $("#stSmtpPw").value, sender: $("#stSmtpSender").value, useTls: $("#stSmtpTls").checked }
      }).then(function (s) { state.admin = s; renderAdmin(); toast("메일 발송 설정을 저장했습니다.", "ok"); }).catch(fail);
    },
    mailTest: function (el) {
      var method = el.getAttribute("data-method");
      var box = $("#smtpDiag");
      if (method === "smtp" && box) box.innerHTML = '<div class="diag-box muted">SMTP 서버에 단계별로 접속해 보는 중… (최대 30초)</div>';
      else toast("테스트 메일 발송 중…");
      el.disabled = true;
      api("POST", "/api/mail/test", {
        method: method, to: $("#stTestTo").value,
        smtp: { host: $("#stSmtpHost").value, port: $("#stSmtpPort").value, username: $("#stSmtpUser").value,
          password: $("#stSmtpPw").value, sender: $("#stSmtpSender").value, useTls: $("#stSmtpTls").checked }
      }).then(function (r) {
        el.disabled = false;
        if (method === "smtp" && box) {
          box.innerHTML = '<div class="diag-box"><div class="diag-title ' + (r.ok ? "ok" : "bad") + '">' + (r.ok ? "✅ " : "❌ ") + esc(r.message) + "</div>" +
            r.steps.map(function (st) {
              return '<div class="diag-step ' + (st.ok ? "ok" : "bad") + '"><b>' + (st.ok ? "✔ " : "✖ ") + esc(st.step) + "</b><span>" + esc(st.detail) + "</span></div>";
            }).join("") + "</div>";
        }
        toast(r.message, r.ok ? "ok" : "err");
      }).catch(function (e) { el.disabled = false; if (box && method === "smtp") box.innerHTML = ""; fail(e); });
    },
    userApprove: function (el) { userAction(el.getAttribute("data-emp"), { action: "approve" }, "승인했습니다. 이제 로그인할 수 있습니다."); },
    userReject: function (el) {
      if (confirm(el.getAttribute("data-emp") + " 가입 신청을 반려할까요?")) userAction(el.getAttribute("data-emp"), { action: "reject" }, "반려했습니다.");
    },
    userResetPw: function (el) {
      var pw = prompt("임시 비밀번호를 입력하세요 (4자 이상). 회원에게 전달 후 [내 정보]에서 변경하도록 안내하세요.");
      if (pw) userAction(el.getAttribute("data-emp"), { action: "resetPassword", password: pw }, "비밀번호를 초기화했습니다.");
    },
    userDelete: function (el) {
      var emp = el.getAttribute("data-emp");
      if (!confirm(emp + " 회원을 삭제할까요?")) return;
      api("DELETE", "/api/admin/users/" + encodeURIComponent(emp)).then(function (list) { state.adminUsers = list; renderUserRows(); toast("삭제했습니다.", "ok"); }).catch(fail);
    },
    matrixSave: function () {
      api("PUT", "/api/settings", { reviewMatrix: state.matrixDraft, teamEmails: state.teamEmailsDraft || {} }).then(function (sv) {
        state.admin = sv; state.reviewMatrix = sv.reviewMatrix; state.matrixDraft = clone(sv.reviewMatrix); state.teamEmailsDraft = null; renderAdmin();
        toast("검토 팀 매트릭스와 메일 주소록을 저장했습니다.", "ok");
      }).catch(fail);
    },
    saveHolidays: function () {
      api("PUT", "/api/settings", { holidays: $("#stHolidays").value }).then(function (sv) {
        state.admin = sv; state.holidays = sv.holidays; renderAdmin();
        toast("휴일 " + sv.holidays.length + "일을 저장했습니다. 이후 계산되는 목표일부터 적용됩니다.", "ok");
      }).catch(fail);
    },
    usePortalUrl: function (el) { $("#stPortalUrl").value = el.getAttribute("data-url"); toast("[💾 저장]을 눌러야 반영됩니다."); },
    teamAdd: function () { state.teamDraft.push({ name: "", sector: "", canApply: false }); renderTeamRows(); },
    teamDel: function (el) { state.teamDraft.splice(+el.getAttribute("data-idx"), 1); renderTeamRows(); },
    teamSave: function () {
      var names = state.teamDraft.map(function (t) { return t.name.trim(); });
      if (names.some(function (n) { return !n; })) { toast("팀 이름이 비어 있는 행이 있습니다.", "err"); return; }
      if (names.some(function (n, i) { return names.indexOf(n) !== i; })) { toast("중복된 팀 이름이 있습니다.", "err"); return; }
      api("PUT", "/api/admin/teams", { teams: state.teamDraft }).then(function (teams) {
        state.teams = teams; state.teamDraft = clone(teams);
        return api("GET", "/api/admin/users");
      }).then(function (list) { state.adminUsers = list; renderAdmin(); toast("팀 목록을 저장했습니다.", "ok"); presencePing(); }).catch(fail);
    },

    changePw: function () {
      var n = $("#pwNew").value;
      if (n !== $("#pwNew2").value) { toast("새 비밀번호가 서로 다릅니다.", "err"); return; }
      api("POST", "/api/admin/password", { current: $("#pwCur").value, new: n }).then(function () {
        ["#pwCur", "#pwNew", "#pwNew2"].forEach(function (s) { $(s).value = ""; });
        toast("비밀번호를 변경했습니다.", "ok");
      }).catch(fail);
    },
    acceptItem: function (el) {
      api("POST", "/api/items/" + encodeURIComponent(el.getAttribute("data-id")) + "/accept").then(function (updated) {
        syncServerFields(updated);
        // 접수 승인 시 서버가 정한 목표일·기본 검토 팀을 화면에도 반영 (안 하면 저장 시 빈 선정으로 덮어씀)
        if (state.detail && state.detail.id === updated.id) {
          ["stages", "reviews", "acceptedAt"].forEach(function (k) { state.detail.draft[k] = clone(updated[k]); state.detail.orig[k] = clone(updated[k]); });
          autoSelectTeams(Object.keys(updated.reviews));  // 자동 선정된 팀 주소록 → 메일 받는 사람 체크
        }
        if (state.detail) renderDetail(); else render(false);
        toast("접수 승인했습니다. 1단계 전문소위원 검토를 진행하세요.", "ok");
      }).catch(fail);
    },
    deleteItem: function (el) {
      var id = el.getAttribute("data-id"), it = findItem(id);
      if (!it || !confirm("[" + id + "] " + it.title + "\n\n이 안건을 삭제할까요? (첨부파일은 backups 폴더로 이동됩니다)")) return;
      api("DELETE", "/api/items/" + encodeURIComponent(id)).then(function () {
        state.items = state.items.filter(function (i) { return i.id !== id; });
        updateNavBadges();
        if (state.detail && state.detail.id === id) closeDetail(true); else render(false);
        toast("삭제했습니다.", "ok");
      }).catch(fail);
    },
    backupJson: function () {
      api("GET", "/api/admin/backup", null, { raw: true }).then(function (res) { return res.blob(); })
        .then(function (b) { downloadBlob(b, "data_backup_" + today() + ".json"); }).catch(fail);
    },
    csvSummary: function () { exportSummary(filteredItems()); },
    csvRisk: function () { exportRisk(state.route === "items" ? filteredItems() : state.items); },
    csvSummaryAll: function () { exportSummary(state.items); },
    csvRiskAll: function () { exportRisk(state.items); },
    csvUpload: function () { pickFile(".csv,text/csv", false, function (files) { handleCsvFile(files[0]); }); },
    // 상세 모달
    closeDetail: function () { closeDetail(false); },
    detailSave: function () { saveDetail(false); },
    csvSingle: exportSingle,
    attPick: function () { $("#attFiles").click(); },
    attDelete: function (el) {
      var name = el.getAttribute("data-name");
      if (!confirm("'" + name + "' 첨부파일을 삭제할까요?")) return;
      api("DELETE", "/api/items/" + encodeURIComponent(state.detail.id) + "/attachments/" + encodeURIComponent(name))
        .then(function (updated) { syncServerFields(updated); renderAttachments(); }).catch(fail);
    },
    mtgAdd: function (el) {
      var key = el.getAttribute("data-stage"), n = (state.detail.draft.stages[key].meetings || []).length + 1;
      state.mtgOpen[key + "-" + n] = true; state.mtgExpand[key] = true;
      meetingApi("POST", key, { date: today() }, n + "차 회의를 추가했습니다. 날짜·결과를 입력하고 회의록을 붙여넣으세요.");
    },
    mtgDel: function (el) {
      if (!confirm(el.getAttribute("data-no") + "차 회의 기록을 삭제할까요? (첨부된 회의록은 백업 폴더로 옮겨집니다)")) return;
      meetingApi("DELETE", el.getAttribute("data-stage") + "/" + el.getAttribute("data-no"), undefined, "회의 기록을 삭제했습니다.");
    },
    mtgExpand: function (el, e) {
      if (e && e.target.closest("[data-action=mtgAdd]")) return;
      var k = el.getAttribute("data-stage");
      state.mtgExpand[k] = !state.mtgExpand[k]; renderMeetings();
    },
    mtgToggle: function (el) {
      var k = el.getAttribute("data-stage") + "-" + el.getAttribute("data-no");
      state.mtgOpen[k] = !state.mtgOpen[k];
      renderMeetings();
      var ta = state.mtgOpen[k] && $('.mtg-text[data-stage="' + el.getAttribute("data-stage") + '"][data-no="' + el.getAttribute("data-no") + '"]');
      if (ta) ta.focus();
    },
    mtgFileDel: function (el) {
      if (!confirm("회의록 '" + el.getAttribute("data-name") + "' 을(를) 삭제할까요?")) return;
      meetingApi("DELETE", el.getAttribute("data-stage") + "/" + el.getAttribute("data-no") + "/minutes/" + encodeURIComponent(el.getAttribute("data-name")), undefined, "회의록을 삭제했습니다.");
    },
    pickMatrix: function () {
      var d = state.detail.draft, teams = (state.reviewMatrix || {})[d.productSize + " " + d.productType] || [];
      var added = teams.filter(function (t) { return !d.reviews[t]; });
      added.forEach(function (t) { d.reviews[t] = newCard(t); });
      autoSelectTeams(added);
      renderTeamPick(); renderReviews(); renderMailPanel();
      toast(added.length ? added.length + "개 팀을 추가했습니다. [💾 저장]을 눌러야 반영됩니다." : "이미 모두 선정되어 있습니다.");
    },
    rvResult: function (el) {
      var d = state.detail.draft, team = el.getAttribute("data-team"), val = el.getAttribute("data-val"), rv = d.reviews[team];
      if (!rv || !canEditTeam(team)) return;
      if (val === "ok") {
        if (rv.risks.some(function (r) { return r.decision; })) { toast("위원회가 이미 결정한 Risk 가 있어 '이상 없음'으로 바꿀 수 없습니다.", "err"); return; }
        if (rv.risks.some(function (r) { return (r.content || "").trim(); }) && !confirm("작성한 Risk " + rv.risks.length + "건이 지워집니다. '이상 없음'으로 바꿀까요?")) return;
        rv.risks = [];
      }
      if (val === "risk" && !rv.risks.length) rv.risks.push({ id: nextSeqId("R", allRisks(d).map(function (x) { return x.risk.id; })), content: "", proposal: "", decision: "", reason: "", taskId: "" });
      rv.result = val;
      renderReviews();
      // 관리자: 팀장이 작성하지 않을 때 '이상 없음'으로 바로 대리 작성 완료
      if (val === "ok" && state.isAdmin && !rv.done && d.accepted !== false &&
          confirm(team + " 을(를) '✅ 이상 없음'으로 관리자 대리 작성 완료할까요?\n\n[확인] 바로 작성 완료 (의견: " + (rv.comment || "특이사항 없음") + ")\n[취소] 선택만 하고 의견 입력 후 [✅ 대리 작성 완료]")) saveTeamProxy(team);
    },
    teamProxy: function (el) { saveTeamProxy(el.getAttribute("data-team")); },
    riskAdd: function (el) {
      var d = state.detail.draft, team = el.getAttribute("data-team");
      d.reviews[team].risks.push({ id: nextSeqId("R", allRisks(d).map(function (x) { return x.risk.id; })), content: "", proposal: "", decision: "", reason: "", taskId: "" });
      renderReviews();
    },
    riskDel: function (el) {
      var d = state.detail.draft, hit = findRisk(d, el.getAttribute("data-risk-id"));
      if (!hit || hit.risk.decision) return;
      d.reviews[hit.team].risks = d.reviews[hit.team].risks.filter(function (r) { return r !== hit.risk; });
      renderReviews();
    },
    riskToTask: function (el) {
      var d = state.detail.draft, hit = findRisk(d, el.getAttribute("data-risk-id"));
      if (!hit) return;
      if (!(hit.risk.content || "").trim()) { toast("Risk 내용이 비어 있습니다.", "err"); return; }
      var id = nextSeqId("T", (d.tasks || []).map(function (t) { return t.id; }));
      d.tasks = d.tasks || [];
      d.tasks.push({ id: id, riskId: hit.risk.id, sector: hit.sector, team: hit.team, title: hit.risk.content, plan: hit.risk.proposal, importance: "중",
        org: "", ownerName: "", ownerEmpId: "", ownerEmail: "", target: "", targetOriginal: "", extensions: [], status: "진행중", doneAt: "", createdAt: today() });
      hit.risk.decision = "task"; hit.risk.taskId = id; hit.risk.reason = "";
      renderReviews(); renderTaskBox();
      toast("과제 " + id + " 를 등록했습니다. [4]에서 중요도·담당·목표일을 지정하고 저장하세요.", "ok");
    },
    riskAccept: function (el) { state.detail.acceptFor = { id: el.getAttribute("data-risk-id"), reason: "" }; renderReviews(); },
    riskAcceptCancel: function () { state.detail.acceptFor = null; renderReviews(); },
    riskAcceptOk: function () {
      var d = state.detail.draft, acc = state.detail.acceptFor, hit = acc && findRisk(d, acc.id);
      if (!hit) return;
      if (!acc.reason.trim()) { toast("수용 사유를 입력하세요.", "err"); return; }
      hit.risk.decision = "accept"; hit.risk.reason = acc.reason.trim(); hit.risk.taskId = "";
      state.detail.acceptFor = null; renderReviews();
    },
    riskUndecide: function (el) {
      var d = state.detail.draft, hit = findRisk(d, el.getAttribute("data-risk-id"));
      if (!hit) return;
      if (hit.risk.decision === "task") {
        var t = findTask(d, hit.risk.taskId);
        if (!confirm("과제 " + hit.risk.taskId + (t && t.status === "완료" ? " (완료된 과제)" : "") + " 를 삭제하고 결정 대기로 되돌릴까요?")) return;
        d.tasks = d.tasks.filter(function (x) { return x.id !== hit.risk.taskId; });
      }
      hit.risk.decision = ""; hit.risk.taskId = ""; hit.risk.reason = "";
      renderReviews(); renderTaskBox();
    },
    taskExtOpen: function (el) {
      var t = findTask(state.detail.draft, el.getAttribute("data-task-id"));
      state.detail.taskExt = { id: t.id, date: t.target ? addBusinessDays(t.target, 5) : addBusinessDays(today(), 10), reason: "" };
      renderTaskBox();
    },
    taskExtCancel: function () { state.detail.taskExt = null; renderTaskBox(); },
    taskExtApply: function () {
      var ext = state.detail.taskExt, t = ext && findTask(state.detail.draft, ext.id);
      if (!t) return;
      if (!ext.date) { toast("날짜를 선택하세요.", "err"); return; }
      if (t.target && ext.date === t.target) { toast("현재 목표일과 같은 날짜입니다.", "err"); return; }
      if (t.target && !ext.reason.trim()) { toast("연장 사유를 입력하세요.", "err"); return; }
      if (t.target) {
        if (!t.targetOriginal) t.targetOriginal = t.target;
        t.extensions.push({ from: t.target, to: ext.date, reason: ext.reason.trim(), by: "관리자", at: today() });
      }
      t.target = ext.date; state.detail.taskExt = null; renderTaskBox();
    },
    stExtOpen: function (el) {
      var key = el.getAttribute("data-step"), o = state.detail.draft.stages[key];
      state.detail.ext = { key: key, date: o.target ? addBusinessDays(o.target, 5) : addBusinessDays(today(), state.leadDays[key]), reason: "" };
      renderStepper();
    },
    stExtCancel: function () { state.detail.ext = null; renderStepper(); },
    stExtApply: applyExtension,
    teamSave: function () { saveTeam(false); },
    teamComplete: function () { saveTeam(true); },
    teamReopen: function (el) {
      var team = el.getAttribute("data-team");
      if (!confirm(team + " 의 '작성 완료' 표시를 해제할까요? (재작성 요청)")) return;
      api("POST", "/api/items/" + encodeURIComponent(state.detail.id) + "/review/" + encodeURIComponent(team) + "/reopen").then(function (updated) {
        syncServerFields(updated);
        ["draft", "orig"].forEach(function (k) {
          var c = state.detail[k].reviews[team];
          if (c) { c.done = clone(updated.reviews[team].done); c.history = clone(updated.reviews[team].history); }
        });
        renderReviews(); toast(team + " 작성 완료를 해제했습니다.", "ok");
      }).catch(fail);
    },

  };
  ["stDone", "stSkip", "stFast", "stSub"].forEach(function (a) { ACTIONS[a] = function (el) { stageAction(a, el.getAttribute("data-step")); }; });
  ["mailLevel", "mailAll", "mailNone", "mailSector", "mailOpen", "mailEml", "mailPreview", "mailMailto", "mailCopyTo", "mailCopyBody"]
    .forEach(function (a) { ACTIONS[a] = function (el) { mailAction(a, el); }; });

  // 신청 폼에서 구분을 바꿀 때 입력값 유지
  function keepApplyInputs(fn) {
    keepInputs(["apTitle", "apReq", "apDept", "apEmail", "apSummary", "apDate", "apSize", "apType", "apMs"], fn);
  }
  // 화면을 다시 그려도 입력 중인 값 유지 (데이터 갱신·접속자 갱신 등으로 다시 그려질 때)
  var ACCOUNT_INPUTS = ["loginEmp", "loginPw", "suEmp", "suName", "suTitle", "suTeam", "suEmail", "suPw", "suPw2"];
  function keepInputs(ids, fn) {
    var saved = {}, act = document.activeElement, focusId = act && ids.indexOf(act.id) !== -1 ? act.id : "", sel = null;
    if (focusId) { try { sel = [act.selectionStart, act.selectionEnd]; } catch (e) { sel = null; } }
    ids.forEach(function (id) { var el = $("#" + id); if (el && el.value) saved[id] = el.value; });
    fn();
    ids.forEach(function (id) { var el = $("#" + id); if (el && saved[id] !== undefined && !el.value) el.value = saved[id]; });
    var f = focusId && $("#" + focusId);  // 입력 중이던 칸에 커서를 그대로 둔다
    if (f) { f.focus(); if (sel && sel[0] !== null) { try { f.setSelectionRange(sel[0], sel[1]); } catch (e) { /* select 등 */ } } }
  }

  function setFilter(path, value) {
    if (path === "dashYear") { state.f.dashYear = value; renderDashboard(); return; }
    var p = path.split(".");
    state.f[p[0]][p[1]] = value;
    if (p[0] === "list") renderItemsTable(); else renderTasksTable();
  }

  function onField(el) {
    if (el.hasAttribute("data-filter")) { setFilter(el.getAttribute("data-filter"), el.value); return; }
    if (el.hasAttribute("data-tpf")) {
      var tpf = el.getAttribute("data-tpf"), tpp = state.taskPanel;
      if (!tpp || !tpp.form) return;
      tpp.form[tpf] = el.value;
      if (tpf === "target" || tpf === "ownerEmpId" || el.tagName === "SELECT") renderTaskPanel();
      else { var sb = document.querySelector("#taskPanel [data-action=taskSave]"); if (sb) sb.disabled = !tpDirty(); }
      return;
    }
    if (el.hasAttribute("data-tp-note")) { state.taskForm[el.getAttribute("data-tp-note")] = el.value; return; }
    if (el.hasAttribute("data-tp-comment")) { state.taskForm[el.getAttribute("data-tp-comment") + "#c"] = el.value; return; }
    if (!state.detail && !state.mail && !state.admin && !state.teamDraft && !state.matrixDraft) return;
    if (el.hasAttribute("data-dfield")) {
      var d = state.detail.draft, f = el.getAttribute("data-dfield");
      d[f] = el.value;
      if (f === "category") { d.npSp = d.category === "제품" ? (d.npSp || "NP") : ""; renderDetail(); }
      if (f === "productSize" || f === "productType") renderTeamPick();
      if (f === "ms" || f === "productSize" || f === "productType") { var bb = $("#bizBox"); if (bb) bb.innerHTML = bizBadge(d); }
      return;
    }
    if (el.hasAttribute("data-stage-done")) {
      var sd = state.detail.draft.stages[el.getAttribute("data-stage-done")];
      if (el.value) { sd.doneAt = el.value; applyStageTargets(state.detail.draft); renderStepper(); }
      return;
    }
    if (el.hasAttribute("data-ext")) { if (state.detail.ext) state.detail.ext[el.getAttribute("data-ext")] = el.value; return; }
    if (state.detail && onReviewField(el)) return;
    if (el.hasAttribute("data-mf")) { state.mail[el.getAttribute("data-mf")] = el.value; state.mail.preview = null; var c = $("#mailCount"); if (c) c.textContent = mailRecipients().length; return; }
    if (el.hasAttribute("data-mail-email")) { state.mail.selected[el.getAttribute("data-mail-email")] = el.checked; state.mail.preview = null; $("#mailCount").textContent = mailRecipients().length; return; }
    if (el.hasAttribute("data-mx-key")) {
      var mk = el.getAttribute("data-mx-key"), mt = el.getAttribute("data-mx-team"), list = state.matrixDraft[mk] = state.matrixDraft[mk] || [];
      if (el.checked && list.indexOf(mt) === -1) list.push(mt);
      if (!el.checked) state.matrixDraft[mk] = list.filter(function (x) { return x !== mt; });
      renderMatrix(); return;
    }
    if (el.hasAttribute("data-team")) {
      var t = state.teamDraft[+el.getAttribute("data-team")], tf = el.getAttribute("data-teamf");
      t[tf] = tf === "canApply" ? el.checked : el.value; return;
    }
    if (el.hasAttribute("data-user-team")) {
      userAction(el.getAttribute("data-user-team"), { action: "update", team: el.value }, "팀을 변경했습니다."); return;
    }
    if (el.hasAttribute("data-te-team")) { state.teamEmailsDraft[el.getAttribute("data-te-team")] = el.value; return; }
  }

  function bindEvents() {
    document.addEventListener("click", function (e) {
      var el = e.target.closest("[data-action]");
      if (!el || el.disabled) return;
      if (el.tagName === "SELECT") return;
      var fn = ACTIONS[el.getAttribute("data-action")];
      if (fn) fn(el, e);
    });
    // 텍스트/날짜/셀렉트는 input, 체크박스는 change (중복 처리 방지)
    document.addEventListener("input", function (e) {
      var t = e.target;
      if (t.type === "checkbox" || t.type === "radio" || t.type === "file" || t.type === "date") return;
      if (t.tagName === "SELECT" || t.hasAttribute("data-mtg")) return;
      onField(t);
    });
    document.addEventListener("change", function (e) {
      var t = e.target;
      if (t.hasAttribute("data-mtg")) { meetingField(t); return; }
      if (t.type === "checkbox" || t.tagName === "SELECT") onField(t);
      else if (t.type === "date") onField(t);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && $("#infoModal") && $("#infoModal").classList.contains("open")) ACTIONS.closeChangelog();
      else if (e.key === "Escape" && state.taskPanel) closeTaskPanel(false);
      else if (e.key === "Escape" && state.detail) closeDetail(false);
      if (e.key === "Enter" && e.target.id === "adminPw") ACTIONS.login();
      if (e.key === "Enter" && (e.target.id === "loginEmp" || e.target.id === "loginPw")) ACTIONS.userLogin();
    });
    $("#detailModal").addEventListener("mousedown", function (e) { if (e.target === this) closeDetail(false); });
    // 드래그 앤 드롭 (신청 폼 / 상세 첨부)
    ["dragenter", "dragover"].forEach(function (ev) {
      document.addEventListener(ev, function (e) {
        var z = e.target.closest && e.target.closest("[data-drop]");
        if (!z) return;
        e.preventDefault(); z.classList.add("over");
      });
    });
    document.addEventListener("dragleave", function (e) { var z = e.target.closest && e.target.closest("[data-drop]"); if (z) z.classList.remove("over"); });
    document.addEventListener("drop", function (e) {
      var z = e.target.closest && e.target.closest("[data-drop]");
      if (!z) return;
      e.preventDefault(); z.classList.remove("over");
      if (z.getAttribute("data-drop") === "apply") addApplyFiles(e.dataTransfer.files);
      else if (state.isAdmin) uploadAttachments(e.dataTransfer.files);
    });
    window.addEventListener("hashchange", onHash);
    window.addEventListener("beforeunload", function (e) { if (isDirty()) { e.preventDefault(); e.returnValue = ""; } });
    // 탭을 닫으면 접속자 목록에서 즉시 제외
    window.addEventListener("pagehide", function () {
      if (navigator.sendBeacon && state.clientId) {
        navigator.sendBeacon("/api/presence/leave", new Blob([JSON.stringify({ clientId: state.clientId })], { type: "text/plain" }));
      }
    });
  }

  // =====================================================================
  // 시작
  // =====================================================================
  function start() {
    bindEvents();
    updateThemeButton();
    $("#verBtn").textContent = APP_VERSION + " · 업데이트 내역";
    state.clientId = safeSession("get", "portalClientId") || newClientId();
    safeSession("set", "portalClientId", state.clientId);
    var auth = state.token
      ? loadAdminSettings().then(function () { state.isAdmin = true; }).catch(function () { state.token = ""; safeSession("del", "portalAdminToken"); })
      : Promise.resolve();
    var login = state.userToken
      ? api("GET", "/api/users/me").then(function (u) { state.user = u; }).catch(function () { state.userToken = ""; safeLocal("del", "portalUserToken"); })
      : Promise.resolve();
    Promise.all([loadAll(), auth, login]).then(function () {
      if (state.isAdmin) { $("#adminBadge").textContent = "인증됨"; $("#adminBadge").classList.add("on"); $(".nav-link[data-route=admin] .nav-ico").textContent = "🔓"; }
      updateNav();
      onHash();
      presencePing();
      setInterval(poll, POLL_MS);
      setInterval(presencePing, PRESENCE_MS);
    }).catch(function (e) {
      setView('<div class="card empty-state">서버에 연결할 수 없습니다. (' + esc(e.message) + ")<br>서버 PC에서 run_server.bat 이 실행 중인지 확인하세요.</div>");
    });
  }
  start();
})();
