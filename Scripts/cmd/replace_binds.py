#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Requirement
python 2.7
"""

"""Usage
$ python replace_binds.py -s hoge.sql

outputs:
  q00.sql
"""

import argparse
import re


def read_file(filename):
    with open(filename) as f:
        raw_text = f.read()
        return raw_text


def remove_last_semicolon(sql_text):
    sql_lines = sql_text.split('\n')
    for indx, line in enumerate(reversed(sql_lines)):
        if line == ';':
            # もし ';' があったらなくす。最後のセミコロンのみ。
            sql_lines[- indx - 1] = ""
            break
    return "\n".join(sql_lines)


def replace_all_colon(sql_text):
    binds = set(re.findall(':[1-9][0-9]+', sql_text))
    max_bind = max([int(b[1:]) for b in binds])
    ret_text = sql_text
    for i in reversed(range(max_bind + 1)):
        new_bind = 'b' + str(i)
        old_bind = ':' + str(i)
        ret_text = ret_text.replace(old_bind, new_bind)
    return ret_text


def replace_all_question_mark(sql_text):
    """上から順に ? を b[数字] に変換して返す"""
    i = 1
    ret_text = sql_text
    for i in range(sql_text.count('?')):
        ret_text = ret_text.replace('?', 'b' + str(i+1), 1)
    return ret_text


def add_plsql_text(sql_text):
    ret_text = "declare\n"
    ret_text += "@bind\n"
    ret_text += "begin\n"
    ret_text += "for r in (\n"
    ret_text += sql_text
    ret_text += "\n) loop\n"
    ret_text += "null ;\n"
    ret_text += "end loop ;\n"
    ret_text += "end ;\n/"
    return ret_text


def make_sql_nobinds(sql_text):
    if "?" in sql_text:
        # ハテナを変換する処理
        sql_text_nosemi = remove_last_semicolon(sql_text)
        sql_nobinds_text = replace_all_question_mark(sql_text_nosemi)
        plsql_text = add_plsql_text(sql_nobinds_text)
        return plsql_text
    elif re.search(":[0-9]+", sql_text):
        sql_text_nosemi = remove_last_semicolon(sql_text)
        sql_nobinds_text = replace_all_colon(sql_text_nosemi)
        plsql_text = add_plsql_text(sql_nobinds_text)
        return plsql_text
    else:
        # もしバインド変数がなかったらそのまま返す
        print('There are no binds.')
        return sql_text


def save_text(bind_sql_text, filename):
    with open(filename, 'w') as f:
        f.write(bind_sql_text)


def make_parse():
    """About arguments"""
    p = argparse.ArgumentParser(
        description="Replace bind values in sql.(ex. ':1' => 'b1', '?' => 'b1'")
    p.add_argument("-s", "--sql",
                   type=str,
                   help="File name of sql",
                   required=True)
    return p


def main_for_cui():
    # read filename from console
    parser = make_parse()
    args = parser.parse_args()
    if args.sql:
        # read files
        sql_text = read_file(args.sql)
        sql_nobinds_text = make_sql_nobinds(sql_text)
        save_text(sql_nobinds_text, "q00.sql")
        print("Make q00.sql.")


def main_for_gui():
    # for GUI
    FILENAME_SQL = "before.sql"
    FILENAME_OUTPUT = "q00.sql"
    sql_text = read_file(FILENAME_SQL)
    sql_nobinds_text = make_sql_nobinds(sql_text)
    save_text(sql_nobinds_text, FILENAME_OUTPUT)


if __name__ == '__main__':
    main_for_cui() # change name for cui or gui
