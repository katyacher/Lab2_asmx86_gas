#!/bin/sh
gcc -c src/lab2.s -o obj/lab2.o -no-pie
gcc -no-pie obj/lab2.o -o exec/lab2
