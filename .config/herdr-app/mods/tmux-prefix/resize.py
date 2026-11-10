#!/usr/bin/env python3
"""Move a pane's border like tmux resize-pane: resize.py left|right|up|down <tab> <pane> [machine] [percent]

The app has no pane resize command, so this edits the split tree in herdr-core's
"herdr-app" document (same approach as kcchien/herdr-pane-equalize). Unknown node
shapes or px sizes abort the write instead of guessing.
"""
import json
import shutil
import os
import subprocess
import sys

DOC = "herdr-app"
AXIS = {"left": "row", "right": "row", "up": "column", "down": "column"}
MIN = 0.05  # no pane below 5% of its split


class Unknown(Exception):
    pass


def rpc(method, params):
    hc = shutil.which("hc") or os.path.expanduser("~/.local/bin/hc")
    req = json.dumps({"jsonrpc": "2.0", "id": 1, "method": method, "params": params})
    out = subprocess.run([hc, "connect", "--json"], input=req + "\n", capture_output=True, text=True, timeout=10)
    lines = out.stdout.splitlines()
    if not lines:
        raise RuntimeError(f"hc connect gave no reply: {out.stderr.strip()}")
    reply = json.loads(lines[0])
    if "error" in reply:
        raise RuntimeError(f"{method}: {reply['error']}")
    return reply["result"]


def path_to(node, pane):
    """Containers from root down to the block with id `pane`, each with the child index taken."""
    kind = node.get("type")
    if kind not in ("row", "column", "block"):
        raise Unknown(f"unknown node type {kind!r}")
    if kind == "block":
        return [] if node.get("id") == pane else None
    for i, k in enumerate(node.get("children") or []):
        p = path_to(k, pane)
        if p is not None:
            return [(node, i)] + p
    return None


def weight(k):
    size = k.get("size", {"weight": 1})
    if not isinstance(size, dict) or set(size) != {"weight"}:
        raise Unknown(f"child {k.get('id')!r} has size {size!r}")
    return float(size["weight"])


def resize(root, pane, direction, percent):
    path = path_to(root, pane)
    if path is None:
        raise Unknown(f"pane {pane!r} not in this tab")
    along = AXIS[direction]
    # Nearest split on that axis with a neighbour: tmux moves the border of the innermost one.
    for node, i in reversed(path):
        kids = node["children"]
        if node["type"] == along and len(kids) > 1:
            break
    else:
        return False
    b = i if i < len(kids) - 1 else i - 1  # the border after child b: our right/bottom one, else our left/top
    ws = [weight(k) for k in kids]
    total = sum(ws)
    step = total * percent / 100 * (1 if direction in ("right", "down") else -1)
    step = max(-(ws[b] - total * MIN), min(step, ws[b + 1] - total * MIN))  # border moves: b grows, b+1 shrinks
    if abs(step) < 1e-9:
        return False
    ws[b] += step
    ws[b + 1] -= step
    for k, w in zip(kids, ws):
        k["size"] = {"weight": w / total}
    return True


def main(argv):
    if len(argv) < 4 or argv[1] not in AXIS:
        print((__doc__ or "").strip(), file=sys.stderr)
        return 2
    direction, tab_id, pane = argv[1:4]
    machine = argv[4] if len(argv) > 4 and argv[4] else None
    percent = float(argv[5]) if len(argv) > 5 else 5
    on = {"on": machine} if machine else {}
    if machine:  # the app shows remote ids as "<machine>/<id>"; that core stores bare ids
        tab_id, pane = (x.split("/", 1)[1] if x.startswith(machine + "/") else x for x in (tab_id, pane))
    try:
        for attempt in (1, 2):  # retry once if another client wrote in between
            got = rpc("doc.get", {"name": DOC, **on})
            value = got["value"]
            tab = next((t for s in value.get("spaces", []) for t in s.get("tabs", []) if t.get("id") == tab_id), None)
            if not tab or "root" not in tab:
                raise Unknown(f"tab {tab_id!r} not found")
            if not resize(tab["root"], pane, direction, percent):
                return 0
            try:
                rpc("doc.set", {"name": DOC, "value": value, "version": got["version"], **on})
                return 0
            except RuntimeError:
                if attempt == 2:
                    raise
    except (Unknown, RuntimeError, subprocess.TimeoutExpired) as e:
        print(f"resize: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
