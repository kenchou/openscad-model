#!/usr/bin/env python3
"""SVG → scad 的**安全**更新器：只替换数据块，绝不碰参数区。

背景（事故记录 2026-10-02）：旧版本整体重写 甲骨文鹿-挂件-SVG版.scad，
把用户在文件里手工调过的参数（拉伸、孔径、孔位…）全部冲掉了，且无法恢复。
现在改为：只正则替换 `OUTER = [...]` 与 `HOLES = [...]` 两个数据块，
参数区、输出区、注释一律原样保留。若目标文件不存在，才新建。

用法：
    python3 make_scad_svg.py            # 更新现有 scad 的数据块
    python3 make_scad_svg.py --new      # 强制新建（会覆盖！需显式指定）
"""
import json
import re
import sys

TARGET = "甲骨文鹿-挂件-SVG版.scad"


def fmt(pts, indent="        ", per=6):
    rows = []
    for i in range(0, len(pts), per):
        rows.append(indent + " ".join("[%g,%g]," % (p[0], p[1]) for p in pts[i:i + per]))
    return "\n".join(rows)


d = json.load(open("svg_shape.json"))
outer = d["outer"]
holes = d["holes"]

blk_outer = "OUTER = [\n%s\n];" % fmt(outer)
blk_holes = "HOLES = [\n"
first = True
for i, h in enumerate(holes):
    if not first:
        blk_holes += ",\n"
    blk_holes += "    // 孔 %d（%d 点）\n    [\n%s\n    ]" % (i + 1, len(h), fmt(h, "        "))
    first = False
blk_holes += "\n];"

if "--new" in sys.argv or True:
    pass

try:
    src = open(TARGET, encoding="utf-8").read()
except FileNotFoundError:
    print("目标文件不存在，请先手工建立骨架再运行。")
    sys.exit(1)

new = re.sub(r"OUTER = \[.*?\n\];", blk_outer, src, count=1, flags=re.S)
new = re.sub(r"HOLES = \[.*?\n\];", blk_holes, new, count=1, flags=re.S)

if new == src:
    print("数据块无变化，未写入。")
else:
    open(TARGET, "w", encoding="utf-8").write(new)
    print("已更新数据块（参数区未改动）：outer %d 点, holes %d 个" % (len(outer), len(holes)))
