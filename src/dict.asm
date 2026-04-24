;; this is more like a linked list, not actually a dictionary
  
extern string_equals
extern string_length

global find_word

section .text

;; rdi - pointer to a null terminated string - key, rsi - pointer to the last word in the dictionary
find_word:
.loop:
  test rsi, rsi                 ; if rsi == 0
  je .not_found                 ; we got to the end of the linked list, thus we didn't find the word

  push rsi
  lea rsi, [rsi + 8]            ; we need rsi to hold the key 
  call string_equals
  pop rsi

  test rax, rax                 ; string_equals returns 1 if both strings are equal
  jne .found

  mov rsi, [rsi]                ; mov to the next node
  jmp .loop
.found:
  mov rax, rsi
  ret
.not_found:
  mov rax, 0
  ret

;; Code From Address
;; rdi - start of an header
cfa:
  lea rdi, [rdi + 8]            ; skip the NATIVE_HEAD
  call string_length

  lea rax, [rdi + rax + 2]      ; + 1 skip null terminator and another one
                                ; to skip flags
  
  ret
