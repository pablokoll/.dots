# python3 -I test_resize.py — checks resize.py's border math on hand-made split trees (no Herdr needed).
import importlib.util, os
spec = importlib.util.spec_from_file_location("r", os.path.join(os.path.dirname(os.path.abspath(__file__)), "resize.py"))
r = importlib.util.module_from_spec(spec); spec.loader.exec_module(r)
def tree(): return {"type": "row", "id": "t", "children": [{"type": "block", "id": "A"}, {"type": "column", "id": "c", "children": [{"type": "block", "id": "B"}, {"type": "block", "id": "C"}]}]}
w = lambda n: [round(k.get("size", {"weight": 1})["weight"], 3) for k in n["children"]]
t = tree(); assert r.resize(t, "A", "right", 10) and w(t) == [0.6, 0.4]        # left pane grows
t = tree(); assert r.resize(t, "B", "left", 10) and w(t) == [0.4, 0.6]         # right pane grows
t = tree(); assert r.resize(t, "B", "down", 10) and w(t["children"][1]) == [0.6, 0.4] and w(t) == [1, 1]  # innermost split only
t = tree(); assert not r.resize(t, "A", "up", 10)                               # no vertical split around A
t = tree(); [r.resize(t, "A", "right", 20) for _ in range(5)]; assert w(t) == [0.95, 0.05]  # 5% floor
t = tree(); t["children"][0]["size"] = {"px": 100}
try: r.resize(t, "A", "right", 10); raise SystemExit("px size should abort")
except r.Unknown: pass
print("ok")
