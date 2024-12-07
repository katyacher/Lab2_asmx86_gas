#!/bin/sh
gcc -c src/scanf_float_printf.s -o obj/scanf_float_printf.o 
gcc obj/scanf_float_printf.o -o exec/scanf_float_printf
