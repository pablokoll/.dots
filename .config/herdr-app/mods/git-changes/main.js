// Changes, as a working git panel after Zed's: stage with checkboxes, commit,
// stash, push and pull, the diff of what's picked, and the history.
// One mod, three roles (props.role): the panel, its menus (popups over the
// window), and the diff, shown in a tab of the main area.
import { View } from "gpui-kit";
import { props, nextCommand } from "herdr";
import { Panel } from "./panel.js";
import { Menu } from "./menu.js";
import { DiffView } from "./diff.js";

export default class GitChanges extends View {
  init(_props, cx) {
    const role = props()?.role;
    this.part = role === "menu" ? new Menu() : role === "diff" ? new DiffView() : new Panel();
    this.part.init(cx);
    if (this.part instanceof Panel) {
      cx.spawn(async cx => { for (;;) if (await nextCommand() === "focus") { this.part.handle.focus(); cx.notify(); } });
      // ponytail: no blur event for a plain handle; poll so the focus border clears.
      cx.timer.every(300, cx => { const f = this.part.handle.is_focused(); if (f !== this.had) { this.had = f; cx.notify(); } });
    }
  }

  render(cx) { return this.part.render(cx); }
}
