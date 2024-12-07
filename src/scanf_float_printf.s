.file "main.s"
.section .rodata
    .Lc0: .ascii "%lf %lf\0" # форматная строка с нулевым байтом в конце строки
    .Lc1: .ascii "x = %f\0" 
    .Lc2: .ascii "a = %f\0" 
    .Lc3: .ascii "%s\0"
    
.data
    x: .float .0
    a: .float .0
    s: .string "\n"
.text
  
.global main
main:
    xorq %rdi,%rdi
    xorq %rsi,%rsi
    
    pushq %rbp 	# для выравнивания стека по 16-байтовой границе
    movq %rsp, %rbp 	# для создания фрейма стека ф-ии main
    
    subq $32, %rsp 		# выделить в стеке 32 байта перед вызовом функции
    
    leaq .Lc0(%rip), %rdi 	# адрес начала форматной строки
    leaq x(%rip), %rsi		#адрес сохранения введённой строки
    leaq a(%rip), %rdx	 	#адрес сохранения введённой строки
    movq $2, %rax
    callq scanf 		# вызов функции scanf
    
    leaq .Lc1(%rip), %rdi 	# адрес начала форматной строки
    movq x(%rip), %rsi		#само выводимое значение x = 
    callq printf		#вызов функции printf
    
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		#само выводимое значение \n
    callq printf		#вызов функции printf
    
    leaq .Lc2(%rip), %rdi 	# адрес начала форматной строки
    movq a(%rip), %rsi		#само выводимое значение a = 
    callq printf		#вызов функции printf
    
    leaq .Lc3(%rip), %rdi 	# адрес начала форматной строки
    leaq s(%rip), %rsi		#само выводимое значение \n
    callq printf		#вызов функции printf
    
    movq %rbp, %rsp	#освобождение стека функции main
    
    popq %rbp		# восстановление регистра %rbp
    mov $0, %eax
    retq
   
   

