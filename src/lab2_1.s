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
    num2: .double 2.0 
    num3: .double 3.0  
    num5: .double 5.0
    num7: .double 7.0
    num9: .double 9.0
    num15: .double 15.0
    x: .double .0
    a: .double .0
    result: .double .0

    msg: .ascii "Program calculates y = y1/y2\n"
    msg_arg_x: .ascii "Input number: x = "
    msg_arg_a: .ascii "Input number: a = "
    msg_div_by_zero: .ascii "Error: division by zero\n"
    msg_res: .ascii "y = %lf\0 "
    s: .string "\n"
    Lc0: .ascii "%lf\0" # форматная строка спецификатор .double с нулевым байтом 
    Lc1: .ascii "x = %lf\0" 
    Lc2: .ascii "a = %lf\0" 
    Lc3: .ascii "%s"
		
.text
.global main

main:
	movq %rsp, %rbp 	# сохраняем начальное значение указателя стека в rbp
	subq $32, %rsp    
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
	
		
         	# keep stack aligned
    	leaq Lc0(%rip), %rdi 	# адрес начала форматной строки
    	leaq x(%rip), %rsi	# адрес сохранения введённой строки
    	movq $1, %rax		# кол-во регистров xmmn
    	callq scanf 		# вызов функции scanf
   			
				
	# выведем строку msg_arg_a на экран
	movq $1, %rax 		# write
	movq $1, %rdi 		# стандартная консоль
	movq $msg_arg_a, %rsi 	# адрес начала строки
	movq $18, %rdx 	# кол-во выводимых символов
	syscall
	
		
	         	# keep stack aligned
    	movq  $1, %rax       	# clear AL (zero FP args in XMM registers)
    	leaq Lc0(%rip), %rdi  	# адрес начала форматной строки
    	leaq a(%rip), %rsi  	# адрес сохранения введённой строки
    	call scanf		# считаем число в переменную a
   			
    	
	# выполним вычисление y = y1/y2 при следующих параметрах:
	# y1 = 15+x, если x > 7, |a| + 9, если x<=7;
	# y2 = 3, если x>2, |x| - 5, если x <= 2;
	xorq %rcx, %rcx
	movq $9, %rcx	# TODO задаем сетчик цикла, проверить регистр

#FPU
	#вычислим у2
	finit
	fldl x 	# st(1) = x	
	fldl num2 	# st(0) = 2.0
	#fcomip %st(0), %st(1)      # сравнивает ST(0) и ST(1), устанавливает биты состояния FLAGS и извлекает верхний элемент (ST(0)) из стека. 
	fcomp 
	fstsw ax 
	sahf
    	jnb arg2       # если st(0) >= st(1), 2 >= x или x<=2
    	fstp %st(0)	# удалить x из st(0)
	fldl num3 	# st(0) = 3 = y2 		
	arg2:
	fabs		# st(0) = |x|
    	fsubl num5 	# st(0) = |x|-5 = y2 
    	fstpl result
    	
    subq $8, %rsp           # выравнивание должно быть по 16 байтам
    movq $msg_res, %rdi     # "y = "  форматная строка
    movq result(%rip), %xmm0
    movq $1, %rax 	     # кол-во регистров xmmn
    call printf
    addq $8, %rsp
    	
    	 
    leaq Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		# само выводимое значение \n
    callq printf		# вызов функции printf
    
exit:
movq %rbp, %rsp 	
    ret

