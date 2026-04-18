global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global read_char
global read_word
global parse_uint
global parse_int
global string_equals
global string_copy

section .text

;; uses rdi as input
exit:
  mov rax, 60
  syscall

;; rdi holds an addr to a null terminated string
string_length:
  xor rax, rax
.iteration:
  cmp byte[rdi + rax], 0
  je .end
  inc rax
  jmp .iteration
.end:
  ret
	
;; rdi holds an addr to null terminated string
print_string:	
  call string_length
  mov rdx, rax                  ; count
  mov rsi, rdi
  
  mov rax, 1                    ; syscall write
  mov rdi, 1                    ; fd stdout
  syscall
  ret
  
;; rdi holds an char
print_char: 
  push rdi

  mov rsi, rsp
  mov rax, 1                    ; syscall write
  mov rdi, 1                    ; stdout
  mov rdx, 1                    ; count of 1
  syscall

  pop rax                       ; register doesn't really matter
  ret

print_newline:  
  mov rdi, 0xA
  jmp print_char

;; rdi holds an unsigned int
print_uint:
  cmp rdi, 0
  jne .print

  mov rdi, 0x30                 ; ASCII for '0'
  call print_char
  ret
.print:
  sub rsp, 32
  mov rcx, 31

  mov byte [rsp + rcx], 0       ; null terminator

  mov rax, rdi
.loop:
  cmp rax, 0
  je .end

  mov r8, 10
  xor rdx, rdx
  div r8                        ; rax /= 10, rdx = rax % 10
  
  dec rcx
  add rdx, 0x30
  mov [rsp + rcx], dl           ; lower part of rdx

  jmp .loop
.end:
  lea rdi, [rsp + rcx]
  call print_string
  add rsp, 32
  
  ret

;; rdi an a signed int
print_int:
  cmp rdi, 0
  jge print_uint
  
  push rdi
  mov rdi, 0x2d                 ; ASCII for '-'
  call print_char
  pop rdi

  neg rdi
  jmp print_uint
  
read_char:  
  sub rsp, 1

  mov rax, 0                    ; sys_read
  mov rdi, 0                    ; stdin
  lea rsi, [rsp]                ; pretty sure could also do mov rsi, rsp
  mov rdx, 1                    ; count
  syscall
  
  mov al, byte [rsi]
  add rsp, 1
  ret

;; rdi holds a buffer addr, rsi holds buffer length
read_word:
  xor r12, r12
  dec rsi
.loop:
  cmp r12, rsi                  ; rcx ? length
  je .err                       ; err ...
  
  push rdi
  push rsi
  call read_char                ; rax = char
  pop rsi
  pop rdi

  cmp rax, 0x20
  je .end
  cmp rax, 0x9
  je .end
  cmp rax, 0x0A
  je .end

  mov byte [rdi], al

  inc rdi
  inc r12
  jmp .loop
.err:                           ; if we read the whole buffer size
  mov rax, 0
  ret
.end:
  mov byte [rdi], 0                    ; null terminate
  ret

;; rdi is a null terminated string
parse_uint:
  xor rax, rax
  xor rcx, rcx
  
  mov r8, 10                    ; for multiplication later
.loop:
  mov r9b, byte[rdi + rcx]
  cmp r9, 0
  je .end

  ;; if r9 < '0' || r9 > '9' finish
  cmp r9, 0x30
  jl .end
  cmp r9, 0x39
  jg .end

  sub r9, 0x30                  ; digit char to int

  xor rdx, rdx
  mul r8                        ; rax * 10
  add rax, r9                   ; (rax * 10) + int

  inc rcx
  jmp .loop
.end:
  mov rdx, rcx
  ret
  
;; rdi is a null terminated string
parse_int:
  cmp byte [rdi], 0x2d               ; ASCII for -
  jne parse_uint
  
  lea rdi, [rdi + 1]
  call parse_int
  
  neg rax
  inc rdx
  ret
  
;; rdi and rsi are pointers to null terminated strings
string_equals:
  xor rcx, rcx
.loop:
  mov al, byte [rdi + rcx]
  mov ah, byte [rsi + rcx]
  
  cmp al, ah
  jne .not_equal
  
  test al, al
  je .equal

  inc rcx
  jmp .loop
.equal:
  mov rax, 1
  ret
.not_equal:
  mov rax, 0
  ret

;; rdi - src, rsi - dst, rdx - dst len
string_copy:
  xor rcx, rcx
  
  test rdx, rdx
  je .end

.loop:
  cmp rcx, rdx
  je .done
  
  cmp byte[rdi + rcx], 0
  je .done

  mov al, byte[rdi + rcx]
  mov byte[rsi + rcx], al

  inc rcx
  jmp .loop
.done:
  mov byte[rsi + rcx], 0
  mov rax, rsi
  ret
.end:
  mov rax, 0
  ret
