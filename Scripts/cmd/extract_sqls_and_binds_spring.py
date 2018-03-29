#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Description
Script for extracting SQL and binds from Spring log
(ex: "2018-01-15 18:14:58.449 DEBUG 15473 --- [           main] j.c.a.w.d.q.m.e.C.selectCB900040         : ==> Parameters: AAA(String), BBB..."
"""

"""Requirement
python 2.7

extract_sqls_spring_log.py
extract_binds_spring_log.py
"""

"""Usage
$ python extract_sqls_and_binds_spring.py -l hoge.log

outputs:
  origin<n>.sql
  binds<n>.sql
  * <n>: 0.....
"""

import argparse
from extract_sqls_spring_log import extract_sqls
from extract_binds_spring_log import extract_some_binds

def read_file(filename):
    with open(filename) as f:
        raw_text = f.read()
        return raw_text
    return None


def extract_sqls_and_binds_spring(log):
    extract_sqls(log)
    extract_some_binds(log)
    print("Make SQL and binds.")


def make_parse():
    """About arguments"""
    p = argparse.ArgumentParser(
        description="Extract SQLs and binds from spring log.")
    p.add_argument("-l", "--logfile",
                   type=str,
                   help="Filename of log",
                   required=True)
    return p


def main():
    parser = make_parse()
    args = parser.parse_args()
    if args.logfile:
        logfile_text = read_file(args.logfile)
        extract_sqls_and_binds_spring(logfile_text)
    print("End !")


if __name__ == '__main__':
    main()
