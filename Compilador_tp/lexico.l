%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "y.tab.h"
#include "constantes.h"

%}

%option noyywrap
%option yylineno
OP_RESTA        ["-"]
OP_SUMA         ["+"]
OP_MULT         ["*"]
OP_DIV          ["/"]
DIGITO			[0-9]
LETRA			[a-zA-Z]
OTRO            .
ESPACIO         [" "]

ID				{LETRA}({LETRA}|{DIGITO}|_)*

A_COMENTARIO	"-/"
C_COMENTARIO	"/-"
CONTENIDO		({LETRA}+|{DIGITO}+|{ESPACIO})*
COMENTARIO 		{A_COMENTARIO}{CONTENIDO}{C_COMENTARIO}	
COMENT_ANIDADO  {A_COMENTARIO}({OTRO}*{COMENTARIO}+{OTRO}*){C_COMENTARIO}	

CARACTER        [a-z,A-Z,0-9,=,>,<,!,:,+,\-,*,/,@]
TEXTO           "\""({CARACTER}+|{ESPACIO})*"\""

INT             {DIGITO}+
FLOAT           {DIGITO}*"."{DIGITO}*|0
OP_NOT			["NOT"|"not"]

%%
"-"				{return RESTA;}
"+"				{return SUMA;}
"*"				{return MULTIPLICACION;}	
"/"				{return DIVISION;}

INT             {return INT;}
FLOAT           {return FLOAT;}
STRING          {return STRING;}

DECVAR			{return DECVAR;}
ENDDEC			{return ENDDEC;}

WRITE           {return WRITE;}
READ            {return READ;}
"NOT"           { return OP_NOT;}
"not"           { return OP_NOT;}

while			{return WHILE;}
if				{return IF;}
else			{return ELSE;}
AVG				{return AVG;}

{ID}			{ 
                    if (strlen(yytext) > COTA_ID) {
                        printf( "El nombre del identificador supera la cantidad maxima permitida. Cantidad: %d\n", COTA_ID);
                        exit(1);
                    } 
					strcpy(yylval.s,yytext);
                    printf( "Identificador en lexico: %s\n",yylval.s);
                    return ID;
                }

{COMENT_ANIDADO}    { printf("Comentario anidado en el lexico\n");}
{COMENTARIO}        { printf("Comentario en el lexico\n");}

{TEXTO}		    {   
                    if (strlen(yytext) > COTA_STR) {
                        printf( "El string ingresado supera la cantidad maxima permitida. Cantidad: %d\n", COTA_STR);
                        exit(1);
                    }
					strcpy(yylval.s,yytext);
                    return T_STRING;                
                }

{INT}	        {
                    if (atoi(yytext) > COTA_INT_INF && atoi(yytext) < COTA_INT_SUP) {
                        strcpy(yylval.s,yytext); 
                        return T_ENTERO;
                    }
                        printf( "El entero ingresado supera la cantidad maxima permitida.\n");
                        exit(1);
                }

{FLOAT}         {
                    if (atof(yytext) > COTA_FLOAT_SUP && atof(yytext) < COTA_FLOAT_INF) {
                        printf( "El flotante ingresado supera la cantidad maxima permitida.\n");
                        exit(1);
                    }  
                    strcpy(yylval.s,yytext);
                    return T_FLOAT;
                }


	
"("				{return P_ABIERTO;}	
")"				{return P_CERRADO;}
"["				{return C_ABIERTO;}
"]"				{return C_CERRADO;}
"{"				{return LL_ABIERTA;}	
"}"				{return LL_CERRADA;}
":="			{return ASIG;}
":"				{return DP;}
";"				{return P_COMA;}
","				{return COMA;}
">"				{return MAYOR;}
">="			{return MAYOR_IGUAL;}
"<"				{return MENOR;}
"<="			{return MENOR_IGUAL;}
"=="			{return IGUAL;}
"!="			{return DISTINTO;}
"&&"			{return AND;}
"||"			{return OR;}

"\n"      		
"\t"
"\r"
{ESPACIO}
{OTRO}   { printf("Caracter invalido!");  exit(1);}
%%
