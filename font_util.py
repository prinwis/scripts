import struct


def calc_table_checksum(src, offset, length):
    count = int(((length + 3) & ~3) / 4)
    dat = src[offset:offset + count * 4]
    data = struct.unpack(f'>{count}I', dat)
    return sum(data)


def get_table_info_list(font_file: str):
    with open(font_file, 'rb') as f:
        sfnt, num_tables, _, _, _ = struct.unpack('>I4H', f.read(12))
        if sfnt == 0x00010000 or sfnt == 0x4F54544F:
            tables = []
            for i in range(num_tables):
                tag, check_sum, offset, length = struct.unpack('>4s3I', f.read(16))
                tables.append({'tag': tag.decode('ascii'), 'check_sum': check_sum, 'offset': offset,
                               'length': length})
            return tables
        else:
            raise ValueError('not a valid font')


def get_table(font_path, table_name):
    with open(font_path, 'rb') as f:
        data = f.read()
        sfnt, num_tables = struct.unpack('>IH', data)
        if sfnt == 0x00010000 or sfnt == 0x4F54544F:
            for i in range(num_tables):
                tag, check_sum, offset, length = struct.unpack_from('>4s3I', data, 12)
                if tag == table_name:
                    return data[offset:offset + length]
        else:
            return b''


def decode_name_string(plat_id: int, enc_id: int, name_string: bytes):
    if plat_id == 1:
        if enc_id == 0:
            try:
                ret = name_string.decode('gbk')  # fix FounderType
            except UnicodeDecodeError:
                ret = name_string.decode('mac_roman')
            return ret
        elif enc_id == 1:
            return name_string.decode('eucjis2004')
        elif enc_id == 2:
            return name_string.decode('big5')
        elif enc_id == 25:
            return name_string.decode('gbk')
    elif plat_id == 3:
        return name_string.decode('UTF-16BE')


def get_name_table(font_file: str):
    name_table = get_table(font_file, "name")
    format_selector, count, string_offset = struct.unpack_from('>3H', name_table)
    if format_selector == 0:
        records = []
        str_off = 0
        for i in range(count):
            plat_id, enc_id, lang_id, name_id, length, rec_off = struct.unpack_from('>6H', name_table, 6 + 12 * i)

            name_string = struct.unpack_from(f'>{length}s', name_table, string_offset + str_off)[0]
            str_off += length
            # if plat_id == 1:
            #     print(name_string)

            records.append({'platformID': plat_id, 'encodingID': enc_id, 'languageID': lang_id,
                            'nameID': name_id, 'nameString': name_string})
        return records
    else:
        raise ValueError('not support')
