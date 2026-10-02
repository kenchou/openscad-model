"""解析用户描的 SVG（贝塞尔路径）→ OpenSCAD 2D 形状 + 可调拉伸参数。

SVG: /Users/ken/Downloads/甲骨文-鹿.svg  (viewBox 0 0 362 662, 1 条 path, 5 个子路径)
      子路径 1 = 外轮廓，其余 4 条 = 镂空。
"""
import json
import re

SRC = "/Users/ken/Downloads/甲骨文-鹿.svg"
SAMPLE_PER_CURVE = 10          # 每条三次贝塞尔采样段数

raw = open(SRC, encoding="utf-8").read()
m = re.search(r'\sd="(.*?)"\s*>', raw, re.S)
d = m.group(1)

# ---------------------------------------------------------------- path 解析
tokens = re.findall(r'[MCLZmlcz]|[-+]?(?:\d+\.?\d*|\.\d+)', d)
i = 0
subpaths = []
cur = None
start = None
cmd = None


def num():
    global i
    v = float(tokens[i]); i += 1
    return v


def bezier(p0, p1, p2, p3, n=SAMPLE_PER_CURVE):
    out = []
    for k in range(1, n + 1):
        t = k / n
        mt = 1 - t
        x = (mt ** 3 * p0[0] + 3 * mt * mt * t * p1[0]
             + 3 * mt * t * t * p2[0] + t ** 3 * p3[0])
        y = (mt ** 3 * p0[1] + 3 * mt * mt * t * p1[1]
             + 3 * mt * t * t * p2[1] + t ** 3 * p3[1])
        out.append((round(x, 2), round(y, 2)))
    return out


while i < len(tokens):
    if tokens[i] in "MCLZmlcz":
        cmd = tokens[i]; i += 1
    if cmd in ("M", "m"):
        x, y = num(), num()
        if cmd == "m":
            x += cur[0] if cur else 0
            y += cur[1] if cur else 0
        if cur is not None:
            subpaths.append(cur)
        cur = [(round(x, 2), round(y, 2))]
        start = (x, y)
        cmd = "L" if cmd == "M" else "l"
    elif cmd in ("C", "c"):
        x1, y1, x2, y2, x, y = (num() for _ in range(6))
        if cmd == "c":
            ox, oy = cur[-1]
            x1 += ox; y1 += oy; x2 += ox; y2 += oy; x += ox; y += oy
        cur.extend(bezier(cur[-1], (x1, y1), (x2, y2), (x, y)))
    elif cmd in ("L", "l"):
        x, y = num(), num()
        if cmd == "l":
            x += cur[-1][0]; y += cur[-1][1]
        cur.append((round(x, 2), round(y, 2)))
    elif cmd in ("Z", "z"):
        if cur and cur[0] != cur[-1]:
            cur.append(cur[0])
        subpaths.append(cur)
        cur = None
        start = None
    else:
        i += 1

if cur:
    subpaths.append(cur)

subpaths = [s for s in subpaths if len(s) > 3]
print("子路径数", len(subpaths), "点数", [len(s) for s in subpaths])


def area(pts):
    s = 0.0
    n = len(pts)
    for k in range(n):
        x1, y1 = pts[k]
        x2, y2 = pts[(k + 1) % n]
        s += x1 * y2 - x2 * y1
    return abs(s) / 2


subpaths.sort(key=area, reverse=True)
print("面积", [round(area(s)) for s in subpaths])

outer = subpaths[0]
holes = subpaths[1:]
xs = [p[0] for p in outer]; ys = [p[1] for p in outer]
bx0, bx1, by0, by1 = min(xs), max(xs), min(ys), max(ys)
print("外轮廓 bbox x %.1f..%.1f (%.1f)  y %.1f..%.1f (%.1f)" % (bx0, bx1, bx1 - bx0, by0, by1, by1 - by0))

json.dump({"w": 362, "h": 662, "outer": outer, "holes": holes,
           "bbox": [bx0, by0, bx1, by1]}, open("svg_shape.json", "w"))
print("saved svg_shape.json")
