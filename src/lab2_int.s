# Хорошко Е.М. ЗКИ21-БBB, Лабораторная работа 1.2,  вариант 12
# "12. программа вычисляет выражение y = y1/y2;
# y1 = 15+x, если x > 7, |a| + 9, если x<=7;"
# y2 = 3, если x>2, |x| - 5, если x <= 2;
# "Program calculates y = y1/y2"
# "Input number: x = "
# "Input number: a = "
# "y = "
#TODO операции с числами с плавающей точкой. Деление, сложение, вычитание. Считывание из строки, преобразование в строку

.file "lab2.s" # имя файла (необязательно)
.data
	msg: .ascii "Program calculates y = y1/y2\n"
	msg_arg_x: .ascii "Input number: x = "
	msg_arg_a: .ascii "Input number: a = "
	msg_div_by_zero: .ascii "Error: division by zero\n"
	
	num15: .double 15.0
	num9: .double 9.0
	num3: .double 3.0
	num5: .double 5.0
	num2: .double 2.0
	num7: .double 7.0
	x: .double ?
	a: .double ?
	
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
	
		
	call scanf		# считаем строку и преобразуем x из символа в число 
				# в %xmm0 результат выполнения процедуры
	
	fmovd %xmm0, %xmm1	# сохраним x в регистре %xmm1  
	
	# выведем строку msg_arg_a на экран
	movq $1, %rax 		# write
	movq $1, %rdi 		# стандартная консоль
	movq $msg_arg_a, %rsi 	# адрес начала строки
	movq $18, %rdx 	# кол-во выводимых символов
	syscall
	
		
	call scanf		# считаем строку и преобразуем a из символа в число
				# в %xmm0 результат выполнения процедуры
	
	fmovd %xmm0, $a_const	# сохраним константу а в переменную (сегмент данных)
	
	# выполним вычисление y = y1/y2 при следующих параметрах:
	# y1 = 15+x, если x > 7, |a| + 9, если x<=7;
	# y2 = 3, если x>2, |x| - 5, если x <= 2;
	
	movq $9, %rcx		# TODO задаем сетчик цикла, проверить регистр
main_loop:
#вычислить y2 - сохранить
	movq $0, %rax		# очистим регистр rax
	cmpq $2, %r12		# выполним проверку условия  x <= 2
	jbe arg2		# если выполняется x <= 2, переходим в метку arg2
	movq $3, %rbx		# если не выполняется x <= 2(т.е. x > 2) %rbx = 3 = y2 
	arg2:			# 
	movq %r12, %rax	# переместим x в rax
	# модуль rax		# |x| TODO как вычислить модуль
	subq $5, %rax		# |x| - 5
	movq %rax, %rbx	# Сохраним y2 в регистре %rbx
	
	#вычислить y1
	movq $0, %rax		# очистим регистр rax
	cmpq $7, %r12		# выполним проверку условия  x <= 7
	jbe arg1		# если выполняется x <= 7, переходим в метку arg2
	movq %r12, %rax	# если не выполняется x <= 7(т.е. x > 7)
	addq $15, %rax		# x + 15
	arg1:			# 
	movq $a_const, %rax	# переместим a_const в %rax
	# модуль rax		# |a| TODO как вычислить модуль
	addq $9, %rax		# |a| + 9 = y1
	
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
	
	# добавим строку "y = " в стек для вывода на экран
	subq $1, %rsp
	movb $32, 0(%rsp)	# запишем символ пробел " "
	subq $1, %rsp
	movb $61, 0(%rsp)	# запишем символ "="
	subq $1, %rsp
	movb $32, 0(%rsp)	# запишем символ пробел " "
	subq $1, %rsp
	movb $122, 0(%rsp)	# запишем символ  "z"


	# выведем результат на экран
	movq $0, %rdx
	movq $1, %rax 		# write
	movq $1, %rdi 		# cout
	movq %rsp, %rsi 	# адрес начала строки - в стеке сохранен результат z
	movq %rcx, %rdx 	# кол-во выводимых символов
	syscall
	
	#увеличить счетчик, проверить выход из цикла
	subq $1, %rcx		#TODO проверить регистр для счетчика
	cmpq $0, %rcx
	jz exit
	jmp main_loop

exit:	
	ret
	
