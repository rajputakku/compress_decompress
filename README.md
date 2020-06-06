# README

The server exposes a POST api with path /api/v1/files.
It expects a query parameter 'mode' whose value can be 'compress' / 'decompress'
It also expects the file as 'multipart/form-data' inside a parameter 'file'.

Based on whether the mode is compress/decompress, it will compress/decompress the file and return the new file.

Example request:

1. Compression:
    curl -v -X POST -F 'file=@file.txt' http://localhost:3000/api/v1/files?mode=compress -OJ

    Input: file.txt -> aaaabbbbcc
    Output: compress_file.txt -> 4a4b2c

2. Decompression:
    curl -v -X POST -F 'file=@compress_file.txt' http://localhost:3000/api/v1/files?mode=decompress -OJ

    Input: file.txt -> 4a4b2c
    Output: compress_file.txt -> aaaabbbbcc