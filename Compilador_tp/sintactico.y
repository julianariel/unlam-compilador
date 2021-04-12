%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <math.h>
#include <string.h>
#include <ctype.h>
#include "y.tab.h"
#include "tercetos.h"
#include "ts.h"
#include "validacion.h"
#include "asm.h"

char *yytext;
FILE  *yyin;
extern int yylex();
void yyerror(char *msg);
int contCte = 0;
%}

%union {
	char s[20];
}

%token <s>ID
%token DECVAR
%token ENDDEC
%token ASIG 

%token MAYOR
%token MAYOR_IGUAL
%token MENOR
%token MENOR_IGUAL
%token IGUAL
%token DISTINTO   

//Asociatividad
%left SUMA RESTA
%left MULTIPLICACION DIVISION

%token AVG

%token INT 
%token FLOAT
%token STRING

%token T_ENTERO
%token T_FLOAT
%token T_STRING

%token IF
%token ELSE
%token WHILE

%token C_ABIERTO      
%token C_CERRADO
%token LL_ABIERTA
%token LL_CERRADA
%token P_ABIERTO 
%token P_CERRADO
%token DP
%token P_COMA
%token COMA

%token AND
%token OR
%token OP_NOT

%token READ 
%token WRITE
%%

raiz:
	{
		char _cte[50] = "&aux2";
		saveSymbol(_cte, "float", "-", '&');
		crear_terceto_(_cte);
		sprintf(_cte, "&aux3");
		saveSymbol(_cte, "float", "-", '&');
		crear_terceto_(_cte);

		sprintf(_cte, "&contAVG");
		saveSymbol(_cte, "float", "-", '&');
		sprintf(_cte, "&cantAVG");
		saveSymbol(_cte, "float", "-", '&');

	} 
	programa 
	{
		printf("Generando Tabla de Simbolos\n");
		symbolTableToHtml(symbolTable,"ts.html");
		printf("Generando GCI\n");
		generarIntermedia();		
		generarASM();
		printf("->COMPILACION OK<-\n");
	};

programa: sentencias;

sentencias:	sentencias sent | sent;

sent: {crear_terceto_("ETIQUETA");}asignacion|promedio
		|declaracion|decision|{crear_terceto_("ETIQUETA");}iteracion|{crear_terceto_("ETIQUETA");}entrada_salida;

asignacion:
			ID ASIG expresion
			{
				//printf("77777777 yytext:%s  yylval.s:%s $1:%s\n",yytext,yylval.s,$1);
				//TS
				validarDefinicionVariable($1);
				symbol id = getSymbol($1);		
				validarTipos(id.tipo);
				saveSymbol($1,id.tipo,"-", '_');
				//Tercetos
				asigIndice = crear_terceto___(":=",id.nombre,expIndice);
				printf("ASIGNACION SIMPLE\n");				
			}
			|ID ASIG asignacion
			{
				//TS
				validarDefinicionVariable($1);
				symbol id = getSymbol($1);
				validarTipos(id.tipo);
				saveSymbol($1,id.tipo,"-", '_');				
				//Tercetos
				expIndice = crear_terceto_(_cte);
				asigIndice = crear_terceto___(":=",id.nombre,expIndice);
				
				printf("ASIGNACION MULTIPLE\n");
			}
			|ID ASIG promedio
			{
				validarDefinicionVariable($1);
				symbol id = getSymbol($1);
				validarTipos(id.tipo);
				saveSymbol($1,id.tipo,"-", '_');				
				//Tercetos
				asigIndice = crear_terceto___(":=",id.nombre,avgInd);
			}
			;		

promedio:
        AVG	P_ABIERTO C_ABIERTO formato_promedio C_CERRADO P_CERRADO									
        {		
			char valor[50];
			
			if(esExpresion)
			{
				cantAVG+=acuAvg;				
				//contAVG++;
			}
			
			esExpresion = 0;
			
			int auxAvgInd = avgInd;

			sprintf(valor, "%d", contAVG);

			contCte++;
			
			sprintf(_cte, "&cte%d", contCte);
			saveSymbol(_cte, "int", valor, '&');
			avgInd = crear_terceto_(_cte);
			//avgInd = crear_terceto_(valor);
			crear_terceto___(":=","&contAVG",avgInd);

			int divInd;
			avgInd = crear_terceto_("&cantAvg");
			divInd = crear_terceto_("&contAvg");
			avgInd = crear_terceto__("/", avgInd, divInd);
		}
		;

formato_promedio:
                tipo_dato_promedio
					{
					//Generacion de la suma en tercetos
					if(esExpresion == 0)
					{
						//avgInd = crear_terceto_("&cantAVG");
						char valor[50];
						cantAVG = atof(yylval.s);
						sprintf(valor, "%.2f", cantAVG);

						contCte++;
						
						sprintf(_cte, "&cte%d", contCte);
						saveSymbol(_cte, "int", valor, '&');
						avgInd = crear_terceto_(_cte);

					}
					//else
					//	avgInd = crear_terceto___(":=","&cantAVG",avgInd);
					int cteInd;
					cteInd = crear_terceto_("&cantAVG");
					avgInd = crear_terceto__("+",avgInd,cteInd);
					avgInd = crear_terceto___(":=","&cantAVG",avgInd);

					contAVG++;
					}
				|tipo_dato_promedio
					{
					//Generacion de la suma en tercetos
					if(esExpresion == 0)
					{
						//avgInd = crear_terceto_("&cantAVG");
						char valor[50];
						cantAVG=atof(yylval.s);
						sprintf(valor, "%.2f", cantAVG);

						contCte++;
						
						sprintf(_cte, "&cte%d", contCte);
						saveSymbol(_cte, "int", valor, '&');
						avgInd = crear_terceto_(_cte);

						
					}
					//else
					//	avgInd = crear_terceto___(":=","&cantAVG",avgInd);
					int cteInd;
					cteInd = crear_terceto_("&cantAVG");
					avgInd = crear_terceto__("+",avgInd,cteInd);
					avgInd = crear_terceto___(":=","&cantAVG",avgInd);

					contAVG++;
					}  
				COMA formato_promedio
	;
				
tipo_dato_promedio:
					T_ENTERO							{printf("AVG-INT\n");}   
					|T_FLOAT							{printf("AVG-FLOAT\n");}
					|expresion							{esExpresion = 1; printf("AVG-EXPRESION\n");}
		;

declaracion:
            DECVAR declaraciones ENDDEC
			{saveIdType();printf("BLOQUE DECLARACION\n");}
			;	
declaraciones:
                declaraciones formato_declaracion
				|formato_declaracion
				;
formato_declaracion:
                    ID DP tipo_dato											    
					{
						validarLongitudId(yylval.s);
						saveId(yylval.s);
						printf("DECLARACION SIMPLE\n");
					}
					|ID COMA formato_declaracion								
					{
						validarLongitudId($1);
						symbol idTipo = getSymbol($1);
						saveId($1);
						saveType(idTipo.tipo);
						printf("DECLARACION MULTIPLE\n");
					}
					;
tipo_dato:
        INT																	    {saveType("int");printf("INT\n");}
		|FLOAT																	{saveType("float");printf("FLOAT\n");}
		|STRING																	{saveType("string");printf("STRING\n");}
		;	

decision:
		IF OP_NOT P_ABIERTO condiciones P_CERRADO LL_ABIERTA sentencias LL_CERRADA	{
																				isNot=1;
																				modificarSalto(nroTerceto + 1, desapilar());
																				isNot=0;
																				auxDesapilar = desapilar();
																				if(auxDesapilar == -1)
																					modificarSalto(nroTerceto + 1, desapilar());
																				else
																					apilar(auxDesapilar);
																				printf("IF con NOT\n");
																				}
		| IF P_ABIERTO condiciones P_CERRADO LL_ABIERTA sentencias LL_CERRADA	{
																				modificarSalto(nroTerceto + 1, desapilar());
																				auxDesapilar = desapilar();
																				if(auxDesapilar == -1)
																					modificarSalto(nroTerceto + 1, desapilar());
																				else
																					apilar(auxDesapilar);
																				printf("IF\n");
																				}
		|IF P_ABIERTO condiciones P_CERRADO LL_ABIERTA sentencias LL_CERRADA ELSE {
																				crear_terceto_("JMP");
																				modificarSalto(nroTerceto + 1, desapilar());				
																				auxDesapilar = desapilar();
																				if(auxDesapilar == -1)
																					modificarSalto(nroTerceto + 1, desapilar());
																				else
																					apilar(auxDesapilar);
																				apilar(nroTerceto);
																				}
		LL_ABIERTA sentencias LL_CERRADA	{modificarSalto(nroTerceto + 1, desapilar());printf("IF-ELSE\n");}
		|IF OP_NOT P_ABIERTO condiciones P_CERRADO LL_ABIERTA sentencias LL_CERRADA ELSE {
																				isNot=1;																				
																				crear_terceto_("JMP");
																				modificarSalto(nroTerceto + 1, desapilar());	
																				isNot=0;			
																				auxDesapilar = desapilar();
																				if(auxDesapilar == -1)
																					modificarSalto(nroTerceto + 1, desapilar());
																				else
																					apilar(auxDesapilar);
																				apilar(nroTerceto);
																				}
		LL_ABIERTA sentencias LL_CERRADA	{modificarSalto(nroTerceto + 1, desapilar());printf("IF-ELSE CON OPERADOR NOT\n");}
	;

	iteracion:
			WHILE P_ABIERTO   
				{
				 apilar(nroTerceto+1);
				}
				condiciones P_CERRADO LL_ABIERTA sentencias LL_CERRADA	
				{
					crear_terceto_("JMP"); /*aca habria que desapilar para saber donde empezo la condicion para volver a ejecutarla*/
					modificarSalto(nroTerceto + 1,desapilar());//terceto de la condicion ante un falso
					auxDesapilar = desapilar();
					if(auxDesapilar == -1)
					{
					    modificarSalto(nroTerceto + 1, desapilar());
					}
					else
					{
					    apilar(auxDesapilar);
					}
					modificarSalto(desapilar()-1, nroTerceto); //salto incondicional al inicio del while
					printf("WHILE\n");
				}
			;

entrada_salida:
		READ ID 
		{
			printf("-----Regla de lectura de entrada READ\n");
			symbol id = getSymbol($2);
			crear_terceto___("READ", id.nombre, -1);
		}
		|WRITE ID 
		{	
			printf("-----Regla de escritura de salida WRITE de variable\n");
			symbol id = getSymbol($2);
			crear_terceto___("WRITE", id.nombre, -1);
			
		}
		|WRITE tipo 
		{
			printf("-----Regla de escritura de salida WRITE de constante\n");
			crear_terceto__("WRITE", facIndice, -1);
		}
		;

condiciones: 
            condicion 
                { 				
                condMulIndice = crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto);
                apilar(nroTerceto);
                }
            |condicion AND 
                {							
                crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto); //salto si es falso
                apilar(nroTerceto);
                apilar(-1); //para indicar que hubo and y tenemos que desapilar dos veces en algunos casos
                }
            condicion 					
                { 				
                crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto); //salto si es falso
                apilar(nroTerceto);
                }
            |condicion OR 
                {								
                crear_terceto__(obtenerSalto(0), condMulIndice, nroTerceto); //salto si es verdadero
                apilar(nroTerceto);
                }
            condicion 
                { 
                crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto); //salto si es falso
                modificarSalto(nroTerceto + 1, desapilar());
                apilar(nroTerceto);
                }
            |C_ABIERTO condicion P_CERRADO
                { 
                condMulIndice = crear_terceto__(obtenerSalto(0), condMulIndice, nroTerceto);
                apilar(nroTerceto);
                }
            ;								

condicion: 
            expresion operador_comparacion
            {
				condIndice = expIndice;
            }
            expresion 
            {
                condMulIndice = crear_terceto__("CMP", condIndice, expIndice);
                printf("\nCONDICION"); 
            }
            ;

operador_comparacion:
                    IGUAL 
                    { 
					//printf("6666666 yytext:%s  yylval.s:%s \n",yytext,yylval.s);
                        operacionLogica = IGUAL;
                        printf("\nComparador: IGUAL\n"); 
                    }| 
                    MENOR 
                    { 
                        operacionLogica = MENOR;
                        printf("\nComparador: MENOR\n"); 
                    }| 
                    MAYOR 
                    { 
                        operacionLogica = MAYOR;
                        printf("\nComparador: MAYOR\n"); 
                    }| MAYOR_IGUAL
                    { 
                        operacionLogica = MAYOR_IGUAL;
                        printf("\nComparador: MAYOR_IGUAL\n"); 
                    }| 
                    MENOR_IGUAL
                    { 
                        operacionLogica = MENOR_IGUAL;
                        printf("\nComparador: MENOR_IGUAL\n"); 
                    }| 
                    DISTINTO 
                    { 
                        operacionLogica = DISTINTO;
                        printf("\nComparador: DISTINTO\n"); 
                    } 
				;	

expresion:
        expresion RESTA termino
		{
			expIndice = crear_terceto__("-", expIndice, terIndice);
			//acuAvg-=atof(yylval.s);
			esExpresion = 1;
			avgInd = expIndice;
			printf("RESTA\n");
		}
		|expresion SUMA {acuAvg+=atof(yylval.s);} termino
		{
			expIndice = crear_terceto__("+", expIndice, terIndice);
			acuAvg+=atof(yylval.s);
			esExpresion = 1;
			avgInd = expIndice;
			printf("SUMA\n");
		}
		|termino																
		{
			expIndice = terIndice;
			printf("TERMINO\n");
		}
		;									

termino:
        termino MULTIPLICACION {acuAvg+=atof(yylval.s);}factor														
		{
			terIndice = crear_terceto__("*", terIndice, facIndice);
			acuAvg*=atof(yylval.s);
			esExpresion = 1;
			avgInd = terIndice;
			printf("MULTIPLICACION\n");
		}
		|termino DIVISION {acuAvg+=atof(yylval.s);}factor														
		{
			terIndice = crear_terceto__("/", terIndice, facIndice);
			acuAvg/=atof(yylval.s);
			esExpresion = 1;
			avgInd = terIndice;
			printf("DIVISION\n");
		}
		|factor																	
		{
			/*float x = atof(yylval.s);
			int x_entero = (int) x;
			
			if(x - x_entero) // Sobra un valor en decimal del tipo 0.resto
			{
			   printf("Es FLOTANTE\n");
			   insertarTipo("float");
			}
			else if(x == 0.0)
			{
			   printf("ES STRING\n");
			   insertarTipo("string");
			}
			else{
			   printf("Es ENTERO\n");
			   insertarTipo("int");				
			}*/
			
			terIndice = facIndice;
			printf("FACTOR\n");
		}
		; 
   
factor:
        ID																		
		{
			symbol id = getSymbol(yylval.s);
			insertarTipo(id.tipo);
			facIndice = crear_terceto_(id.nombre);
			printf("ID\n");
		}								
		|tipo 								   
		{
			printf("Esto es una cte\n");
		}
		|P_ABIERTO {terAuxIndice = terIndice; expAuxIndice = expIndice;} expresion P_CERRADO
			{ 
				facIndice = expIndice;
				terIndice = terAuxIndice;
				expIndice = expAuxIndice;
				printf("(EXPRESION)\n");
			} 
		;

tipo: 
		T_ENTERO    {
						validarInt(yytext);
						contCte++;
						insertarTipo("int");
						sprintf(_cte, "&cte%d", contCte);
						saveSymbol(_cte, "int", yytext, '&');
						facIndice = crear_terceto_(_cte);
					}
		|T_FLOAT    {
						validarFloat(yytext);
						contCte++;
						insertarTipo("float");
						sprintf(_cte, "&cte%d", contCte);
						saveSymbol(_cte, "float", yytext, '&');
						facIndice = crear_terceto_(_cte);
					}
		|T_STRING	{
						
						validarTipos("STRING");						
						validarString(yytext);
						contCte++;
						insertarTipo("string");
						sprintf(_cte, "&cte%d", contCte);
						saveSymbol(_cte, "string", yytext, '&');
						facIndice = crear_terceto_(_cte);
					}
	;
%%
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se pudo abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}