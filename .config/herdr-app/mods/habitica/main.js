// Habitica to-dos in the side panel, grouped by urgency like Area/Habitica.md.
// Reads habitica-sync's cache (~/.cache/habitica/todos.json); the box completes
// a to-do (`habitica-sync done <id>`), ↻ syncs now. Keyboard: j/k, x or Enter
// completes, r syncs.
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { home, readTextFile, exec, notify, theme, nextCommand } from "herdr";

const RED = "#ff5d6c", AMBER = "#ffb347";
const BIN = () => `${home()}/.local/bin/habitica-sync`;

function groups(todos, today) {
  const g = { "⚠️ Vencidos": [], Hoy: [], Próximos: [], "Sin fecha": [] };
  for (const t of todos) g[!t.date ? "Sin fecha" : t.date < today ? "⚠️ Vencidos" : t.date === today ? "Hoy" : "Próximos"].push(t);
  return Object.entries(g).filter(([, list]) => list.length);
}

export default class HabiticaPanel extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.done = new Set(); // completed here, waiting for the sync to drop them
    this.load(cx);
    cx.timer.every(30000, (cx) => this.load(cx));
    // ponytail: no blur event for a plain handle; poll so the focus border clears.
    cx.timer.every(300, (cx) => { const f = this.handle.is_focused(); if (f !== this.had) { this.had = f; cx.notify(); } });
    cx.spawn(async (cx) => { for (;;) if ((await nextCommand()) === "focus") { this.handle.focus(); cx.notify(); } });
  }

  load(cx) {
    cx.spawn(async (cx) => {
      try { this.s = JSON.parse(await readTextFile(`${home()}/.cache/habitica/todos.json`)); } catch { this.s = null; }
      cx.notify();
    });
  }

  run(args, cx) {
    this.busy = true;
    cx.notify();
    cx.spawn(async (cx) => {
      const r = await exec("python3", [BIN(), ...args]).catch((e) => ({ code: 1, stderr: String(e) }));
      this.busy = false;
      this.error = r.code === 0 ? null : (r.stderr || r.stdout || `exit ${r.code}`).trim().split("\n").pop();
      if (this.error) notify({ title: "Habitica sync failed", body: this.error.slice(-200), level: "error" });
      this.done.clear();
      this.load(cx);
    });
  }

  complete(id, cx) {
    if (!id || this.done.has(id)) return;
    this.done.add(id);
    this.run(["done", id], cx);
  }

  key(e, cx) {
    const m = e.modifiers;
    if (m.control || m.alt || m.platform) return;
    const order = this.order ?? [], at = Math.max(0, order.indexOf(this.cursor));
    if (e.key === "j" || e.key === "down") this.cursor = order[Math.min(at + 1, order.length - 1)];
    else if (e.key === "k" || e.key === "up") this.cursor = order[Math.max(at - 1, 0)];
    else if (e.key === "x" || e.key === "enter") this.complete(this.cursor, cx);
    else if (e.key === "r") this.run([], cx);
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  render() {
    const t = theme(), s = this.s, focused = this.handle.is_focused();
    const today = new Date().toLocaleDateString("sv"); // YYYY-MM-DD, local
    const todos = (s?.todos ?? []).filter((x) => !this.done.has(x.id));
    this.order = [];
    if (focused && !todos.some((x) => x.id === this.cursor)) this.cursor = todos[0]?.id;
    const row = (x, tone) => {
      this.order.push(x.id);
      const kb = focused && this.cursor === x.id;
      return h_flex().id(`todo-${x.id}`).px(10).py(5).gap(9).items_start().rounded(6)
        .when(kb, (el) => el.bg(t.selected)).hover((el) => el.bg(t.hover))
        .child(div().id(`box-${x.id}`).mt(2).size(13).flex_none().rounded(3).border(1).border_color(tone).cursor_pointer()
          .hover((el) => el.bg(tone)).on_click((_e, cx) => this.complete(x.id, cx)))
        .child(v_flex().flex_1().min_w(0)
          .child(div().text_color(t.foreground).child(x.text))
          .when(Boolean(x.date), (el) => el.child(div().text_size(11).text_color(tone).child(x.date))));
    };
    const tones = { "⚠️ Vencidos": RED, Hoy: AMBER };
    return v_flex().id("habitica").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(focused ? t.accent : t.border)
      .text_size(12.5).text_color(t.muted)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().text_color(t.foreground).child("Habitica"))
        .child(div().flex_1().text_size(11).text_color(t.dim).child(this.error ? `error: ${this.error}` : s ? `${todos.length} · sync ${s.synced?.slice(11, 16)}` : ""))
        .child(div().id("habitica-sync").px(8).py(2).rounded(5).on_mouse_down("left", (_e, cx) => cx.stop_propagation()).text_color(t.dim).cursor_pointer().hover((el) => el.bg(t.hover).text_color(t.foreground))
          .on_click((_e, cx) => this.run([], cx)).child(this.busy ? "…" : "↻")))
      .child(v_flex().id("habitica-list").flex_1().min_h(0).p(6).gap(2).overflow_y_scrollbar()
        .when(!s, (el) => el.child(div().p(10).text_color(t.dim).child("Sin datos: tocá ↻ para sincronizar")))
        .when(Boolean(s) && !todos.length, (el) => el.child(div().p(10).text_color(t.dim).child("Nada pendiente 🎉")))
        .children(groups(todos, today).flatMap(([name, list]) => [
          div().px(10).pt(8).pb(2).text_size(11).font_semibold().text_color(tones[name] ?? t.dim).child(name),
          ...list.map((x) => row(x, tones[name] ?? t.muted)),
        ])));
  }
}
