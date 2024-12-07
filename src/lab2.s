# Хорошко Е.М. ЗКИ21-БBB, Лабораторная работа 1.2,  вариант 12
# "12. программа вычисляет выражение y = y1/y2;
# y1 = 15+x, если x > 7, |a| + 9, если x<=7;"
# y2 = 3, если x>2, |x| - 5, если x <= 2;
# "Program calculates y = y1/y2"
# "Input number: x = "
# "Input number: a = "
# "y = "
#TODO операции с числами с плавающей точкой. Деление, сложение, вычитание. Считывание из строки, преобразование в строку выполняются в функциях printf, scanf
#TODO реализовать очистку экрана clrscr()

.file "lab2.s" # имя файла (необязательно)
.section	.rodata

	msg: .ascii "Program calculates y = y1/y2\n"
	msg_arg_x: .ascii "Input number: x = "
	msg_arg_a: .ascii "Input number: a = "
	msg_div_by_zero: .ascii "Error: division by zero\n"
	msg_res: .ascii "y = "
	f:  .string "%d" 	# форматный спецификатор .double
.data
	num2: .double 2.0 
	num3: .double 3.0  
	num5: .double 5.0
	num7: .double 7.0
	num9: .double 9.0
	num15: .double 15.0
	
	x: .double 0
	a: .double 0
	result: .double 0
	  
	
	
.text
.global main
main:
	movq %rsp, %rbp 	# сохраняем начальное значение указателя стека в rbp
	
	# выведем строку msg на экран
	movq $1, %rax 		# sys_write
	movq $1, %rdi 		# стандартная консоль
	movq $msg, %rsi 	# адрес начала строки
	movq $29, %rdx 	# кол-во выводимых символов
	syscall
	
	# выведем строку msg_arg_x на экран
	movq $1, %rax 		# write
	movq $1, %rdi 		# стандартная консоль
	movq $msg_arg_x, %rsi 	# адрес начала строки
	movq $18, %rdx 	# кол-во выводимых символов
	syscall
	
		
	push %rbp           	# keep stack aligned
    	mov  $0, %eax       	# clear AL (zero FP args in XMM registers)
    	leaq f(%rip), %rdi  	# load format string
    	leaq x(%rip), %rsi  	# set storage to address of x
    	call scanf		# считаем число в переменную x
   	pop %rbp		
				
	# выведем строку msg_arg_a на экран
	movq $1, %rax 		# write
	movq $1, %rdi 		# стандартная консоль
	movq $msg_arg_a, %rsi 	# адрес начала строки
	movq $18, %rdx 	# кол-во выводимых символов
	syscall
	
		
	push %rbp           	# keep stack aligned
    	mov  $0, %eax       	# clear AL (zero FP args in XMM registers)
    	leaq f(%rip), %rdi  	# load format string
    	leaq a(%rip), %rsi  	# set storage to address of a
    	call scanf		# считаем число в переменную a
   	pop %rbp		
	
	
	# выполним вычисление y = y1/y2 при следующих параметрах:
	# y1 = 15+x, если x > 7, |a| + 9, если x<=7;
	# y2 = 3, если x>2, |x| - 5, если x <= 2;
	
	movq $9, %rcx		# TODO задаем сетчик цикла, проверить регистр
	
main_loop:
	#вычислим у2
	fld $x 	# st(1) = x	# FPU	
	fld $num2 	# st(0) = 2.0
	fcomip %st(0), %st(1)      # сравнивает ST(0) и ST(1), устанавливает биты состояния FLAGS и извлекает верхний элемент (ST(0)) из стека. 
    	jnb arg2       # если st(0) >= st(1), 2 >= x или x<=2
    	fstp st(0)	# удалить x из st(0)
	fld $num3 	# st(0) = 3 = y2 		
	arg2:
	fabs		# st(0) = |x|
    	fsub $num5 	# st(0) = |x|-5 = y2 
	
	#вычислим у1
	fld $x		# st(1) = x
	fld $num7	# st(0) = 7.0
	fcomip %st(0), %st(1) 
	jnb arg1       # если st(0) >= st(1), x<=7
	fld $num1 	# st(0) = 15.0, st(1) = x
	fadd 		# st(0) = 15 + x = y1
	arg1:
	fstp st(0)	# удалить x
	fld $a
	fabs st(0)	#|a|
	fadd $num9	#|a| + 9 = st(0) = y1

	#выполнить деление у1/у2 # st(0) = 0, st(1) = y1, st(2) = y2		
	fld $0
	fcomip %st(2)		# ftst проверка на ноль в делителе
	je div_by_zero
	fdivr			# st(0) = st(0)/st(1)
	fstp $result
	
	#вывести на экран
	jmp res
	
	div_by_zero: 		# вывод сообщения об ошибке msg_div_by_zero
		movq $1, %rax 			# sys_write
		movq $1, %rdi 			# std<<cout
		movq $msg_div_by_zero, %rsi 	# адрес начала строки
		movq $24, %rdx 		# кол-во выводимых символов
		syscall
		
		jmp exit		#завершение программы
		
	res:
	
##############################################################################	

	#выполнить деление
	movq $0, %rdx		# очистим регистр rdx - необязательно, далее перед делением
	cmpq $0, %rbx		# проверка на ноль в делителе
	je div_by_zero
	movq $0, %rdx		# обнулить rdx перед делением (для положительных чисел важно)
	cmpq $0, %rax 		# проверить, отрицательное ли делимое
	jge div1		# если делимое >= 0, выполняем деление
		notq %rdx	#  если делимое < 0 - инвертировать биты в rdx
	div1:
	idiv %rbx		# выполним целочисленное деление для чисел со знаком  -x/y
	movq %rax, %r13	# сохраним промежуточный результат в регистр %r13
	movq %rdx, %r9		# сохраним остаток от деления в r9 - необязательно
	
##############################################################################
	#вывести на экран
	jmp res
	
	div_by_zero: 		# вывод сообщения об ошибке msg_div_by_zero
		movq $1, %rax 		# write
		movq $1, %rdi 		# std<<cout
		movq $msg_div_by_zero, %rsi 	# адрес начала строки
		movq $24, %rdx 		# кол-во выводимых символов
		syscall
		
		jmp exit		#завершение программы
		
	res:
	# выведем строку "y = "  на экран
	subq $8, %rsp           # выравнивание должно быть по 16 байтам
    	movq $msg_res, %rdi     # первый параметр функции printf - строка форматирования
    	call printf
    	addq $8, %rsp
    	
    	subq $8, %rsp           # выравнивание должно быть по 16 байтам
    	movq $msg_res, %rdi     # первый параметр функции printf - строка форматирования
    	call printf
    	addq $8, %rsp
    	
##############################################################################
	# выделим 1 байт на стеке для символа перевода строки
	subq $1, %rsp 		# резерв для символа конца строки
	movb $10, 0(%rsp)	 # "\n" в %rsp
	
	# преобразование результата вычисления в строку и сохранение его в стек
	xorq %rbx, %rbx	# очистим регистр %rbx
	movq $10, %rbx 	# система счисления - десятичная
	movq $5, %rcx 		# счетчик длинны строки от 5ти , т.к. добавится "\n" + "z = ", 1+4
	
	movq $ret2, %rdi
	jmp to_str_proc
	ret2:
	
	
##############################################################################	

	# выведем результат на экран
	printf #TODO
	 
	# уменьшить счетчик, проверить выход из цикла
	subq $1, %rcx		
	cmpq $0, %rcx
	jz exit
	# увеличить x на 1
	
	jmp main_loop

exit:	
	ret
	

	
