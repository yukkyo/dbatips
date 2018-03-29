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
$ python extract_binds_from_springlog.py -l hoge.log

outputs:
  bind.sql
"""


import argparse
import re

# example => "b401	VARCHAR2(32) := 'AAAAA';"
BINDS_PATTERN = r"b[1-9][0-9]*.+;(\n)?"
REPATTER = re.compile(BINDS_PATTERN)

LENGTH_VARCHAR = 180  # Please define this parameter

# TODO: もしかしたら lowercase 前提にした方が安全かもしれない
# DEFAULT 値対応 => UNKNOWN

"""About data type mapping
https://docs.oracle.com/cd/E82638_01/JJDBC/accessing-and-manipulating-Oracle-data.htm#GUID-1AF80C90-DFE6-4A3E-A407-52E805726778
"""
MAP_TYPE_JAVA_TO_SQL = {
    # Default Java Type
    "STRING":"VARCHAR2(" + str(LENGTH_VARCHAR) + ")",
    "BIGDECIMAL":"NUMBER",
    "BOOLEAN":"NUMBER",
    "BYTE":"NUMBER",
    "SHORT":"NUMBER",
    "INT":"NUMBER",
    "LONG":"NUMBER",
    "FLOAT":"NUMBER",
    "DOUBLE":"NUMBER",
    "BYTE[]":"NUMBER",
    "DATE":"DATE",
    "TIME":"DATE",
    "TIMESTAMP":"TIMESTAMP",  # ここは要チェック 要件によっては DATE かもしれない
    "BLOB":"BLOB",
    "CLOB":"CLOB",
    "ROWID":"ROWID",
    "NCLOB":"NCLOB",
    # JDBC Code without default javatype
    "CHAR":"CHAR",
    "VARCHAR":"VARCHAR2(" + str(LENGTH_VARCHAR) + ")",
    "LONGVARCHAR":"LONG",
    "NUMERIC":"NUMBER",
    "DECIMAL":"NUMBER",
    "BIT":"NUMBER",
    "TINYINT":"NUMBER",
    "SMALLINT":"NUMBER",
    "INTEGER":"NUMBER",
    "BIGINT":"NUMBER",
    "REAL":"NUMBER",
    "BINARY":"RAW",
    "VARBINARY":"RAW",
    "LONGBINARY":"LONGRAW",
    # Oracle Extension Java Type
    "NUMBER":"NUMBER",
    "RAW":"RAW",
    "ORACLEBLOB":"BLOB",
    "ORACLECLOB":"CLOB"
}


def read_file(filename):
    with open(filename) as f:
        raw_text = f.read()
        return raw_text


def extract_parameters(log_text):
    PARAMS_TEXT = "Parameters: "
    for line in (log_text.split('\n')):
        if PARAMS_TEXT in line:
            return line.split(PARAMS_TEXT)[1].split(', ')
    raise Exception("No parameters in log !")


def convert_value_to_text(value, type_sql):
    if "VARCHAR2" in type_sql:
        return "'" + value + "'"   # rpadding する
    elif type_sql == "NUMBER":
        return value
    elif type_sql == "TIMESTAMP":
        return "to_timestamp('" + value  + "', 'yyyy-mm-dd hh24:mi:ss.ff3')"
    elif type_sql == "DATE":
        # value example: 2011-08-23 00:00:00.0
        if "." in value:
            value_tmp = value.split(".")[0]
        else:
            value_tmp = value
        return "to_date('" + value_tmp + "', 'yyyy-mm-dd hh24:mi:ss')"
    elif type_sql in ["BINARY_FLOAT", "BINARY_DOUBLE"]:
        return value
    else:
        return value

def convert_param_to_bind(param_text, bind_num):
    """
    * example of param
    'HO26-4(String)', '19992325135(BigDecimal)'
    * example of outputs
       b1 VARCHAR2(32)    := 'HO26-4' ;
       b2 NUMBER          := 19992325135 ;
    """
    ret_text = ("b" + str(bind_num)).ljust(8)
    # TODO: 値の NULL チェック対応
    splited_text = param_text[0:-1].split('(')  # 値が NULL じゃない前提
    value = splited_text[0]
    
    # print(value[0].upper())
    
    if value.upper() == 'NUL':
        return ret_text + "NULL ;\n"
    type_java = splited_text[1].upper()
    type_sql = MAP_TYPE_JAVA_TO_SQL[type_java]
    ret_text += type_sql.ljust(20)
    ret_text += ":= "
    ret_text += convert_value_to_text(value, type_sql)
    ret_text += " ;\n"
    return ret_text


def extract_binds_from_spring_log(log_text):
    ret_text = ""
    params_text = extract_parameters(log_text)
    for bind_num, param_text in enumerate(params_text):
        ret_text += convert_param_to_bind(param_text, bind_num + 1)
    return ret_text


def make_parse():
    """About arguments"""
    p = argparse.ArgumentParser(
        description="Extract bind values from exec plan.")
    p.add_argument("-l", "--logfile",
                   type=str,
                   help="File name of log",
                   required=True)
    return p


def save_text(text, filename):
    with open(filename, 'w') as f:
        f.write(text)


def test():
    sql_text = read_file("./rm12124.log")
    a = extract_binds_from_spring_log(sql_text)
    print(a)


def extract_some_binds(logfile):
    logs = logfile.split("Parameters: ")[1:]  # [0] is not including parameters
    logs_new = ["Parameters: " + log for log in logs]
    for i, log in enumerate(logs_new):
        binds_text = extract_binds_from_spring_log(log)
        save_text(binds_text, "bind" + str(i+1) + ".sql")
    print("Make bind.sql")


def main():
    parser = make_parse()
    args = parser.parse_args()
    if args.logfile:
        logfile_text = read_file(args.logfile)
        extract_some_binds(logfile_text)
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

