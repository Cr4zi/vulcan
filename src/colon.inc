%define LIST_HEAD 0

%macro colon 2
%2:
  dq LIST_HEAD
  db %1, 0
  
%define LIST_HEAD %2
%endmacro