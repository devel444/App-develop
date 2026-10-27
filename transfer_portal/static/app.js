/* 양산이관 검증위원회 포털 - 프론트엔드 (Vanilla JS, 외부 라이브러리 없음) */
(function () {
  "use strict";

  // =====================================================================
  // 상수
  // =====================================================================
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
    route: "dashboard",
    f: {
      dashYear: "ALL",
      list: { cat: "ALL", year: "ALL", status: "ALL", q: "" },
      task: { grade: "ALL", sector: "ALL", status: "ALL", q: "" }
    },
    detail: null,           // { id, orig, draft }
    mail: null,             // 검토 요청 메일 패널 상태
    adminMailItemId: "",
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
  function stageInfo(item) {
    var st = item.stages || {};
    var g = function (k) { return st[k] || {}; };
    var fastTrack = !!(g("step2").skipped && g("step3").skipped && g("step4").skipped);
    var subDecision = !!(!g("step2").skipped && g("step3").skipped && g("step4").skipped);
    var base = { fastTrack: fastTrack, subDecision: subDecision };
    if (item.accepted === false) return Object.assign(base, { phase: "WAIT", col: 0, isDone: false, name: "접수대기" });
    if (g("step5").done) return Object.assign(base, { phase: "DONE", col: 5, isDone: true, name: "최종승인 완료" });
    var idx = 0;
    while (idx < 4 && (g(STAGES[idx].key).done || g(STAGES[idx].key).skipped)) idx++;
    var cur = g(STAGES[idx].key);
    return Object.assign(base, {
      phase: "ING", col: idx + 1, idx: idx, isDone: false,
      name: (idx + 1) + ". " + STAGES[idx].name + (cur.date ? " (" + cur.date.slice(5) + " 예정)" : " (일정 미수립)")
    });
  }
  function delayDays(r) {
    if (r.status === "완료" || !r.schedule) return 0;
    var d = daysBetween(r.schedule, today());
    return d > 0 ? d : 0;
  }
  function tasksOf(items) {
    var arr = [];
    items.forEach(function (item) {
      (item.risks || []).forEach(function (r, idx) {
        if (!r.noRisk && r.isTask === "O") arr.push({ item: item, risk: r, idx: idx, delay: delayDays(r) });
      });
    });
    return arr;
  }
  function catBadge(item) {
    return item.category === "제품"
      ? '<span class="badge badge-product">제품</span><span class="badge badge-npsp">' + esc(item.npSp || "NP") + "</span>"
      : '<span class="badge badge-tech">기술</span>';
  }
  function catText(item) { return item.category === "제품" ? "제품(" + (item.npSp || "NP") + ")" : "기술"; }
  function statusBadge(si) {
    if (si.phase === "WAIT") return '<span class="badge badge-wait">접수대기</span>';
    if (si.isDone) return '<span class="badge badge-done">최종승인완료</span>';
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
      var cls = o.skipped ? "skipped" : o.done ? (i === 4 ? "final-done" : "done") : o.date ? "scheduled" : "";
      var tip = s.name + (o.skipped ? " - 생략" : o.done ? " - 완료" : o.date ? " - " + o.date + " 예정" : " - 미수립");
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
  function canApply() { return state.isAdmin || !!(state.user && state.user.canApply); }
  function mySector() { return state.user && state.user.sector ? state.user.sector : ""; }
  function userLabel(u) { return (u.team ? u.team + " " : "") + u.name + (u.title ? " " + u.title : ""); }
  function canEditRow(r) { return state.isAdmin || (!!mySector() && r.sector === mySector()); }

  function emptyRisk(sector) {
    return { sector: sector || SECTORS[0], reviewer: "", noRisk: false, riskItem: "", isTask: "X", grade: "", planContent: "", org: "", schedule: "", status: "진행중" };
  }

  // =====================================================================
  // 데이터 로드 / 실시간 갱신
  // =====================================================================
  function loadAll() {
    return api("GET", "/api/bootstrap").then(function (d) {
      state.items = d.items; state.version = d.version;
      state.criteria = d.settings.criteria; state.storage = d.storage; state.teams = d.settings.teams || [];
      updateNavBadges();
    });
  }
  function updateNavBadges() {
    var delayed = tasksOf(state.items).filter(function (t) { return t.delay > 0; }).length;
    $("#navDelayBadge").textContent = delayed > 0 ? delayed : "";
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
    var MAX = 8;
    var names = p.users.slice(0, MAX).map(function (u) {
      return '<li title="' + esc(userLabel(u)) + '"><span class="pres-team">' + esc(u.team) + "</span>" + esc(u.name) + (u.title ? " " + esc(u.title) : "") +
        (u.admin ? ' <span class="pres-admin">관리자</span>' : "") + "</li>";
    }).join("");
    var extra = [];
    if (p.users.length > MAX) extra.push("외 " + (p.users.length - MAX) + "명");
    if (p.admins) extra.push("관리자 " + p.admins);
    if (p.anonymous) extra.push("비로그인 " + p.anonymous);
    box.innerHTML = '<div class="pres-head"><span class="pres-dot"></span>현재 접속 <b>' + p.count + "</b>명</div>" +
      (names ? '<ul class="pres-list">' + names + "</ul>" : "") +
      (extra.length ? '<div class="pres-extra">' + extra.join(" · ") + "</div>" : "");
  }

  // =====================================================================
  // 회원 / 관리자 상태
  // =====================================================================
  function setUser(token, user, msg) {
    state.userToken = token || ""; state.user = user || null;
    if (token) safeLocal("set", "portalUserToken", token); else safeLocal("del", "portalUserToken");
    updateNav();
    if (msg) toast(msg, user ? "ok" : "");
    if (state.detail) renderDetail();
    render(false);
    presencePing();
  }
  function updateNav() {
    var u = state.user;
    $("#navApply").style.display = canApply() ? "" : "none";
    $("#navAccountLabel").textContent = u ? u.name + (u.title ? " " + u.title : "") : "로그인 / 가입";
    var tb = $("#navAccountBadge");
    tb.textContent = u ? u.team : "";
    tb.style.display = u ? "" : "none";
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
    dashboard: renderDashboard, items: renderItems, tasks: renderTasks,
    apply: renderApply, criteria: renderCriteria, admin: renderAdmin, account: renderAccount
  };
  function onHash() {
    var parts = location.hash.replace(/^#\/?/, "").split("/");
    var route = VIEWS[parts[0]] ? parts[0] : "dashboard";
    var changed = route !== state.route;
    state.route = route;
    $all(".nav-link").forEach(function (a) { a.classList.toggle("active", a.getAttribute("data-route") === route); });
    render(true);
    if (changed) { window.scrollTo(0, 0); if (state.clientId) presencePing(); }
    if (route === "items" && parts[1]) openDetail(decodeURIComponent(parts[1]));
  }
  function go(route) {
    if (location.hash === "#" + route) onHash(); else location.hash = route;
  }
  function render(animate) {
    var view = $("#view");
    VIEWS[state.route]();
    if (animate) { view.classList.remove("enter"); void view.offsetWidth; view.classList.add("enter"); }
  }
  function setView(html) { $("#view").innerHTML = html; }

  // =====================================================================
  // 메뉴 1: 대시보드
  // =====================================================================
  function donutPath(cx, cy, ro, ri, a0, a1) {
    if (a1 - a0 >= 359.99) a1 = a0 + 359.99;
    var r = function (a) { return (a - 90) * Math.PI / 180; };
    var p = function (rad, ang) { return [cx + rad * Math.cos(r(ang)), cy + rad * Math.sin(r(ang))]; };
    var o1 = p(ro, a0), o2 = p(ro, a1), i1 = p(ri, a1), i2 = p(ri, a0);
    var large = a1 - a0 > 180 ? 1 : 0;
    return ["M", o1, "A", ro, ro, 0, large, 1, o2, "L", i1, "A", ri, ri, 0, large, 0, i2, "Z"].join(" ").replace(/,/g, " ");
  }
  function seg(count, max, color, label) {
    if (!count) return "";
    var w = (count / max) * 100;
    return '<div class="bar-seg" style="width:' + w + "%;background:" + color + '" title="' + esc(label + " " + count + "건") + '">' +
      (w >= 9 ? esc(label) + " " + count : "") + "</div>";
  }

  function renderDashboard() {
    var y = state.f.dashYear;
    var items = state.items.filter(function (i) { return y === "ALL" || yearOf(i.proposalDate) === y; });
    var prod = items.filter(function (i) { return i.category === "제품"; });
    var np = prod.filter(function (i) { return i.npSp === "NP"; });
    var sp = prod.filter(function (i) { return i.npSp === "SP"; });
    var tech = items.filter(function (i) { return i.category === "기술"; });

    var wait = 0, ing = 0, done = 0, fast = 0, sub = 0, cols = [0, 0, 0, 0, 0, 0];
    items.forEach(function (i) {
      var s = stageInfo(i);
      if (s.phase === "WAIT") wait++; else if (s.isDone) done++; else ing++;
      if (s.fastTrack && s.phase !== "WAIT") fast++;
      if (s.subDecision && s.phase !== "WAIT") sub++;
      cols[s.col]++;
    });
    var rate = items.length ? Math.round(done / items.length * 100) : 0;

    var tasks = tasksOf(items);
    var delayed = tasks.filter(function (t) { return t.delay > 0; });
    var maxDelay = delayed.reduce(function (m, t) { return Math.max(m, t.delay); }, 0);
    var gStat = {}; GRADES.forEach(function (g) { gStat[g] = { ing: 0, done: 0 }; });
    var sStat = {}; SECTORS.forEach(function (s) { sStat[s] = { ing: 0, delay: 0, done: 0 }; });
    tasks.forEach(function (t) {
      var g = normGrade(t.risk.grade) || "중";
      var isDone = t.risk.status === "완료";
      gStat[g][isDone ? "done" : "ing"]++;
      var ss = sStat[t.risk.sector] || sStat[SECTORS[0]];
      if (isDone) ss.done++; else if (t.delay > 0) ss.delay++; else ss.ing++;
    });

    // 1. 도넛 파이차트
    var pieSegs = [
      { key: "제품-NP", label: "제품 [NP]", color: "#2563eb", items: np },
      { key: "제품-SP", label: "제품 [SP]", color: "#6366f1", items: sp },
      { key: "기술", label: "기술", color: "#0d9488", items: tech }
    ];
    var slices = "", angle = 0;
    if (!items.length) {
      slices = '<circle cx="100" cy="100" r="67" fill="none" stroke="#e2e8f0" stroke-width="38"/>';
    } else {
      pieSegs.forEach(function (sg) {
        if (!sg.items.length) return;
        var a = sg.items.length / items.length * 360;
        slices += '<path class="pie-slice" d="' + donutPath(100, 100, 86, 48, angle, angle + a) + '" fill="' + sg.color +
          '" data-action="pieGo" data-key="' + sg.key + '"><title>' + sg.label + " " + sg.items.length + "건</title></path>";
        angle += a;
      });
    }
    var legend = pieSegs.map(function (sg) {
      var cnt = sg.items.length;
      var dn = sg.items.filter(function (i) { return stageInfo(i).isDone; }).length;
      var pct = items.length ? Math.round(cnt / items.length * 100) : 0;
      return '<div class="pie-legend-item" data-action="pieGo" data-key="' + sg.key + '">' +
        '<div class="legend-left"><span class="legend-dot" style="background:' + sg.color + '"></span>' + sg.label + "</div>" +
        '<div class="legend-right"><strong>' + cnt + "건 (" + pct + "%)</strong><div>진행 " + (cnt - dn) + " · 완료 " + dn + "</div></div></div>";
    }).join("");

    // 2. 파이프라인
    var funnelDefs = [{ name: "접수대기", cls: "wait" }].concat(STAGES.map(function (s, i) {
      return { name: (i + 1) + ". " + s.name, cls: i === 4 ? "final" : "" };
    }));
    var maxCol = Math.max.apply(null, [1].concat(cols));
    var funnel = funnelDefs.map(function (fd, i) {
      var cnt = cols[i];
      var h = cnt ? Math.max(Math.round(cnt / maxCol * 100), 10) : 3;
      var extra = i === 0 ? "신규 신청" : i === 5 ? "완료 " + done + " · 대기 " + (cnt - done) : "";
      return '<div class="funnel-col ' + fd.cls + '" title="' + esc(fd.name + " " + cnt + "건") + '"><div class="funnel-val">' + cnt + "건</div>" +
        '<div class="funnel-bar-wrap"><div class="funnel-bar" style="height:' + h + '%"></div></div>' +
        '<div class="funnel-name">' + esc(fd.name) + '</div><div class="funnel-extra">' + extra + "</div></div>";
    }).join("");

    // 3. 등급별
    var maxG = Math.max(1, Math.max.apply(null, GRADES.map(function (g) { return gStat[g].ing + gStat[g].done; })));
    var gradeRows = GRADES.map(function (g) {
      var s = gStat[g];
      return '<div class="bar-row" data-action="gradeGo" data-grade="' + g + '">' +
        '<div class="bar-label"><span class="grade-chip ' + GRADE_CLS[g] + '">' + g + "</span>" + g + " 등급</div>" +
        '<div class="bar-track">' + seg(s.ing, maxG, "var(--c-ing)", "진행중") + seg(s.done, maxG, "var(--c-done)", "완료") + "</div>" +
        '<div class="bar-count">진행 ' + s.ing + " / 완료 " + s.done + "</div></div>";
    }).join("");

    // 4. 부문별
    var maxS = Math.max(1, Math.max.apply(null, SECTORS.map(function (s) { var x = sStat[s]; return x.ing + x.delay + x.done; })));
    var sectorRows = SECTORS.map(function (sec) {
      var s = sStat[sec];
      return '<div class="bar-row" data-action="sectorGo" data-sector="' + esc(sec) + '">' +
        '<div class="bar-label">' + esc(sec) + "</div>" +
        '<div class="bar-track">' + seg(s.delay, maxS, "var(--c-delay)", "지연") + seg(s.ing, maxS, "var(--c-ing)", "진행") +
        seg(s.done, maxS, "var(--c-done)", "완료") + "</div>" +
        '<div class="bar-count">진행 ' + (s.ing + s.delay) + (s.delay ? ' <span class="delay-txt">(지연 ' + s.delay + ")</span>" : "") +
        " / 완료 " + s.done + "</div></div>";
    }).join("");

    setView(
      '<div class="page-head"><div><h2>📊 대시보드</h2><p>양산이관 검증 현황 요약 · 그래프를 클릭하면 해당 목록으로 이동합니다</p></div>' +
      '<div class="page-actions"><span class="filter-label">기준연도</span><select class="select" data-filter="dashYear">' + yearOptions(y) + "</select>" +
      '<button class="btn btn-secondary" data-action="refresh">🔄 최신 데이터</button></div></div>' +

      '<section class="kpi-grid">' +
      '<div class="kpi-card"><div class="kpi-label"><span>총 양산이관 대상</span><span class="badge badge-product">제품 / 기술</span></div>' +
      '<div class="kpi-value">' + items.length + '건</div><div class="kpi-sub"><span class="kpi-pill">제품 ' + prod.length +
      " (NP " + np.length + " / SP " + sp.length + ')</span><span class="kpi-pill">기술 ' + tech.length + "</span></div></div>" +

      '<div class="kpi-card progress"><div class="kpi-label"><span>검증 진행 / 최종승인 완료</span><span class="badge badge-done">완료율 ' + rate + "%</span></div>" +
      '<div class="kpi-value">진행중 ' + ing + " / 완료 " + done + '</div><div class="kpi-sub">' +
      '<span class="kpi-pill" style="background:#ede9fe;color:#6d28d9">🆕 접수대기 ' + wait + "</span>" +
      '<span class="kpi-pill" style="background:#fef08a;color:#854d0e">⚡ 패스트트랙 ' + fast + "</span>" +
      '<span class="kpi-pill" style="background:#e0f2fe;color:#0369a1">📌 소위전결 ' + sub + "</span></div></div>" +

      '<div class="kpi-card delay ' + (delayed.length ? "has-delay" : "") + '" data-action="delayGo" title="클릭 시 지연 과제 목록으로 이동">' +
      '<div class="kpi-label"><span>🚨 지연 과제</span><span class="badge" style="background:#fee2e2;color:#b91c1c">목표일 경과 · 진행중</span></div>' +
      '<div class="kpi-value">' + delayed.length + '건</div><div class="kpi-sub"><span class="kpi-pill">전체 과제 ' + tasks.length + "건</span>" +
      '<span class="kpi-pill">진행중 ' + tasks.filter(function (t) { return t.risk.status !== "완료"; }).length + "</span>" +
      (maxDelay ? '<span class="kpi-pill" style="color:#b91c1c">최장 +' + maxDelay + "일</span>" : "") +
      '</div><div class="kpi-hint">클릭 → 보완 과제 현황(지연 필터)</div></div></section>' +

      '<section class="charts-grid">' +
      '<div class="card chart-card"><div class="chart-head"><div><div class="card-title">1. 구분별 양산이관 현황</div>' +
      '<div class="card-sub">조각 클릭 → 세부현황 구분 필터 적용</div></div></div><div class="chart-body"><div class="pie-wrap">' +
      '<div class="pie-svg-wrap"><svg class="pie-svg" viewBox="0 0 200 200">' + slices + '</svg><div class="pie-center"><b>' + items.length +
      "건</b><span>" + (y === "ALL" ? "전체 연도" : y + "년") + '</span></div></div><div class="pie-legend">' + legend + "</div></div></div></div>" +

      '<div class="card chart-card"><div class="chart-head"><div><div class="card-title">2. 검증 단계별 진행 현황</div>' +
      '<div class="card-sub">현재 계류 단계 기준 · 패스트트랙/소위전결(Skip) 반영</div></div></div><div class="chart-body"><div class="funnel">' + funnel + "</div></div></div>" +

      '<div class="card chart-card"><div class="chart-head"><div><div class="card-title">3. 등급별(상·중·하) 도출 과제 현황</div>' +
      '<div class="card-sub">막대 클릭 → 보완 과제 현황 등급 필터</div></div><div class="legend-inline"><span><i style="background:var(--c-ing)"></i>진행중</span>' +
      '<span><i style="background:var(--c-done)"></i>완료</span></div></div><div class="chart-body">' + gradeRows + "</div></div>" +

      '<div class="card chart-card"><div class="chart-head"><div><div class="card-title">4. 6대 부문별 도출 과제 및 지연 현황</div>' +
      '<div class="card-sub">막대 클릭 → 보완 과제 현황 부문 필터</div></div><div class="legend-inline"><span><i style="background:var(--c-delay)"></i>지연</span>' +
      '<span><i style="background:var(--c-ing)"></i>진행중</span><span><i style="background:var(--c-done)"></i>완료</span></div></div>' +
      '<div class="chart-body">' + sectorRows + "</div></div></section>"
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
      if (f.status !== "ALL" && stageInfo(i).phase !== f.status) return false;
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
      [["ALL", "전체"], ["WAIT", "접수대기"], ["ING", "검토진행중"], ["DONE", "최종승인완료"]].map(function (o) {
        return '<option value="' + o[0] + '"' + (f.status === o[0] ? " selected" : "") + ">" + o[1] + "</option>";
      }).join("") + "</select>" +
      '<input class="input" style="width:200px" placeholder="제품/기술명, 요청자 검색" data-filter="list.q" value="' + esc(f.q) + '" /></div></div>' +
      '<div class="card-sub">검색 결과 <b id="itemsCount">0</b>건</div>' +
      '<div class="table-wrap"><table><thead><tr><th style="width:52px">번호</th><th style="width:110px">구분</th><th>제품 / 기술명</th>' +
      '<th style="width:150px">요청자</th><th style="width:100px">발제일</th><th style="width:270px">현재 진행 단계</th>' +
      '<th style="width:170px">도출 과제 (상·중·하)</th><th style="width:60px">첨부</th><th style="width:105px">상태</th></tr></thead>' +
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
      tasks.forEach(function (t) { gc[normGrade(t.risk.grade) || "중"]++; if (t.risk.status === "완료") dn++; if (t.delay) dl++; });
      var chips = GRADES.filter(function (g) { return gc[g]; }).map(function (g) {
        return '<span class="grade-chip ' + GRADE_CLS[g] + '">' + g + ":" + gc[g] + "</span>";
      }).join("");
      return '<tr class="row-link" data-action="openDetail" data-id="' + esc(item.id) + '">' +
        '<td class="muted" style="font-weight:700">' + (list.length - idx) + "</td><td>" + catBadge(item) + "</td>" +
        '<td><div style="font-weight:700">' + esc(item.title) + trackBadges(si) + '</div><div class="muted" style="font-size:11px">' + esc(item.id) + "</div></td>" +
        "<td>" + esc(item.requester) + (item.requesterDept ? '<div class="muted" style="font-size:11px">' + esc(item.requesterDept) + "</div>" : "") + "</td>" +
        '<td style="font-weight:600">' + esc(item.proposalDate || "-") + "</td>" +
        '<td><div style="display:flex;align-items:center">' + miniDots(item) + '<span style="font-size:12px;font-weight:700">' + esc(si.name) + "</span></div></td>" +
        "<td>" + (tasks.length ? '<span style="font-weight:700;font-size:12px;margin-right:4px">완료 ' + dn + "/" + tasks.length + "</span>" + chips +
          (dl ? '<span class="badge badge-delay">지연 ' + dl + "</span>" : "") : '<span class="muted" style="font-size:12px">없음</span>') + "</td>" +
        "<td>" + (item.attachments.length ? '<span title="' + esc(item.attachments.map(function (a) { return a.name; }).join("\n")) + '">📎 ' + item.attachments.length + "</span>" : '<span class="muted">-</span>') + "</td>" +
        "<td>" + statusBadge(si) + "</td></tr>";
    }).join("");
  }

  // =====================================================================
  // 메뉴 3: 보완 과제 현황
  // =====================================================================
  function filteredTasks() {
    var f = state.f.task, q = f.q.trim().toLowerCase();
    return tasksOf(state.items).filter(function (t) {
      var r = t.risk;
      if (f.grade !== "ALL" && normGrade(r.grade) !== f.grade) return false;
      if (f.sector !== "ALL" && r.sector !== f.sector) return false;
      if (f.status === "DELAY" && !t.delay) return false;
      if ((f.status === "진행중" || f.status === "완료") && r.status !== f.status) return false;
      if (q && [r.riskItem, r.planContent, r.org, r.reviewer, t.item.title].join(" ").toLowerCase().indexOf(q) === -1) return false;
      return true;
    }).sort(function (a, b) {
      // 지연(지연일 큰 순) → 진행중(목표일 빠른 순, 미정은 뒤) → 완료(최근 순)
      var ra = a.delay ? 0 : a.risk.status === "완료" ? 2 : 1, rb = b.delay ? 0 : b.risk.status === "완료" ? 2 : 1;
      if (ra !== rb) return ra - rb;
      if (ra === 0) return b.delay - a.delay;
      if (ra === 1) return (a.risk.schedule || "9999").localeCompare(b.risk.schedule || "9999");
      return (b.risk.schedule || "").localeCompare(a.risk.schedule || "");
    });
  }

  function renderTasks() {
    var f = state.f.task;
    var all = tasksOf(state.items);
    var delayCnt = all.filter(function (t) { return t.delay; }).length;
    setView(
      '<div class="page-head"><div><h2>🛠️ 보완 과제 현황</h2><p>과제화(O)된 Risk 보완 과제 통합 추적 · 목표일이 지난 진행중 과제는 최상단에 표시됩니다</p></div>' +
      '<div class="page-actions"><span class="badge badge-gray">전체 ' + all.length + '건</span><span class="badge badge-delay">🚨 지연 ' + delayCnt + "건</span>" +
      '<button class="btn btn-excel" data-action="csvRisk">📥 엑셀(Risk 상세표)</button></div></div>' +
      '<div class="card"><div class="toolbar"><div class="filter-group"><span class="filter-label">등급</span>' +
      [["ALL", "전체"], ["상", "상"], ["중", "중"], ["하", "하"]].map(function (g) {
        return '<button class="chip-btn ' + (f.grade === g[0] ? "active" : "") + '" data-action="taskGrade" data-grade="' + g[0] + '">' + g[1] + "</button>";
      }).join("") +
      '<span class="filter-label" style="margin-left:8px">상태</span>' +
      [["ALL", "전체"], ["DELAY", "🚨 지연과제만"], ["진행중", "진행중"], ["완료", "완료"]].map(function (s) {
        return '<button class="chip-btn ' + (s[0] === "DELAY" ? "danger " : "") + (f.status === s[0] ? "active" : "") + '" data-action="taskStatus" data-status="' + s[0] + '">' + s[1] + "</button>";
      }).join("") +
      '</div><div class="filter-group"><span class="filter-label">부문</span><select class="select" data-filter="task.sector">' +
      ['<option value="ALL">전체 부문</option>'].concat(SECTORS.map(function (s) {
        return '<option value="' + esc(s) + '"' + (f.sector === s ? " selected" : "") + ">" + esc(s) + "</option>";
      })).join("") + "</select>" +
      '<input class="input" style="width:200px" placeholder="담당조직, Risk, 보완방안 검색" data-filter="task.q" value="' + esc(f.q) + '" />' +
      '<button class="btn btn-secondary btn-sm" data-action="taskReset">초기화</button></div></div>' +
      '<div class="card-sub">검색 결과 <b id="tasksCount">0</b>건' + (state.isAdmin ? " · 상태 버튼을 누르면 진행중 ⇄ 완료가 즉시 저장됩니다" : " · 상태 변경은 관리자 모드에서 가능합니다") + "</div>" +
      '<div class="table-wrap"><table><thead><tr><th style="width:52px">번호</th><th style="width:90px">구분</th><th style="width:200px">제품 / 기술명</th>' +
      '<th style="width:90px">부문</th><th style="width:70px">등급</th><th>예상 Risk 항목 및 보완 방안</th><th style="width:140px">담당조직 (팀장)</th>' +
      '<th style="width:130px">목표 일정</th><th style="width:110px">과제 상태</th></tr></thead><tbody id="tasksBody"></tbody></table></div></div>'
    );
    renderTasksTable();
  }

  function renderTasksTable() {
    var list = filteredTasks();
    $("#tasksCount").textContent = list.length;
    var body = $("#tasksBody");
    if (!list.length) { body.innerHTML = '<tr><td colspan="9" class="empty-state">조건에 해당하는 보완 과제가 없습니다.</td></tr>'; return; }
    body.innerHTML = list.map(function (t, idx) {
      var r = t.risk, g = normGrade(r.grade) || "중", isDone = r.status === "완료";
      return '<tr class="' + (t.delay ? "row-delay" : "") + '">' +
        '<td class="muted" style="font-weight:700">' + (list.length - idx) + "</td><td>" + catBadge(t.item) + "</td>" +
        '<td><span class="link-text" data-action="openDetail" data-id="' + esc(t.item.id) + '">' + esc(t.item.title) + "</span></td>" +
        '<td><span class="badge badge-gray">' + esc(r.sector) + "</span></td>" +
        '<td><span class="grade-chip ' + GRADE_CLS[g] + '">' + g + "</span></td>" +
        '<td><div class="pre" style="font-weight:700">⚠️ ' + esc(r.riskItem || "-") + "</div>" +
        '<div class="pre" style="font-size:12px;color:var(--text-sub);margin-top:3px">💡 보완: ' + esc(r.planContent || "-") + "</div></td>" +
        '<td><div style="font-weight:700">' + esc(r.org || "-") + "</div>" + (r.reviewer ? '<div class="muted" style="font-size:11px">팀장: ' + esc(r.reviewer) + "</div>" : "") + "</td>" +
        '<td style="font-weight:600">' + esc(r.schedule || "미정") + (t.delay ? '<div><span class="badge badge-delay">🚨 지연 (+' + t.delay + "일)</span></div>" : "") + "</td>" +
        '<td><button class="btn btn-sm ' + (isDone ? "btn-teal" : "btn-secondary") + '" data-action="taskToggle" data-id="' + esc(t.item.id) + '" data-idx="' + t.idx + '"' +
        (state.isAdmin ? "" : ' disabled title="관리자 모드에서 변경 가능"') + ">" + (isDone ? "✓ 완료" : "⏳ 진행중") + "</button></td></tr>";
    }).join("");
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
      '<div class="field"><label for="apDate">발제일</label><input id="apDate" type="date" class="input" value="' + today() + '" /></div>' +
      '<div class="field full"><label for="apTitle">제품 / 기술명 <span class="req">*</span></label><input id="apTitle" class="input" maxlength="200" placeholder="예) 차세대 SiC 전력반도체 모듈 Gen-4" /></div>' +
      '<div class="field"><label for="apReq">요청자 성명 <span class="req">*</span></label><input id="apReq" class="input" maxlength="100" placeholder="예) 홍길동 책임" value="' + esc(me.name ? me.name + (me.title ? " " + me.title : "") : "") + '" /></div>' +
      '<div class="field"><label for="apDept">소속 부서 <span class="req">*</span></label><input id="apDept" class="input" maxlength="100" placeholder="예) 제품개발팀" value="' + esc(me.team || "") + '" /></div>' +
      '<div class="field full"><label for="apEmail">요청자 이메일 <span class="muted">(선택 · 검토 요청 메일 참조로 자동 포함)</span></label><input id="apEmail" type="email" class="input" placeholder="name@company.com" value="' + esc(me.email || "") + '" /></div>' +
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
      "<li><span>3</span><span>전 부문 특이사항이 없으면 <b>⚡ 패스트트랙</b>으로 2~4단계를 생략합니다.</span></li>" +
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
    fd.append("title", title); fd.append("requester", req); fd.append("requesterDept", dept);
    fd.append("requesterEmail", email); fd.append("proposalDate", $("#apDate").value || today());
    fd.append("summary", $("#apSummary").value);
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
  function teamOptions(selected) {
    return '<option value="">팀 선택</option>' + state.teams.map(function (t) {
      var tag = t.canApply ? " (신청 가능)" : t.sector ? " (" + t.sector + " 부문 검토)" : "";
      return '<option value="' + esc(t.name) + '"' + (selected === t.name ? " selected" : "") + ">" + esc(t.name + tag) + "</option>";
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
      '<div class="admin-grid"><div class="card"><div class="card-title">🔐 로그인</div>' +
      '<div class="field"><label>사번</label><input id="loginEmp" class="input" autocomplete="username" placeholder="예) 2015001" /></div>' +
      '<div class="field"><label>비밀번호</label><input id="loginPw" type="password" class="input" autocomplete="current-password" /></div>' +
      '<button class="btn btn-primary btn-lg" data-action="userLogin">로그인</button>' +
      '<div class="card-sub">비밀번호를 잊었으면 관리자에게 임시 비밀번호 발급을 요청하세요.</div></div>' +
      '<div class="card"><div class="card-title">📝 가입 신청</div><div class="info-grid" style="grid-template-columns:1fr 1fr">' +
      '<div class="field"><label>사번 <span class="req">*</span></label><input id="suEmp" class="input" maxlength="20" placeholder="영문/숫자" /></div>' +
      '<div class="field"><label>이름 <span class="req">*</span></label><input id="suName" class="input" maxlength="30" /></div>' +
      '<div class="field"><label>직급</label><input id="suTitle" class="input" maxlength="20" placeholder="예) 팀장, 책임" /></div>' +
      '<div class="field"><label>팀 <span class="req">*</span></label><select id="suTeam" class="select">' + teamOptions("") + "</select></div>" +
      '<div class="field span2"><label>이메일 <span class="req">*</span> <span class="muted">(작성 완료·검토 요청 메일에 사용)</span></label><input id="suEmail" type="email" class="input" placeholder="name@company.com" /></div>' +
      '<div class="field"><label>비밀번호 <span class="req">*</span></label><input id="suPw" type="password" class="input" autocomplete="new-password" /></div>' +
      '<div class="field"><label>비밀번호 확인 <span class="req">*</span></label><input id="suPw2" type="password" class="input" autocomplete="new-password" /></div>' +
      '</div><button class="btn btn-teal" data-action="userSignup">가입 신청</button>' +
      '<div class="card-sub">· 개발팀(결정성장/EPI/Wafering/제품개발팀): 양산이관 신청 가능<br>· 6대 부문 검토팀: 담당 부문 Risk 검토 작성 및 작성 완료 처리</div></div></div>'
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
      }).join("") + "</div>" + body + "</div>"
    );
    if (c.tab === "forms" && c.forms === null) loadForms();
  }
  // 1~5단계를 한 줄로: 각 단계 카드(주관·검토자·주요 활동·결과) + 생략(Skip) 경로는 아래 띠로 표시
  var PROCESS_STEPS = [
    { no: "접수", cls: "start", title: "양산이관 신청", who: "개발팀 (신청) → 간사 (접수)",
      act: ["양산이관 신청서·검증보고서 등록", "간사 접수 승인 (접수대기 → 접수)"], out: "6대 부문 검토 요청" },
    { no: "1단계", title: "전문소위원 검토", who: "6대 부문 팀장 (서면검토)",
      act: ["부문별 예상 Risk 항목 작성", "과제화 여부(O/X)·등급(상·중·하)", "보완 방안·담당조직·목표 일정"], out: "부문별 [작성 완료] → 간사 메일" },
    { no: "2단계", title: "양산이관 검증소위원회", who: "간사 주관 · 부문 팀장 참석",
      act: ["1단계 Risk 심의", "보완 과제 확정"], out: "소위 전결 또는 상정" },
    { no: "3단계", title: "전문위원 검토", who: "담당 · 본부장급",
      act: ["미결·중대 Risk 검토", "보완 방안 적정성 확인"], out: "검증위원회 상정" },
    { no: "4단계", title: "검증위원회", who: "위원장 · 전문위원",
      act: ["양산이관 가부 심의·의결"], out: "최종승인 요청" },
    { no: "5단계", cls: "final", title: "최종승인", who: "위원장",
      act: ["보완 과제 이행 확인", "양산이관 최종승인"], out: "양산이관 완료" }
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
      skip("fast", "⚡", "패스트트랙", "1단계 완료", "5단계 최종승인", "1단계 6대 부문 모두 '특이사항 없음'", "3 / span 9") +
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
    if (!state.adminMailItemId || !findItem(state.adminMailItemId)) state.adminMailItemId = state.items[0] ? state.items[0].id : "";

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
      '<div class="table-wrap"><table><thead><tr><th>팀 이름</th><th style="width:170px">검토 부문</th><th style="width:130px">양산이관 신청</th><th style="width:60px"></th></tr></thead><tbody id="teamBody"></tbody></table></div>' +
      '<div style="display:flex;justify-content:space-between;gap:6px"><button class="btn btn-secondary btn-sm" data-action="teamAdd">+ 팀 추가</button>' +
      '<button class="btn btn-primary btn-sm" data-action="teamSave">💾 팀 목록 저장</button></div></div>' +

      // 알림 수신자
      '<div class="card"><div class="card-title">📨 신규 신청 알림 수신자</div>' +
      '<div class="field"><label>담당자(간사) 이메일 <span class="muted">(여러 명은 ; 또는 줄바꿈 구분)</span></label><textarea id="stSecretary" class="textarea" style="min-height:60px">' + esc(s.secretaryEmails.join("; ")) + "</textarea></div>" +
      '<div class="field"><label>팀장 이메일</label><textarea id="stLeader" class="textarea" style="min-height:60px">' + esc(s.leaderEmails.join("; ")) + "</textarea></div>" +
      '<div class="field"><label>포털 접속 주소 <span class="muted">(메일 본문 링크 · 비우면 자동: ' + esc(s.suggestedPortalUrl) + ")</span></label>" +
      '<input id="stPortalUrl" class="input" value="' + esc(s.portalUrl) + '" placeholder="' + esc(s.suggestedPortalUrl) + '" /></div>' +
      '<div style="display:flex;justify-content:flex-end"><button class="btn btn-primary btn-sm" data-action="saveRecipients">💾 저장</button></div></div>' +

      // 메일 발송 설정
      '<div class="card"><div class="card-title">⚙️ 메일 발송 설정</div>' +
      '<label class="check-line"><input type="checkbox" id="stPreferOutlook" ' + (s.mail.preferOutlook ? "checked" : "") + " /> 서버 PC Outlook 자동 발송 우선 사용 (실패 시 SMTP)</label>" +
      '<div class="info-grid" style="grid-template-columns:2fr 1fr"><div class="field"><label>SMTP 호스트</label><input id="stSmtpHost" class="input" value="' + esc(smtp.host) + '" placeholder="mail.company.com" /></div>' +
      '<div class="field"><label>포트</label><input id="stSmtpPort" type="number" class="input" value="' + esc(smtp.port) + '" /></div>' +
      '<div class="field"><label>계정 (선택)</label><input id="stSmtpUser" class="input" value="' + esc(smtp.username) + '" autocomplete="off" /></div>' +
      '<div class="field"><label>비밀번호 ' + (smtp.hasPassword ? '<span class="badge badge-done">저장됨</span>' : "") + '</label><input id="stSmtpPw" type="password" class="input" placeholder="' + (smtp.hasPassword ? "변경 시에만 입력" : "") + '" autocomplete="new-password" /></div>' +
      '<div class="field"><label>발신자 주소</label><input id="stSmtpSender" class="input" value="' + esc(smtp.sender) + '" placeholder="미입력 시 계정/간사 주소" /></div>' +
      '<div class="field"><label>&nbsp;</label><label class="check-line"><input type="checkbox" id="stSmtpTls" ' + (smtp.useTls ? "checked" : "") + " /> STARTTLS</label></div></div>" +
      '<div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center"><input id="stTestTo" class="input" style="flex:1;min-width:160px" placeholder="테스트 수신 주소 (비우면 간사)" />' +
      '<button class="btn btn-secondary btn-sm" data-action="mailTest" data-method="outlook">Outlook 테스트</button>' +
      '<button class="btn btn-secondary btn-sm" data-action="mailTest" data-method="smtp">SMTP 테스트</button>' +
      '<button class="btn btn-primary btn-sm" data-action="saveMailCfg">💾 저장</button></div></div>' +

      // 주소록
      '<div class="card full"><div class="card-title">📒 6대 부문별 검토자 주소록 <span class="card-sub">전문소위원 = 팀장급, 전문위원 = 담당/본부장급</span></div>' +
      '<div class="table-wrap"><table><thead><tr><th style="width:120px">부문</th><th style="width:190px">구분</th><th style="width:130px">성명</th><th style="width:110px">직급</th><th>이메일</th><th style="width:60px"></th></tr></thead><tbody id="rvBody"></tbody></table></div>' +
      '<div style="display:flex;justify-content:space-between;gap:6px"><button class="btn btn-secondary btn-sm" data-action="rvAdd">+ 검토자 추가</button>' +
      '<button class="btn btn-primary btn-sm" data-action="rvSave">💾 주소록 저장</button></div></div>' +

      // 메일 작성
      '<div class="card full"><div class="card-title">✉️ 검토 요청 메일 작성</div>' +
      '<div class="filter-group"><span class="filter-label">대상 안건</span><select class="select" style="min-width:360px" data-action-change="adminMailItem">' +
      state.items.map(function (i) {
        return '<option value="' + esc(i.id) + '"' + (i.id === state.adminMailItemId ? " selected" : "") + ">[" + esc(i.id) + "] " + esc(i.title) + "</option>";
      }).join("") + '</select></div><div id="mailHost-admin"></div></div>' +

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
      "<b>자동 백업</b><span>backups/data_YYYYMMDD.json (최근 30일)</span></div></div>" +
      "</div>"
    );
    renderReviewerRows();
    if (!state.teamDraft) state.teamDraft = clone(state.teams);
    renderTeamRows();
    if (state.adminUsers) renderUserRows();
    else api("GET", "/api/admin/users").then(function (list) { state.adminUsers = list; renderUserRows(); }).catch(fail);
    var it = findItem(state.adminMailItemId);
    if (it && (!state.mail || state.mail.host !== "admin" || state.mail.itemId !== it.id)) initMail(it, "admin");
    renderMailPanel();
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
      return '<tr><td><input class="input" style="width:100%" data-team="' + i + '" data-teamf="name" value="' + esc(t.name) + '" /></td>' +
        '<td><select class="select" data-team="' + i + '" data-teamf="sector"><option value="">(없음)</option>' + SECTORS.map(function (s) {
          return '<option value="' + esc(s) + '"' + (t.sector === s ? " selected" : "") + ">" + esc(s) + "</option>";
        }).join("") + "</select></td>" +
        '<td><label class="check-line"><input type="checkbox" data-team="' + i + '" data-teamf="canApply"' + (t.canApply ? " checked" : "") + " /> 신청 가능</label></td>" +
        '<td><button class="btn btn-danger btn-sm" data-action="teamDel" data-idx="' + i + '">✕</button></td></tr>';
    }).join("");
  }
  function userAction(empId, body, msg) {
    return api("POST", "/api/admin/users/" + encodeURIComponent(empId), body).then(function (list) {
      state.adminUsers = list; renderUserRows(); if (msg) toast(msg, "ok");
    }).catch(fail);
  }

  function renderReviewerRows() {
    var body = $("#rvBody");
    if (!body) return;
    var list = state.admin.reviewers;
    if (!list.length) { body.innerHTML = '<tr><td colspan="6" class="empty-state">등록된 검토자가 없습니다.</td></tr>'; return; }
    body.innerHTML = list.map(function (r, i) {
      return "<tr><td><select class=\"select\" data-rv=\"" + i + "\" data-rvf=\"sector\">" + SECTORS.map(function (s) {
        return '<option value="' + esc(s) + '"' + (r.sector === s ? " selected" : "") + ">" + esc(s) + "</option>";
      }).join("") + "</select></td>" +
        '<td><select class="select" data-rv="' + i + '" data-rvf="level"><option value="sub"' + (r.level === "sub" ? " selected" : "") + '>전문소위원 (팀장)</option>' +
        '<option value="main"' + (r.level === "main" ? " selected" : "") + ">전문위원 (담당/본부장)</option></select></td>" +
        '<td><input class="input" style="width:100%" data-rv="' + i + '" data-rvf="name" value="' + esc(r.name) + '" /></td>' +
        '<td><input class="input" style="width:100%" data-rv="' + i + '" data-rvf="title" value="' + esc(r.title) + '" /></td>' +
        '<td><input class="input" style="width:100%" data-rv="' + i + '" data-rvf="email" value="' + esc(r.email) + '" placeholder="name@company.com" /></td>' +
        '<td><button class="btn btn-danger btn-sm" data-action="rvDel" data-idx="' + i + '">✕</button></td></tr>';
    }).join("");
  }

  // =====================================================================
  // 상세 모달
  // =====================================================================
  // 다른 사람이 방금 작성한 내용이 보이도록, 열기 전에 서버 버전을 확인해 필요하면 새로 불러온다.
  function openDetail(id) {
    api("GET", "/api/version").then(function (v) { if (v.version !== state.version) return loadAll(); })
      .catch(function () { /* 오프라인이면 캐시로 연다 */ })
      .then(function () { openDetailNow(id); });
  }
  function openDetailNow(id) {
    var item = findItem(id);
    if (!item) { toast("안건을 찾을 수 없습니다: " + id, "err"); return; }
    state.detail = { id: id, orig: clone(item), draft: clone(item) };
    initMail(item, "detail");
    renderDetail();
    $("#detailModal").classList.add("open");
    $("#detailModal").setAttribute("aria-hidden", "false");
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
    ["rev", "attachments", "accepted", "notify", "updatedAt"].forEach(function (k) {
      state.detail.draft[k] = clone(updated[k]);
      state.detail.orig[k] = clone(updated[k]);
    });
  }

  function renderDetail() {
    var d = state.detail.draft, si = stageInfo(d), admin = state.isAdmin, dis = admin ? "" : "disabled";
    var sec = admin ? "" : mySector(), editRisk = admin || !!sec;
    var roleBanner = admin ? ""
      : sec ? '<div class="banner info"><span>🖊 <b>' + esc(sec) + "</b> 부문 검토 작성 권한이 있습니다. 아래 [4] Risk 테이블에서 " + esc(sec) +
        " 행만 작성하고 <b>[✅ 작성 완료]</b>를 누르면 간사에게 메일이 발송됩니다.</span></div>"
      : '<div class="banner warn"><span>🔒 열람 모드입니다. ' + (state.user ? "검토 작성은 6대 부문 검토팀 회원만 가능합니다." : "부문 검토 작성은 로그인 후, 전체 수정은 [관리자 모드]에서 가능합니다.") + "</span>" +
        (state.user ? "" : '<button class="btn btn-secondary btn-sm" data-action="nav" data-route="account">👤 로그인</button>') + "</div>";
    var sectorBtns = sec ? '<button class="btn btn-secondary btn-sm" data-action="riskAdd">+ ' + esc(sec) + ' 행 추가</button>' +
      '<button class="btn btn-teal btn-sm" data-action="sectorSave">💾 임시 저장</button>' +
      '<button class="btn btn-primary btn-sm" data-action="sectorComplete">✅ ' + esc(sec) + " 작성 완료</button>" : "";
    $("#detailHeader").innerHTML =
      '<div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap"><h3>' + esc(d.title || "(제목 없음)") + "</h3>" + catBadge(d) + trackBadges(si) +
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
      roleBanner +

      '<div class="section"><div class="section-head"><div class="section-title">📌 기본 정보</div></div><div class="info-grid">' +
      '<div class="field"><label>구분</label><select class="select" data-dfield="category" ' + dis + '><option value="제품"' + (d.category === "제품" ? " selected" : "") + '>제품</option><option value="기술"' + (d.category === "기술" ? " selected" : "") + ">기술</option></select></div>" +
      '<div class="field"><label>NP / SP</label><select class="select" data-dfield="npSp" ' + (admin && d.category === "제품" ? "" : "disabled") + ">" +
      (d.category === "제품" ? '<option value="NP"' + (d.npSp === "NP" ? " selected" : "") + '>NP</option><option value="SP"' + (d.npSp === "SP" ? " selected" : "") + ">SP</option>" : '<option value="">해당없음</option>') + "</select></div>" +
      '<div class="field span2"><label>제품 / 기술명</label><input class="input" data-dfield="title" value="' + esc(d.title) + '" ' + dis + " /></div>" +
      '<div class="field"><label>요청자</label><input class="input" data-dfield="requester" value="' + esc(d.requester) + '" ' + dis + " /></div>" +
      '<div class="field"><label>소속 부서</label><input class="input" data-dfield="requesterDept" value="' + esc(d.requesterDept) + '" ' + dis + " /></div>" +
      '<div class="field"><label>요청자 이메일</label><input class="input" data-dfield="requesterEmail" value="' + esc(d.requesterEmail) + '" ' + dis + " /></div>" +
      '<div class="field"><label>발제일</label><input type="date" class="input" data-dfield="proposalDate" value="' + esc(d.proposalDate) + '" ' + dis + " /></div>" +
      '<div class="field span4"><label>양산이관 주요 내용 및 변경점</label><textarea class="textarea" data-dfield="summary" ' + dis + ">" + esc(d.summary) + "</textarea></div>" +
      '<div class="field span4"><span class="lbl">첨부파일</span><div id="attBox"></div></div></div></div>' +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">1</span>비고란 (Note)</div></div>' +
      '<textarea class="textarea note" data-dfield="note" placeholder="회의 요약 및 특이사항 기록..." ' + dis + ">" + esc(d.note) + "</textarea></div>" +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">2</span>5단계 진행 현황 및 전결(Skip) 제어</div>' +
      '<span id="stageBadge"></span></div><div class="stepper" id="stepperBox"></div>' +
      '<div class="card-sub">날짜 입력 = 일정 수립 · [완료 처리] 버튼 = 완료 · ⚡/📌 버튼은 다시 누르면 원복됩니다</div></div>' +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">3</span>전문(소)위원 · 전문위원 검토 요청 메일 발송</div>' +
      '<span class="card-sub">저장된 안건 내용 기준으로 작성됩니다</span></div><div id="mailHost-detail"></div></div>' +

      '<div class="section"><div class="section-head"><div class="section-title"><span class="section-num">4</span>전문(소)위원 검토 — 6대 부문 통합 Risk 테이블</div>' +
      (admin ? '<div style="display:flex;gap:6px"><button class="btn btn-secondary btn-sm" data-action="riskAddSix">+ 6대 부문 기본행</button><button class="btn btn-primary btn-sm" data-action="riskAdd">+ Risk 행 추가</button></div>' : "") +
      (sectorBtns ? '<div style="display:flex;gap:6px;flex-wrap:wrap">' + sectorBtns + "</div>" : "") +
      '</div><div class="sector-status" id="sectorStatus"></div><div class="table-wrap"><table class="risk-table"><thead>' +
      '<tr><th rowspan="2" style="width:110px">부문</th><th colspan="2">팀장 검토</th><th colspan="3">양산이관 시 예상되는 Risk 항목</th><th colspan="4">Risk 보완 방안 및 진행상태</th>' + (editRisk ? '<th rowspan="2" style="width:44px">삭제</th>' : "") + "</tr>" +
      '<tr><th style="width:110px">검토 팀장</th><th style="width:120px">특이사항 여부</th><th style="min-width:230px">예상 Risk 항목</th><th style="width:84px">과제화</th>' +
      '<th style="width:86px">Risk 등급</th><th style="min-width:230px">Risk 보완 방안 내용</th><th style="width:110px">담당조직</th><th style="width:128px">목표 일정</th><th style="width:90px">과제 상태</th></tr>' +
      '</thead><tbody id="riskBody"></tbody></table></div></div>';

    $("#detailFooter").innerHTML =
      (admin ? '<button class="btn btn-danger" data-action="deleteItem" data-id="' + esc(d.id) + '">🗑 이 안건 삭제</button>' : "<span></span>") +
      '<div style="display:flex;gap:8px;margin-left:auto"><button class="btn btn-secondary" data-action="closeDetail">닫기</button>' +
      (admin ? '<button class="btn btn-primary" data-action="detailSave">💾 저장 (공유폴더 즉시 반영)</button>' : "") +
      (sec ? '<button class="btn btn-teal" data-action="sectorSave">💾 임시 저장</button><button class="btn btn-primary" data-action="sectorComplete">✅ ' + esc(sec) + " 작성 완료 (간사에게 메일)</button>" : "") + "</div>";

    renderAttachments(); renderStepper(); renderMailPanel(); renderRiskTable(); renderSectorStatus();
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
    $("#stepperBox").innerHTML = STAGES.map(function (s, i) {
      var o = st[s.key];
      var cls = "step-box" + (o.skipped ? " skipped" : o.done ? " completed" : o.date ? " scheduled" : "") + (i === 4 ? " final" : "");
      var label = o.skipped ? "🚫 생략(Skip)" : o.done ? "✓ 완료됨" : o.date ? "📅 일정 수립됨" : "미수립";
      var doneBtn = '<button class="step-btn ' + (o.done ? "on" : "") + '" data-action="stDone" data-step="' + s.key + '"' + (admin && !o.skipped ? "" : " disabled") + ">" +
        (o.done ? (i === 4 ? "✓ 최종승인 완료 (해제)" : "✓ 완료됨 (해제)") : (i === 4 ? "최종승인 완료 처리" : "완료 처리")) + "</button>";
      var skipBtn = '<button class="step-btn skip ' + (o.skipped ? "on" : "") + '" data-action="stSkip" data-step="' + s.key + '"' + dis + ">" + (o.skipped ? "생략됨 (클릭 시 원복)" : "이 단계 생략(Skip)") + "</button>";
      var extra = "";
      if (i === 0) extra = '<button class="step-btn fast ' + (fastOn ? "on" : "") + '" data-action="stFast"' + dis + ">" + (fastOn ? "⚡ 패스트트랙 해제 (원복)" : "⚡ 특이사항 없음 (2~4단계 Skip)") + "</button>";
      if (i === 1) extra = '<button class="step-btn subd ' + (subOn ? "on" : "") + '" data-action="stSub"' + (admin && !st.step2.skipped ? "" : " disabled") + ">" + (subOn ? "📌 소위 전결 해제 (원복)" : "📌 소위 전결 (3·4단계 Skip)") + "</button>";
      return '<div class="' + cls + '"><div><div class="step-top"><span class="step-index">' + (i + 1) + '단계</span><span class="step-status">' + label + "</span></div>" +
        '<div class="step-name">' + s.name + "</div></div>" +
        '<input type="date" class="input" data-stage="' + s.key + '" value="' + esc(o.date) + '"' + (admin && !o.skipped ? "" : " disabled") + " />" +
        '<div class="step-btns">' + doneBtn + (i >= 1 && i <= 3 ? skipBtn : "") + extra + "</div></div>";
    }).join("");
    var si = stageInfo(d);
    $("#stageBadge").innerHTML = statusBadge(si) + ' <span class="badge badge-gray">현재: ' + esc(si.name) + "</span>";
  }

  function renderRiskTable() {
    var d = state.detail.draft, admin = state.isAdmin, body = $("#riskBody"), delCol = admin || !!mySector();
    if (!d.risks.length) { body.innerHTML = '<tr><td colspan="11" class="empty-state">등록된 Risk 검토 행이 없습니다.' + (admin ? " [+ 6대 부문 기본행]을 눌러 추가하세요." : "") + "</td></tr>"; return; }
    body.innerHTML = d.risks.map(function (r, i) {
      var noRisk = r.noRisk, task = !noRisk && r.isTask === "O", edit = canEditRow(r);
      var disA = edit ? "" : " disabled", disR = edit && !noRisk ? "" : " disabled", disT = edit && task ? "" : " disabled";
      var disSec = admin ? "" : " disabled";
      var attr = function (f) { return ' data-ri="' + i + '" data-rf="' + f + '"'; };
      return '<tr class="' + (noRisk ? "no-risk" : "") + (edit && !admin ? " mine" : "") + '">' +
        '<td><select class="select"' + attr("sector") + disSec + ">" + SECTORS.map(function (s) { return '<option value="' + esc(s) + '"' + (r.sector === s ? " selected" : "") + ">" + esc(s) + "</option>"; }).join("") + "</select></td>" +
        '<td><input class="input" placeholder="팀장명"' + attr("reviewer") + ' value="' + esc(r.reviewer) + '"' + disA + " /></td>" +
        '<td><label class="risk-check ' + (noRisk ? "checked" : "") + '"><input type="checkbox"' + attr("noRisk") + (noRisk ? " checked" : "") + disA + " />" +
        (noRisk ? "✓ 특이사항 없음" : "⚠️ 특이사항 있음") + "</label></td>" +
        '<td><textarea class="textarea" placeholder="예상되는 Risk 항목을 상세히 입력"' + attr("riskItem") + disR + ">" + esc(r.riskItem) + "</textarea></td>" +
        '<td><select class="select"' + attr("isTask") + disR + '><option value="O"' + (task ? " selected" : "") + '>O</option><option value="X"' + (!task ? " selected" : "") + ">X</option></select></td>" +
        '<td><select class="select"' + attr("grade") + disT + ">" + (task ? GRADES.map(function (g) { return '<option value="' + g + '"' + ((normGrade(r.grade) || "중") === g ? " selected" : "") + ">" + g + "</option>"; }).join("") : '<option value="">-</option>') + "</select></td>" +
        '<td><textarea class="textarea" placeholder="Risk 보완 방안을 상세히 입력"' + attr("planContent") + disR + ">" + esc(r.planContent) + "</textarea></td>" +
        '<td><input class="input" placeholder="담당조직"' + attr("org") + ' value="' + esc(r.org) + '"' + disR + " /></td>" +
        '<td><input type="date" class="input"' + attr("schedule") + ' value="' + esc(r.schedule) + '"' + disT + " />" +
        (delayDays(r) && task ? '<div style="margin-top:4px"><span class="badge badge-delay">🚨 +' + delayDays(r) + "일</span></div>" : "") + "</td>" +
        '<td><select class="select"' + attr("status") + disT + ">" + (task ? '<option value="진행중"' + (r.status !== "완료" ? " selected" : "") + '>진행중</option><option value="완료"' + (r.status === "완료" ? " selected" : "") + ">완료</option>" : '<option value="">-</option>') + "</select></td>" +
        (delCol ? '<td style="text-align:center">' + (edit ? '<button class="btn btn-danger btn-sm" data-action="riskDel" data-idx="' + i + '">✕</button>' : "") + "</td>" : "") + "</tr>";
    }).join("");
  }

  function renderSectorStatus() {
    var box = $("#sectorStatus");
    if (!box) return;
    var rv = state.detail.draft.sectorReviews || {};
    box.innerHTML = '<span class="filter-label">부문 작성 현황</span>' + SECTORS.map(function (sec) {
      var r = rv[sec];
      if (!r) return '<span class="sec-chip">' + esc(sec) + " · 미작성</span>";
      return '<span class="sec-chip done" title="' + esc(r.team + " " + r.name + " · " + r.at) + '">✓ ' + esc(sec) + " · " + esc(r.name) + " " + esc((r.at || "").slice(5, 10)) +
        (state.isAdmin ? '<button class="x" data-action="sectorReopen" data-sector="' + esc(sec) + '" title="작성 완료 해제(재작성 요청)">✕</button>' : "") + "</span>";
    }).join("");
  }
  function saveSector(complete) {
    var sec = mySector(), d = state.detail.draft;
    var rows = d.risks.filter(function (r) { return r.sector === sec; });
    if (complete) {
      var empty = rows.filter(function (r) { return !r.noRisk && !r.riskItem.trim(); });
      if (!rows.length) { toast(sec + " 부문 행이 없습니다. [+ 행 추가] 후 작성하세요.", "err"); return; }
      if (empty.length && !confirm("Risk 항목이 비어 있는 행이 " + empty.length + "개 있습니다. 그대로 작성 완료할까요?\n(특이사항이 없으면 '특이사항 없음'을 체크하세요)")) return;
      if (!confirm(sec + " 부문 검토를 작성 완료하고 간사에게 메일을 보낼까요?")) return;
    }
    api("POST", "/api/items/" + encodeURIComponent(d.id) + "/sector/" + encodeURIComponent(sec), { rows: rows, complete: complete }).then(function (r) {
      replaceItem(r.item); updateNavBadges();
      state.detail.orig = clone(r.item); state.detail.draft = clone(r.item);
      renderDetail();
      if (!complete) toast("임시 저장했습니다.", "ok");
      else if (r.mail === "sent") toast("작성 완료! 간사에게 메일을 발송합니다.", "ok");
      else toast("작성 완료 처리했습니다. (간사 메일 주소가 설정되지 않아 메일은 보내지 않았습니다)", "ok");
    }).catch(fail);
  }

  function onRiskField(el) {
    var d = state.detail.draft, r = d.risks[+el.getAttribute("data-ri")], f = el.getAttribute("data-rf");
    if (!r || !canEditRow(r)) return;
    if (f === "noRisk") {
      r.noRisk = el.checked;
      if (r.noRisk) { r.riskItem = ""; r.planContent = ""; r.isTask = "X"; r.grade = ""; r.status = "완료"; } else { r.status = "진행중"; }
      renderRiskTable();
    } else if (f === "isTask") {
      r.isTask = el.value; r.grade = el.value === "O" ? "중" : "";
      if (el.value === "O") r.status = "진행중";
      renderRiskTable();
    } else {
      r[f] = el.value;
      if (f === "schedule" || f === "status") renderRiskTable();
    }
  }

  function stageAction(action, key) {
    var st = state.detail.draft.stages, o = st[key];
    var mark = function (k) { st[k].done = true; st[k].skipped = false; if (!st[k].date) st[k].date = today(); };
    var skip = function (k) { st[k].skipped = true; st[k].done = false; st[k].date = ""; };
    if (action === "stDone") { if (o.done) o.done = false; else mark(key); }
    if (action === "stSkip") { if (o.skipped) o.skipped = false; else skip(key); }
    if (action === "stFast") {
      if (st.step2.skipped && st.step3.skipped && st.step4.skipped) ["step2", "step3", "step4"].forEach(function (k) { st[k].skipped = false; });
      else { mark("step1"); ["step2", "step3", "step4"].forEach(skip); }
    }
    if (action === "stSub") {
      if (!st.step2.skipped && st.step3.skipped && st.step4.skipped) ["step3", "step4"].forEach(function (k) { st[k].skipped = false; });
      else { mark("step2"); ["step3", "step4"].forEach(skip); }
    }
    // 단계를 처리하면 접수된 것으로 본다
    if (state.detail.draft.accepted === false) { state.detail.draft.accepted = true; toast("단계 처리로 접수 승인 상태로 바뀝니다. (저장 시 반영)"); renderDetail(); return; }
    renderStepper();
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
      host: host, itemId: item.id, level: "sub", selected: {},
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
    var book = state.admin.reviewers.filter(function (r) { return r.level === m.level && r.email; });
    var groups = SECTORS.map(function (sec) {
      var people = book.filter(function (r) { return r.sector === sec; });
      return '<div class="recipient-sector"><h5>' + esc(sec) + (people.length ? '<button class="btn btn-secondary btn-sm" style="padding:1px 6px;font-size:10.5px" data-action="mailSector" data-sector="' + esc(sec) + '">선택</button>' : "") + "</h5>" +
        (people.length ? people.map(function (r) {
          return '<label><input type="checkbox" data-mail-email="' + esc(r.email) + '"' + (m.selected[r.email] ? " checked" : "") + " /><span><b>" + esc(r.name) + "</b> " + esc(r.title) + '<br><span class="muted">' + esc(r.email) + "</span></span></label>";
        }).join("") : '<span class="muted" style="font-size:11.5px">주소록 미등록</span>') + "</div>";
    }).join("");
    var to = mailRecipients();
    box.innerHTML = '<div class="mail-panel"><div style="display:flex;flex-direction:column;gap:10px">' +
      '<div class="level-toggle">' + Object.keys(LEVELS).map(function (k) {
        return '<div class="radio-card ' + (m.level === k ? "selected" : "") + '" data-action="mailLevel" data-level="' + k + '">' + (k === "sub" ? "👥 " : "🏢 ") + LEVELS[k] + "</div>";
      }).join("") + "</div>" +
      '<div style="display:flex;justify-content:space-between;align-items:center"><span class="filter-label">받는 사람 (6대 부문 주소록) · 선택 <b id="mailCount">' + to.length + "</b>명</span>" +
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
    if (action === "mailLevel") { m.level = el.getAttribute("data-level"); m.selected = {}; m.preview = null; renderMailPanel(); return; }
    if (action === "mailAll" || action === "mailNone") {
      state.admin.reviewers.forEach(function (r) { if (r.level === m.level && r.email) m.selected[r.email] = action === "mailAll"; });
      m.preview = null; renderMailPanel(); return;
    }
    if (action === "mailSector") {
      var sec = el.getAttribute("data-sector");
      state.admin.reviewers.forEach(function (r) { if (r.level === m.level && r.sector === sec && r.email) m.selected[r.email] = true; });
      m.preview = null; renderMailPanel(); return;
    }
    if (action === "mailOpen") {
      if (!mailRecipients().length) { toast("받는 사람을 1명 이상 선택하세요.", "err"); return; }
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
    var head = ["ID", "구분", "NP/SP", "제품/기술명", "접수상태", "패스트트랙", "소위전결", "요청자", "소속부서", "요청자이메일", "발제일"];
    STAGES.forEach(function (s, i) { var n = i + 1; head.push(n + "단계 일정", n + "단계 완료", n + "단계 생략"); });
    head.push("진행상태", "현재단계", "주요내용", "비고");
    var rows = [head];
    list.forEach(function (i) {
      var si = stageInfo(i), st = i.stages;
      var row = [i.id, i.category, i.npSp, i.title, i.accepted === false ? "접수대기" : "접수", OX(si.fastTrack), OX(si.subDecision), i.requester, i.requesterDept, i.requesterEmail, i.proposalDate];
      STAGES.forEach(function (s) { row.push(st[s.key].date, OX(st[s.key].done), OX(st[s.key].skipped)); });
      row.push(si.phase === "WAIT" ? "접수대기" : si.isDone ? "최종승인완료" : "검토진행중", si.name, i.summary, i.note);
      rows.push(row);
    });
    downloadCsv("양산이관_요약목록_" + today() + ".csv", rows);
  }
  var RISK_HEAD = ["부문", "검토팀장", "특이사항여부", "Risk항목", "과제화", "등급", "보완방안", "담당조직", "일정", "과제상태", "지연일수"];
  function riskCells(r) {
    return [r.sector, r.reviewer, r.noRisk ? "특이사항 없음" : "특이사항 있음", r.riskItem, r.isTask, r.grade, r.planContent, r.org, r.schedule, r.isTask === "O" ? r.status : "", delayDays(r) && r.isTask === "O" ? delayDays(r) : ""];
  }
  function exportRisk(list) {
    var rows = [["ID", "구분", "NP/SP", "제품/기술명", "요청자", "발제일"].concat(RISK_HEAD).concat(["비고"])];
    list.forEach(function (i) {
      var base = [i.id, i.category, i.npSp, i.title, i.requester, i.proposalDate];
      if (!i.risks.length) rows.push(base.concat(RISK_HEAD.map(function () { return ""; })).concat([i.note]));
      i.risks.forEach(function (r) { rows.push(base.concat(riskCells(r)).concat([i.note])); });
    });
    downloadCsv("양산이관_Risk상세표_" + today() + ".csv", rows);
  }
  function exportSingle() {
    var d = state.detail.draft;
    var rows = [["ID", d.id], ["구분", catText(d)], ["제품/기술명", d.title], ["요청자", d.requester + " " + d.requesterDept], ["발제일", d.proposalDate],
      ["진행상태", stageInfo(d).name], ["주요내용", d.summary], ["비고", d.note], [], RISK_HEAD];
    d.risks.forEach(function (r) { rows.push(riskCells(r)); });
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
    var hasRisk = ["부문", "Risk항목", "예상Risk항목"].some(function (k) { return col[k] !== undefined; });
    var map = {}, order = [], byKey = {};
    var put = function (it) { map[it.id] = it; order.push(it.id); byKey[it.category + "||" + it.title] = it.id; };
    if (merge) state.items.forEach(function (it) { var c = clone(it); c._reset = hasRisk; put(c); });
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
          proposalDate: "", summary: "", note: "", accepted: true, stages: {}, risks: hasRisk ? [] : SECTORS.map(emptyRisk), attachments: [] };
        STAGES.forEach(function (s) { t.stages[s.key] = { date: "", done: false, skipped: false }; });
        put(t);
      }
      t.category = cat; t.npSp = npSp; t.title = title;
      var setIf = function (field, names, fn) { var v = get(row, names); if (v) t[field] = fn ? fn(v) : v; };
      setIf("requester", ["요청자", "담당자"]); setIf("requesterDept", ["소속부서", "소속"]); setIf("requesterEmail", ["요청자이메일", "이메일"]);
      setIf("proposalDate", ["발제일", "등록일"], normDate); setIf("summary", ["주요내용", "주요내용및변경점"]); setIf("note", ["비고", "비고(Note)"]);
      if (!t.proposalDate) t.proposalDate = today();
      var acc = get(row, ["접수상태"]);
      if (acc) t.accepted = acc !== "접수대기";
      if (hasRisk && t._reset) { t.risks = []; delete t._reset; }
      STAGES.forEach(function (s, si) {
        var n = si + 1, o = t.stages[s.key];
        var dv = get(row, [n + "단계일정", n + "단계"]), dn = get(row, [n + "단계완료"]).toUpperCase(), sk = get(row, [n + "단계생략"]).toUpperCase();
        if (dv) o.date = normDate(dv);
        if (dn) o.done = dn === "O" || dn === "완료" || dn === "TRUE";
        if (sk) o.skipped = sk === "O" || sk === "생략" || sk === "TRUE";
      });
      var ft = get(row, ["패스트트랙"]).toUpperCase();
      if (ft === "O") { t.stages.step1.done = true; ["step2", "step3", "step4"].forEach(function (k) { t.stages[k].skipped = true; t.stages[k].done = false; }); }
      if (hasRisk) {
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
    pieGo: function (el) { state.f.list = { cat: el.getAttribute("data-key"), year: state.f.dashYear, status: "ALL", q: "" }; go("items"); },
    gradeGo: function (el) { state.f.task = { grade: el.getAttribute("data-grade"), sector: "ALL", status: "ALL", q: "" }; go("tasks"); },
    sectorGo: function (el) { state.f.task = { grade: "ALL", sector: el.getAttribute("data-sector"), status: "ALL", q: "" }; go("tasks"); },
    delayGo: function () { state.f.task = { grade: "ALL", sector: "ALL", status: "DELAY", q: "" }; go("tasks"); },
    // 목록
    listCat: function (el) { state.f.list.cat = el.getAttribute("data-cat"); renderItems(); },
    taskGrade: function (el) { state.f.task.grade = el.getAttribute("data-grade"); renderTasks(); },
    taskStatus: function (el) { state.f.task.status = el.getAttribute("data-status"); renderTasks(); },
    taskReset: function () { state.f.task = { grade: "ALL", sector: "ALL", status: "ALL", q: "" }; renderTasks(); },
    taskToggle: function (el) {
      el.disabled = true;
      api("POST", "/api/items/" + encodeURIComponent(el.getAttribute("data-id")) + "/risks/" + el.getAttribute("data-idx") + "/toggle")
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
    userLogout: function () {
      api("POST", "/api/users/logout").catch(function () { });
      setUser(null, null, "로그아웃했습니다.");
    },
    userSignup: function () {
      var v = function (id) { return $("#" + id).value.trim(); };
      if (!v("suEmp") || !v("suName") || !v("suTeam") || !v("suEmail") || !$("#suPw").value) { toast("필수 항목(*)을 모두 입력하세요.", "err"); return; }
      if ($("#suPw").value !== $("#suPw2").value) { toast("비밀번호 확인이 일치하지 않습니다.", "err"); return; }
      api("POST", "/api/users/signup", { empId: v("suEmp"), name: v("suName"), title: v("suTitle"), team: v("suTeam"), email: v("suEmail"), password: $("#suPw").value })
        .then(function (r) {
          toast(r.message, "ok");
          ["suEmp", "suName", "suTitle", "suEmail", "suPw", "suPw2"].forEach(function (id) { $("#" + id).value = ""; });
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
        mail: { preferOutlook: $("#stPreferOutlook").checked },
        smtp: { host: $("#stSmtpHost").value, port: $("#stSmtpPort").value, username: $("#stSmtpUser").value, password: $("#stSmtpPw").value, sender: $("#stSmtpSender").value, useTls: $("#stSmtpTls").checked }
      }).then(function (s) { state.admin = s; renderAdmin(); toast("메일 발송 설정을 저장했습니다.", "ok"); }).catch(fail);
    },
    mailTest: function (el) {
      toast("테스트 메일 발송 중…");
      api("POST", "/api/mail/test", { method: el.getAttribute("data-method"), to: $("#stTestTo").value })
        .then(function (r) { toast(r.message, "ok"); }).catch(fail);
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
    rvAdd: function () { state.admin.reviewers.push({ sector: SECTORS[0], level: "sub", name: "", title: "팀장", email: "" }); renderReviewerRows(); },
    rvDel: function (el) { state.admin.reviewers.splice(+el.getAttribute("data-idx"), 1); renderReviewerRows(); },
    rvSave: function () {
      var bad = state.admin.reviewers.filter(function (r) { return r.email && !parseEmails(r.email).length; });
      if (bad.length) { toast("이메일 형식이 올바르지 않은 행이 있습니다: " + bad[0].email, "err"); return; }
      api("PUT", "/api/settings", { reviewers: state.admin.reviewers }).then(function (s) { state.admin = s; state.mail = null; renderAdmin(); toast("주소록을 저장했습니다.", "ok"); }).catch(fail);
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
    riskAdd: function () {
      var sec = state.isAdmin ? "" : mySector(), row = emptyRisk(sec || undefined);
      if (sec && state.user) row.reviewer = state.user.name + (state.user.title ? " " + state.user.title : "");
      var rs = state.detail.draft.risks, at = rs.length;
      if (sec) {  // 내 부문 행 바로 아래에 추가
        for (var i = rs.length - 1; i >= 0; i--) { if (rs[i].sector === sec) { at = i + 1; break; } }
      }
      rs.splice(at, 0, row); renderRiskTable();
    },
    sectorSave: function () { saveSector(false); },
    sectorComplete: function () { saveSector(true); },
    sectorReopen: function (el) {
      var sec = el.getAttribute("data-sector");
      if (!confirm(sec + " 부문 '작성 완료' 표시를 해제할까요? (재작성 요청)")) return;
      api("POST", "/api/items/" + encodeURIComponent(state.detail.id) + "/sector/" + encodeURIComponent(sec) + "/reopen").then(function (updated) {
        syncServerFields(updated); state.detail.draft.sectorReviews = clone(updated.sectorReviews); state.detail.orig.sectorReviews = clone(updated.sectorReviews);
        renderSectorStatus(); toast(sec + " 부문 작성 완료를 해제했습니다.", "ok");
      }).catch(fail);
    },
    riskAddSix: function () { SECTORS.forEach(function (s) { state.detail.draft.risks.push(emptyRisk(s)); }); renderRiskTable(); },
    riskDel: function (el) { state.detail.draft.risks.splice(+el.getAttribute("data-idx"), 1); renderRiskTable(); }
  };
  ["stDone", "stSkip", "stFast", "stSub"].forEach(function (a) { ACTIONS[a] = function (el) { stageAction(a, el.getAttribute("data-step")); }; });
  ["mailLevel", "mailAll", "mailNone", "mailSector", "mailOpen", "mailEml", "mailPreview", "mailMailto", "mailCopyTo", "mailCopyBody"]
    .forEach(function (a) { ACTIONS[a] = function (el) { mailAction(a, el); }; });

  // 신청 폼에서 구분을 바꿀 때 입력값 유지
  function keepApplyInputs(fn) {
    var ids = ["apTitle", "apReq", "apDept", "apEmail", "apSummary", "apDate"], saved = {};
    ids.forEach(function (id) { var el = $("#" + id); if (el) saved[id] = el.value; });
    fn();
    ids.forEach(function (id) { var el = $("#" + id); if (el && saved[id] !== undefined) el.value = saved[id]; });
  }

  function setFilter(path, value) {
    if (path === "dashYear") { state.f.dashYear = value; renderDashboard(); return; }
    var p = path.split(".");
    state.f[p[0]][p[1]] = value;
    if (p[0] === "list") renderItemsTable(); else renderTasksTable();
  }

  function onField(el) {
    if (el.hasAttribute("data-filter")) { setFilter(el.getAttribute("data-filter"), el.value); return; }
    if (!state.detail && !state.mail && !state.admin && !state.teamDraft) return;
    if (el.hasAttribute("data-dfield")) {
      var d = state.detail.draft, f = el.getAttribute("data-dfield");
      d[f] = el.value;
      if (f === "category") { d.npSp = d.category === "제품" ? (d.npSp || "NP") : ""; renderDetail(); }
      return;
    }
    if (el.hasAttribute("data-stage")) { state.detail.draft.stages[el.getAttribute("data-stage")].date = el.value; renderStepper(); return; }
    if (el.hasAttribute("data-rf")) { onRiskField(el); return; }
    if (el.hasAttribute("data-mf")) { state.mail[el.getAttribute("data-mf")] = el.value; state.mail.preview = null; var c = $("#mailCount"); if (c) c.textContent = mailRecipients().length; return; }
    if (el.hasAttribute("data-mail-email")) { state.mail.selected[el.getAttribute("data-mail-email")] = el.checked; state.mail.preview = null; $("#mailCount").textContent = mailRecipients().length; return; }
    if (el.hasAttribute("data-team")) {
      var t = state.teamDraft[+el.getAttribute("data-team")], tf = el.getAttribute("data-teamf");
      t[tf] = tf === "canApply" ? el.checked : el.value; return;
    }
    if (el.hasAttribute("data-user-team")) {
      userAction(el.getAttribute("data-user-team"), { action: "update", team: el.value }, "팀을 변경했습니다."); return;
    }
    if (el.hasAttribute("data-rv")) { state.admin.reviewers[+el.getAttribute("data-rv")][el.getAttribute("data-rvf")] = el.value; return; }
    if (el.getAttribute("data-action-change") === "adminMailItem") {
      state.adminMailItemId = el.value; initMail(findItem(el.value), "admin"); renderMailPanel();
    }
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
      if (t.tagName === "SELECT") return;
      onField(t);
    });
    document.addEventListener("change", function (e) {
      var t = e.target;
      if (t.type === "checkbox" || t.tagName === "SELECT") onField(t);
      else if (t.type === "date") onField(t);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && state.detail) closeDetail(false);
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
