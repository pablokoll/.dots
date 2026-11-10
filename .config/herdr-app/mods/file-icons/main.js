// Herdr's Files panel with VS Code's Material Icon Theme icons: a lazy file browser for the
// focused pane's folder, with bounded read-only previews.
//
// Modified from Herdr's shipped `files` mod (https://github.com/herdrdev/herdr-app, Apache-2.0):
// added DIR, icon() and the Material Icon Theme icons in the rows and the preview header.
//
// Keyboard and search (2026-11-06), with the same pieces picker/retro-spaces use (on_key_down,
// InputState/Input, a row window driven by on_size_change + on_scroll_wheel; no virtual list):
//   tree     j/k ↓/↑ move · l/→/enter open folder, enter it, or preview a file · h/← close or
//            go to parent · o/space toggle · g/G first/last · / find file · ? search text ·
//            e open in nvim (a terminal labelled nvim.server) · r reload
//   search   type · ctrl-j/ctrl-k (or ↑/↓, ctrl-n/ctrl-p) choose · enter preview · esc back to the tree
//   preview  h/←/esc/q/backspace back · e open in nvim (at the matched line)
import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, Editor, EditorState, InputState, Input } from "gpui-base";
import { spaces, panes, focused, nextCommand, exec, readTextFile, watchFolder, theme, settings, window, terminals, run } from "herdr";
import ICONS from "./icons.js";

function location() {
  const space = spaces().find(s => s.active), f = focused();
  const pane = f?.pane ? panes().find(p => p.pane === f.pane) : null;
  const on = f?.pane === null ? (f.terminal?.includes("/") ? f.terminal.split("/")[0] : null) : space?.machine ?? null;
  return { cwd: pane?.cwd || f?.cwd || space?.folder, on };
}
const key = () => JSON.stringify(location());
const LANG = { ts: "js", tsx: "js", mts: "js", cts: "js", jsx: "js", mjs: "js", toml: "yaml", jsonc: "json", svelte: "html", vue: "html" };
const PER_FOLDER = 500, TOTAL = 5000;
const DIR = "mods/file-icons";
const ROW = 28, NAME_LIMIT = 200, TEXT_LIMIT = 300, INDEX_LIMIT = 50000;

// Material Icon Theme's rules, as VS Code applies them: names match case-insensitively; a
// path rule (".github/workflows") beats a name, a name beats an extension, and the longest
// extension wins ("spec.ts" over "ts"). Light themes check the theme's light table first.
const bare = name => name.replace(/^__(.+)__$/, "$1").replace(/^[._-]/, "");
const opened = id => id.endsWith("_light") ? `${id.slice(0, -6)}-open_light` : `${id}-open`;
function lookup(table, key, dark) { return (dark ? undefined : ICONS.light[table][key]) ?? ICONS[table][key]; }
function icon(path, dir, open, dark) {
  const parts = path.toLowerCase().split("/"), name = parts[parts.length - 1];
  const table = dir ? "folderNames" : "fileNames", find = key => lookup(table, key, dark) ?? (dir ? lookup(table, bare(key), dark) : undefined);
  let id;
  for (let i = 0; !id && i < parts.length - 1; i++) id = find(parts.slice(i).join("/"));
  if (dir) {
    id ??= find(name) ?? ICONS.folder;
    return `${DIR}/icons/${open ? opened(id) : id}.svg`;
  }
  id ??= lookup(table, name, dark);
  for (let dot = name.indexOf("."); !id && dot !== -1; dot = name.indexOf(".", dot + 1)) id = lookup("fileExtensions", name.slice(dot + 1), dark);
  return `${DIR}/icons/${id ?? ICONS.file}.svg`;
}

async function directory(path, on) {
  if (!on && window()?.platform === "windows") {
    const r = await exec("powershell", ["-NoProfile", "-Command", "& { param($p) @(Get-ChildItem -LiteralPath $p -Force -ErrorAction Stop | Where-Object Name -ne '.git' | Select-Object -First 501 | ForEach-Object { @{ name=$_.Name; dir=($_.PSIsContainer -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint)) } }) | ConvertTo-Json -Compress }", path]);
    if (r.code !== 0) throw new Error(r.stderr || "Cannot list this folder");
    const result = JSON.parse(r.stdout || "[]");
    return Array.isArray(result) ? result : [result];
  }
  const script = 'n=0; for p in "$1"/* "$1"/.[!.]* "$1"/..?*; do [ -e "$p" ] || [ -L "$p" ] || continue; name=${p##*/}; [ "$name" = .git ] && continue; if [ -d "$p" ] && [ ! -L "$p" ]; then kind=d; else kind=f; fi; printf "%s\\0%s\\0" "$kind" "$name"; n=$((n+1)); [ "$n" -gt 500 ] && break; done; test -d "$1"';
  const r = await exec("sh", ["-c", script, "files", path], { on });
  if (r.code !== 0) throw new Error(r.stderr || "Cannot list this folder");
  const fields = r.stdout.split("\0"), out = [];
  for (let i = 0; i + 1 < fields.length; i += 2) out.push({ name: fields[i + 1], dir: fields[i] === "d" });
  return out;
}

// Every file under root (for "find file"): rg --files, else find. Paths relative to root.
async function listFiles(root, on) {
  const r = await exec("rg", ["--files", "--hidden", "-g", "!.git", "-g", "!node_modules"], { cwd: root, on })
    .catch(() => exec("sh", ["-c", "find . -type f -not -path '*/.git/*' -not -path '*/node_modules/*' | sed 's|^\\./||'"], { cwd: root, on }));
  if (r.code !== 0 && !r.stdout) throw new Error(r.stderr || "Cannot list files");
  return r.stdout.split("\n").filter(Boolean).slice(0, INDEX_LIMIT);
}

// rg over file contents: [{ path, line, text }]. Exit 1 = no matches.
async function grep(root, on, query) {
  const r = await exec("rg", ["-n", "-S", "--no-heading", "--color", "never", "--max-columns", "300", "--max-count", "20", "-g", "!node_modules", "--", query], { cwd: root, on });
  if (r.code > 1) throw new Error(r.stderr || "Search failed");
  const out = [];
  for (const l of r.stdout.split("\n")) {
    const m = /^(.+?):(\d+):(.*)$/.exec(l);
    if (m) out.push({ path: m[1], line: Number(m[2]), text: m[3].trim() });
    if (out.length >= TEXT_LIMIT) break;
  }
  return out;
}

const vimString = s => `'${String(s).replace(/'/g, "''")}'`;

export default class Files extends View {
  init(_props, cx) {
    this.entries = new Map(); this.folders = new Set(); this.pending = new Set(); this.marks = {};
    this.cursor = null; this.top = 0; this.listHeight = 0;
    this.mode = null; this.results = []; this.at = 0; this.index = null; this.searchSeq = 0;
    this.input = InputState.new({ placeholder: "Find file…" });
    this.input.on("change", (_e, cx) => this.search(cx));
    this.input.on("submit", (_e, cx) => this.pick(cx));
    this.refresh(cx);
    cx.timer.every(10000, cx => this.refresh(cx));
    this.handle = cx.focus_handle();
    // keys.json "mod:file-icons": ctrl-j/ctrl-k → file-icons.next/prev (they beat the global
    // pane navigation only while this panel has focus).
    cx.spawn(async cx => {
      for (;;) {
        const c = await nextCommand();
        if (c === "focus") { this.handle.focus(); cx.notify(); }
        else if (c === "next" || c === "prev") this.step(c === "next" ? 1 : -1, cx);
      }
    });
    // ponytail: no blur event for a plain handle; poll so the focus border clears.
    cx.timer.every(300, cx => { const f = this.handle.is_focused(); if (f !== this.had) { this.had = f; cx.notify(); } });
  }

  watch(root, cx) {
    if (this.on || this.watched === root) return;
    this.watched = root;
    cx.spawn(async cx => {
      try { while (this.watched === root) { await watchFolder(root); if (this.watched === root) this.refresh(cx); } }
      catch { if (this.watched === root) this.watched = null; }
    });
  }

  async loadFolder(path, context) {
    const on = this.on, root = this.root;
    const entries = await directory(path ? `${root}/${path}` : root, on);
    if (key() !== context || (path && !this.folders.has(path))) return;
    const used = [...this.entries.entries()].filter(([p]) => p !== path).reduce((n, [, e]) => n + e.length, 0);
    this.entries.set(path, entries.slice(0, Math.max(0, Math.min(PER_FOLDER, TOTAL - used))).sort((a, b) => Number(b.dir) - Number(a.dir) || a.name.localeCompare(b.name)));
    if (entries.length > PER_FOLDER || used + entries.length > TOTAL) this.limited = true;
  }

  refresh(cx) {
    if (this.loading) return;
    const { cwd, on } = location(), context = key();
    if (context !== this.context) {
      this.context = context; this.root = cwd; this.on = on; this.entries = new Map(); this.folders = new Set();
      this.pending = new Set(); this.marks = {}; this.show(null); this.watched = null; this.error = null; this.limited = false;
      this.cursor = null; this.top = 0; this.index = null; this.leaveSearch();
    }
    if (!cwd) return;
    this.loading = true;
    this.limited = false;
    cx.spawn(async cx => {
      try {
        for (const path of ["", ...this.folders]) await this.loadFolder(path, context);
        const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on }).catch(() => null);
        const marks = {};
        if (top?.code === 0) {
          // Writes nothing under .git (index lock, fsmonitor cookie): the folder watch would refresh again.
          const status = await exec("git", ["--no-optional-locks", "-c", "core.fsmonitor=false", "status", "--porcelain=v1", "-z", "--no-renames", "--untracked-files=normal"], { cwd, on }).catch(() => null);
          if (status?.code === 0) for (const entry of status.stdout.split("\0").filter(Boolean).slice(0, TOTAL)) {
            const xy = entry.slice(0, 2);
            marks[`${top.stdout.trim()}/${entry.slice(3)}`] = xy === "??" || xy.includes("A") ? "A" : xy.includes("U") ? "U" : xy.includes("D") ? "D" : "M";
          }
        }
        if (key() !== context) return;
        this.marks = marks; this.error = null; this.watch(cwd, cx);
      } catch (e) { if (key() === context) this.error = String(e); }
      finally { this.loading = false; cx.notify(); }
    });
  }

  toggle(path, cx) {
    if (this.folders.has(path)) {
      for (const folder of [...this.folders]) if (folder === path || folder.startsWith(path + "/")) {
        this.folders.delete(folder);
        this.entries.delete(folder);
      }
    } else {
      this.folders.add(path);
      if (!this.entries.has(path) && !this.pending.has(path)) {
        const context = this.context;
        this.pending.add(path);
        cx.spawn(async cx => {
          try { await this.loadFolder(path, context); }
          catch (e) { if (key() === context) this.error = String(e); }
          finally { this.pending.delete(path); cx.notify(); }
        });
      }
    }
    cx.notify();
  }

  // Preview a file; with `line`, start a few lines above it (the preview can't scroll to a line).
  show(path, cx, line) {
    this.code?.release(); this.code = null; this.file = path; this.fileLine = line ?? null; this.fileError = null;
    if (!path || !cx) return;
    const context = this.context, root = this.root, on = this.on;
    cx.spawn(async cx => {
      try {
        let text = await readTextFile(`${root}/${path}`, { on });
        if (this.file !== path || key() !== context) return;
        if (text === null) { this.fileError = "This file is no longer available"; return; }
        if (text.includes("\0")) { this.fileError = "Binary file · no text preview"; return; }
        if (line > 4) text = `… (from line ${line - 3}; e opens it in nvim at line ${line})\n` + text.split("\n").slice(line - 4).join("\n");
        const t = theme(), ext = path.includes(".") ? path.split(".").pop() : "txt";
        this.code = EditorState.new({ language: LANG[ext] ?? ext, readonly: true, soft_wrap: true,
          value: text.length > 400000 ? text.slice(0, 400000) + "\n… (file truncated)" : text,
          font_family: settings().font_family, font_size: 12,
          syntax: { keyword: t.ansi5, string: t.ansi2, comment: t.dim, function: t.ansi4, type: t.ansi3, number: t.ansi1, constant: t.ansi6 } });
      } catch { if (this.file === path && key() === context) this.fileError = "Cannot preview this file (binary, too large, or unreadable)"; }
      finally { cx.notify(); }
    });
  }

  // ── tree, flattened: one item per visible row (what j/k walk) ───────────────
  flat(prefix, depth, out) {
    if (out.length >= TOTAL || depth > 40) return out;
    for (const entry of this.entries.get(prefix) ?? []) {
      if (out.length >= TOTAL) break;
      const path = prefix ? `${prefix}/${entry.name}` : entry.name, open = this.folders.has(path);
      out.push({ path, entry, depth, open });
      if (entry.dir && open) this.flat(path, depth + 1, out);
    }
    return out;
  }

  row({ path, entry, depth, open }, t, dark, kb) {
    const mark = this.marks[`${this.root}/${path}`];
    return h_flex().id(`file-${path}`).h(ROW).flex_none().pl(8 + depth * 18).pr(8).gap(7).items_center().rounded(7).cursor_pointer().hover(s => s.bg(t.hover))
      .when(kb, el => el.bg(t.hover).border_1().border_color(t.accent))
      .on_click((_e, cx) => { this.cursor = path; entry.dir ? this.toggle(path, cx) : this.show(path, cx); })
      .child(entry.dir ? svg(`${DIR}/chevron-${open ? "down" : "right"}.svg`).size(12).flex_none().text_color(t.dim) : div().w(12).flex_none())
      .child(image(icon(path, entry.dir, open, dark)).size(16).flex_none())
      .child(div().flex_1().min_w(0).truncate().child(entry.name))
      .when(Boolean(mark), el => el.child(div().text_size(11).text_color(mark === "A" ? t.ansi2 : mark === "D" || mark === "U" ? t.ansi1 : t.blocked).child(mark)));
  }

  // How many rows fit, and keep `top` so the row at `index` is on screen.
  fit(index, count) {
    const rows = Math.max(1, Math.floor(this.listHeight / ROW) || 20);
    if (index < this.top) this.top = index;
    if (index >= this.top + rows) this.top = index - rows + 1;
    this.top = Math.max(0, Math.min(this.top, Math.max(0, count - rows)));
    return rows;
  }

  // ── search: / file names, ? text (rg) ───────────────────────────────────────
  startSearch(mode, cx) {
    this.mode = mode; this.at = 0; this.results = []; this.top = 0;
    this.input.set_value("");
    this.input.focus();
    if (mode === "name" && !this.index) {
      const context = this.context, root = this.root, on = this.on;
      cx.spawn(async cx => {
        try { const files = await listFiles(root, on); if (key() === context) { this.index = files; this.search(cx); } }
        catch (e) { this.searchError = String(e); }
        finally { cx.notify(); }
      });
    }
    cx.notify();
  }

  leaveSearch(cx) {
    this.mode = null; this.results = []; this.searchError = null;
    this.handle?.focus();
    cx?.notify();
  }

  search(cx) {
    const q = this.input.value().trim(), seq = ++this.searchSeq;
    this.at = 0; this.top = 0; this.searchError = null;
    if (!q) { this.results = []; return cx.notify(); }
    if (this.mode === "name") {
      const terms = q.toLowerCase().split(/\s+/);
      const hits = [];
      for (const p of this.index ?? []) {
        const lp = p.toLowerCase();
        if (terms.every(term => lp.includes(term))) hits.push(p);
      }
      const base = p => p.slice(p.lastIndexOf("/") + 1).toLowerCase();
      hits.sort((a, b) => Number(!base(b).includes(terms[0])) - Number(!base(a).includes(terms[0])) || a.length - b.length);
      this.results = hits.slice(0, NAME_LIMIT).map(path => ({ path }));
      return cx.notify();
    }
    // text: wait for a pause in typing, then rg
    cx.timer.after(250, cx => {
      if (seq !== this.searchSeq) return;
      const context = this.context;
      this.searching = true; cx.notify();
      cx.spawn(async cx => {
        try { const r = await grep(this.root, this.on, q); if (seq === this.searchSeq && key() === context) this.results = r; }
        catch (e) { if (seq === this.searchSeq) this.searchError = String(e); }
        finally { if (seq === this.searchSeq) this.searching = false; cx.notify(); }
      });
    });
  }

  pick(cx) {
    const r = this.results[this.at];
    if (!r) return;
    this.leaveSearch(cx);
    this.show(r.path, cx, r.line);
  }

  // Open in the nvim of a terminal labelled nvim.server on this machine, and focus it.
  openInNvim(path, line, cx) {
    const machine = t => (t.address?.includes("/") ? t.address.split("/")[0] : null);
    const nv = terminals().find(t => t.labels?.["nvim.server"] && machine(t) === (this.on ?? null));
    if (!nv) { this.notice = "No nvim running here (needs the nvim.server label)"; cx.timer.after(3000, cx => { this.notice = null; cx.notify(); }); return cx.notify(); }
    const cmd = `execute('edit ${line ? "+" + line + " " : ""}' . fnameescape(${vimString(`${this.root}/${path}`)}))`;
    cx.spawn(async () => {
      await exec("nvim", ["--server", nv.labels["nvim.server"], "--remote-expr", cmd], { on: this.on }).catch(() => null);
      run("pane.focus", { terminal: nv.address });
    });
  }

  // ctrl-j/ctrl-k: next/previous result while searching, tree row otherwise; in the
  // preview (no list) they keep moving between panes.
  step(d, cx) {
    if (this.mode) {
      const n = this.results.length;
      if (n) this.at = (this.at + d + n) % n;
    } else if (this.file) {
      run("pane.go", { direction: d > 0 ? "down" : "up" });
      return;
    } else {
      const items = this.flat("", 0, []);
      if (!items.length) return;
      const at = Math.max(0, items.findIndex(it => it.path === this.cursor));
      this.cursor = items[Math.max(0, Math.min(items.length - 1, at + d))].path;
    }
    cx.notify();
  }

  onKey(e, cx) {
    const m = e.modifiers, k = e.key;
    if (this.mode) {
      // The input has the keyboard; take only list movement and escape.
      const n = this.results.length;
      if (k === "escape") this.leaveSearch(cx);
      else if (k === "down" || (m.control && k === "n")) { if (n) this.at = (this.at + 1) % n; }
      else if (k === "up" || (m.control && k === "p")) { if (n) this.at = (this.at + n - 1) % n; }
      else return;
      cx.stop_propagation(); cx.notify();
      return;
    }
    if (m.control || m.alt || m.platform) return;
    if (this.file) {
      if (["h", "left", "escape", "q", "backspace"].includes(k)) this.show(null);
      else if (k === "e") this.openInNvim(this.file, this.fileLine, cx);
      else return;
      cx.stop_propagation(); cx.notify();
      return;
    }
    if (k === "/") return (cx.stop_propagation(), this.startSearch(m.shift ? "text" : "name", cx));
    if (k === "?") return (cx.stop_propagation(), this.startSearch("text", cx));
    if (k === "r") { this.refresh(cx); cx.stop_propagation(); return; }
    const items = this.flat("", 0, []);
    if (!items.length) return;
    let at = items.findIndex(it => it.path === this.cursor);
    if (at < 0) at = 0;
    const it = items[at];
    const go = i => { this.cursor = items[Math.max(0, Math.min(items.length - 1, i))].path; };
    if (k === "j" || k === "down") go(at + 1);
    else if (k === "k" || k === "up") go(at - 1);
    else if (k === "G" || (k === "g" && m.shift) || k === "end") go(items.length - 1);
    else if (k === "g" || k === "home") go(0);
    else if (k === "l" || k === "right" || k === "enter") {
      this.cursor = it.path;
      if (!it.entry.dir) this.show(it.path, cx);
      else if (!it.open) this.toggle(it.path, cx);
      else if (items[at + 1]?.depth > it.depth) go(at + 1);
    }
    else if (k === "h" || k === "left") {
      if (it.entry.dir && it.open) { this.cursor = it.path; this.toggle(it.path, cx); }
      else if (it.depth > 0) go(items.findIndex(x => x.path === it.path.slice(0, it.path.lastIndexOf("/"))));
    }
    else if (k === "o" || k === "space") { if (it.entry.dir) { this.cursor = it.path; this.toggle(it.path, cx); } }
    else if (k === "e") { if (!it.entry.dir) this.openInNvim(it.path, null, cx); }
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  // A window of rows that fits the box; the wheel moves it (as picker does).
  rowWindow(id, count, index, draw) {
    const rows = this.fit(index, count);
    return v_flex().id(id).flex_1().min_h(0).overflow_hidden().p(6)
      .on_size_change((size, cx) => { const h = size.height / (Number(settings().zoom) || 1) - 12; if (Math.abs(h - this.listHeight) > 1) { this.listHeight = h; cx.notify(); } })
      .on_scroll_wheel((e, cx) => {
        const step = Math.sign(-e.delta.y) * Math.max(1, Math.round(Math.abs(e.delta.y) / ROW));
        this.top = Math.max(0, Math.min(this.top + step, Math.max(0, count - rows)));
        cx.notify();
      })
      .children(Array.from({ length: Math.min(rows, count - this.top) }, (_x, k) => draw(this.top + k)));
  }

  render(cx) {
    if (key() !== this.context) this.refresh(cx);
    const t = theme(), dark = Boolean(settings().dark), kbd = this.handle.is_focused();
    const root = v_flex().id("files").track_focus(this.handle).on_key_down((e, cx) => this.onKey(e, cx)).size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(kbd || this.mode ? t.accent : t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .when(Boolean(this.file), el => el.child(div().id("files-back").w(20).cursor_pointer().text_color(t.muted).on_click((_e, cx) => { this.show(null); cx.notify(); }).child("←")))
        .child(div().font_semibold().child(this.mode === "name" ? "Find file" : this.mode === "text" ? "Search text" : "Files"))
        .child(h_flex().flex_1().min_w(0).gap(6).justify_end().items_center().text_size(12).text_color(t.dim)
          .when(Boolean(this.file), el => el.child(image(icon(this.file, false, false, dark)).size(14).flex_none()))
          .child(div().min_w(0).truncate().child(this.notice ?? (this.file ? this.file + (this.fileLine ? `:${this.fileLine}` : "") : this.root?.split(/[\\/]/).pop() ?? "")))));

    if (this.mode) {
      const n = this.results.length, q = this.input.value().trim();
      const status = this.searchError ?? (this.mode === "name" && !this.index ? "Indexing files…" : this.searching ? "Searching…" : !q ? (this.mode === "name" ? "Type part of a path" : "Type text to search (rg, smart case)") : n ? `${n}${n >= (this.mode === "name" ? NAME_LIMIT : TEXT_LIMIT) ? "+" : ""} result${n > 1 ? "s" : ""} · ctrl-j/k · enter preview · esc back` : "No results");
      return root
        .child(h_flex().h(34).flex_none().mx(8).mt(8).px(10).gap(8).items_center().rounded(8).border_1().border_color(t.accent)
          .child(div().text_color(t.dim).child(this.mode === "name" ? "/" : "?"))
          .child(Input.new(this.input).flex_1().h_full().text_size(12.5).text_color(t.foreground)))
        .child(div().px(14).py(4).text_size(11).text_color(t.dim).child(status))
        .child(this.rowWindow("files-results", n, this.at, i => {
          const r = this.results[i], slash = r.path.lastIndexOf("/");
          return h_flex().id(`res-${i}`).h(ROW).flex_none().px(8).gap(7).items_center().rounded(7).cursor_pointer().hover(s => s.bg(t.hover))
            .when(i === this.at, el => el.bg(t.hover).border_1().border_color(t.accent))
            .on_click((_e, cx) => { this.at = i; this.pick(cx); })
            .child(image(icon(r.path, false, false, dark)).size(16).flex_none())
            .child(div().flex_none().max_w(220).truncate().child(r.path.slice(slash + 1) + (r.line ? `:${r.line}` : "")))
            .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.dim).child(r.line ? r.text : r.path.slice(0, Math.max(0, slash))));
        }));
    }

    if (this.file) return root.child(this.code ? Editor.new(this.code).flex_1().min_h(0) : div().p(12).text_color(t.dim).child(this.fileError || "Loading file…"));

    const items = this.flat("", 0, []);
    if (items.length && !items.some(it => it.path === this.cursor)) this.cursor = items[0].path;
    const at = Math.max(0, items.findIndex(it => it.path === this.cursor));
    return root
      .when(items.length > 0, el => el.child(this.rowWindow("files-tree", items.length, at, i => this.row(items[i], t, dark, kbd && i === at))))
      .when(items.length === 0, el => el.child(div().p(14).text_size(12).text_color(t.dim).child(this.error || (this.loading ? "Loading files…" : this.root ? "No files" : "No folder"))))
      .when(this.limited, el => el.child(div().p(8).text_size(11).text_color(t.dim).child("File list limited to 500 entries per folder and 5,000 total")))
      .when(kbd && items.length > 0, el => el.child(div().px(14).py(4).flex_none().text_size(10.5).text_color(t.dim).child("j/k · l open · h close · / file · ? text · e nvim")));
  }
}
