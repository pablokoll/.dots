// Agents in grouped or priority views; parents take their most urgent sub-agent's place.
// A viewed done agent stays in Done until left.

import { View, div, image, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, terminals, panes, focused, spaces, machines, run, nextCommand, theme, shared, setShared, setAgentOrder, openOverlay, closeOverlay, props, window, layout } from "herdr";

// Same as retro-spaces.
const PX = "PxPlus IBM VGA 8x16";
const MACHINE_COLORS = ["#ff7a45", "#9ece6a", "#3fd0c9", "#bb9af7", "#7aa2f7", "#f5a524"];
// Focus/selection highlight, kept yellow when the machine palette changed.
const ACCENT = "#f5a524";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// To the rail (on macOS wide enough for the traffic lights), or back to the width it had.
function toggleSidebar() {
  const width = find(layout(), "sidebar")?.size?.px;
  if (!narrow()) setShared("sidebar.width", width);
  // Mods edited before the rail went by width still read the flag.
  setShared("sidebar.collapsed", !narrow());
  run("layout.resize", { id: "sidebar", px: narrow() ? (shared("sidebar.width") ?? 268) : window()?.platform === "macos" ? 76 : 44 });
}

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();

function lead(tab, all = panes()) {
  const mine = all.filter(p => p.tab === tab.id && p.terminal);
  return mine.find(p => p.program?.agent) ?? mine.find(p => p.focused) ?? mine[0];
}

function title(tab, l) {
  const prog = l?.program?.name;
  const live = clean(l?.title);
  const telling = live && live !== prog && !/^[~/]|^[A-Za-z]:\\/.test(live) && !live.includes("@") && live.toLowerCase() !== l?.program?.key;
  return (tab.name === prog || !tab.named) && telling ? live : tab.name;
}
const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
// A sub-agent without a pane isn't in agents(): its raw word, error counting as
// blocked. It's never done: it reports to its parent, and the parent's done is the news.
const kidStatus = (k, listed) => {
  const s = listed.get(k.address) ?? k.status;
  return s === "error" ? "blocked" : s === "done" ? "idle" : s;
};
const SORTS = [
  { id: "priority", label: "Priority", icon: "clock" },
  { id: "grouped", label: "Grouped by space", icon: "layers" },
];
const sortOf = () => SORTS.find((s) => s.id === shared("agents.sort")) ?? SORTS[0];
const SECTION = { 4: "Needs you", 3: "Done", 2: "Working", 1: "Idle" };
const SECTION_STATUS = { 4: "blocked", 3: "done", 2: "working" };

function duration(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "<1m";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

// The agent's icon from the app's program table: a one-color glyph or a picture.
function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

function hash(str) {
  let h = 2166136261;
  for (const c of str) h = Math.imul(h ^ c.codePointAt(0), 16777619);
  return h >>> 0;
}
const SKINS = ["#f5a524", "#3fd0c9", "#bb9af7", "#ff7a45", "#9ece6a", "#7aa2f7", "#f7768e", "#ffd866"];
// Card fill and border per machine, in the same order as MACHINE_COLORS.
const CARDS = [["#2a1f3d", "#5b3f80"], ["#1c2b22", "#3f6a3a"], ["#1b2e33", "#2f5a5e"], ["#2d2238", "#5e4a7a"]];
// Hand-drawn 16x16 tech sprites, left halves (mirrored) or full 16-wide rows: one per agent, picked by
// its address, with its accent color ("a") from SKINS.
const ART = {
  robot: ["........", ".......r", ".......G", "....kkkk", "...kgggg", "..kggggg", "..kgkkkk", "..kgkcwc", "..kgkkkk", "...kgggg", "....kkkk", "....kGGG", "..kkaaaa", "..kaaaay", "....kGk.", "...kkkk."],
  computer: ["........", "..kkkkkk", ".kssssss", ".kskkkkk", ".kskCCCC", ".kskCcCC", ".kskCCCC", ".kskCcCC", ".kskCCcc", ".kskCCCC", ".kskkkkk", ".kssssss", ".kkkkkkk", "....kSSS", "..kkSSSS", "..kkkkkk"],
  boxbot: ["..r.....", "..G.....", "..Gkkkkk", "..kaaaaa", "..kaaaaa", "..kakyaa", "..kaaaaa", "..kakwkw", "..kaaaaa", "..kkkkkk", "..kGGGGG", ".dkGkcGG", ".dkGGGGG", "..kkkkkk", "...kdk..", "..kkkk.."],
  server: ["........", "...kkkkk", "...kdddd", "...kdGGG", "...kdcGy", "...kdddd", "...kdGGG", "...kdaGc", "...kdddd", "...kdGGG", "...kdcGa", "...kdddd", "...kdddd", "...kkkkk", "....k...", "........"],
  handheld: ["........", "...kkkkk", "...kgggg", "...kgkkk", "...kgkcc", "...kgkcw", "...kgkcc", "...kgkkk", "...kgggg", "...kgagg", "...kaaag", "...kgagg", "...kgggg", "...kgdgd", "....kkkk", "........"],
  chest: ["........", "........", "...kkkkk", "..kooooo", ".kooyooo", ".kOOyOOO", ".kkkkkkk", ".kyyyyyy", ".kooyokk", ".kooyokc", ".kOOyOkk", ".kooyooo", ".kOOyOOO", ".kkkkkkk", "........", "........"],
  book: ["................", "...kkkkkkkkkk...", "..kUuuuuuuuuuk..", "..kUuuuuuuuuuk..", "..kUuuuuuuuuuk..", "..kUuuuyyyuuuk..", "..kUuuykkkyuuk..", "..kUuuykckyuuk..", "..kUuuykkkyuuk..", "..kUuuuyyyuuuk..", "..kUuuuuuuuuuk..", "..kUuccccccuuk..", "..kUuuuuuuuuuk..", "..kUppppppprpk..", "...kkkkkkkrkk...", "..........r....."],
  brain: ["........", "........", "....kkkk", "..kkPPPQ", ".kPPPQPQ", "ckPQQPPQ", "wPPPPQPQ", "kPQPPPQQ", "kPPQPQPQ", "wkPPPPQQ", "ckQPPQPQ", "..kkPPPQ", "....kkkk", "......kc", ".....kGc", "....kkkk"],
  journal: ["................", "................", "..kkkkkkkkkkk...", "..kVvvvvvVvpk..g", "..kVvvvvvVvpk.gG", "..kVyyvyyVvpkgG.", "..kVyyyyyVvpgG..", "..kVvyyyvVvgG...", "..kVvvyvvVyGk...", "..kVvvvvvkypk...", "..kVvvvvvVvpk...", "..kVvvvvvVvpk...", "..kVvvvvvVvpk...", "..kkkkkkkkkkk...", ".....rr.........", ".....r.........."],
  ufo: ["........", "........", "......kk", ".....kcc", "....kccw", "...kkkkk", ".kkGGGGG", "kGGGaGGa", ".kkddddd", "...kkkkk", "....y..y", "...y...y", "..y....y", "........", "........", "........"],
};
const INK = { v: "#8c3b3b", V: "#5c2424", P: "#e88aa8", Q: "#a8506e", h: "#95bf47", H: "#5e8e3e", u: "#2f6f8f", U: "#1e4459", o: "#8a5a2b", O: "#5e3a1a", p: "#e8e4d8", k: "#191a27", g: "#c0c6d9", G: "#8b93b8", d: "#4a4f6a", c: "#3fd0c9", C: "#0f2a33", w: "#ffffff", r: "#ff5f5f", y: "#ffd866", s: "#e0cfa0", S: "#a8946a" };
// Tabs and spaces with their own sprite, by name (the tab's wins); other agents
// draw from ART by address.
const SPACE_ART = { core: "brain", vault: "chest", learning: "book", journal: "journal" };
// shopimasters: Shopify things (full 16-wide rows), one per agent by address.
const SHOP_ART = {
  bag: ["................", "......HHHH......", ".....HH..HH.....", ".....H....H.....", "..kkkkkkkkkkkk..", "..khhhhhhhhhhk..", "..khhhwwwwhhhk..", "..khhwwhhhhhhk..", "..khhhwwwhhhhk..", "..khhhhhwwhhhk..", "..khhwwwwhhhhk..", "..khhhhhhhhhhk..", "..kHHHHHHHHHHk..", "..kkkkkkkkkkkk..", "................", "................"],
  cart: ["................", "kkk.............", ".kH.............", "..kkkkkkkkkkkkk.", "...khwhwhwhwhk..", "...khhhhhhhhhk..", "....khwhwhwhk...", "....khhhhhhhk...", ".....kkkkkkk....", "....kHHHHHHHHk..", "................", ".....kk...kk....", "....kGGk.kGGk...", ".....kk...kk....", "................", "................"],
  store: ["................", "..kkkkkkkkkkkk..", ".khwhwhwhwhwhwk.", ".khwhwhwhwhwhwk.", "..kHkHkHkHkHk...", "..kppppppppppk..", "..kpkkkkpkkkpk..", "..kpkcckpkHkpk..", "..kpkcckpkHkpk..", "..kpkkkkpkHkpk..", "..kppppppkykpk..", "..kppppppkHkpk..", "..kkkkkkkkkkkk..", ".kHHHHHHHHHHHHk.", "................", "................"],
  tag: ["........k.......", "......kkkk......", ".....khhhhk.....", "....khhkkhhk....", "...khhhkkhhhk...", "..khhhhwwhhhhk..", "..khhhwwwwhhhk..", "..khhwwhhhhhhk..", "..khhhwwwwhhhk..", "..khhhhhhwwhhk..", "..khhhwwwwhhhk..", "..khhhhwwhhhhk..", "..khhhhhhhhhhk..", "..kkkkkkkkkkkk..", "................", "................"],
  box: ["................", "................", "...kkkkkkkkkk...", "..kooooyyooook..", ".kkkkkkkkkkkkkk.", ".kOOOOOyyOOOOOk.", ".koooooyyoooook.", ".koooooyyoooook.", ".kooooooooooook.", ".kohhhhoooooook.", ".kohwwhoooooook.", ".kohhhhoooooook.", ".kooooooooooook.", ".kkkkkkkkkkkkkk.", "................", "................"],
};
// `size`: the sprite's width in px; cells are as big as fit.
function sprite(key, size, machine, space, tab) {
  let rows;
  {
    const h = hash(key), names = Object.keys(ART).filter((n) => !Object.values(SPACE_ART).includes(n));
    const ink = { ...INK, a: SKINS[(h >>> 8) % SKINS.length] };
    const shop = Object.values(SHOP_ART);
    const art = machine === "shopimasters" ? shop[h % shop.length] : ART[SPACE_ART[tab?.toLowerCase()] ?? SPACE_ART[space?.toLowerCase()] ?? names[h % names.length]];
    rows = art.map((r) => { const c = [...r].map((ch) => ink[ch] ?? null); return r.length === 16 ? c : [...c, ...c.slice().reverse()]; });
  }
  const px = Math.floor(size / rows[0].length);
  return v_flex().flex_none().children(rows.map((r) => h_flex().children(r.map((c) => div().size(px).when(Boolean(c), (el) => el.bg(c))))));
}

// Each space's Agent panel (tabs-graph): a core terminal named `a` + the space id's
// last 31 characters, without a tab or pane, so agents() leaves it out.
function panelAgents(all) {
  const sp = spaces(), f = focused();
  return all.flatMap((x) => {
    if (x.state !== "live" || !/^a[0-9a-f]{31}$/.test(x.name ?? "")) return [];
    const machine = x.address.includes("/") ? x.address.split("/")[0] : null;
    const s = sp.find((s) => (s.machine ?? null) === machine && s.id.split("/").pop().endsWith(x.name.slice(1)));
    if (!s) return [];
    return [{
      address: x.address, pane: null, space: s.id, space_name: s.name, tab: null, status: x.status, app: x.report?.app ?? null,
      program: x.program, title: "agent", seq: 0, pinned: false, focused: f?.terminal === x.address
    }];
  });
}

export default class Agents extends View {
  init(_props, cx) {
    if (props()?.sortMenu) return;
    this.folded = new Set();
    // Each agent's last state and when it changed (ms), kept across restarts.
    this.changed = JSON.parse(localStorage.getItem("changed") ?? "{}");
    this.pendingPins = JSON.parse(localStorage.getItem("pins") ?? "[]");
    if (!this.pendingPins.length) localStorage.removeItem("pins");
    this.migratingPins = new Set();
    cx.timer.every(30000, (cx) => cx.notify());
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      for (; ;) {
        const c = await nextCommand();
        if (c === "leave") { this.leave(); continue; }
        if (c !== "focus") continue;
        this.handle.focus();
        // Any shared write re-renders every mod: the other sidebar block drops its cursor.
        setShared("sidebar.owner", { mod: "retro-agents", at: Date.now() });
        this.cursorId = this.start();
        cx.notify();
      }
    });
  }

  start() { return agents().find((a) => a.focused)?.address ?? this.order?.[0]; }

  open(address) {
    const a = agents().find((x) => x.address === address);
    if (a) return run("pane.focus", { pane: a.pane });
    // A space's Agent panel (tabs-graph): that mod opens it, asked through shared state.
    const p = panelAgents(terminals()).find((x) => x.address === address);
    if (!p) return;
    run("space.select", { id: p.space });
    setShared("agent.open", { space: p.space, at: Date.now() });
  }

  // Keyboard: pane.go (ctrl+hjkl) gives this list the keyboard; j/k or arrows move
  // the cursor, enter or l opens the row, esc goes back to the panes. Ctrl keys
  // fall through to keys.json, so ctrl+j/k still moves between sidebar blocks.
  // pane.focus, not pane.go: pane.go misses when the pane is on another machine.
  leave() { const pane = focused()?.pane; if (pane) run("pane.focus", { pane }); }

  key(e, cx) {
    const m = e.modifiers;
    if (m.control || m.alt || m.platform) return;
    const order = this.order ?? [];
    const at = Math.max(0, order.indexOf(this.cursorId));
    if (e.key === "j" || e.key === "down") this.cursorId = order[Math.min(at + 1, order.length - 1)];
    else if (e.key === "k" || e.key === "up") this.cursorId = order[Math.max(at - 1, 0)];
    else if (e.key === "enter" || e.key === "l") { if (this.cursorId) this.open(this.cursorId); }
    else if (e.key === "escape") this.leave();
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  // Stamps agents whose state changed. Done and idle count as one: looking at a
  // finished agent turns done into idle, and looking isn't the agent doing anything.
  track(list, now) {
    let dirty = false;
    for (const a of list) {
      const s = a.status === "done" ? "idle" : a.status;
      if (this.changed[a.address]?.s === s) continue;
      this.changed[a.address] = { s, at: now };
      dirty = true;
    }
    if (!dirty) return;
    // Gone and old: the list alone is empty right after a start.
    const listed = new Set(list.map((a) => a.address));
    for (const [k, c] of Object.entries(this.changed)) if (!listed.has(k) && now - c.at > 30 * 86400000) delete this.changed[k];
    localStorage.setItem("changed", JSON.stringify(this.changed));
  }

  // Keep offline pins until their terminal returns, and keep each pending until
  // core echoes the label so a failed write doesn't erase the old pin.
  migratePins(all) {
    const listed = new Map(all.filter((t) => t.state === "live").map((t) => [t.address, t]));
    const pending = this.pendingPins.filter((address) => {
      const terminal = listed.get(address);
      if (!terminal) return true;
      if (terminal.labels?.["herdr.pinned"]) return false;
      if (!this.migratingPins.has(address)) {
        this.migratingPins.add(address);
        run("terminal.pin", { terminal: address, pinned: true });
      }
      return true;
    });
    if (pending.length === this.pendingPins.length) return;
    this.pendingPins = pending;
    if (pending.length) localStorage.setItem("pins", JSON.stringify(pending));
    else localStorage.removeItem("pins");
  }

  since(a) {
    return this.changed[a.address]?.at ?? 0;
  }

  // Looking at a done agent makes it idle; it stays with Done until you leave
  // it rather than drop away under you. Any other change moves it at once.
  hold(list) {
    const cur = list.find((a) => a.focused);
    const same = cur && cur.address === this.held?.address;
    // Arriving, or any change but done turning idle, sets what it was.
    if (!same || cur.status !== "idle") this.held = cur ? { address: cur.address, rank: RANK[cur.status] ?? 0 } : null;
  }

  rank(a) {
    const sawDone = a.address === this.held?.address && this.held.rank === RANK.done && a.status === "idle";
    return sawDone ? RANK.done : RANK[a.status] ?? 0;
  }

  sortMenu(t) {
    const on = sortOf().id;
    return v_flex()
      .w_full()
      .p(5)
      .bg(t.popover)
      .text_size(12.8)
      .child(div().px(8).pt(4).pb(6).text_size(11).text_color(t.dim).child("Sort agents"))
      .children(SORTS.map((s) => h_flex()
        .id(`sort-${s.id}`)
        .h(31)
        .px(8)
        .gap(9)
        .rounded(7)
        .items_center()
        .text_color(t.foreground)
        .hover((el) => el.bg(t.hover))
        .on_click(() => {
          setShared("agents.sort", s.id);
          closeOverlay(props().overlay);
        })
        .child(svg(`mods/workspace-chrome/${s.icon}.svg`).size(14).flex_none().text_color(t.muted))
        .child(div().flex_1().child(s.label))
        .when(s.id === on, (el) => el.child(svg("mods/workspace-chrome/check.svg").size(14).flex_none().text_color(t.foreground)))));
  }

  peek(addr) {
    run("terminal.peek", { terminal: addr });
  }

  // Live sub-agents of `addr`, depth first, each with the tree lines in front of it.
  tree(all, addr, lead = []) {
    const kids = all.filter((k) => k.parent === addr && k.state === "live");
    return kids.flatMap((k, i) => {
      const last = i === kids.length - 1;
      return [
        { t: k, lines: [...lead, last ? "└" : "├"] },
        ...this.tree(all, k.address, [...lead, last ? "" : "│"]),
      ];
    });
  }

  subRow(t, s, shown, compact) {
    const k = s.t;
    const st = kidStatus(k, this.listed);
    const pic = icon(k.program, 14, t.foreground);
    const on = k.address === shown;
    return h_flex()
      .id(`sub-${k.address}`)
      .pl(39)
      .pr(8)
      .rounded(8)
      .h(26)
      .flex_none()
      .gap(0)
      .items_center()
      .text_size(12.5)
      .when(on, (el) => el.bg(t.raised))
      .hover((s) => s.bg(t.hover))
      .on_click(() => this.peek(k.address))
      .children(s.lines.map(l => div().self_start().mt(-4).w(9).h(17).mr(4).flex_none()
        .when(Boolean(l), el => el.border_l(1.5).border_color(t.input))
        .when(l === "└" || l === "├", el => el.border_b(1.5).rounded_bl(6))))
      .when(Boolean(pic), el => el.child(div().mr(8).child(pic)))
      .child(div().flex_1().truncate().text_color(on ? t.foreground : t.muted).child(k.name || k.template || k.program?.name || k.address))
      .child(this.status(t, { status: st }, compact));
  }

  // compact: a ! for blocked where a header already says "Needs you".
  status(t, a, compact = false) {
    const color = t[a.status] ?? t.dim;
    if (a.status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(t.working).spin(900);
    if (a.status === "blocked" && compact) return div().size(14).flex_none().rounded(4).bg(t.blocked + "26").text_size(10.5).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!");
    if (a.status === "blocked") return div().flex_none().px(6).h(18).rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).flex().items_center().child("Needs you");
    // Idle: a ring; done: a dot.
    if (a.status === "idle") return div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
    return div().size(7).mx(3).flex_none().rounded(4).bg(a.status === "done" ? color : t.dim + "00");
  }

  render(cx) {
    const t = theme();
    if (props()?.sortMenu) return this.sortMenu(t);
    this.order = []; // filled as the cards below are built, in display order
    const collapsed = narrow();
    const sort = sortOf();
    const all = terminals();
    let list = [...agents(), ...panelAgents(all)];
    this.listed = new Map(list.map((a) => [a.address, a.status]));
    this.migratePins(all);
    const shown = focused()?.agent;
    const now = Date.now();
    this.track(list, now);
    this.hold(list);
    const byPriority = sort.id === "priority";
    const urgency = new Map(list.map((a) => [a.address, Math.max(this.rank(a), ...this.tree(all, a.address).map((s) => RANK[kidStatus(s.t, this.listed)] ?? 0))]));
    const rankOf = (a) => urgency.get(a.address);
    if (byPriority) list = [...list].sort((x, y) => rankOf(y) - rankOf(x) || this.since(y) - this.since(x) || y.seq - x.seq);
    const pinned = list.filter((a) => a.pinned);
    const rest = list.filter((a) => !a.pinned);
    list = [...pinned, ...rest];
    setAgentOrder(list.map((a) => a.address));

    const withKids = (a, i) => {
      const subs = collapsed ? [] : this.tree(all, a.address);
      const r = row(a, i, subs);
      if (this.folded.has(a.address)) return [r];
      return [r, ...subs.map((s) => this.subRow(t, s, shown, byPriority))];
    };

    // The fold chevron; folded, the count too, colored by the most urgent one.
    const fold = (a, subs) => {
      const sts = subs.map((s) => kidStatus(s.t, this.listed));
      const top = sts.reduce((m, s) => ((RANK[s] ?? 0) > (RANK[m] ?? 0) ? s : m), null);
      const open = !this.folded.has(a.address);
      return div()
        .id(`fold-${a.address}`)
        .h(18)
        .px(3)
        .gap(3)
        .flex()
        .items_center()
        .rounded(4)
        .text_size(11)
        .text_color(open ? t.dim : (t[top] ?? t.dim))
        .cursor_pointer()
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_click((_e, cx) => {
          cx.stop_propagation();
          open ? this.folded.add(a.address) : this.folded.delete(a.address);
          cx.notify();
        })
        .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(11).flex_none())
        .when(!open, (el) => el.child(String(subs.length)));
    };

    // A row reads "space \u00b7 detail": the detail is a tab someone named or the
    // agent's own title, never an automatic tab number unless two rows would
    // otherwise read the same.
    const remoteNames = [...new Set([...machines().map((m) => m.name), ...list.map((a) => (a.address.includes("/") ? a.address.split("/")[0] : null))].filter(Boolean))].sort();
    const machineIndex = (m) => (m ? remoteNames.indexOf(m) + 1 : 0);
    const tabs = spaces().flatMap(s => s.tabs);
    const label = (a) => {
      const tab = tabs.find(tab => tab.id === a.tab);
      return tab ? title(tab, lead(tab)) : a.title || a.program?.name || "";
    };
    const detail = new Map(list.map(a => [a.address, /^\d+$/.test(label(a)) ? null : label(a)]));
    const seen = {};
    for (const a of list) { const k = `${a.space_name}\u0000${detail.get(a.address) ?? ""}`; seen[k] = (seen[k] ?? 0) + 1; }
    for (const a of list) {
      if (detail.get(a.address) == null && seen[`${a.space_name}\u0000`] > 1) detail.set(a.address, label(a));
    }

    const row = (a, i, subs = []) => {
      const pic = icon(a.program, 16, t.foreground);
      const more = detail.get(a.address);
      // An agent on another machine (`vps/t7`) says which.
      const machine = a.address.includes("/") ? a.address.split("/")[0] : null;
      if (collapsed) {
        return h_flex()
          .id(`ag-${a.address}`)
          .h(26)
          .px(8)
          .flex_none()
          .items_center()
          .gap(4)
          .hover((s) => s.bg(t.hover))
          .on_click(() => this.open(a.address))
          .child(div().flex_1().min_w(0).whitespace_nowrap().text_right().text_color(t.muted).child(String(i + 1)))
          .child(h_flex().w(14).flex_none().items_center().justify_center().child(this.status(t, a, true)));
      }
      const colors = MACHINE_COLORS;
      const col = colors[machineIndex(machine) % colors.length];
      const [fill, edge] = CARDS[machineIndex(machine) % CARDS.length];
      const cwd = panes().find((p) => p.pane === a.pane)?.cwd;
      const title = a.space_name && a.space_name !== "~" ? a.space_name : (cwd ? cwd.replace(/\/+$/, "").split("/").pop() : "") || label(a);
      const word = { working: "WORKING", blocked: "NEEDS YOU", done: "DONE", idle: "IDLE" }[a.status] ?? "?";
      const tone = a.status === "idle" ? t.muted : t[a.status] ?? t.dim;
      // A tab number says nothing on a card: the program instead.
      const sub = (more && !/^\d+$/.test(more) ? more : a.program?.name) ?? "";
      this.order?.push(a.address);
      const kb = this.handle?.is_focused() && this.cursorId === a.address;
      return h_flex()
        .id(`ag-${a.address}`)
        .mx(4)
        .my(3)
        .p(3)
        .gap(6)
        .flex_none()
        .items_center()
        .bg(fill)
        .border(2)
        .border_color(kb ? t.foreground : a.focused ? ACCENT : edge)
        .cursor_pointer()
        .hover((el) => el.border_color(a.focused ? ACCENT : col))
        .on_click(() => this.open(a.address))
        .on_mouse_down("right", (_e, cx) => {
          run("terminal.pin", { terminal: a.address, pinned: !a.pinned });
          cx.notify();
        })
        .tooltip(a.pinned ? "Right-click: unpin" : "Right-click: pin to top")
        .child(div().relative().w(60).h(60).flex_none().flex().items_center().justify_center().bg("#14151f").border(1).border_color(edge)
          .children([6, 12, 18].map((b) => div().absolute().left(0).right(0).bottom(b).h(1).bg("#4a2240")))
          .child(div().absolute().top(5).left(6).size(3).bg(col))
          .when(a.status === "idle", (el) => el.child(div().absolute().top(4).right(4).size(13).border(1).border_color(t.muted).font_family(PX).text_size(10).text_color(t.muted).flex().items_center().justify_center().child("z")))
          .when(a.pinned, (el) => el.child(svg("mods/workspace-chrome/pin.svg").absolute().bottom(4).right(4).size(11).text_color(ACCENT)))
          .child(div().when(a.status === "working", (el) => el.loop("top", { from: 0, to: -3, period: 700 })).child(sprite(a.address, 48, machine, a.space_name, a.tab_name))))
        .child(v_flex().flex_1().min_w(0).gap(2)
          .child(h_flex().child(div().px(4).border(1).border_color(tone).font_family(PX).text_size(10).text_color(tone)
            .when(a.status === "working" || a.status === "blocked", (el) => el.loop("opacity", { from: 0.45, to: 1, period: 1100 }))
            .child(word)))
          .child(div().truncate().font_family(PX).text_size(14).line_height("16px").font_bold().text_color(t.foreground).child(title))
          .when(Boolean(sub), (el) => el.child(div().truncate().text_size(11).line_height("13px").text_color(t.muted).child(sub)))
          .when(subs.length > 0, (el) => el.child(fold(a, subs))));
    };

    // Groups in list order: spaces (grouped) or priority sections. Agents of a
    // space are next to each other in agents(), so neighbours make a group.
    const machineOf = (a) => (a.address.includes("/") ? a.address.split("/")[0] : null);
    const groups = [];
    for (const a of list) {
      const m = machineOf(a);
      const id = `m-${m ?? "local"}`;
      const g = groups.find((g) => g.id === id) ?? groups[groups.push({ id, machine: m, label: m ?? "Core", members: [] }) - 1];
      g.members.push(a);
    }
    groups.sort((x, y) => machineIndex(x.machine) - machineIndex(y.machine));

    // A group's header; it folds the group. Folded, it says how many and the most urgent state.
    const header = (g) => {
      const open = !this.folded.has(g.id);
      const top = g.members.reduce((m, a) => ((RANK[a.status] ?? 0) > (RANK[m] ?? 0) ? a.status : m), null);
      const col = MACHINE_COLORS[machineIndex(g.machine) % MACHINE_COLORS.length];
      const busy = g.members.filter((a) => a.status === "working").length;
      return h_flex()
        .id(g.id)
        .px(6)
        .pt(10)
        .h(34)
        .flex_none()
        .gap(8)
        .items_center()
        .cursor_pointer()
        .on_click((_e, cx) => {
          open ? this.folded.add(g.id) : this.folded.delete(g.id);
          cx.notify();
        })
        .child(svg(`mods/workspace-chrome/${g.machine ? "server" : "monitor"}.svg`).size(13).flex_none().text_color(col))
        .child(div().flex_none().max_w(150).truncate().font_family(PX).text_size(14).font_bold().text_color(col).child(g.label.toUpperCase()))
        .child(div().flex_1().min_w(8).h(2).bg(col + "55"))
        .when(!open && top && top !== "idle", (el) => el.child(this.status(t, { status: top }, true)))
        .child(div().flex_none().font_family(PX).text_size(14).text_color(t.muted).child(`${busy}/${g.members.length}${open ? "" : "▸"}`));
    };
    const rows = collapsed
      ? list.flatMap(withKids)
      : groups.flatMap((g) => [header(g), ...(this.folded.has(g.id) ? [] : g.members.flatMap(withKids))]);

    return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .border_t(1)
      .border_color(t.border)
      .text_size(13)
      .when(!collapsed, (el) =>
        el.child(
          h_flex()
            .px(16)
            .h(41)
            .pt(14)
            .pb(5)
            .flex_none()
            .items_center()
            .justify_between()
            .child(h_flex().gap(8).items_center()
              .child(div().size(14).flex_none().bg(t.input).border(2).border_color(t.dim))
              .child(div().font_family(PX).text_size(15).text_color(t.muted).child("AGENTS")))
            .child(div().flex_1())
            .child(div().mr(8).font_family(PX).text_size(14).text_color(list.some((a) => a.status === "working") ? t.working : t.muted).child(`${list.filter((a) => a.status === "working").length} BUSY`))
            .child(
              div()
                .id("ag-sort")
                .text_size(11)
                .text_color(t.dim)
                .hover((s) => s.text_color(t.foreground))
                .on_click(() => openOverlay({ mod: "retro-agents", kind: "popup", width: 200, height: 140, props: { sortMenu: true } }))
                .tooltip(`Sort agents: ${sort.label}`)
                .child(svg(`mods/workspace-chrome/${sort.icon}.svg`).size(14)),
            ),
        ),
      )
      .when(list.length === 0 && !collapsed, (el) =>
        el.child(div().px(12).text_size(12).text_color(t.dim).child("No agents yet. Agents show up here once they report their state. Old versions and agents inside tmux may not show.")),
      )
      .child(v_flex().id("ag-list").flex_1().min_h(0).px(collapsed ? 0 : 8).overflow_y_scrollbar().mode("always").children(rows))
      .when(collapsed, (el) =>
        el.child(
          h_flex()
            .h(28)
            .items_center()
            .justify_center()
            .child(
              div()
                .id("collapse")
                .text_size(13)
                .text_color(t.dim)
                .hover((s) => s.text_color(t.foreground))
                .on_click(toggleSidebar)
                .child("»"),
            ),
        ),
      );
  }
}
