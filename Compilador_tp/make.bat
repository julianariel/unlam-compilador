bison -dyv sintactico.y
flex lexico.l
gcc.exe lex.yy.c y.tab.c pila.c -o segunda.exe

echo Ejecutando pruebas!
segunda.exe Pruebas.txt
pause
