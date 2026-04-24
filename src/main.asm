%include "src/macros.inc"

global _start

extern find_word

extern exit
extern print_string
extern print_newline
extern string_length

section .rodata
  colon "third word", third_word
  db "third word explanation", 0
  
  colon "second word", second_word
  db "second word explanation", 0
  
  colon "first word", first_word
  db "first word explanation", 0

section .data
    my_word: db "first word", 0

section .text
_start:
  mov rdi, my_word
  mov rsi, first_word
  call find_word
  
  test rax, rax
  je .end

  lea rdi, [rax + 8]
  call string_length

  lea rdi, [rdi + rax + 1]
  call print_string
  call print_newline
.end:  
  mov rdi, 0
  call exit
