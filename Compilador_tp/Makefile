all: compilador

compilador.tab.c compilador.tab.h: sintactico.y
	bison -dyv sintactico.y

lex.yy.c: lexico.l compilador.tab.h
	flex lexico.l

compilar: lex.yy.c compilador.tab.c compilador.tab.h
	gcc -o compilador.exe lex.yy.c y.tab.c
probar: compilar
	./compilador.exe Pruebas.txt
clean:
	rm compilador.exe lex.yy.c 

