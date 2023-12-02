# 修正方正中文字体里某些标点符号的位置，源文件是otfcc导出的字体的json形式的数据

import json
from ..utils import *


def move_point(c, offset):
    result = []
    for i in c:
        if isinstance(i, list):
            result.append(move_point(i, offset))
        else:
            i['x'] += offset
            result.append(i)
    return result


def grouping(contours):
    if contours[0][0]['y'] > contours[1][0]['y']:
        return contours[0], contours[1]
    else:
        return contours[1], contours[0]


def move_contour(contours: list, x_offset: int = 0, y_offset: int = 0) -> list:
    result = []
    for i in contours:
        result.append({
            'x': i['x'] + x_offset,
            'y': i['y'] + y_offset,
            'on': i['on']
        })
    return result


def get_boundary(g: list):
    x_min = min([i['x'] for i in g])
    x_max = max([i['x'] for i in g])
    y_min = min([i['y'] for i in g])
    y_max = max([i['y'] for i in g])
    return x_min, x_max, y_min, y_max


def get_centeral_sym_point(src_points, center: tuple):
    result = []
    for i in src_points:
        result.append((2 * center[0] - i[0], 2 * center[1] - i[1]))
    return result


left = '，。、；！？'
pair_open = '》〉】）〗｝〕］」』”’'
pair_close = '《〈【（〖｛〔［「『“‘'


def get_offset(x_list, c):
    if c in left:
        length = min(flatten_list(x_list))
        offset = min(125 - length, 0)
    elif c in pair_open:
        length = min(flatten_list(x_list))
        offset = min(75 - length, 0)
    elif c in pair_close:
        length = max(flatten_list(x_list))
        offset = max(925 - length, 0)
    else:
        raise ValueError("I don't know how to manipulate")
    return offset


def fix_pos(filepath, output_path):
    with open(filepath) as handle:
        font = json.load(handle)
        cmap = font['cmap']
        glyf = font['glyf']

        for k, v in left + pair_open + pair_close:
            for i in v:
                unicode = str(ord(i))
                glyf_id = cmap[unicode]
                x = [item['x'] for item in flatten_list(glyf[glyf_id]['contours'])]
                offset = get_offset(x, i)
                contours = glyf[glyf_id]['contours']
                after_move = move_point(contours, offset)
                glyf[glyf_id]['contours'] = after_move

        with open(output_path, 'w') as output:
            json.dump(font, output)
