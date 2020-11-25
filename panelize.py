#!/usr/bin/python3
from kikit import panelize, substrate
from shapely.geometry import Polygon
import shapely
import pcbnew
import sys

sep = panelize.fromMm(3)
tabWidth = panelize.fromMm(8)
mouseBitesDiameter = panelize.fromMm(0.5)
mouseBitesSpace = panelize.fromMm(0.8)
frameWidth = panelize.fromMm(5)

def add_vtab(tabs, cuts, panel, b, tabWidth, sep):
    x = b[0] + b[2]/2
    y = b[1] + b[3] + sep/2
    t, c = panel.boardSubstrate.tab(pcbnew.wxPoint(x, y), [0, 1], tabWidth)
    tabs.append(t)
    cuts.append(c)
    t, c = panel.boardSubstrate.tab(pcbnew.wxPoint(x, y), [0, -1], tabWidth)
    tabs.append(t)
    cuts.append(c)

def add_htab(tabs, cuts, panel, b, tabWidth, sep):
    x = b[0] - sep/2
    y = b[1] + b[3]/2
    t, c = panel.boardSubstrate.tab(pcbnew.wxPoint(x, y), [1, 0], tabWidth)
    tabs.append(t)
    cuts.append(c)
    t, c = panel.boardSubstrate.tab(pcbnew.wxPoint(x, y), [-1, 0], tabWidth)
    tabs.append(t)
    cuts.append(c)

def add_frame(tabs, cuts, panel, tabWidth, sep, width, outline):
    left = Polygon([
        (outline[0] - sep, outline[1]),
        (outline[0] - sep - width, outline[1]),
        (outline[0] - sep - width, outline[1] + outline[3]),
        (outline[0] - sep, outline[1] + outline[3])
    ])
    right = Polygon([
        (outline[0] + outline[2] + sep, outline[1]),
        (outline[0] + outline[2] + sep + width, outline[1]),
        (outline[0] + outline[2] + sep + width, outline[1] + outline[3]),
        (outline[0] + outline[2] + sep, outline[1] + outline[3])
    ])

    panel.appendSubstrate(left)
    panel.appendSubstrate(right)

    t, c = panel.boardSubstrate.tab(
        pcbnew.wxPoint(outline[0] - sep/2, outline[1] + 1 * outline[3] // 4),
        [1, 0], tabWidth
    )
    tabs.append(t)
    cuts.append(c)

    t, c = panel.boardSubstrate.tab(
        pcbnew.wxPoint(outline[0] - sep/2, outline[1] + 3 * outline[3] // 4),
        [1, 0], tabWidth
    )
    tabs.append(t)
    cuts.append(c)

    t, c = panel.boardSubstrate.tab(
        pcbnew.wxPoint(outline[0] + outline[2] + sep/2, outline[1] + 1 * outline[3] // 4),
        [-1, 0], tabWidth
    )
    tabs.append(t)
    cuts.append(c)

    t, c = panel.boardSubstrate.tab(
        pcbnew.wxPoint(outline[0] + outline[2] + sep/2, outline[1] + 3 * outline[3] // 4),
        [-1, 0], tabWidth
    )
    tabs.append(t)
    cuts.append(c)


def export_panel(input_file, output_file, columns):
    panel = panelize.Panel()

    x = 0
    panelOrigin = pcbnew.wxPointMM(20, 50)

    tabs = []
    cuts = []

    renamer = lambda x, y: "Board_{}-{}".format(x, y)


    for i in range(columns):
        top = panel.appendBoard(input_file,
                                panelOrigin + pcbnew.wxPoint(x, 0),
                                origin=panelize.Origin.TopLeft,
                                tolerance=panelize.fromMm(5),
                                rotationAngle=900)
        bot = panel.appendBoard(input_file,
                                panelOrigin + pcbnew.wxPoint(x, top[3] + sep),
                                origin=panelize.Origin.BottomRight,
                                tolerance=panelize.fromMm(5),
                                rotationAngle=2700)

        add_vtab(tabs, cuts, panel, top, tabWidth, sep)

        if (i == 0):
            panel_x = top[0]
            panel_y = top[1]
            panel_h = bot[1] + bot[3] - top[1]
            panel_w = columns * top[2] + (columns - 1) * sep
            outline = pcbnew.wxRect(panel_x, panel_y, panel_w, panel_h)

        if (i > 0):
            for b in [top, bot]:
                add_htab(tabs, cuts, panel, b, tabWidth, sep)
        x += sep + top[2]

    add_frame(tabs, cuts, panel, tabWidth, sep, frameWidth, outline)
    panel.appendSubstrate(tabs)
    panel.addMillFillets(panelize.fromMm(1))
    panel.makeMouseBites(cuts, mouseBitesDiameter, mouseBitesSpace,
                         offset=-mouseBitesDiameter/2)
    panel.save(output_file)

if len(sys.argv) == 3:
    columns = 3
elif len(sys.argv) == 4:
    columns = int(sys.argv[3])
else:
    print("Usage: {} <INPUT> <OUTPUT> [COLUMNS]".format(sys.args[0]))
    sys.exit()

export_panel(sys.argv[1], sys.argv[2], columns)
