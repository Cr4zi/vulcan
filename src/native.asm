%define NATIVE_HEAD 0

%macro native 3
section .data
w_%2:
  dq NATIVE_HEAD
  db %1, 0
  db %3                         ; flags
xt_%2:
  dq %2_impl

%define NATIVE_HEAD w_%2

section .text
%2_impl:
%endmacro

;; since most words won't need flags
%macro native 2
native %1, %2, 0
%endmacro

extern string_length

section .text
;; Code From Address
;; rdi - start of an header
cfa:
  lea rdi, [rdi + 8]            ; skip the NATIVE_HEAD
  call string_length

  lea rax, [rdi + rax + 2]      ; + 1 skip null terminator and another one
                                ; to skip flags
  
  ret
