# 0x304B - 0x309D: hiragana
# 0x30AB - 0x30fD: katakana

voiceless_to_voiced = {
    "う": "ゔ", "か": "が", "き": "ぎ", "く": "ぐ", "け": "げ",
    "こ": "ご", "さ": "ざ", "し": "じ", "す": "ず", "せ": "ぜ",
    "そ": "ぞ", "た": "だ", "ち": "ぢ", "つ": "づ", "て": "で",
    "と": "ど", "は": "ば", "ひ": "び", "ふ": "ぶ", "へ": "べ",
    "ほ": "ぼ", "ゝ": "ゞ", "カ": "ガ", "キ": "ギ", "ク": "グ",
    "ケ": "ゲ", "コ": "ゴ", "サ": "ザ", "シ": "ジ", "ス": "ズ",
    "セ": "ゼ", "ソ": "ゾ", "タ": "ダ", "チ": "ヂ", "ツ": "ヅ",
    "テ": "デ", "ト": "ド", "ハ": "バ", "ヒ": "ビ", "フ": "ブ",
    "ヘ": "ベ", "ホ": "ボ", "ウ": "ヴ", "ワ": "ヷ", "ヰ": "ヸ",
    "ヱ": "ヹ", "ヲ": "ヺ", "ヽ": "ヾ"
}

voiceless_to_semiVoiced = {
    "ひ": "ぴ", "ふ": "ぷ", "へ": "ぺ", "ほ": "ぽ", "ハ": "パ",
    "ヒ": "ピ", "フ": "プ", "ヘ": "ペ", "ホ": "ポ",
}

kana_half2full_dict = {
    "ｦ": "ヲ", "ｧ": "ァ", "ｨ": "ィ", "ｩ": "ゥ", "ｪ": "ェ",
    "ｫ": "ォ", "ｬ": "ャ", "ｭ": "ュ", "ｮ": "ョ", "ｯ": "ッ",
    "ｰ": "ー", "ｱ": "ア", "ｲ": "イ", "ｳ": "ウ", "ｴ": "エ",
    "ｵ": "カ", "ｶ": "カ", "ｷ": "キ", "ｸ": "ク", "ｹ": "ケ",
    "ｺ": "コ", "ｻ": "サ", "ｼ": "シ", "ｽ": "ス", "ｾ": "セ",
    "ｿ": "ソ", "ﾀ": "タ", "ﾁ": "チ", "ﾂ": "ツ", "ﾃ": "テ",
    "ﾄ": "ト", "ﾅ": "ナ", "ﾆ": "ニ", "ﾇ": "ヌ", "ﾈ": "ネ",
    "ﾉ": "ノ", "ﾊ": "ハ", "ﾋ": "ヒ", "ﾌ": "フ", "ﾍ": "ヘ",
    "ﾎ": "ホ", "ﾏ": "マ", "ﾐ": "ミ", "ﾑ": "ム", "ﾒ": "メ",
    "ﾓ": "モ", "ﾔ": "ヤ", "ﾕ": "ユ", "ﾖ": "ヨ", "ﾗ": "ラ",
    "ﾘ": "リ", "ﾙ": "ル", "ﾚ": "レ", "ﾛ": "ロ", "ﾜ": "ワ",
    "ﾝ": "ン", "ﾞ": "゛", "ﾟ": "゜"
}

fullwidth_number = '０１２３４５６７８９'
fullwidth_punct = '！＂＃＄％＆＇（）＊＋，－．／：；＜＝＞？＠［＼］＾＿｀｛｜｝～'
fullwidth_lowercase = 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'
fullwidth_uppercase = 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ'
fullwidth_alphabet = fullwidth_uppercase + fullwidth_lowercase


def kana_half2full(s: str) -> str:
    ret = ''
    for i in s:
        if i in kana_half2full_dict.keys():
            ret += kana_half2full_dict[i]
        else:
            ret += i
    return ret


def ascii_full2half(s: str, conv_number=True, conv_punct=True,
                    conv_alphabet=True, excludes=None) -> str:
    ret = ''
    convert_range = ''
    if conv_number:
        convert_range += fullwidth_number
    if conv_punct:
        convert_range += fullwidth_punct
    if conv_alphabet:
        convert_range += fullwidth_alphabet
    if excludes is not None:
        for i in excludes:
            convert_range.replace(i, '')
    for i in s:
        if i in convert_range:
            ret += chr(ord(i) - 0xfee0)
        else:
            ret += i
    return ret


def combine2single(s: str, strict=True) -> str:
    ret = ''
    for i, v in enumerate(s):
        if ord(v) == 0x3099:
            if i > 0 and s[i-1] in voiceless_to_voiced.keys():
                ret += voiceless_to_voiced[s[i-1]]
            elif not strict:
                ret += chr(0x309b)
        elif ord(v) == 0x309a:
            if i > 0 and s[i-1] in voiceless_to_semiVoiced.keys():
                ret += voiceless_to_semiVoiced[s[i-1]]
            elif not strict:
                ret += chr(0x309c)
        else:
            ret += v
    return ret
