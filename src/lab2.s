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
.global main
.data

    x: .double 0
    .balign 16
    a: .double 0
    .balign 16
    result: .double 0
    .balign 16
    num0: .double 0.0
    .balign 16
    num2: .double 2.0 
    .balign 16
    num3: .double 3.0  
    .balign 16
    num5: .double 5.0
    .balign 16
    num7: .double 7.0
    .balign 16
    num9: .double 9.0
    .balign 16
    num15: .double 15.0
    .balign 16
    num1: .double 1.0
    .balign 16
    msg: .ascii "Program calculates y = y1/y2\n"
    msg_arg_x: .ascii "Input number: x = "
    msg_arg_a: .ascii "Input number: a = "
    msg_div_by_zero: .ascii "Error: division by zero\n"
    msg_res: .ascii "y = %lf\0 "
    s: .string "\n"
    .Lc0: .ascii "%lf\0" # форматная строка спецификатор .double с нулевым байтом 
    .Lc1: .ascii "x = %lf \0" 
    .Lc2: .ascii "a = %lf \0" 
    .Lc3: .ascii "%s"
		
.text

main:
    pushq %rbp 
    movq %rsp, %rbp 	# сохраняем начальное значение указателя стека в rbp
  
    # выведем строку msg на экран
    movq $1, %rax 		# sys_write
    movq $1, %rdi 		# стандартная консоль
    movq $msg, %rsi 		# адрес начала строки
    movq $29, %rdx 		# кол-во выводимых символов
    syscall
	
    # выведем строку msg_arg_x на экран
    movq $1, %rax 		# write
    movq $1, %rdi 		# стандартная консоль
    movq $msg_arg_x, %rsi 	# адрес начала строки
    movq $18, %rdx 		# кол-во выводимых символов
    syscall
		
   # pushq %rbp           	# keep stack aligned
    leaq .Lc0(%rip), %rdi 	# адрес начала форматной строки
    leaq x(%rip), %rsi		# адрес сохранения введённой строки
    movq $1, %rax		# кол-во регистров xmmn
    callq scanf 		# вызов функции scanf
    #popq %rbp		
				
    # выведем строку msg_arg_a на экран
    movq $1, %rax 		# write
    movq $1, %rdi 		# стандартная консоль
    movq $msg_arg_a, %rsi 	# адрес начала строки
    movq $18, %rdx 		# кол-во выводимых символов
    syscall
		
   # pushq %rbp           	# keep stack aligned
    movq  $1, %rax       	# clear AL (zero FP args in XMM registers)
    leaq .Lc0(%rip), %rdi  	# адрес начала форматной строки
    leaq a(%rip), %rsi  	# адрес сохранения введённой строки
    call scanf			# считаем число в переменную a
   # popq %rbp		
    
    # выполним вычисление y = y1/y2 при следующих параметрах:
    # y1 = 15+x, если x > 7, |a| + 9, если x<=7;
    # y2 = 3, если x>2, |x| - 5, если x <= 2;
    xorq %rcx, %rcx
    movq $9, %rcx	# задаем сетчик цикла
    movq %rcx, %r15

   	
main_loop:
    #вычислим у2
    finit
    fldl num5	#st(2) = 5.0
    fldl x 	# st(1) = x
    fldl num2 	# st(0) = 2.0
    #fcomip %st(0), %st(1)      # сравнивает ST(0) и ST(1), устанавливает биты состояния FLAGS и извлекает верхний элемент (ST(0)) из стека. 
    fcomp
    xorq %rax, %rax
    fstsw  %ax 
    sahf
    jge arg2       	# если st(0) > st(1),  x<=2
    fabs		# st(0) = |x|
    fsubp %st(0), %st(1)		# st(0) = |x|-5 = y2 
    jmp y1		
    arg2:
    finit
    #fstp %st(0)	# удалить x из st(0)
    #fstp %st(0)	# удалить 5 из st(0)
    fldl num3 		# st(0) = 3 = y2 
    
  
    y1:
    #вычислим у1	st(2) = y2
    fldl x		# st(1) = x
    fldl num7	# st(0) = 7.0
    fcomp 
    xorq %rax, %rax
    fstsw %ax 
    sahf
    jge arg1       	# если st(0) >= st(1), x<=7
    fstp %st(0)	# удалить x
    fldl a
    fabs		#|a|
    fldl num9
    faddp %st(0), %st(1)	#|a| + 9 = st(0) = y1
    jmp div1
    arg1:
    fldl num15			# st(0) = 15.0, st(1) = x
    faddp  %st(0), %st(1)	# st(0) = 15 + x = y1
   
 				
    div1:
    #выполнить деление у1/у2 # st(0) = 0, st(1) = y1, st(2) = y2		
    fldl num0
    # ftst проверка на ноль в делителе
    fcomp %st(2) 
    xorq %rax, %rax 
    fstsw %ax 
    sahf
    jz div_by_zero
    fdiv %st(1), %st(0)			# st(1) = st(0)/st(1)
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

    # выведем результат на экран	
    res:
    # выведем на экран переменные
   # pushq %rbp
   # movq %rsp, %rbp 	# сохраняем начальное значение указателя стека в rbp
   # pushq %rcx  	
    xorq %rax, %rax
    movq $1, %rax              #1 регистр xmm0
    leaq .Lc1(%rip), %rdi 	# адрес начала форматной строки
    movq x(%rip), %rsi		#само выводимое значение x = 
    callq printf		#вызов функции printf
    #addq  $8, %rsp
   # popq  %rcx 
    
   # pushq %rcx              # сохранить регистр
   # pushq $s  # напечатать символ новой строки     
   # call  printf
    #addq  $8, %rsp
   # popq  %rcx             #восстановить регистр             
 m1:
   # pushq %rcx   
    xorq %rax, %rax
    leaq .Lc2(%rip), %rdi 	# адрес начала форматной строки
    movq a(%rip), %rsi	# само выводимое значение a = 
    callq printf		#вызов функции printf
    #addq  $8, %rsp          # выровнять стек  
    #popq  %rcx             #восстановить регистр             
 
   
    # выведем на экран результат
   # pushq %rbp
    #movq %rsp, %rbp
    #subq $8, %rsp           # выравнивание должно быть по 16 байтам
    #pushq %rcx 
    xorq %rax, %rax
    leaq msg_res(%rip), %rdi     # "y = "  форматная строка
    movq $1, %rax 	    	 # кол-во регистров xmmn
    movq result(%rip), %rsi
    call printf
    #addq  $8, %rsp          # выровнять стек  
    #popq  %rcx 
    
    #pushq %rcx 
    xorq %rax, %rax
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		# само выводимое значение \n
    callq printf		# вызов функции printf
   # addq  $8, %rsp          # выровнять стек   
   # popq %rcx 
    
   # movq %rbp, %rsp 	# восстанавливаем стек
    #popq %rbp
    
m:# для отладки  
   
    # уменьшить счетчик, проверить выход из цикла
    #movq $1, %rcx
    subq $1, %r15		
    cmpq $0, %r15
    je exit
    finit	
    fldl x 	# st(1) = x
    fld1	# st(0) = 1
    faddp %st(0), %st(1) 	# st(0) = x + 1  увеличить x на 1
    fstpl x			# сохранить в x
    jmp main_loop		# перейти на начало цикла

exit:	
    movq %rbp, %rsp
    movq $60, %rax 	# exit
    movq $0, %rdi
    syscall
