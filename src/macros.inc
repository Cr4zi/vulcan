%define COLON_HEAD 0

%macro colon 2
%2:
  dq COLON_HEAD
  db %1, 0
  
%define COLON_HEAD %2
%endmacro

%define NATIVE_HEAD 0

%macro native 3
section .data
w_%2:
  dq NATIVE_HEAD
  db %1, 0
  db %3                         ; flags
xt_%2:
  dq %2_impl

section .text
%2_impl:
%define NATIVE_HEAD w_%2

section .text
%2_impl:
%endmacro

;; since most words won't need flags
%macro native 2
native %1, %2, 0
%endmacro
