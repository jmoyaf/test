#!/usr/bin/env python
# -*- coding: UTF-8 -*-

filename = '/root/scripts/passwol.txt'
separator=" "

for line in open(filename, 'r'):
    data = line.split(separator)

u = data[0]
p = data[1]