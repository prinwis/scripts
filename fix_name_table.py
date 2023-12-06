# 修正某些中文字体的name表，源文件是otfcc导出的字体的json形式的数据
# 除name表外，会影响字体引擎识别字体名称的相关字段也一并调整，如
# head['macStyle'], OS_2['fstype'], OS_2['fsSelection']
# 部分nameID的含义
# 0  -> Copyright notice
# 1  -> Family Name
# 2  -> Subfamily Name, one of 'Regular', 'Italic', 'Bold', 'Bold Italic'
# 3  -> Unique identifier
# 4  -> Fullname
# 5  -> Version string, Version <number>.<number>. e.g. Version 1.00
# 6  -> PostScript Name, can't contains '[', ']', '(', ')', '{', '}', '<', '>', '/', '%'
# 16 -> Typographic Family Name
# 17 -> Typographic Subfamily Name, can be any string
#
# 对于单个字体，例如 FZNewShuSongGBK（方正新书宋）
# Family Name(id 1) = FZNewShuSongGBK
# Subfamily Name(id 2) = Regular
# Fullname(id 4) = FZNewShuSongGBK
# Typographic Family Name(id 16) = FZNewShuSongGBK
# Typographic Subfamily Name(id 17) = Regular
#
# 对于四基本样式字体，例如 Windows 自带的Times New Roman
# Family Name(id 1) = Times New Roman
# Subfamily Name(id 2) = Regular (Bold, Italic, Bold Italic)
# Fullname(id 4) = Times New Roman ([Regular]（可选）, Bold, Italic, Bold, Italic)
# Typographic Family Name(id 16) = Times New Roman
# Typographic Subfamily Name(id 17) = Regular
#
# 对于有更多样式的字体, 例如 Calluna, 四样式可参照上面，四样式以外的
# Family Name(id 1) = Calluna Black
# Subfamily Name(id 2) = Regular
# Fullname(id 4) = Calluna Black
# Typographic Family Name(id 16) = Calluna
# Typographic Subfamily Name(id 17) = Black
#
# 另外，OTF 字体还有 CFF 表
# CFF 表中有 FullName 和 FamilyName 这两个字段


from copy import deepcopy
import os


def parse_name_table(font: dict) -> dict:
    name_table: list = deepcopy(font['name'])
    name = {}
    for entry in name_table:
        key = (entry['platformID'], entry['encodingID'], entry['languageID'], entry['nameID'])
        value = entry['nameString']
        name[key] = value
    return name


def title_style(s: str):
    sp = s.split(' ')
    return ' '.join([i.title() for i in sp])


def fix_name_table(table: dict, info_table: dict, base_style: str) -> None:
    for iden in [(1, 0, 0), (3, 1, 1033)]:
        if base_style.lower() in ['regular', 'italic', 'bold', 'bold italic']:
            table[iden + (1,)] = info_table['base_name']
            table[iden + (2,)] = base_style.title()
        else:
            if 'italic' in base_style.lower():
                table[iden + (1,)] = info_table['base_name'] + ' ' + base_style.split(' ', maxsplit=1)[0].title()
                table[iden + (2,)] = 'Italic'
            else:
                table[iden + (1,)] = info_table['base_name'] + ' ' + base_style.title()
                table[iden + (2,)] = 'Regular'
        table[iden + (4,)] = info_table['base_name'] + ' ' + title_style(base_style)
        table[iden + (6,)] = info_table['base_name'].replace(' ', '') + '-' + title_style(base_style).replace(' ',
                                                                                                              '')
        table[iden + (16,)] = info_table['base_name']
        table[iden + (17,)] = title_style(base_style)


def fix_cff_name(cff: dict, info_table: dict, base_style: str) -> dict:
    d = cff.copy()
    cff_name = title_style(info_table['base_name']).replace(' ', '') + '-' + title_style(base_style).replace(' ',
                                                                                                             '')
    d['fontName'] = cff_name
    d['fullName'] = cff_name
    d['familyName'] = title_style(info_table['base_name']).replace(' ', '')
    d['weight'] = title_style(base_style).replace(' ', '')
    return d


def dump_name_table(table: dict) -> list:
    tables = []
    for k, v in table.items():
        d = {
            'platformID': k[0],
            'encodingID': k[1],
            'languageID': k[2],
            'nameID': k[3],
            'nameString': v
        }
        tables.append(d)
    return tables


def fix_name(font: dict, info_table: dict, base_style: str) -> None:
    name_table = parse_name_table(font)
    fix_name_table(name_table, info_table, base_style)
    font['name'] = dump_name_table(name_table)
    if 'CFF_' in font.keys():
        cff_table = fix_cff_name(font['CFF_'], info_table, base_style)
        font['CFF_'] = cff_table


def get_style(filename: str) -> str:
    basename: str = os.path.splitext(filename)[0]
    style = basename.split(' ', maxsplit=3)[3]
    return style


def fix_name2(font, **name_table):
    font_name: list = font['name']
    en = name_table['en']
    entry_names = ['copyrights', 'family', 'subfamily', 'identifier', 'fullname', 'version',
                   'postscript_name', 'typo_family', 'typo_subfamily']
    entry_ids = [0, 1, 2, 3, 4, 5, 6, 16, 17]

    entrys = zip(entry_names, entry_ids)
    for i in entrys:
        d = {
            "platformID": 3,
            "encodingID": 1,
            "languageID": 1033,
            "nameID": i[1],
            "nameString": en[i[0]]
        }
        font_name.append(d)

    if 'sc' in name_table.keys():
        sc = name_table['sc']
        sc_entry_names = ['family', 'subfamily', 'fullname', 'typo_family', 'typo_subfamily']
        sc_entry_ids = [1, 2, 4, 16, 17]
        sc_entrys = zip(sc_entry_names, sc_entry_ids)
        for i in sc_entrys:
            d = {
                "platformID": 3,
                "encodingID": 1,
                "languageID": 2052,
                "nameID": i[1],
                "nameString": sc[i[0]]
            }
            font_name.append(d)



