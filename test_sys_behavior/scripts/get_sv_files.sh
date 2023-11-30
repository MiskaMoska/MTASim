#!/bin/bash

directory="../rtl"

# 递归获取所有子目录中的 .sv 文件名
find "$directory" -type f -name "*.sv" | while read -r file; do
    echo "$file"
done