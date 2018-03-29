#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Requirement
python 2.7
"""

"""Usage
$ python all_convet_binds_in_sql.py

outputs:
  q00_n.sql
"""

from convert_binds_in_sql import read_file, make_sql_nobinds, save_text
import os

FILENAME = "origin"

def main():
    files = os.listdir(".")
    for f in files:
        if FILENAME in f and ".sql" in f:
            i = int(f.split(".")[0][len(FILENAME):])
            sql_text = read_file(f)
            sql_nobinds_text = make_sql_nobinds(sql_text, i)
            filename = "q00_" + str(i) + ".sql"
            save_text(sql_nobinds_text, filename)
    print("all file converted")

if __name__ == '__main__':
    main()


