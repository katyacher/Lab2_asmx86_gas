.file "main.s"
.global main

.data
    x: .double 0.0
    .balign 8
    a: .double 0.0
    .balign 8
    num3: .double 3.0
     .balign 8
    num5: .double 5.0
      .balign 8
    num2: .double 2.0
      .balign 8
      
    s: .string "\n"
    .Lc0: .ascii "%lf %lf\0" 	# форматная строка с нулевым байтом в конце строки
    .Lc1: .ascii "x = %f\0" 
    .Lc2: .ascii "a = %f\0" 
    .LcY: .ascii "y = %f\0"
    .Lc3: .ascii "%s"
.text
  
main:
    xorq %rdi,%rdi
    xorq %rsi,%rsi
    
    pushq %rbp 		# для выравнивания стека по 16-байтовой границе
    movq %rsp, %rbp 		# для создания фрейма стека ф-ии main
    
    subq $48, %rsp 		# выделить в стеке 32 байта перед вызовом функции
    
    leaq .Lc0(%rip), %rdi 	# адрес начала форматной строки
    leaq x(%rip), %rsi		#адрес сохранения введённой строки
    leaq a(%rip), %rdx	 	#адрес сохранения введённой строки
    movq $2, %rax
    callq scanf 		# вызов функции scanf
    
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
    
   
   

	#вычислим у2
	finit
	fld num2 	# st(0) = 2.0
	fld x	# st(1) = x	
#	fcomip %st, %st(1)      # сравнивает ST(0) и ST(1), устанавливает биты состояния FLAGS и извлекает верхний элемент (ST(0)) из стека. 
	fcomp  	# извлекает верхний элемент st(0) = 2
	fstsw %ax 
	sahf
   	jnb arg2       # если st(0) >= st(1), 2 >= x или x<=2
   	fstp %st(0)	# удалить x из st(0)
	fldl num3 	# st(0) = 3 = y2 		
	arg2:
	fabs		# st(0) = |x|
    	fsubl num5 	# st(0) = |x|-5 = y2 
    	fstp x
    	
#	#вычислим у1	st(2) = y2
#	fldl x		# st(1) = x
#	fldl num7	# st(0) = 7.0
#	#fcomipl %st(0), %st(1) 
#	fcomp 
#	fstsw ax 
#	sahf
#	jnb arg1       # если st(0) >= st(1), x<=7
#	fldl num1 	# st(0) = 15.0, st(1) = x
#	faddp 		# st(0) = 15 + x = y1
#	arg1:
#	fstp %st(0)	# удалить x
#	fldl a
#	fabs		#|a|
#	fldl num9
#	faddp 		#|a| + 9 = st(0) = y1

#	#выполнить деление у1/у2 # st(0) = 0, st(1) = y1, st(2) = y2		
#	fldl null
#	#fcomipl %st(2)		# ftst проверка на ноль в делителе
#	fcomp 
#	fstsw ax 
#	sahf
#	je div_by_zero
#	fdivrp			# st(0) = st(0)/st(1)
#	fstpl result
	
#	#вывести на экран
#	jmp res
	
#	div_by_zero: 		# вывод сообщения об ошибке msg_div_by_zero
#		movq $1, %rax 			# sys_write
#		movq $1, %rdi 			# std<<cout
#		movq $msg_div_by_zero, %rsi 	# адрес начала строки
#		movq $24, %rdx 		# кол-во выводимых символов
#		syscall
#		
#		jmp exit		#завершение программы
		

    


    leaq .Lc1(%rip), %rdi 	# адрес начала форматной строки
    movq x(%rip), %xmm0	# само выводимое значение y = 
    callq printf		#вызов функции printf
    
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		#само выводимое значение \n
    callq printf		#вызов функции printf
	 
exit:	
 movq %rbp, %rsp	#освобождение стека функции main
    
    popq %rbp		# восстановление регистра %rbp
mov $0, %eax
retq

		
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
