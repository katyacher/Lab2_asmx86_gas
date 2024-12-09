#!/bin/sh
gcc -c src/try3.s -o obj/try3.o -no-pie
gcc -no-pie obj/try3.o -o exec/try3
