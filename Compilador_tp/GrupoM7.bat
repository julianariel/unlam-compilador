"C:\Program Files (x86)\GUI Turbo Assembler\BIN\tasm" /la /zi Final.asm
REM tasm /la /zi bin\numbers.asm
"C:\Program Files (x86)\GUI Turbo Assembler\BIN\tlink" /3 Final.obj numbers.obj /v /s /m
del FINAL.OBJ
del FINAL.MAP
del FINAL.LST