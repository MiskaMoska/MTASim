#!/bin/bash

# 读取文本文件内容
while IFS= read -r line; do

  # 提取 parameter int 后面的变量名
  if [[ $line =~ parameter[[:space:]]+int[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
    echo "'${BASH_REMATCH[1]}',"
  fi

  # 提取 parameter bit 后面的变量名
  if [[ $line =~ parameter[[:space:]]+bit[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
    echo "'${BASH_REMATCH[1]}',"
  fi

  # 提取 parameter string 后面的变量名
  if [[ $line =~ parameter[[:space:]]+string[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
    echo "'${BASH_REMATCH[1]}',"
  fi

done