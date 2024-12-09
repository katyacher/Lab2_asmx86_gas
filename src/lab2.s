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

.data
    num0: .double 0.0
    .balign 8
    num2: .double 2.0 
     .balign 8
    num3: .double 3.0  
     .balign 8
    num5: .double 5.0
     .balign 8
    num7: .double 7.0
   .balign 8
    num9: .double 9.0
     .balign 8
    num15: .double 15.0
     .balign 8
     num1: .double 1.0
	 .balign 8
    x: .double 0
    .balign 8
    a: .double 0
     .balign 8
    result: .double 0
 .balign 8
    msg: .ascii "Program calculates y = y1/y2\n"
    msg_arg_x: .ascii "Input number: x = "
    msg_arg_a: .ascii "Input number: a = "
    msg_div_by_zero: .ascii "Error: division by zero\n"
    msg_res: .ascii "y = %lf\0 "
    s: .string "\n"
    .Lc0: .ascii "%lf\0" # форматная строка спецификатор .double с нулевым байтом 
    .Lc1: .ascii "x = %lf\0" 
    .Lc2: .ascii "a = %lf\0" 
    .Lc3: .ascii "%s"
		
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
    	leaq .Lc0(%rip), %rdi 	# адрес начала форматной строки
    	leaq x(%rip), %rsi	# адрес сохранения введённой строки
    	movq $1, %rax		# кол-во регистров xmmn
    	callq scanf 		# вызов функции scanf
   	pop %rbp		
				
	# выведем строку msg_arg_a на экран
	movq $1, %rax 		# write
	movq $1, %rdi 		# стандартная консоль
	movq $msg_arg_a, %rsi 	# адрес начала строки
	movq $18, %rdx 	# кол-во выводимых символов
	syscall
	
		
	push %rbp           	# keep stack aligned
    	movq  $1, %rax       	# clear AL (zero FP args in XMM registers)
    	leaq .Lc0(%rip), %rdi  	# адрес начала форматной строки
    	leaq a(%rip), %rsi  	# адрес сохранения введённой строки
    	call scanf		# считаем число в переменную a
   	pop %rbp		
    
	# выполним вычисление y = y1/y2 при следующих параметрах:
	# y1 = 15+x, если x > 7, |a| + 9, если x<=7;
	# y2 = 3, если x>2, |x| - 5, если x <= 2;
	xorq %rcx, %rcx
	movq $9, %rcx	# TODO задаем сетчик цикла, проверить регистр
	
	finit
	fld x 	# st(1) = x
# FPU		
main_loop:
	#вычислим у2
	
	fld num2 	# st(0) = 2.0
		
	#fcomip %st(0), %st(1)      # сравнивает ST(0) и ST(1), устанавливает биты состояния FLAGS и извлекает верхний элемент (ST(0)) из стека. 
	fcomp 
	fstsw  %ax 
	sahf
    	jnb arg2       # если st(0) >= st(1), 2 >= x или x<=2
    	fstp %st(0)	# удалить x из st(0)
	fld num3 	# st(0) = 3 = y2 		
	arg2:
	fabs		# st(0) = |x|
    	fsub num5 	# st(0) = |x|-5 = y2 
    	
	#вычислим у1	st(2) = y2
	fldl x		# st(1) = x
	fldl num7	# st(0) = 7.0
	#fcomipl %st(0), %st(1) 
	fcomp 
	fstsw %ax 
	sahf
	jnb arg1       # если st(0) >= st(1), x<=7
	fadd num15 	# st(0) = 15.0, st(1) = x
	 		# st(0) = 15 + x = y1
	arg1:
	fstp %st(0)	# удалить x
	fldl a
	fabs		#|a|
	fadd  num9	#|a| + 9 = st(0) = y1
			

	#выполнить деление у1/у2 # st(0) = 0, st(1) = y1, st(2) = y2		
	fldl num0
	#fcomipl %st(2)		# ftst проверка на ноль в делителе
	fcomp 
	fstsw %ax 
	sahf
	je div_by_zero
	fdivr st, st(1)			# st(0) = st(0)/st(1) ??
	fstpl result
	
	#вывести на экран
	jmp res
	
	div_by_zero: 		# вывод сообщения об ошибке msg_div_by_zero
		movq $1, %rax 			# sys_write
		movq $1, %rdi 			# std<<cout
		movq $msg_div_by_zero, %rsi 	# адрес начала строки
		movq $24, %rdx 		# кол-во выводимых символов
		syscall
		
		jmp exit		#завершение программы
		
##############################################################################	
#
#	#выполнить деление - отрицательные числа ???
#	movq $0, %rdx		# очистим регистр rdx - необязательно, далее перед #делением
#	cmpq $0, %rbx		# проверка на ноль в делителе
#	je div_by_zero
#	movq $0, %rdx		# обнулить rdx перед делением (для положительных чисел #важно)
#	cmpq $0, %rax 		# проверить, отрицательное ли делимое
#	jge div1		# если делимое >= 0, выполняем деление
#		notq %rdx	#  если делимое < 0 - инвертировать биты в rdx
#	div1:
#	idiv %rbx		# выполним целочисленное деление для чисел со знаком  -#x/y
#	movq %rax, %r13	# сохраним промежуточный результат в регистр %r13
#	movq %rdx, %r9		# сохраним остаток от деления в r9 - необязательно
#	
##############################################################################
    # выведем результат на экран	
    res:
    # выведем на экран переменные
     push %rbp  	
    xorq %rax, %rax
    leaq .Lc1(%rip), %rdi 	# адрес начала форматной строки
    movq x(%rip), %xmm0	#само выводимое значение x = 
    movq $1, %rax
    callq printf		#вызов функции printf
    
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		#само выводимое значение \n
    callq printf		#вызов функции printf
    
    leaq .Lc2(%rip), %rdi 	# адрес начала форматной строки
    movq a(%rip), %xmm0	# само выводимое значение a = 
    callq printf		#вызов функции printf
    
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		#само выводимое значение \n
    callq printf		#вызов функции printf
    pop %rbp
    
    
    # выведем на экран результат
    subq $8, %rsp           # выравнивание должно быть по 16 байтам
    movq $msg_res, %rdi     # "y = "  форматная строка
    movq $1, %rax 	     # кол-во регистров xmmn
    call printf
    addq $8, %rsp
   
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		# само выводимое значение \n
    callq printf		# вызов функции printf

	 
    # уменьшить счетчик, проверить выход из цикла
    subq $1, %rcx		
    cmpq $0, %rcx
    jz exit
    # увеличить x на 1
    fldl x 	# st(1) = x
    fadd num1 	#fld1   	# st(0) = x + 1
    # сохранить в x
    # fstp x
    # перейти на начало цикла
    jmp main_loop

exit:	
    ret
