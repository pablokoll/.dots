// This computer's CPU, temperature, memory and disk, for the bottom bar.
import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { readTextFile, exec, theme } from "herdr";

const AMBER = "#ffb347", RED = "#ff5d6c";
const read = async (p) => { try { return await readTextFile(p); } catch { return null; } };

// hwmon numbers change between boots: find the CPU sensor by name.
async function cpuTempPath() {
  for (let i = 0; i < 12; i++) {
    const name = (await read(`/sys/class/hwmon/hwmon${i}/name`))?.trim();
    if (name === "k10temp" || name === "coretemp") return `/sys/class/hwmon/hwmon${i}/temp1_input`;
  }
  return null;
}

export default class PcStats extends View {
  init(_props, cx) {
    this.s = {};
    cx.spawn(async (cx) => { this.tempPath = await cpuTempPath(); });
    const fast = (cx) => cx.spawn(async (cx) => {
      const stat = (await read("/proc/stat"))?.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
      if (stat) {
        const idle = stat[3] + stat[4], total = stat.reduce((a, b) => a + b, 0);
        if (this.prev) this.s.cpu = Math.round(100 * (1 - (idle - this.prev.idle) / (total - this.prev.total || 1)));
        this.prev = { idle, total };
      }
      const mem = await read("/proc/meminfo");
      const kb = (k) => Number(new RegExp(`${k}:\\s+(\\d+)`).exec(mem ?? "")?.[1] ?? 0);
      if (mem) { this.s.memUsed = (kb("MemTotal") - kb("MemAvailable")) / 1048576; this.s.memTotal = kb("MemTotal") / 1048576; }
      if (this.tempPath) this.s.temp = Math.round(Number(await read(this.tempPath)) / 1000);
      cx.notify();
    });
    const slow = (cx) => cx.spawn(async (cx) => {
      const out = (await exec("df", ["-P", "/"]).catch(() => null))?.stdout.split("\n")[1]?.trim().split(/\s+/);
      if (out) this.s.disk = parseInt(out[4]);
      cx.notify();
    });
    fast(cx); slow(cx);
    cx.timer.every(2000, fast);
    cx.timer.every(60000, slow);
  }

  render() {
    const t = theme(), s = this.s;
    const tone = (v, warn, bad) => (v >= bad ? RED : v >= warn ? AMBER : t.muted);
    const item = (label, value, color) => h_flex().gap(4).items_center().flex_none()
      .child(div().text_color(t.dim).child(label)).child(div().text_color(color).child(value));
    const memPct = s.memTotal ? (100 * s.memUsed) / s.memTotal : 0;
    return h_flex().size_full().px(12).gap(14).items_center().justify_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8)
      .when(s.cpu != null, (el) => el.child(item("CPU", `${s.cpu}%`, tone(s.cpu, 70, 90))))
      .when(s.temp != null, (el) => el.child(item("TEMP", `${s.temp}°`, tone(s.temp, 75, 90))))
      .when(s.memTotal != null, (el) => el.child(item("RAM", `${s.memUsed.toFixed(1)}/${Math.round(s.memTotal)}G`, tone(memPct, 80, 92))))
      .when(s.disk != null, (el) => el.child(item("DISK", `${s.disk}%`, tone(s.disk, 85, 95))));
  }
}
