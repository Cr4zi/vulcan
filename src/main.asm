%include "src/macros.inc"

%define WORD_LENGTH 32          ; assuming a word as at most 32 bytes
%define PC r15
%define W r14
%define rstack r13
%define SAVED_RSP r12

global _start

extern find_word

extern exit
extern print_string
extern print_newline
extern string_length
extern read_word
extern print_int
extern cfa
extern parse_int

native ".S", prints
  xor rcx, rcx
.loop:
  lea r8, [rsp + 8 * rcx]
  cmp SAVED_RSP, r8
  je .end
  
  mov rdi, [r8]
  push rcx
  call print_int
  call print_newline
  pop rcx
  
  inc rcx
  jmp .loop
.end:
  jmp next

native "+", plus
  pop rax
  add [rsp], rax
  
  jmp next

native "-", minus
  pop rax
  sub [rsp], rax
  
  jmp next
  
native "*", mul
  pop rax
  pop rcx
  imul rax, rcx
  push rax

  jmp next

native "/", div
  pop rax
  pop rcx
  
  xor rdx, rdx
  idiv rcx
  
  push rax

native "=", equals
  pop rax
  pop rcx
  
  cmp rax, rcx
  jne .not_equals
  
  push 1
  jmp next

.not_equals:
  push 0
  jmp next

native "<", less_than
  pop rax
  pop rcx
  cmp rcx, rax
  jl .less_than
  
  push 0
  jmp next

.less_than:
  push 1
  jmp next

native "and", logic_and
  pop rax
  pop rcx
  
  and rax, rcx
  test rax, rax
  jz .zero

  push 1
  jmp next

.zero:
  push 0
  jmp next

native "not", logic_not
  pop rax
  test rax, rax
  jz .zero
  
  push 0
  jmp next
.zero:
  push 1
  jmp next

section .rodata
read_err_msg: db "Couldn't read word", 0

unknown_word_msg: db "Unknown word", 0

section .bss
word_buff: resb WORD_LENGTH 
resq 1023
rstack_start: resq 1

section .data
program_stub: dq 0
xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop

section .text
init:
  xor PC, PC
  xor W, W
  mov rstack, rstack_start
  ret
  
next: 
  mov W, [PC]                   ; W = execution token
  add PC, 8                     ; Next execution token
  jmp [W]

interpreter_loop:
  mov rdi, word_buff
  mov rsi, WORD_LENGTH
  call read_word
  test rax, rax                 ; if didn't read correctly
  je .read_err
  
  mov al, byte [rdi]            ; if first character is 0 then word is empty
  test al, al
  je .end

  mov rdi, word_buff
  mov rsi, NATIVE_HEAD          ; we'll do colon later
  call find_word
  test rax, rax
  je .number

  mov rdi, rax
  call cfa

  mov [program_stub], rax       ; [program_stub] = addr of execution token
  mov PC, program_stub
  jmp next

.number:
  call parse_int
  test rdx, rdx                 ; if length is zero
  je .unknown_word
  
  push rax                      ; pushing number onto the stack
  
  jmp interpreter_loop
.unknown_word:
  mov rdi, unknown_word_msg
  call print_string
  call print_newline
  jmp interpreter_loop

.read_err:
  mov rdi, read_err_msg
  call print_string
  call print_newline

.end:
  mov rdi, 0
  call exit

_start:
  call init
  
  mov SAVED_RSP, rsp

  jmp interpreter_loop
