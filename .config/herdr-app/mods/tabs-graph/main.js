import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, run, openOverlay, theme, window, shared, layout, settings, hc, notify, readTextFile, appHome } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// One claude per space in the side panel: a core terminal named after the space,
// started on the space's machine in its folder, shown by pointing the "agent"
// block at it. Not labeled herdr.space, so it never becomes a tab.
const PANEL = () => (find(layout(), "panel") ? "panel" : "panel-body");

// Where a space's Agent starts when the space has no folder yet, by machine.
const AGENT_FOLDER = { shopimasters: "/home/pablo/Work/clients/shopimasters" };

async function openAgent(space, focus) {
  const folder = space.folder || AGENT_FOLDER[space.machine];
  const id = space.id.split("/").pop();
  const name = `a${id.slice(-31)}`;
  const addr = space.machine ? `${space.machine}/${name}` : name;
  let live = false;
  try { live = JSON.parse((await hc(["get", addr, "--json"])).stdout).state === "live"; } catch {}
  if (!live) {
    const r = await hc(["run", "--bg", "--keep", "--no-parent", "--name", name,
      ...(space.machine ? ["--on", space.machine] : []), ...(folder ? ["--cwd", folder] : []), "--", "sh", "-lc", "exec claude"]); // login shell: claude can live on a profile-only PATH (mise)
    if (r.code !== 0) return notify({ title: "Agent", body: r.stderr || r.stdout, level: "error" });
  }
  // Edit the layout file, not layout(): that one is simplified.
  let root = null;
  try { root = JSON.parse(await readTextFile(`${appHome()}/layouts/${shared("layout")}.json`)); } catch {}
  const body = find(root, "panel-body");
  if (!body) return notify({ title: "Agent", body: "no panel-body in this layout", level: "error" });
  let node = find(root, "agent");
  if (!node) body.children.unshift(node = { id: "agent", type: "block" });
  if (node.content?.terminal !== addr) { node.content = { terminal: addr }; run("layout.set", { layout: root }); }
  run("layout.select", { stack: "panel-body", child: "agent" });
  run("layout.show", { id: PANEL() });
  if (focus) run("pane.focus", { terminal: addr });
}

export default class Tabs extends View {
  init() {
    this.pressed = null;
    this.panels = JSON.parse(localStorage.getItem("panels") ?? "{}");
    this.minimized = new Set(JSON.parse(localStorage.getItem("sidebar.minimized") ?? "[]"));
  }

  // The side panel is remembered per space: switching shows that space's choice
  // (closed if it never had one), and opening or closing it records it.
  syncPanel(space, panel, body, enabled) {
    if (!space || !panel) return;
    const now = panel.hidden ? null : body?.active ?? null;
    if (space.id !== this.space) {
      const first = this.space === undefined;
      this.space = space.id; this.pending = null;
      if (!(first && !(space.id in this.panels))) {
        const stored = this.panels[space.id] ?? null, want = enabled.includes(stored) ? stored : null;
        if (want !== now || want === "agent") {
          this.pending = { want, until: Date.now() + 1000 };
          if (want === "agent") openAgent(space);
          else if (want) { run("layout.select", { stack: "panel-body", child: want }); run("layout.show", { id: PANEL() }); }
          else run("layout.hide", { id: PANEL() });
          return;
        }
      }
    }
    // Until the restore lands (or something else won), the old state isn't a choice.
    if (this.pending) {
      if (this.pending.want !== now && Date.now() < this.pending.until) return;
      this.pending = null;
    }
    if (this.panels[space.id] === now) return;
    this.panels[space.id] = now;
    localStorage.setItem("panels", JSON.stringify(this.panels));
  }

  render() {
    const t = theme();
    const space = spaces().find(p => p.active);
    const shown = space?.tabs ?? [];
    const stop = (_e, cx) => cx.stop_propagation();
    const button = (id, label, action) => div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop).on_click(action).child(label);
    const item = (c, i) => {
      const program = panes().find(p => p.tab === c.id && p.program?.agent)?.program ?? panes().find(p => p.tab === c.id)?.program;
      const name = /^tb\d+$/.test(c.name) ? program?.name ?? "Terminal" : c.name;
      return h_flex().id(`tab-${c.id}`).h(29).px(10).gap(7).rounded(7).items_center().flex_none().text_size(12.8)
        .border(1).border_color(c.active ? t.border : t.chrome).bg(c.active ? t.raised : t.chrome).text_color(c.active ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover))
        .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.pressed = i; if (e.click_count === 2) run("tab.rename", { id: c.id }); })
        .on_mouse_up("left", () => {
          const from = this.pressed; this.pressed = null;
          if (from !== null && from !== i) run("tab.move", { id: shown[from].id, index: space.tabs.findIndex(x => x.id === c.id) + 1 });
          else run("tab.select", { id: c.id });
        })
        .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }); })
        .when(Boolean(program?.icon), el => el.child(program.tint ? svg(program.icon).size(14).text_color(t.muted) : image(program.icon).size(14)))
        .child(div().max_w(170).truncate().child(c.zoomed ? `${name} Z` : name))
        .when(c.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
        .when(c.status === "blocked" || c.status === "done", el => el.child(div().size(6).rounded(3).bg(t[c.status])))
        .when(c.active, el => el.child(div().id(`close-${c.id}`).text_color(t.dim).on_mouse_down("left", stop).on_click((_e, cx) => { cx.stop_propagation(); run("tab.close", { id: c.id }); }).child(svg("mods/pane/close.svg").size(12))));
    };
    const root = layout(), sidebar = find(root, "sidebar"), w = window();
    const panel = find(root, "panel") ?? find(root, "panel-body"), body = find(root, "panel-body");
    // Old saved rails and a dragged-narrow sidebar can be smaller than the window buttons.
    const lightsPadding = w?.platform === "macos" && w.titlebar === "none" && !w.fullscreen && root?.traffic_lights
      ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom - (sidebar?.hidden ? 0 : sidebar?.size?.px ?? 0))
      : 10;
    // The app merges a single-child "panel" column into "panel-body", so in retro the
    // stack itself is what shows and hides (PANEL).
    const enabled = [...(shared("workspace.panels") ?? ["files", "changes"]), "review", "agent"];
    // Prefix keys (tmux-prefix "panel:<what>"): toggle a side panel, or minimize the
    // sidebar for this space.
    const req = shared("panel.toggle");
    if (space && req && req.at !== this.toggled && Date.now() - req.at < 3000) {
      this.toggled = req.at;
      if (req.what === "sidebar") {
        this.minimized.has(space.id) ? this.minimized.delete(space.id) : this.minimized.add(space.id);
        localStorage.setItem("sidebar.minimized", JSON.stringify([...this.minimized]));
        this.sidebarFor = null;
      } else if (req.what === "right") { // the whole right panel: close it, or reopen what it last showed
        if (panel && !panel.hidden) run("layout.hide", { id: PANEL() });
        else if (body?.active === "agent") openAgent(space, true);
        else run("layout.show", { id: PANEL() });
      } else if (panel && !panel.hidden && body?.active === req.what) run("layout.hide", { id: PANEL() });
      else if (req.what === "agent") openAgent(space, true);
      else { run("layout.select", { stack: "panel-body", child: req.what }); run("layout.show", { id: PANEL() }); }
    }
    // The sidebar is a rail in spaces where it was minimized.
    if (space && this.sidebarFor !== space.id) {
      this.sidebarFor = space.id;
      run("layout.resize", { id: "sidebar", px: this.minimized.has(space.id) ? 44 : 268 });
    }
    // The agents list asks for a space's Agent panel (retro-agents open()).
    const ask = shared("agent.open");
    if (ask && ask.at !== this.asked && Date.now() - ask.at < 3000) {
      this.asked = ask.at; this.panels[ask.space] = "agent";
      localStorage.setItem("panels", JSON.stringify(this.panels));
      const s = spaces().find(s => s.id === ask.space);
      if (s) openAgent(s, true);
    }
    this.syncPanel(space, panel, body, enabled);
    const panelButton = (id, label, icon, open) => {
      const on = panel && !panel.hidden && body?.active === id;
      return h_flex().id(`panel-${id}`).h(26).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(on ? t.selected : t.chrome).text_color(on ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
        .on_click(() => {
          if (on) run("layout.hide", { id: PANEL() });
          else if (open) open();
          else { run("layout.select", { stack: "panel-body", child: id }); run("layout.show", { id: PANEL() }); }
        }).child(svg(icon).size(14)).child(label);
    };
    return h_flex().size_full().min_w(0).px(10).pl(lightsPadding).gap(3).items_center().bg(t.chrome).border_b(1).border_color(t.border)
      .on_mouse_up("left", () => { this.pressed = null; })
      .on_scroll_wheel(e => { if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next"); })
      .child(h_flex().id("tab-scroll").flex_1().min_w(0).h_full().items_center().gap(3).overflow_x_scrollbar().children(shown.map(item)))
      .child(button("tab-new", "+", () => openOverlay({ mod: "new-menu", kind: "popup", width: 250, height: 512 })))
      .when(Boolean(space), el => el.child(panelButton("agent", "Agent", "mods/workspace-chrome/terminal.svg", () => openAgent(space))))
      .when(enabled.includes("files"), el => el.child(panelButton("files", "Files", "mods/files/file.svg")))
      .when(enabled.includes("changes"), el => el.child(panelButton("changes", "Changes", "mods/changes/changes.svg")))
      .child(panelButton("review", "Review", "mods/reviewer/comment.svg"))
      .when(w?.buttons, el => el.child(button("minimize", w.platform === "windows" ? svg("mods/tabs-graph/win-min.svg").size(16) : "−", () => run("window.minimize")))
        .child(button("maximize", w.platform === "windows" ? svg(`mods/tabs-graph/${w.maximized ? "win-restore" : "win-max"}.svg`).size(16) : "□", () => run("window.maximize")))
        .child(button("close-window", w.platform === "windows" ? svg("mods/tabs-graph/win-close.svg").size(16) : svg("mods/pane/close.svg").size(13), () => run("window.close"))));
  }
}
