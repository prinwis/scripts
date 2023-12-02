import os
import re
import json
import shutil
import hashlib
import subprocess
from collections import defaultdict


def sort_files(d, match, by):
    ret = defaultdict(list)
    for root, dirs, files in os.walk(d):
        for f in files:
            full_path = os.path.join(root, f)
            if match(full_path):
                ret[by(full_path)].append(full_path)
    return ret


def get_file_checksum(file: str, method='md5'):
    with open(file, "rb") as handle:
        method_map = {
            'md5': hashlib.md5,
            'sha1': hashlib.sha1,
            'sha256': hashlib.sha256
        }
        sha1 = method_map[method](handle.read())
        return sha1.digest()


def find_copies(directory):
    book_exts = ['.pdf', '.epub', '.mobi', '.azw', '.azw3']

    def match_func(i):
        return os.path.splitext(i)[1] in book_exts

    def by(i):
        return os.stat(i).st_size

    books = sort_files(directory, match=match_func, by=by)
    redundants = []
    for value in books.values():
        if len(value) > 1:
            checksums = set()
            for i in value:
                file_checksum = get_file_checksum(i)
                if file_checksum in checksums:
                    redundants.append(i)


def read_large_file(file_obj, chunk_size=4096):
    buf = b''
    while True:
        data = file_obj.read(chunk_size)
        if not data:
            break
        buf += data
    return buf


def get_file_hash(filepath: str, method=None) -> str:
    if method is None:
        if shutil.which('sha1sum'):
            result = subprocess.check_output(f'sha1sum {filepath}', shell=True).decode('utf-8')
            return result.split('  ', maxsplit=1)[0]
        else:
            raise ValueError("`sha1sum` not found")
    else:
        hs = method()
        buf_size = 2 ** 20
        with open(filepath, 'rb') as f:
            while True:
                buf = f.read(buf_size)
                if not buf:
                    break
                hs.update(buf)
        return hs.hexdigest()


def fs_case_insensitive():
    home = os.path.expanduser('~')
    return os.path.exists(home.upper()) and os.path.exists(home.lower())


def strip_extension(filepath: str):
    basename = os.path.basename(filepath)
    return os.path.splitext(basename)


def lower_file_basename(filepath: str) -> str:
    d, f = os.path.split(filepath)
    base, ext = os.path.splitext(f)
    base = base.lower()
    return os.path.join(d, base + ext)


def name_conflict(src: str, dest: str, check_case=True) -> bool:
    src_base = os.path.split(src)[1]
    if check_case:
        lower_base = lower_file_basename(src)
        lower_dest = [lower_file_basename(i) for i in os.listdir(dest)]
        return lower_base in lower_dest
    else:
        return src_base in os.listdir(dest)


def safe_move(src: str, dest: str, check_hash=False):
    if not name_conflict(src, dest):
        shutil.move(src, dest)
    else:
        suffix_num = 1
        while True:
            base_wo_ext, ext = strip_extension(src)
            new_base = base_wo_ext + f'({suffix_num})' + ext
            if not os.path.exists(os.path.join(dest, new_base)):
                shutil.move(src, os.path.join(dest, new_base))
                break
            else:
                suffix_num += 1


def merge_dir(src: str, dest: str):
    src_files = os.listdir(src)
    for i in src_files:
        src_full = os.path.join(src, i)
        dest_full = os.path.join(dest, i)
        if not os.path.exists(dest_full):
            safe_move(os.path.join(src, i), dest)
        else:
            hash_src = get_file_hash(src_full)
            hash_dest = get_file_hash(dest_full)
            if hash_src == hash_dest:
                print(f'exists: {i}')
            else:
                pass


def flat_move(src: str, dest: str):
    for root, dirs, files in os.walk(src):
        for f in files:
            fullpath = os.path.join(root, f)
            safe_move(fullpath, dest)


def hash_all_files(dirpath: str, out: str, ext: str):
    d = defaultdict(list)
    for root, dirs, files in os.walk(dirpath):
        for f in files:
            if f.endswith(ext):
                hash_result = get_file_hash(os.path.join(root, f))
                d[hash_result].append(os.path.join(root, f))
    with open(out, 'w', encoding='utf-8') as o:
        json.dump(d, o, ensure_ascii=False, indent=4)


def filter_dups(json_path: str, out: str):
    with open(json_path, 'r', encoding='utf-8') as f:
        d = json.load(f)
        dups = {}
        for k in d.keys():
            if len(d[k]) > 1:
                dups[k] = d[k]
        with open(out, 'w', encoding='utf-8') as o:
            json.dump(dups, o, ensure_ascii=False, indent=4)


def clean_dups(dirpath: str, out_dir: str, ext_list: list):
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)
    for ext in ext_list:
        out_file = os.path.join(out_dir, f'{ext.replace(".", "")}.json')
        if not os.path.exists(out_file):
            hash_all_files(dirpath, out_file, ext)
        dup_out = os.path.join(out_dir, f'dup_{ext.replace(".", "")}.json')
        filter_dups(out_file, dup_out)


def strip_useless_parentheses(dirpath: str):
    """
    删掉文件名中多余的(1), (2) 和（1）（2）...
    """
    for root, dirs, files in os.walk(dirpath):
        for f in files:
            if re.match(r'.* [(（][0-9][）)].*', f):
                s = re.sub(r' [(（][0-9][）)]', '', f)
                if not os.path.exists(s):
                    os.rename(os.path.join(root, f), os.path.join(root, s))
