#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Description
Script for extracting bind values from Spring log
(ex: "2018-01-15 18:14:58.449 DEBUG 15473 --- [           main] j.c.a.w.d.q.m.e.C.selectCB900040         : ==> Parameters: AAA(String), BBB..."
"""

"""Requirement
python 2.7
"""

"""Usage
$ python extract_sqls_spring_log.py -l hoge.log

outputs:
  origin_<n>.sql
  * <n>: 0.....
"""

import argparse

SQL_TEXT_START = " Preparing: "

def read_file(filename):
    with open(filename) as f:
        raw_text = f.read()
        return raw_text
    return None


def extract_sql(log_txt):
    for line in (log_txt.split('\n')):
        if SQL_TEXT_START in line:
            return line.split(SQL_TEXT_START)[1] + '\n'
    raise Exception("No SQL in log !")


def extract_sqls(logfile):
    logs = logfile.split(SQL_TEXT_START)[1:]  # [0] is not including parameters
    logs_new = [SQL_TEXT_START + log for log in logs]
    for i, log in enumerate(logs_new):
        sql_text = extract_sql(log)
        save_text(sql_text, "origin" + str(i+1) + ".sql")
    print("Make origin.sql")


def make_parse():
    """About arguments"""
    p = argparse.ArgumentParser(
        description="Extract sqls from spring log.")
    p.add_argument("-l", "--logfile",
                   type=str,
                   help="Filename of log",
                   required=True)
    return p


def save_text(text, filename):
    with open(filename, 'w') as f:
        f.write(text)

def main():
    parser = make_parse()
    args = parser.parse_args()
    if args.logfile:
        logfile_text = read_file(args.logfile)
        extract_sqls(logfile_text)
    print("End !")
        
# old
# def main():
#     # read filename from console
#     parser = make_parse()
#     args = parser.parse_args()
#     if args.logfile:
#         """実行計画(バインド変数込み)"""
#         logfile_text = read_file(args.logfile)
#         binds_text = extract_binds_from_spring_log(logfile_text)
#         save_text(binds_text, "bind.sql")
#     print("Make bind.sql")


if __name__ == '__main__':
    # test()
    main()

