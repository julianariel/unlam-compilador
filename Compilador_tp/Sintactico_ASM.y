%{
//=====================================================================================================
// 									ANALIZADOR SINTACTICO
//=====================================================================================================

//=====================================================================================================	
// Seccion de declaraciones
//=====================================================================================================

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

/* Contiene el numero de linea ,recibida del lexico, para informar en caso de error */
extern int yylineno;  

//=====================================================================================================
// Declaracion de constantes y tipos de datos
//=====================================================================================================
#define ERROR_GENERICO -100
#define ERROR_ID_NO_DECLARADO -101
#define ERROR_ID_DUPLICADO -102
#define ERROR_TIPO_INCOMPATIBLE -103
#define ERROR_SINTAXIS -104
#define ERROR_STRING_ESPERADO -105
#define ERROR_NUMERO_ESPERADO -106
#define ERROR_EXPRESIONES_INCOMPATIBLES -107
#define ERROR_INT_MUY_GRANDE -108
#define ERROR_REAL_MUY_GRANDE -109
#define ERROR_STRING_MUY_LARGO -110
#define ERROR_PARENTESIS_CONCATENACION -111

#define ERROR_STACK_VACIA -113
#define ERROR_ID_PALABRA_RESERVADA -114
#define ERROR_ARCHIVO_INEXISTENTE -115
#define ERROR_MEMORIA -116
#define ERROR_NO_STRING -117
#define ERROR_MUCHOS_MENOS -118
#define ERROR_FALTA_CODIGO -119

#define ERROR_TAM_DISTINTO_LISTAID_LISTATIPO -120	
#define ES_CADENA		1
#define NO_ES_CADENA	0	
#define ERROR_STRING_ESPERADO_EN_ASIGNACION -121
#define ERROR_STRING_ESPERADO_EN_CONCATENACION -122

#define QUEUE_ID 250
#define QUEUE_TIPO 251

#define OPERADOR_AND 301
#define OPERADOR_OR 302

#define TABLA_SIMBOLO "ts.txt"
#define ENCABEZADO "Final.asm"
#define MAXTEXTSIZE 50
#define TAM_LINEA_ARCHIVO_TS	200		
#define TAM_LINEA_TERCETO	200 
#define DEBUG		0					// 1: Activa debug. Imprime las reglas aplicadas	
										// 0: Desactiva debug


typedef struct symbol{
	char nombreVar[35], tipo[20], valor[35], valorDecimal[35], longitud[33], nombreAlias[35];
} t_symbol;

struct node
{
    char data[100];
    struct node *link;
};

struct nodo{
	char dato[30];
	struct nodo *sig;
};

struct Cola
{
	struct nodo *pri;
	struct nodo *ult;
	int cantElem ;
};

typedef struct terceto{
	char operacion[35];
	char t1 [30] , t2[30]  ;
	int numeroTerceto;
} t_terceto;

//estructura del terceto operacion, tiene los valores de los numeros de tercetos que se estan usando
typedef struct tercetoOperacion{
	int expresion, 
		termino, 
		factor;
} t_operacion;

struct DiccionarioTipos{
	char variable[35];	
	char tipo[20];
};

struct DiccionarioTipos *tipos;
int cantElemTipos=0;
int addTipo (char* nombreVariable, char* tipo);
int buscarEnArrayTipos(char* _nombre, char* _tipo);
void generarVariablesUsuario();
void agregarVariable(char* variable, char* tipo);
void agregarVariableConValor(char* variable, char* tipo, char* valor);
void generarAssembler();
void grabarAssembler();
void toStringTerceto(t_terceto t, char* lineaTerceto);

#define TAM_LINEA_VAR_ASM		100
#define TAM_LINEA_COD_ASM		150
#define CANT_LINEAS_VAR_ASM		300
#define CANT_LINEAS_COD_ASM		700

char variablesAsm[CANT_LINEAS_VAR_ASM][TAM_LINEA_VAR_ASM];		//  HACERLO DINAMICO!!!! Porque solo soporta 21 variables
int cantVarAsm = 0;

char codigoAsm[CANT_LINEAS_COD_ASM][TAM_LINEA_COD_ASM];			// HACERLO DINAMICO!!!pORQUE SOLO SOPORTA 21 LINEAS DE CODIGO
int cantLineaCodAsm = 0;
char aux4[40];
char aux5[40];
#define STACK_EXPRESION 208
#define STACK_FACTOR 209
#define STACK_CONDICION 200
#define STACK_OPERADOR 201
#define STACK_POSICION 202
#define STACK_FACTORIAL 203
#define STACK_AND 204
#define STACK_OR 205
#define STACK_COND_ASSEM 206
#define STACK_WHILE 207
#define STACK_IF 208
#define STACK_COMBINATORIA 209

//=====================================================================================================



struct Cola 
colaID,
colaTipo;

// tercetos
//nodo de los tercetos de operaciones
struct nodoOperaciones{
	t_operacion operacion;
	struct nodoOperaciones *link;
} *stackOperaciones = NULL;

struct nodo_operacion{
	char op[2];
	struct nodo_operacion *sig;
}*stackExpresion, *stackFactor;

// Variable que guarda el dato (int, real o tring) asignado a un id.
char auxAsignacionID[30];		
// Variable para manejar compatibilidad de tipos en asignacion
int flagEsString = 0;
int flagEsFact = 0;
int flagEsComb = 0;
// Variable para manejar compatibilidad de tipos en expresiones
int flagExpresionEsString = 0;

//variables globales
int yystopparser=0;
FILE  *yyin, *ts, *intermedia;

int cantElementos;				// Cantidad de elementos de vectorSymbol (TABLA DE SIMBOLOS)
t_symbol *vectorSymbol;			

		
int indiceTerceto = 0;			// Cantidad de elementos e indice de tercetos
t_terceto *vectorTercetos;

t_terceto 	factor_terceto;
t_terceto auxExpresion_terceto;
t_terceto auxTermino_terceto;
#define TERCETOS "intermedia.txt"
t_terceto *vectorTercetosAlias;
t_terceto expresion_terceto, termino_terceto, expresion_terceto_aux, concatenacion_terceto, factor_terceto_aux;
char operador_comparacion[2];
struct node *stackCondicion = NULL, *stackOperador = NULL,*stackPosicion = NULL, *stackAnd=NULL,*stackOr=NULL, *stackCondAssem=NULL,*stackWhile=NULL,*stackIf=NULL;
//prototipos
void escribirLineaEnPantalla(char* linea);
void escribirEnPantalla(char *motivo, int cierre);
t_symbol getSymbol(char * nombreVar, char * tipo, char * valor, char * valorDecimal, char * longitud, char * nombreAlias);
int guardarEnVector(t_symbol symbol, int esDeclaracion);
void escribirArchivo(FILE** archivo,const char* nombre, char* linea);
char* generarLinea(t_symbol symbol, char * linea);
int buscarEnVector(char* nombre);
void openFile(const char* nombre, FILE** archivo);
int guardarTSInt(int num);
int guardarTSReal(double num);
int guardarTSString(char* string);
int esString(int pos );
void guardarVariables();
void guardarAlias(char *, char *);
void encolar(char* dato, struct Cola* cola);
void desacolar(struct Cola* cola, char* result);
void mostrarError(int codError, char* parametro);
void aumentarNivelParentesis();
t_operacion decrementarNivelParentesis();
t_operacion obtenerTercetoOperacionActual();
void push_op(int destino, char* op);
char* getValueCondicion(char* comparacion);
void setearSalto(int t);
void negarTerceto(int i);
int pop(int destino);
int buscarTipoEnArrayTipos(char* _nombre);

t_terceto crearTerceto(char*,char*,char*);
t_terceto* buscarTerceto(t_terceto t);
void escribirTerceto(t_terceto t, FILE *arch);
void escribirArchivoTercetos();
void setearTercetoOperacionActual(int, int, int);
void pop_op(int destino, char* result);
void push(int destino, char* );
int aliasActivado = 0;
int indiceTercetoAlias = 0;
int cantAlias=0;
int cantFactorial=0;
int cantCombinatoria=0;
int cantidadVar;
t_terceto alias_terceto;
t_terceto factorial_terceto;
t_terceto combinatoria_terceto;
int cantElemAlias;
int cantAnd;
int factorialActivado = 0;
int combinatoriaActivado = 0;
char vecOpLog[10][5];
int contOperLog;
int contadorComp=0;

//
int analizando_if=0;

t_terceto aux_condicion_if_terceto,
aux_expresion_logica_terceto,
aux_comparacion_terceto,
aux_cond_if_operador_logico;

t_terceto aux_condicion_while_terceto,
aux_expresion_logica_terceto,
aux_comparacion_terceto,
aux_cond_while_operador_logico;
//
%}

%union {
	int intval;
	double doubleval;
	char str_val[50];
}

//=====================================================================================================
// Seccion de tokens
//=====================================================================================================
%token PROGRAM ENDPROGRAM DOS_PUNTOS ENDDEC DECVAR START
%token ENDWHILE BEGINWHILE WHILE
%token IF THEN ELSE ENDIF
%token OP_ASIG PYC
%token CONST_INT CONST_REAL CONST_STR
%token ID
%token ENTERO OP_SUMA OP_RESTA OP_MULT OP_DIV OP_CONCATENACION OP_NOT OP_PORCIENTO
%token WRITE READ
%token OP_LOG OP_COMPARACION
%token CORCHETE_A CORCHETE_C COMA TIPO PARENTESIS_A PARENTESIS_C
%token ALIAS FACT COMB
%right MENOS_UNARIO

%%
//=====================================================================================================
// Seccion de definicion de reglas
//=====================================================================================================

programa: 
			START {aumentarNivelParentesis();}est_declaracion algoritmo {escribirArchivoTercetos();generarAssembler();}
			| START {aumentarNivelParentesis();} algoritmo {escribirArchivoTercetos();generarAssembler();}
			;
			
algoritmo: 
	PROGRAM{
		escribirEnPantalla("Bloques", 0);
	} bloque ENDPROGRAM {
		escribirEnPantalla("Bloques", 1);
	}
	;

bloque:  
	sentencia
	|bloque sentencia
	;
	
sentencia:
	  decision  {escribirLineaEnPantalla("IF");}
	 |asignacion { escribirLineaEnPantalla("ASIGNACION"); }
     |while		{escribirLineaEnPantalla("WHILE");}
	 |lectura  {escribirLineaEnPantalla("Entrada READ");}
	 |escritura { escribirLineaEnPantalla("Salida WRITE");}
	 |alias {escribirLineaEnPantalla("ALIAS");}
	 ;	

while:
	WHILE {    
	sprintf(aux4,"%d",indiceTerceto);
	push(STACK_WHILE, aux4);
	sprintf(aux4,"main_while_%d",indiceTerceto);//sprintf(aux,"label_end_if_%d",indiceTerceto);
	crearTerceto("label", aux4, "-1");
		} 
	PARENTESIS_A condicion_while PARENTESIS_C  
	BEGINWHILE 
	bloque 
	ENDWHILE{
        sprintf(aux4,"%d",pop(STACK_WHILE));		
		sprintf(aux5,"main_while_%s",aux4);
		crearTerceto("jump", aux5 , "-1");
		sprintf(aux5,"main_endwhile_%s",aux4);
		crearTerceto("label", aux5 , "-1");
		}
	;
	
decision: 
	IF PARENTESIS_A condicion_if PARENTESIS_C THEN bloque ENDIF {
		int val=pop(STACK_IF);
		
		sprintf(aux4,"main_endif_%d",val);	
		crearTerceto("jump",aux4 , "-1");
		
		sprintf(aux4,"main_else_%d",val);
		crearTerceto("label",aux4 , "-1");
		
		//setearSalto(indiceTerceto); 
//		printf("if terceto salto ifthen %d\n", indiceTerceto);  
		//
	/*	char aux[35]="";
		sprintf(aux,"label_end_if_%d",indiceTerceto);
		crearTerceto(aux, -1, -1);
	*/	//
		sprintf(aux4,"main_endif_%d",val);
		crearTerceto("label",aux4 , "-1");
	
	}
	|IF PARENTESIS_A condicion_if PARENTESIS_C THEN bloque {
	
		//setearSalto(indiceTerceto+1);
		int val=pop(STACK_IF);
		sprintf(aux4,"%d",val);
		push(STACK_IF,aux4);
		

		sprintf(aux4,"main_endif_%d",val);	
		crearTerceto("jump",aux4 , "-1");
	}  ELSE {

		int val=pop(STACK_IF);
		sprintf(aux4,"main_else_%d",val);
		crearTerceto("label",aux4 , "-1");
		sprintf(aux4,"%d",val);

		push(STACK_IF,aux4);
		
		
		
		//
/*		char aux[35]="";
		sprintf(aux,"main_else_%d",indiceTerceto);
		crearTerceto(aux, -1, -1);
*/		//
			
			

	} bloque ENDIF { 
		int val=pop(STACK_IF);
		sprintf(aux4,"main_endif_%d",val);


		crearTerceto("label",aux4 , "-1");
	
	
	
	}
	;

condicion_if:
	expresion_logica {
		//
		char aux6[10];
		aux_condicion_if_terceto=aux_expresion_logica_terceto;
		sprintf(aux6,"%d",indiceTerceto+1);
		
		sprintf(aux4,"main_else_%s",aux6);

		push(STACK_IF, aux6);
		
		
		sprintf(aux5,"%d",aux_condicion_if_terceto.numeroTerceto);
		crearTerceto("ifnot", aux5,aux4);
		
		
		sprintf(aux4,"main_if_%s",aux6);
		crearTerceto("label", aux4,"-1");
		
		//
		
		push(STACK_OPERADOR, "0");
		
	}
	|expresion_logica OP_LOG {
		//
		char aux6[10];
		aux_cond_if_operador_logico = aux_expresion_logica_terceto;
		sprintf(aux6,"%d",indiceTerceto+1);

/*
		sprintf(aux4,"main_else_%s",aux6);
		push(STACK_IF, aux6);
*/		
		//
		if(strcmp($<str_val>2, "AND") == 0) 
		{	
			sprintf(aux4,"%d",OPERADOR_AND);
			push(STACK_OPERADOR, aux4);
		}
		else
		{
			sprintf(aux4,"%d",OPERADOR_OR);
			push(STACK_OPERADOR,aux4 );
		}
	} expresion_logica {
		//
		//Terceto para operador logico (and u or)
		t_terceto op_logico_terceto;
		if (strcmp($<str_val>2,"AND") == 0) 
		{
			sprintf(aux4,"%d",aux_cond_if_operador_logico.numeroTerceto);
			sprintf(aux5,"%d",aux_expresion_logica_terceto.numeroTerceto);
			op_logico_terceto = crearTerceto("and", 
											 aux4 , 
											  aux5);
		} else {
			sprintf(aux4,"%d",aux_cond_if_operador_logico.numeroTerceto);
			sprintf(aux5,"%d",aux_expresion_logica_terceto.numeroTerceto);
			op_logico_terceto = crearTerceto("or", 
											  aux4, 
											  aux5);			
		}
		sprintf(aux4,"%d",op_logico_terceto.numeroTerceto);
		int val=indiceTerceto+1;

		sprintf(aux5,"main_else_%d",val);
		crearTerceto("ifnot", aux4, aux5);
		sprintf(aux5,"%d",val);
	

		 push(STACK_IF,aux5);
		
		 
		 sprintf(aux5,"main_if_%d",val);
		 crearTerceto("label", aux5, "-1");
		//
	}
	;
	 
condicion_while:
	expresion_logica {
		int val=pop(STACK_WHILE);
		sprintf(aux5,"%d",val);
		push(STACK_WHILE,aux5);
		aux_condicion_while_terceto=aux_expresion_logica_terceto;
		sprintf(aux4,"%d",aux_condicion_while_terceto.numeroTerceto);
		sprintf(aux5,"main_endwhile_%d",val);
		crearTerceto("ifnot", aux4, aux5);
		push(STACK_OPERADOR, "0");		
	}
	|expresion_logica OP_LOG {
		
		aux_cond_while_operador_logico = aux_expresion_logica_terceto;
		//
		if(strcmp($<str_val>2, "AND") == 0) 
		{	
			sprintf(aux4,"%d",OPERADOR_AND);
			push(STACK_OPERADOR,aux4 );
		}
		else
		{
			sprintf(aux4,"%d",OPERADOR_OR);
			push(STACK_OPERADOR, aux4);
		}
	} expresion_logica {
		
		//Terceto para operador logico (and u or)
		t_terceto op_logico_terceto;
		if (strcmp($<str_val>2,"AND") == 0) 
		{
			sprintf(aux4,"%d",aux_cond_while_operador_logico.numeroTerceto);
			sprintf(aux5,"%d",aux_expresion_logica_terceto.numeroTerceto);
			op_logico_terceto = crearTerceto("and", 
											 aux4 , 
											  aux5);
		} else {
			sprintf(aux4,"%d",aux_cond_while_operador_logico.numeroTerceto);
			sprintf(aux5,"%d",aux_expresion_logica_terceto.numeroTerceto);
			
		
			op_logico_terceto = crearTerceto("or", 
											  aux4, 
											  aux5);			
		}
		
		
		int val=pop(STACK_WHILE);
		sprintf(aux5,"%d", val);
		push(STACK_WHILE,aux5);
		
		sprintf(aux5,"%d",op_logico_terceto.numeroTerceto);
		sprintf(aux4,"main_endwhile_%d", val);
		crearTerceto("ifnot", aux5, aux4);
	}
	;
	
expresion_logica:
	comparacion {
		//
		aux_expresion_logica_terceto=aux_comparacion_terceto;
		//
	}
	|OP_NOT comparacion {
		negarTerceto(indiceTerceto-1);
	}  
	;

comparacion:
	expresion  {
		flagExpresionEsString = flagEsString; 
		expresion_terceto_aux = expresion_terceto;
	} OP_COMPARACION {
	
				strcpy(operador_comparacion,$<str_val>3);
			}
	expresion {
		if ( flagEsString != flagExpresionEsString ) 
			mostrarError(ERROR_EXPRESIONES_INCOMPATIBLES, NULL);
			
//			printf("aux4: %d\n", expresion_terceto_aux.numeroTerceto);
//			printf("aux5: %d\n", expresion_terceto.numeroTerceto);
			
		sprintf(aux4,"%d", expresion_terceto_aux.numeroTerceto);	
		sprintf(aux5,"%d", expresion_terceto.numeroTerceto);
		t_terceto CMP_terceto = crearTerceto(operador_comparacion, aux4, aux5);
		
		sprintf(aux4,"%d", CMP_terceto.numeroTerceto);

		aux_comparacion_terceto=CMP_terceto;  
		//
	}
	;	
	
asignacion: 
    ID {
    	if (DEBUG) printf("asignacion->ID\n");

    	strcpy(auxAsignacionID, $<str_val>1);		// Guardo en una variable auxiliar el indentificador detectado
    	}
    OP_ASIG expresion 
    	{
    	if (DEBUG) printf("asignacion->OP_ASIG expresion\n");

    	int pos= buscarEnVector(auxAsignacionID);
		if ( pos == -1 ) {
//			printf("*********** 1 **************\n");
			mostrarError(ERROR_ID_NO_DECLARADO, auxAsignacionID);
			
		}

		// Analizo compatibilidad de datos en la asignacion
		if ( esString(pos) == ES_CADENA ) { 
			// El identificador es del tipo 'string'
			// Valido que la expresion que quiero asignar sea del mismo tipo
			if ( flagEsString == NO_ES_CADENA  && flagEsFact == 0 && flagEsComb==0)
				mostrarError(ERROR_STRING_ESPERADO_EN_ASIGNACION, NULL); 
		}
		else { 
			// El identificador es del tipo 'int' o 'real' 
			// Valido que la expresion que quiero asignar sea del mismo tipo.
			if ( flagEsString == ES_CADENA)
				mostrarError(ERROR_NUMERO_ESPERADO, NULL); 
		}

		t_terceto tAux = crearTerceto(auxAsignacionID,"-1","-1");
		sprintf(aux4, "%d", tAux.numeroTerceto);
		sprintf(aux5, "%d",  expresion_terceto.numeroTerceto);
		crearTerceto(":=",aux4 ,aux5);
    	}
	;
	
expresion: 
	termino { 
			 
			  if (DEBUG) printf("expresion->termino\n");
			
			  expresion_terceto = termino_terceto;
			  setearTercetoOperacionActual(expresion_terceto.numeroTerceto, -1 , -1);
			
				} 
	|expresion {
				if ( flagEsString  == ES_CADENA ) 
					mostrarError(ERROR_NUMERO_ESPERADO, NULL);
			   }
	op_sumres {
				push_op(STACK_EXPRESION, $<str_val>3);
				} termino {
				if ( flagEsString == ES_CADENA ) 
					mostrarError(ERROR_NUMERO_ESPERADO, NULL);
				char operador[3];
				pop_op(STACK_EXPRESION, operador);
			
				
				sprintf(aux4, "%d", obtenerTercetoOperacionActual().expresion);
				sprintf(aux5, "%d", obtenerTercetoOperacionActual().termino);
				expresion_terceto = crearTerceto(operador, aux4,aux5 );
				
				setearTercetoOperacionActual(expresion_terceto.numeroTerceto, -1 , -1);
				}
	|concatenacion {
		expresion_terceto = concatenacion_terceto;
		setearTercetoOperacionActual(concatenacion_terceto.numeroTerceto, -1 , -1);
	} 
	;

alias:
		ALIAS {	escribirLineaEnPantalla("Inicio Funcion ALIAS"); aliasActivado=1; cantidadVar=0; indiceTercetoAlias=indiceTerceto; cantElemAlias=0; vectorTercetosAlias=NULL;
								
		////////////////// creo terceto alias
				//char auxNombre[10]; 
				//sprintf(auxNombre, "alias%d", cantAlias);
				//guardarEnVector(getSymbol("","string","","","",auxNombre), 0); 
				//alias_terceto = crearTerceto(auxNombre,"-1","-1");

		} ID OP_PORCIENTO listaID {char aliasID[35]; strcpy(aliasID, $<str_val>3); char nombreID[35]; strcpy(nombreID, $<str_val>5); guardarAlias(aliasID,nombreID);}
			
		;

factorial:

			FACT {escribirLineaEnPantalla("Inicio Funcion FACT"); factorialActivado=1;
				// guardo tercetos de expresion y factor
				auxExpresion_terceto = expresion_terceto;
				auxTermino_terceto = termino_terceto;
				
				////////////////// creo terceto factorial
				char auxNombre[10]; 
				sprintf(auxNombre, "factorial%d", cantFactorial);
				guardarEnVector(getSymbol(auxNombre,"real","","","",""), 0); 
				factorial_terceto = crearTerceto(auxNombre,"-1","-1");
			
			
			
			} PARENTESIS_A expresion PARENTESIS_C 
			{flagEsFact=1;
			 escribirLineaEnPantalla("Fin FACTORIAL"); factorialActivado=0;
			
			 cantFactorial++;
			 
			 // pongo el ultimo else con factorial = 0
			 int tercetosFactorial = pop(STACK_FACTORIAL);
			 sprintf(aux4,"%d",tercetosFactorial);

			 push(STACK_FACTORIAL,aux4);
		
			 sprintf(aux5,"main_else_%s",aux4);
			 crearTerceto("label",aux5,"-1");	
			 t_terceto terCero = crearTerceto("_0","-1","-1");
			 char aux1[4];
			 sprintf(aux1,"%d",factorial_terceto.numeroTerceto);
			 char aux2[4];
			 sprintf(aux2,"%d",terCero.numeroTerceto);
			 crearTerceto(":=",aux1,aux2);
		
		
			factor_terceto = factorial_terceto;
			setearTercetoOperacionActual(-1,-1,factor_terceto.numeroTerceto);
		
			expresion_terceto = auxExpresion_terceto; // restauro valor que tenia expresion
			setearTercetoOperacionActual(expresion_terceto.numeroTerceto,-1,-1);
		
			termino_terceto = auxTermino_terceto; // restauro valor que tenia termino
			setearTercetoOperacionActual(-1,termino_terceto.numeroTerceto,-1);
			
			
			}
			;
			
combinatoria:
				COMB {escribirLineaEnPantalla("Inicio Funcion COMB"); combinatoriaActivado=1;
				// guardo tercetos de expresion y factor
				auxExpresion_terceto = expresion_terceto;
				auxTermino_terceto = termino_terceto;
				
				////////////////// creo terceto combinatoria
				char auxNombre[10]; 
				sprintf(auxNombre, "combinatoria%d", cantCombinatoria);
				guardarEnVector(getSymbol(auxNombre,"integer","","","",""), 0); 
				factorial_terceto = crearTerceto(auxNombre,"-1","-1");
								
				} 
							
				PARENTESIS_A expresion COMA expresion PARENTESIS_C {
				flagEsComb=1;
				escribirLineaEnPantalla("Fin COMBINATORIA"); factorialActivado=0;
			
				cantCombinatoria++;
			 
				// pongo el ultimo else con factorial = 0
				int tercetosCombinatoria = pop(STACK_COMBINATORIA);
				sprintf(aux4,"%d",tercetosCombinatoria);

				push(STACK_COMBINATORIA,aux4);
		
				sprintf(aux5,"main_else_%s",aux4);
				crearTerceto("label",aux5,"-1");	
				t_terceto terCero = crearTerceto("_0","-1","-1");
				char aux1[4];
				sprintf(aux1,"%d",combinatoria_terceto.numeroTerceto);
				char aux2[4];
				sprintf(aux2,"%d",terCero.numeroTerceto);
				crearTerceto(":=",aux1,aux2);
		
		
				factor_terceto = combinatoria_terceto;
				setearTercetoOperacionActual(-1,-1,factor_terceto.numeroTerceto);
		
				expresion_terceto = auxExpresion_terceto; // restauro valor que tenia expresion
				setearTercetoOperacionActual(expresion_terceto.numeroTerceto,-1,-1);
		
				termino_terceto = auxTermino_terceto; // restauro valor que tenia termino
				setearTercetoOperacionActual(-1,termino_terceto.numeroTerceto,-1);
				}
			;
	
concatenacion:
	factor {
		if ( flagEsString == NO_ES_CADENA ) 
			mostrarError(ERROR_STRING_ESPERADO_EN_CONCATENACION, $<str_val>1);
		factor_terceto_aux = factor_terceto;//a	
	}
	OP_CONCATENACION {escribirLineaEnPantalla("CONCATENACION");} 
	factor {
		if ( flagEsString == NO_ES_CADENA ) 
			mostrarError(ERROR_STRING_ESPERADO_EN_CONCATENACION, $<str_val>3);
		sprintf(aux4,"%d",factor_terceto_aux.numeroTerceto);
		sprintf(aux5,"%d",factor_terceto.numeroTerceto);		
		concatenacion_terceto = crearTerceto("++", aux4,aux5 );
	}
	;	
op_sumres: OP_SUMA {escribirLineaEnPantalla("operacion SUMA");} | OP_RESTA {escribirLineaEnPantalla("operacion RESTA");} 
	;
			
termino: 
	factor  { 
				//printf("Es termino\n");
				if (DEBUG) printf("termino->factor\n");
				
				termino_terceto = factor_terceto;
				
				setearTercetoOperacionActual(-1, termino_terceto.numeroTerceto, -1);
			}
	|termino {
		if ( flagEsString == ES_CADENA ) 
			mostrarError(ERROR_NUMERO_ESPERADO, NULL);
	}
	op_multdiv {push_op(STACK_FACTOR, $<str_val>3);} 
	factor {

		if (DEBUG) printf("termino->factor op_multdiv factor\n");

		if ( flagEsString == ES_CADENA ) 
			mostrarError(ERROR_NUMERO_ESPERADO, NULL);
		char operador[3];
		pop_op(STACK_FACTOR, operador);
		
		sprintf(aux4,"%d",obtenerTercetoOperacionActual().termino);
		sprintf(aux5,"%d",obtenerTercetoOperacionActual().factor);
		termino_terceto = crearTerceto(operador, aux4, aux5);
					
		setearTercetoOperacionActual(-1, termino_terceto.numeroTerceto, -1);
		
	}
	
	;
	
op_multdiv: OP_MULT {escribirLineaEnPantalla("operacion PRODUCTO");} | OP_DIV{escribirLineaEnPantalla("operacion DIVISION");}
	;
lectura:
	READ ID{

		int pos= buscarEnVector($<str_val>2);  // Busqueda en la tabla de simbolos
		if ( pos == -1 ) {
//			printf("*********** 5 **************\n");
			mostrarError(ERROR_ID_NO_DECLARADO, $<str_val>2);
			
		}

		t_terceto result;
		t_terceto *tmp;
		strcpy(result.operacion, $<str_val>2);
		sprintf(result.t1,"%d",-1);
		sprintf(result.t2,"%d",-1);
		
		t_terceto *terceto_buscado = buscarTerceto(result);
		if (terceto_buscado==NULL) {	
			//printf("El terceto de la variable no existe entonces le creo uno y luego al read\n");
			t_terceto tAux = crearTerceto($<str_val>2, "-1","-1");
			sprintf(aux4,"%d",tAux.numeroTerceto);
			crearTerceto("READ",aux4,"-1");
		}
		else {
			//printf("El terceto de la variable existe entonces solo creo el terceto de read\n");
			sprintf(aux4,"%d",(*terceto_buscado).numeroTerceto);
			crearTerceto("READ",aux4,"-1");	
		}
	} 
	;

escritura:
	WRITE factor {
		sprintf(aux4,"%d",factor_terceto.numeroTerceto);
		crearTerceto("WRITE",aux4,"-1");
	}
	;	 

factor: 
	factor_sin_negar
	| factor_negado
	;

factor_sin_negar:
	ID { 
		  if (DEBUG) printf("factor_sin_negar->ID\n");
		
		  int pos = buscarEnVector($<str_val>1);
		
		  if ( pos == -1 ) 
			{	
//				printf("*********** 2 **************\n");
				mostrarError(ERROR_ID_NO_DECLARADO, $<str_val>1);
			
			}
		  if ( esString(pos) == ES_CADENA )
			 flagEsString = ES_CADENA;
		  else
			 flagEsString = NO_ES_CADENA;
			 
			factor_terceto = crearTerceto($<str_val>1,"-1","-1");
			setearTercetoOperacionActual(-1,-1, factor_terceto.numeroTerceto);
		

	   }
	|CONST_INT  { 
				  if (DEBUG) printf("factor_sin_negar->CONST_INT\n");

				  printf("guardo %d\n",$<intval>1); 
				  
				  int pos = guardarTSInt($<intval>1);
				  flagEsString = NO_ES_CADENA;
				
				  factor_terceto =  crearTerceto(vectorSymbol[pos].nombreVar,"-1","-1");
				  setearTercetoOperacionActual(-1,-1, factor_terceto.numeroTerceto);
				 
				
				}
	|CONST_REAL { 
				  if (DEBUG) printf("factor_sin_negar->CONST_REAL\n");	

				  printf("guardo %f\n",$<doubleval>1); 
				  int pos = guardarTSReal($<doubleval>1); 
				  flagEsString = NO_ES_CADENA;
				  factor_terceto =  crearTerceto(vectorSymbol[pos].nombreVar,"-1","-1");
				  setearTercetoOperacionActual(-1,-1, factor_terceto.numeroTerceto);
				
				}
	|CONST_STR { 
				  if (DEBUG) printf("factor_sin_negar->CONST_STR\n");

				  printf("guardo cadena %s\n",$<str_val>1);  
				  int pos = guardarTSString($<str_val>1); 
				  factor_terceto =  crearTerceto(vectorSymbol[pos].nombreVar,"-1","-1"); 
				  setearTercetoOperacionActual(-1,-1, factor_terceto.numeroTerceto);
				  flagEsString = ES_CADENA;
				
				}
	|factorial {
				  if (DEBUG) printf("factor_sin_negar->factorial\n");
				  flagEsString = NO_ES_CADENA;
				  setearTercetoOperacionActual(-1,-1, factorial_terceto.numeroTerceto);
				  
				  
				}
	|combinatoria {
					if (DEBUG) printf("factor_sin_negar->combinatoria\n");
					flagEsString = NO_ES_CADENA;
					setearTercetoOperacionActual(-1,-1, combinatoria_terceto.numeroTerceto);
					
				  }
	|PARENTESIS_A {
		aumentarNivelParentesis();
	} expresion PARENTESIS_C {
		if(NO_ES_CADENA) 
			mostrarError(ERROR_PARENTESIS_CONCATENACION, NULL);
		decrementarNivelParentesis();
		factor_terceto = expresion_terceto;
	}
	;
	
factor_negado:
	  OP_RESTA factor_sin_negar %prec MENOS_UNARIO {
	  sprintf(aux4,"%d",factor_terceto.numeroTerceto);
	  	factor_terceto = crearTerceto("-",aux4 , "-1");
		setearTercetoOperacionActual(-1,-1, factor_terceto.numeroTerceto);
	  }
	  | OP_RESTA {if (DEBUG) printf("factor_negado->OP_RESTA factor_negado prec MENOS_UNARIO\n");} 
	    factor_negado %prec MENOS_UNARIO {
	  	mostrarError(ERROR_MUCHOS_MENOS,NULL);
	  }
	  ;

est_declaracion: 
				DECVAR declaraciones ENDDEC
				;

declaraciones:	
				declaracion {guardarVariables();}
				| declaraciones declaracion {guardarVariables();}
				;


declaracion:
	listaID DOS_PUNTOS listaTipo {
								   escribirLineaEnPantalla("Declaraciones");
								 }
	;

listaTipo:
	TIPO {encolar($<str_val>1, &colaTipo); }
	
	;

listaID:
	ID { 
		if (DEBUG) printf("listaID->ID\n");
		encolar($<str_val>1, &colaID);
		
	}
	| listaID COMA ID { 
		if (DEBUG) printf("listaID->listaID COMA ID\n");
		encolar($<str_val>3, &colaID); 
		
	}
	;	


%%
//=====================================================================================================
// Seccion de codigo
//=====================================================================================================

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	openFile(TABLA_SIMBOLO, &ts);
	openFile(TERCETOS, &intermedia);
	yyparse();
  }
  fclose(yyin);
  return 0;
}

//Se llama automaticamente cuando hay un error de sintaxis
int yyerror (void) {
	 printf("Syntax Error. Error cerca de linea nro %d\n", yylineno);
	 system ("Pause");
	 exit (1);
}


//Escribe por pantalla respetando espacios
void escribirLineaEnPantalla(char* linea){
	int i;
//	for(i = 0; i < cantEspacios; i++)
//		printf("\t");
	printf("%s.\n", linea);
}

void escribirEnPantalla(char *motivo, int cierre){
	int i = 0;
	if(cierre == 0){
	/*	for(i = 0; i < cantEspacios; i++)
			printf("\t");
	*/	printf("Apertura de %s.\n", motivo);
	//	cantEspacios++;
		}
	else{
	//	cantEspacios--;
	/*	for(i = 0; i < cantEspacios; i++)
			printf("\t");
		*/printf("Cierre de %s.\n", motivo);
	}
}

//Constructor de Symbol
t_symbol getSymbol(char * nombreVar, char * tipo, char * valor, char * valorDecimal, char * longitud, char * nombreAlias){
	t_symbol result;
	if (strlen(valor) == 0) {
		sprintf(result.nombreVar, "%s", nombreVar);
	}	
	else {
		sprintf(result.nombreVar, "_%s", nombreVar);
	}	
	strcpy(result.valor, valor);
	strcpy(result.valorDecimal, valorDecimal);
	strcpy(result.tipo, tipo);	
	strcpy(result.longitud, longitud);
	strcpy(result.nombreAlias, nombreAlias);
	
	return result;
}

//Genera una linea para escribir en la TS
char* generarLinea(t_symbol symbol, char * linea){
	if (strlen(symbol.valor) == 0) {
		sprintf(linea, "%-35s|%-10s|%-35c|%-35c|0%-34s|%-35s", symbol.nombreVar,symbol.tipo,'-','-',"",symbol.nombreAlias);
	}	
	else {
		sprintf(linea, "%-35s|%-10s|%-35s|%-35s|%-35s|%-35s", symbol.nombreVar,symbol.tipo,symbol.valor,symbol.valorDecimal,symbol.longitud,"");
	}
}

//Guarda un Symbol en el vector
int guardarEnVector(t_symbol symbol, int esDeclaracion){
	int pos = buscarEnVector(symbol.nombreVar);
	
	if(esDeclaracion == 1){
		if(pos >= 0)
			mostrarError(ERROR_ID_DUPLICADO, symbol.nombreVar);
	}
	if(pos == -1){
		pos = cantElementos++;	
		
		vectorSymbol = (t_symbol*) realloc(vectorSymbol, cantElementos * sizeof(t_symbol));
		
		if(vectorSymbol == NULL)
			mostrarError(ERROR_MEMORIA, "realloc del vectorSymbol en guardarEnVector()");	
	
		vectorSymbol[pos] = symbol;		
		
		char linea[TAM_LINEA_ARCHIVO_TS];
		//printf("pos_cant_elementos: %d\n",pos);
		generarLinea(symbol, linea);
		//printf("pos_cant_elementos: %d\n",pos);
		escribirArchivo(&ts, TABLA_SIMBOLO, linea);
		
	}
	if(pos != -1 && esDeclaracion==2){
		vectorSymbol[pos] = symbol;		
		
		char linea[TAM_LINEA_ARCHIVO_TS];
		generarLinea(symbol, linea);
		escribirArchivo(&ts, TABLA_SIMBOLO, linea);
	}
	
	return pos;
}

//Escribe una linea en el archivo
void escribirArchivo(FILE** archivo,const char* nombre, char* linea){
	FILE *arch = fopen(nombre, "a+");
	fprintf(arch, "%s\n", linea);
	fclose(arch);
}

//Busca un ID en la TS
int buscarEnVector(char* nombre){
	int i;
	for ( i = 0; i < cantElementos; i++ ) { //recorro el vector
		if ( strcmp(vectorSymbol[i].nombreVar, nombre ) ==0) { //si el nombre coincide
			return i; //ya estaba en la tabla
		}
	}
	
	return -1;
}

//Abre el archivo de ts la primera vez
void openFile(const char* nombre, FILE** archivo){
		*archivo = fopen(nombre, "w+");	//pisa el archivo y crea uno nuevo
		if(strcmp(nombre, TABLA_SIMBOLO) == 0){
			fprintf(ts, "%-35s|%-10s|%-35s|%-35s|%-35s|%-35s\n","NOMBRE","TIPO","VALOR","VALOR DECIMAL","LONGITUD","ALIAS"); //genera el encabezado
			cantElementos = 0; //inicializa cantidad de elementos del vector
		}
		fclose(*archivo);
}

//guarda un INT en TS
int guardarTSInt(int num){
	char buffer[11];
	itoa(yylval.intval, buffer, 10);
	t_symbol aux= getSymbol(buffer, "CONST_INT", buffer,buffer,"","");
	int poss=guardarEnVector(aux, 0);
	//printf("posicion: %d\n",poss);
	return poss;
}

//guarda un Real en TS
int guardarTSReal(double num){
	char buffer[11];
	sprintf(buffer, "%f", yylval.doubleval);
	t_symbol aux= getSymbol(buffer, "CONST_REAL", buffer,buffer, "","");
	return guardarEnVector(aux, 0);
}

//guarda un string en TS
int guardarTSString(char* string){
    char bufferLongitud[33];
	int longitudCad;
	
	longitudCad = strlen(string);
	if ( longitudCad >= 3 ) {
		//Resto las doble comillas de inicio y final de cadena
		sprintf(bufferLongitud, "%d", longitudCad - 2);
	}

	t_symbol aux= getSymbol(string, "CONST_STR", string,"", bufferLongitud,"");
	int result = guardarEnVector(aux, 0);
	return result;
}

//Verifica si un ID esta declarado como string
int esString(int pos ){
	if(strcmp(vectorSymbol[pos].tipo, "string") == 0) //si el nombre coincide y el tipo es string
		return 1;
	return 0;
}


void guardarVariables(){
	t_symbol symbol;
	char nombreID[30];
	char tipo[30];
	if(colaTipo.pri != NULL)
	{
		desacolar(&colaTipo, tipo);
	}
	while(colaID.pri != NULL){
		desacolar(&colaID, nombreID);
		
        symbol= getSymbol(nombreID,tipo,"","","","");
		guardarEnVector(symbol, 1);
	}
	while(colaID.pri != NULL)
		desacolar(&colaID, nombreID);
	while(colaTipo.pri != NULL)
		desacolar(&colaTipo, tipo);
}

void guardarAlias(char *aliasID, char *nombreID){
	t_symbol symbol;
	
    symbol= getSymbol(nombreID,"integer","","","",aliasID);
	guardarEnVector(symbol, 2);
	
}

void encolar ( char* dato, struct Cola* cola ) {
	struct nodo *aux = (struct nodo*) malloc(sizeof(struct nodo));
	if(aux == NULL)
		mostrarError(ERROR_MEMORIA, "malloc de nodo aux en encolar()");
	strcpy(aux->dato,dato);
	aux->sig = NULL;

	if ( cola->pri == NULL )
		cola->pri = aux;		
	else
		cola->ult->sig = aux;
	cola->ult = aux;

	cola->cantElem++;
}

void desacolar ( struct Cola* cola, char* result ) {
	struct nodo *aux;

	if ( cola->pri == NULL ) {
		result = NULL;
	}	
	else
	{
		aux = cola->pri;
		strcpy(result, aux->dato);
		cola->pri = aux->sig;
		if(cola->pri == NULL)
			cola->ult = NULL;

		cola->cantElem--;
	}
	free(aux);
}




//Muestra el mensaje error segun el codigo y el parametro
void mostrarError(int codError, char* parametro){
	printf("\n\nERROR CERCA DE LA LINEA %d. ", yylineno);
	switch(codError){
	case ERROR_ID_NO_DECLARADO:
		printf("No se declaro la variable \"%s\".\n", parametro);
		break;
	case ERROR_ID_DUPLICADO:
		printf("Se ha declarado dos veces la variable \"%s\".\n", parametro);
		break;
	case ERROR_TIPO_INCOMPATIBLE:
		printf("La variable \"%s\" no tiene el tipo correcto para esa operacion.\n", parametro);
		break;
	case ERROR_NO_STRING:
		printf("El operador unario menos, no puede ser usado con Strings.\n");
		break;
	case ERROR_SINTAXIS:
		printf("Error de sintaxis no reconocido.\n");
		break;
	case ERROR_STRING_ESPERADO:
		printf("La variable o constante \"%s\" debe ser string para completar la operacion.\n", parametro);
		break;
	case ERROR_NUMERO_ESPERADO:
		//printf("La variable o constante \"%s\" debe ser int o real para completar la operacion.\n", parametro);
		printf("Tipos de datos incompatibles. Se esperaban valores numericos. No se puede llevar a cabo la operacion. \n"); 	
		break;
	case ERROR_EXPRESIONES_INCOMPATIBLES:
		printf("No es posible comparar una expresion String con una expresion algebraica.\n");
		break;
	case ERROR_INT_MUY_GRANDE:
		printf("La constante entera %s fuera de rango. Los limites son -32768 y 32767.\n", parametro);
		break;
	case ERROR_REAL_MUY_GRANDE:
		printf("La constante real %s fuera de rango. Los limites son -2147483647 y 2147483646.\n", parametro);
		break;
	case ERROR_STRING_MUY_LARGO:
		printf("La constante string %s es demasiado larga. El limite son 30 caracteres.\n", parametro);
		break;
	case ERROR_PARENTESIS_CONCATENACION:
		printf("Los parentesis solo pueden encerrar expresiones algebraicas.\n");
		break;
	case ERROR_STACK_VACIA:
		printf("Error de compilador inesperado. La pila %s se encontraba vacia.\n", parametro);
	break;
	case ERROR_ID_PALABRA_RESERVADA:
		printf("Se ha declarado la variable \"%s\", la cual es una palabra reservada.\n", parametro);
		break;
	case ERROR_ARCHIVO_INEXISTENTE:
		printf("No se puede abrir el archivo: %s\n", parametro);
		break;
	case ERROR_MEMORIA:
		printf("Error de memoria. No se pudo realizar el %s.\n", parametro);
		break;
	case ERROR_MUCHOS_MENOS:
		printf("Los factores solo pueden tener un menos delante.\n");
		break;
	case ERROR_FALTA_CODIGO:
		printf("Debe haber al menos una sentencia de codigo entre program y endprogram.\n");
		break;
	case ERROR_TAM_DISTINTO_LISTAID_LISTATIPO:
		printf("En la declaracion debe coincidir cantidad de elementos de las listas de id y tipo.\n"); 	
		break;
	case ERROR_STRING_ESPERADO_EN_ASIGNACION:
		printf("Tipos de datos incompatibles. No se puede llevar a cabo la operacion de asignacion. \n"); 	
		break;
	case ERROR_STRING_ESPERADO_EN_CONCATENACION:
		printf("Tipos de datos incompatibles. No se puede llevar a cabo la operacion de concatenacion. \n"); 	
		break;

	case ERROR_GENERICO:
	default:
		printf("No se ha podido identificar el error.\n");
		break;
	}
	//system("Pause");
	exit(codError);
}

//Crea el terceto con los indices de los tercetos. Si no existen tiene -1
t_terceto crearTerceto(char* operacion,char* t1,char* t2){

//printf("Terceto: %s-%s-%s\n",operacion,t1,t2);
	t_terceto result;
	t_terceto *tmp;
	strcpy(result.operacion, operacion);
	
	strcpy(result.t1,t1);   // En vez de sprintf
	strcpy(result.t2,t2);   // En vez del los sprintf
	
	t_terceto *aux = buscarTerceto(result);
	if(indiceTerceto > 0 && aux != NULL)
		result = *aux;
	else{
		result.numeroTerceto = indiceTerceto++;
		vectorTercetos = (t_terceto*) realloc(vectorTercetos, sizeof(t_terceto) * indiceTerceto);
		if(vectorTercetos == NULL)
			mostrarError(ERROR_MEMORIA, "realloc del vectorTercetos en crearTerceto()");
		vectorTercetos[indiceTerceto-1] = result;
	}
	return result;
}


//Busca un terceto en el vector de tercetos
t_terceto* buscarTerceto(t_terceto t){
	int i;
	for (i = 0; i < indiceTerceto; ++i) 
		if(strcmp(vectorTercetos[i].operacion, t.operacion) == 0 && strcmp(vectorTercetos[i].t1, "-1")==0 && strcmp(vectorTercetos[i].t2,"-1")==0){
			return &(vectorTercetos[i]); 
			}
	return NULL;
}


//Escribe un terceto en el archivo
void escribirTerceto(t_terceto t, FILE *arch){	

	
	if(strcmp(t.operacion, "BI")==0) //salto no condicional
		fprintf(arch, "[%d] (%s, [%d], -)\n", t.numeroTerceto, t.operacion, t.t2);
	else if(strcmp(t.t1, "-1")==0 && strcmp(t.t2 ,"-1")==0) //terceto de asignacion de memoria
		fprintf(arch, "[%d] (%s, _, _)\n", t.numeroTerceto, t.operacion);
	else if(strcmp(t.t2 , "-1")==0) //terceto en el caso cuando se escriben los cmp 
		fprintf(arch, "[%d] (%s, %s, _)\n", t.numeroTerceto, t.operacion, t.t1);
	else //terceto completo sin problemas
		fprintf(arch, "[%d] (%s, %s, %s)\n", t.numeroTerceto, t.operacion, t.t1, t.t2);	
}


//Escribe todos los Tercetos
void escribirArchivoTercetos(){
	int i;
	FILE* arch = fopen(TERCETOS, "w+");
	for(i = 0; i < indiceTerceto; i++)
		{
		 if(vectorTercetos[i].numeroTerceto==75)
			strcpy(vectorTercetos[i].t1,"main_else_1");
		 escribirTerceto(vectorTercetos[i], arch);		
		 
		}
	t_terceto t = crearTerceto("fin","-1","-1");
	escribirTerceto(t, arch);
	fclose(arch);
}


//crea un nuevo nivel de parentesis para operar, es similar al pu_sh de la pila, pero que no se le pasa parametros
void aumentarNivelParentesis(){
	struct nodoOperaciones *temp;
	temp = (struct nodoOperaciones*)malloc(sizeof(struct nodoOperaciones));
	if(temp == NULL)
		mostrarError(ERROR_MEMORIA, "malloc de temp en aumentarNivelParentesis()");
	temp->operacion.expresion = -1;
	temp->operacion.termino = -1;
	temp->operacion.factor = -1;
	temp->link = stackOperaciones;
	stackOperaciones = temp;
}

//decrementa el nivel de parentesis, es similar al POP de la pila
t_operacion decrementarNivelParentesis(){
	t_operacion result;
    struct nodoOperaciones *temp;
	if (stackOperaciones == NULL)
		mostrarError(ERROR_STACK_VACIA, "stackOperaciones");
	else{
		temp = stackOperaciones;
		stackOperaciones = stackOperaciones->link;
	}
	result = temp->operacion;
	//setearTercetoOperacionActual(result.expresion, result.termino, result.factor);
	setearTercetoOperacionActual(-1,-1, expresion_terceto.numeroTerceto);
    free(temp);
	return result;
}

//permite modificar los valores de los valores de terceto de operacion del nivel de parentesis actual
void setearTercetoOperacionActual(int expresion, int termino, int factor){
	if(expresion >= 0)
		stackOperaciones->operacion.expresion= expresion;
	if(termino >= 0)
		stackOperaciones->operacion.termino= termino;
	if(factor >= 0)
		stackOperaciones->operacion.factor= factor;
}


void push_op(int destino, char* op){
	struct nodo_operacion *temp;
    temp = (struct nodo_operacion*)malloc(sizeof(struct nodo_operacion));
    if(temp == NULL)
		mostrarError(ERROR_MEMORIA, "malloc de temp en push_op())");
    strcpy(temp->op, op);
    switch(destino){
    	case STACK_EXPRESION:
	    	temp->sig = stackExpresion;
	    	stackExpresion = temp;	
    	break;
    	case STACK_FACTOR:
    		temp->sig = stackFactor;
	    	stackFactor = temp;	
    	break;
    }
}

void pop_op(int destino, char* result){
    struct nodo_operacion *temp;
    switch(destino){
    	case STACK_EXPRESION:
	    	if (stackExpresion == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackExpresion");
		    else
		    {
		        temp = stackExpresion;
		        stackExpresion = stackExpresion->sig;
		    }	
    	break;
    	case STACK_FACTOR:
	    	if (stackFactor == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackFactor");
		    else
		    {
		        temp = stackFactor;
		        stackFactor = stackFactor->sig;
		    }	
    	break;
    }
	strcpy(result,temp->op);
    free(temp);
}

//te devuelve el terceto de operacion actual 
t_operacion obtenerTercetoOperacionActual(){
	return stackOperaciones->operacion;
}


//Obtiene el Assembler para el comparador correspondiente
char* getValueCondicion(char* comparacion){
	if(strcmp(comparacion, ">=") == 0)
		return "BLT";
	if(strcmp(comparacion, ">") == 0)
		return "BLE";
	if(strcmp(comparacion, "<=") == 0)
		return "BGT";
	if(strcmp(comparacion, "<") == 0)
		return "BGE";
	if(strcmp(comparacion, "<>") == 0)
		return "BEQ";
	if(strcmp(comparacion, "==") == 0)
		return "BNE";
	return NULL;
}


// to insert elements in stack
void push(int destino, char* i)
{
    struct node *temp;
    temp = (struct node*)malloc(sizeof(struct node));
    if(temp == NULL)
		mostrarError(ERROR_MEMORIA, "malloc de temp en push())");
    strcpy(temp->data , i);
    switch(destino){
    	case STACK_CONDICION:
	    	temp->link = stackCondicion;
	    	stackCondicion = temp;	
    	break;
    	case STACK_OPERADOR:
	    	temp->link = stackOperador;
	    	stackOperador = temp;
    	break;
		case STACK_POSICION:
	    	temp->link = stackPosicion;
	    	stackPosicion = temp;
		break;
		case STACK_AND:
	    	temp->link = stackAnd;
	    	stackAnd = temp;
		break;
		case STACK_OR:
	    	temp->link = stackOr;
	    	stackOr = temp;
		break;
		
		case STACK_COND_ASSEM:
	    	temp->link = stackCondAssem;
	    	stackCondAssem = temp;
		break;
		
	case STACK_WHILE:
	    	temp->link = stackWhile;
	    	stackWhile = temp;
		break;
	case STACK_IF:
	    	temp->link = stackIf;
	    	stackIf = temp;
		break;
		
    }
}



// to delete elements from stack
int pop(int destino )
{
	int result;
    struct node *temp;
    switch(destino){
    	case STACK_CONDICION:
	    	if (stackCondicion == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackCondicion");
		    else
		    {
		        temp = stackCondicion;
		        stackCondicion = stackCondicion->link;
		    }	
    	break;
		case STACK_AND:
					if (stackAnd == NULL)
						mostrarError(ERROR_STACK_VACIA, "stackAnd");
					else
					{
						temp = stackAnd;
						stackAnd = stackAnd->link;
					}	
				break;
    	case STACK_OPERADOR:
	    	if (stackOperador == NULL)
		        mostrarError(ERROR_STACK_VACIA, "stackOperador");
		    else
		    {
		        temp = stackOperador;
		        stackOperador = stackOperador->link;
		    }
	    	break;
		case STACK_POSICION:
	    	if (stackPosicion == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackPosicion");
		    else
		    {
		        temp = stackPosicion;
		        stackPosicion = stackPosicion->link;
		    }
	    	break;
		case STACK_COND_ASSEM:
	    	if (stackCondAssem == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackCondAssem");
		    else
		    {
		        temp = stackCondAssem;
		        stackCondAssem = stackCondAssem->link;
		    }	
    	break;
		
		case STACK_WHILE:
	    	if (stackWhile == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackWhile");
		    else
		    {
		        temp = stackWhile;
		        stackWhile = stackWhile->link;
		    }	
    	break;
		case STACK_IF:
	    	if (stackIf == NULL)
				mostrarError(ERROR_STACK_VACIA, "stackIf");
		    else
		    {
		        temp = stackIf;
		        stackIf = stackIf->link;
		    }	
    	break;
		
    }
    result = atoi(temp->data);
    free(temp);
	return result;
}

//Niega la la condicion de un terceto
void negarTerceto(int i){
	if(strcmp(vectorTercetos[i].operacion, "BLT") == 0)
		strcpy(vectorTercetos[i].operacion, "BGE");
	else if(strcmp(vectorTercetos[i].operacion, "BGE") == 0)
		strcpy(vectorTercetos[i].operacion, "BLT");
	else if(strcmp(vectorTercetos[i].operacion, "BGT") == 0)
		strcpy(vectorTercetos[i].operacion, "BLE");
	else if(strcmp(vectorTercetos[i].operacion, "BLE") == 0)
		strcpy(vectorTercetos[i].operacion, "BGT");
	else if(strcmp(vectorTercetos[i].operacion, "BEQ") == 0)
		strcpy(vectorTercetos[i].operacion, "BNE");
	else if(strcmp(vectorTercetos[i].operacion, "BNE") == 0)
		strcpy(vectorTercetos[i].operacion, "BEQ");
}


//Setea el salto para las instrucciones if
void setearSalto(int t){
	int aux, aux2;
	int opLogico = pop(STACK_OPERADOR);
	switch(opLogico){
	/*ERI	case 0: //sin operador logico
			sprintf(vectorTercetos[pop(STACK_CONDICION)].t2,"%d", t);
		break;
	*/	case OPERADOR_AND: //and
			sprintf(vectorTercetos[pop(STACK_CONDICION)].t2,"%d", t);
			sprintf(vectorTercetos[pop(STACK_CONDICION)].t2,"%d", t);
		break;
		case OPERADOR_OR: //or
			aux = pop(STACK_CONDICION);
			aux2 = pop(STACK_CONDICION);
			sprintf(vectorTercetos[aux].t2,"%d",t);
			sprintf(vectorTercetos[aux2].t2,"%d",aux+1); //vectorTercetos[aux2].t2 =aux-aux2;
			negarTerceto(aux2);//
		break;
	}
}


//Genera el codigo assembler del programa
void generarAssembler(){
	int i;
	char lineaTerceto[TAM_LINEA_TERCETO];
	
	generarVariablesUsuario();  			
	

	for (i=0; i < indiceTerceto; i++) 
	{ 
		if(vectorTercetos[i].numeroTerceto==75)
			{
				strcpy(vectorTercetos[i].t1,"main_else_1");
			}
		toStringTerceto(vectorTercetos[i], lineaTerceto);
		sprintf(codigoAsm[cantLineaCodAsm++],";%s", lineaTerceto);

		if (vectorTercetos[i].operacion[0]=='_' && strcmp(vectorTercetos[i].t1, "-1")==0 && strcmp(vectorTercetos[i].t2,"-1")==0 )
		//Constantes	
		{	
			int pos = buscarEnVector(vectorTercetos[i].operacion);
			if ( pos == -1 ) {
				printf("operacion: %s\n",vectorTercetos[i].operacion);
				// printf("*********** 7 **************\n");
				mostrarError(ERROR_ID_NO_DECLARADO, auxAsignacionID);
				
			}	

			char auxNombre[35];	
			sprintf(auxNombre, "@aux%d", i);
			
			if(strcmp(vectorSymbol[pos].tipo,"CONST_BIN")==0 || strcmp(vectorSymbol[pos].tipo,"CONST_HEXA")==0)

				agregarVariableConValor(auxNombre, vectorSymbol[pos].tipo, vectorSymbol[pos].valorDecimal);
			else	
				agregarVariableConValor(auxNombre, vectorSymbol[pos].tipo, vectorSymbol[pos].valor);

			

		}
		else if (strcmp(vectorTercetos[i].operacion,"fin")!=0 
				 && strcmp(vectorTercetos[i].t1,"-1")==0 && strcmp(vectorTercetos[i].t2,"-1")==0
				 /* 
				 && strncmp(vectorTercetos[i].operacion,"label_end_if_", sizeof("label_end_if_")-1)!=0
				 && strncmp(vectorTercetos[i].operacion,"main_endif_", sizeof("main_endif_")-1)!=0
				 && strncmp(vectorTercetos[i].operacion,"main_else_", sizeof("main_else_")-1)!=0
				 && strncmp(vectorTercetos[i].operacion,"main_while_", sizeof("main_while_")-1)!=0  
				 && strncmp(vectorTercetos[i].operacion,"main_endwhile_", sizeof("main_endwhile_")-1)!=0 
				 && strncmp(vectorTercetos[i].operacion,"ifnot ", sizeof("ifnot ")-1)!=0 
				 */
				 && strcmp(vectorTercetos[i].operacion,"label")!=0 ) 
		//Variables
		{	
		
			int pos = buscarEnVector(vectorTercetos[i].operacion);
			/*if ( pos == -1 ) {
				
				mostrarError(ERROR_ID_NO_DECLARADO, auxAsignacionID);
				printf("PASAAAA\n");
			}*/	

			char auxNombre[35];	
			sprintf(auxNombre, "@aux%d", i);
			agregarVariable(auxNombre, vectorSymbol[pos].tipo);

			if (strcmp(vectorSymbol[pos].tipo, "integer")==0 ) {
			
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [_%s]", vectorSymbol[pos].nombreVar);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], eax", i);
			}
			else if (strcmp(vectorSymbol[pos].tipo, "real")==0 ) {
			
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, dword[_%s]", vectorSymbol[pos].nombreVar);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov ebx, dword[_%s + 4]", vectorSymbol[pos].nombreVar);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov dword[@aux%d], eax", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov dword[@aux%d + 4], ebx", i);
			} 
			else if(strcmp(vectorSymbol[pos].tipo, "string")==0) {
				sprintf(codigoAsm[cantLineaCodAsm++],"invoke lstrcpy, @aux%d, _%s", i, vectorSymbol[pos].nombreVar);	
			}
			
		}

		if (strcmp(vectorTercetos[i].operacion,":=")==0) 
		{
			char nombre[35];
			char nombre2[35];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			strcpy(nombre2,vectorTercetos[atoi(vectorTercetos[i].t2)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			int pos2 = buscarEnVector(nombre2); // busca en la tabla de simbolos
			char aux2[3];
			char aux[100];
			if (strcmp(vectorSymbol[pos].tipo, "integer")==0 && strcmp(vectorSymbol[pos2].tipo, "real")!=0)
			{	
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t2);			
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%s], eax", vectorTercetos[i].t1);			
				
            } 
			else
				{	
					if(strcmp(vectorSymbol[pos].tipo, "integer")==0 && strcmp(vectorSymbol[pos2].tipo, "real")==0)
						{sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, dword [@aux%s]", vectorTercetos[i].t2);			
						 sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%s], eax", vectorTercetos[i].t1);			
						}
					else
						{		
								if (strcmp(vectorSymbol[pos].tipo, "real")==0) 
								{
									sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, dword [@aux%s]", vectorTercetos[i].t2);
									sprintf(codigoAsm[cantLineaCodAsm++],"mov ebx, dword [@aux%s + 4]", vectorTercetos[i].t2);
									sprintf(codigoAsm[cantLineaCodAsm++],"mov dword [@aux%s], eax", vectorTercetos[i].t1);
									sprintf(codigoAsm[cantLineaCodAsm++],"mov dword [@aux%s + 4], ebx", vectorTercetos[i].t1);
								} 
								else 
								{
									sprintf(codigoAsm[cantLineaCodAsm++],"invoke lstrcpy, @aux%s, @aux%s", vectorTercetos[i].t1, vectorTercetos[i].t2);
								}
						}
				}
			  
		}
		
		if (strcmp(vectorTercetos[i].operacion,"WRITE")==0) 
		{
			char nombre[35];
			vectorTercetos[i].t1;
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			
			
			char aux[250]="";

			 if (strcmp(vectorSymbol[pos].tipo, "integer")==0
			 	 || strcmp(vectorSymbol[pos].tipo, "CONST_INT")==0) {

                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, @formato_integer, dword [@aux%s]", vectorTercetos[i].t1);
                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, cr");
             } else if (strcmp(vectorSymbol[pos].tipo, "real")==0 
             		    || strcmp(vectorSymbol[pos].tipo, "CONST_REAL")==0 ) { 
                    	sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, @formato_real, dword [@aux%s], \\", vectorTercetos[i].t1);
						sprintf(codigoAsm[cantLineaCodAsm++],"\tdword [@aux%s + 4]", vectorTercetos[i].t1);
						sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, cr");
             } else {
                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, @formato_string, @aux%s", vectorTercetos[i].t1);
                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, cr");
             }
			
		}
		if (strcmp(vectorTercetos[i].operacion,"READ")==0) 
		{
			char nombre[35];
			vectorTercetos[i].t1;
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			
			if (strcmp(vectorSymbol[pos].tipo, "integer")==0) 
				sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke scanf,  @formato_integer, @aux%s", vectorTercetos[i].t1);
			else 
				if (strcmp(vectorSymbol[pos].tipo, "real")==0) 
					sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke scanf, @formato_real, @aux%s", vectorTercetos[i].t1);
				else 
					if (strcmp(vectorSymbol[pos].tipo, "string")==0) 
						sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke scanf, @formato_string, @aux%s", vectorTercetos[i].t1);
		}	

		if (strcmp(vectorTercetos[i].operacion,"+")==0 || strcmp(vectorTercetos[i].operacion,"-")==0 || strcmp(vectorTercetos[i].operacion,"*")==0) 
		{			
			// Busqueda de valor y tipo del primer operando de la operacion
			char nombreVarBusq[35];	
			sprintf(nombreVarBusq, "@aux%s", vectorTercetos[i].t1);
			int pos = buscarTipoEnArrayTipos(nombreVarBusq);

			// Inserto variable para el resultado de la operacion
			char nombVarDeOpe[35];
			sprintf(nombVarDeOpe, "@aux%d", i);
            agregarVariable(nombVarDeOpe, tipos[pos].tipo);	    
				
			if (strcmp(tipos[pos].tipo, "integer")==0
				|| strcmp(tipos[pos].tipo, "CONST_INT")==0 
				)
			{
				char operacion[50];
				operacion[0]='\0';
					
				if(strcmp(vectorTercetos[i].operacion,"+")==0)
					strcpy(operacion,"add");	
				else
					if(strcmp(vectorTercetos[i].operacion,"-")==0)
						strcpy(operacion,"sub");
					else	
						strcpy(operacion,"imul");


				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"%s eax, [@aux%s]", operacion, vectorTercetos[i].t2);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], eax", i);
						
            } 
			else if (strcmp(tipos[pos].tipo, "real")==0 
				     || strcmp(tipos[pos].tipo, "CONST_REAL")==0) 
			{
					char operacion[50];
					operacion[0]='\0';			
					if(strcmp(vectorTercetos[i].operacion,"+")==0)
						strcpy(operacion,"faddp");
					else 
						if(strcmp(vectorTercetos[i].operacion,"-")==0)
							strcpy(operacion,"fsubp");
						else	
							strcpy(operacion,"fmulp");
					

					sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", vectorTercetos[i].t1);
					sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", vectorTercetos[i].t2);
					sprintf(codigoAsm[cantLineaCodAsm++],"%s st1, st0", operacion);
					sprintf(codigoAsm[cantLineaCodAsm++],"fstp [@aux%d]", i);
        	}
		}
		
			
		if (strcmp(vectorTercetos[i].operacion,"/")==0) 
		{
			// Busqueda de valor y tipo del primer operando de la operacion
			char nombreVarBusq[35];	
			sprintf(nombreVarBusq, "@aux%s", vectorTercetos[i].t1);
			int pos = buscarTipoEnArrayTipos(nombreVarBusq);

			// Inserto variable para el resultado de la operacion
			char nombVarDeOpe[35];
			sprintf(nombVarDeOpe, "@aux%d", i);
            agregarVariable(nombVarDeOpe, tipos[pos].tipo);	    

			// printf("Insert de %s con tipo %s\n", nombVarDeOpe, tipos[pos].tipo );

            char  aux[100], aux4[9];
            if (strcmp(tipos[pos].tipo, "integer")==0 
            	|| strcmp(tipos[pos].tipo, "CONST_INT")==0 
            	)
			{
				sprintf(codigoAsm[cantLineaCodAsm++],"mov edx, 0");
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov ebx, [@aux%s]", vectorTercetos[i].t2);
				sprintf(codigoAsm[cantLineaCodAsm++],"idiv ebx");
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], eax", i);
			}
			else if (strcmp(tipos[pos].tipo, "real")==0
				|| strcmp(tipos[pos].tipo, "CONST_REAL")==0 )
			{
				sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", vectorTercetos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", vectorTercetos[i].t2);
				sprintf(codigoAsm[cantLineaCodAsm++],"fdivp st1, st0");
				sprintf(codigoAsm[cantLineaCodAsm++],"fstp [@aux%d]", i);

        	}
		}

		if (strcmp(vectorTercetos[i].operacion,"and")==0 || strcmp(vectorTercetos[i].operacion,"or")==0) 
		{
			// printf("OPERACION ES: %s\n",vectorTercetos[i].operacion);
			// printf("I ES: %d\n",i);

		    char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			//int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);
		
            agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares


		    if (strcmp(vectorTercetos[i].operacion,"and")==0) {
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 0", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 0");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t2);	
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 0");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);	
            	sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 1", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"end_%d:", i);
		    } 
		    else if (strcmp(vectorTercetos[i].operacion,"or")==0) {
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 1", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 1");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", vectorTercetos[i].t2);	
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 1");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);	
            	sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 0", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"end_%d:", i);		    	
		    }
	    }

		if (strcmp(vectorTercetos[i].operacion,"<>")==0 )  //BNE
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca la variable en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);		
            agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares

		    if (strcmp(vectorSymbol[pos].tipo,"integer")==0) 
			{
				aux[0]='\0';
				strcpy(aux,"mov eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			else
			{
				aux[0]='\0';
				strcpy(aux,"fld [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
                sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4,"%d",vectorTercetos[i].numeroTerceto);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 1");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"jmp end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 0");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
		}
		
		if (strcmp(vectorTercetos[i].operacion,"==")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca la variable en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);		
	        agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares

		    if (strcmp(vectorSymbol[pos].tipo,"integer")==0) 
			{
				aux[0]='\0';
				strcpy(aux,"mov eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"jne cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			else
			{
				aux[0]='\0';
				strcpy(aux,"fld [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"jne cmp_");
				sprintf(aux4,"%d",vectorTercetos[i].numeroTerceto);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 1");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"jmp end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 0");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
		}
		
		if (strcmp(vectorTercetos[i].operacion,">")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);

			int pos = buscarEnVector(nombre); // busca la variable en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);		
	        agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares



		    if (strcmp(vectorSymbol[pos].tipo,"integer")==0) 
			{
				aux[0]='\0';
				strcpy(aux,"mov eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"jl cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			else
			{
				aux[0]='\0';
				strcpy(aux,"fld [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"jb cmp_");
				sprintf(aux4,"%d",vectorTercetos[i].numeroTerceto);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 1");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"jmp end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 0");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
		}
		
		if (strcmp(vectorTercetos[i].operacion,">=")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca la variable en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);		
	        agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares
		    if (strcmp(vectorSymbol[pos].tipo,"integer")==0) 
			{
				aux[0]='\0';
				strcpy(aux,"mov eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"jl cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				/*aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);*/
			
			}
			else
			{
				aux[0]='\0';
				strcpy(aux,"fld [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"jb cmp_");
				sprintf(aux4,"%d",vectorTercetos[i].numeroTerceto);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				/*aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);*/
			
			}
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 1");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"jmp end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 0");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
		}
		
		if (strcmp(vectorTercetos[i].operacion,"<")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);		
	        agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares
		    if (strcmp(vectorSymbol[pos].tipo,"integer")==0) 
			{
				aux[0]='\0';
				strcpy(aux,"mov eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"jg cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			else
			{
				aux[0]='\0';
				strcpy(aux,"fld [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", vectorTercetos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"ja cmp_");
				sprintf(aux4,"%d",vectorTercetos[i].numeroTerceto);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			}
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 1");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"jmp end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"mov [@aux");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,"], 0");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
			
			aux[0]='\0';
			strcpy(aux,"end_cmp_");
			sprintf(aux4, "%d", i);
			strcat(aux,aux4);
			strcat(aux,":");
			sprintf(codigoAsm[cantLineaCodAsm++],aux);
		}
		
		if (strcmp(vectorTercetos[i].operacion,"<=")==0 )  
			{
				char nombre[35];
				char aux[100];
				char operacion[50];
				strcpy(nombre,vectorTercetos[atoi(vectorTercetos[i].t1)].operacion);
				int pos = buscarEnVector(nombre); // busca la variable en la tabla de simbolos
				char auxNombre[100];
				auxNombre[0]='\0';
				char aux4[6];
				sprintf(auxNombre, "@aux%d", i);		
	            agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares
			    if (strcmp(vectorSymbol[pos].tipo,"integer")==0) 
				{
					aux[0]='\0';
					strcpy(aux,"mov eax, [@aux");
					sprintf(aux4, "%s", vectorTercetos[i].t1);
					strcat(aux,aux4);
					strcat(aux,"]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
				   
					aux[0]='\0';
					strcpy(aux,"cmp eax, [@aux");
					sprintf(aux4, "%s", vectorTercetos[i].t2);
					strcat(aux,aux4);
					strcat(aux, "]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
					
					aux[0]='\0';
					strcpy(aux,"jg cmp_");
					sprintf(aux4, "%d", i);
					strcat(aux,aux4);
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
					
					/*aux[0]='\0';
					strcpy(aux,"je cmp_");
					sprintf(aux4, "%d", i);
					strcat(aux,aux4);
					sprintf(codigoAsm[cantLineaCodAsm++],aux);*/
				
				}
				else
				{
					aux[0]='\0';
					strcpy(aux,"fld [@aux");
					sprintf(aux4, "%s", vectorTercetos[i].t1);
					strcat(aux,aux4);
					strcat(aux,"]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
							
					aux[0]='\0';
					strcpy(aux,"fcomp [@aux");
					sprintf(aux4, "%s", vectorTercetos[i].t2);
					strcat(aux,aux4);
					strcat(aux, "]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
							
					sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	                sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
					
					aux[0]='\0';
					strcpy(aux,"ja cmp_");
					sprintf(aux4,"%d",vectorTercetos[i].numeroTerceto);
					strcat(aux,aux4);
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
					
					/*aux[0]='\0';
					strcpy(aux,"je cmp_");
					sprintf(aux4, "%d", i);
					strcat(aux,aux4);
					sprintf(codigoAsm[cantLineaCodAsm++],aux);*/
				
				}
				aux[0]='\0';
				strcpy(aux,"mov [@aux");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				strcat(aux,"], 1");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"jmp end_cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				strcat(aux,":");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"mov [@aux");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				strcat(aux,"], 0");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
				
				aux[0]='\0';
				strcpy(aux,"end_cmp_");
				sprintf(aux4, "%d", i);
				strcat(aux,aux4);
				strcat(aux,":");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
		}
		
		
			
		if (strcmp(vectorTercetos[i].operacion, "++")==0) 
		{	
			char aux23[100];	
			sprintf(aux23, "@aux%d", i);
			agregarVariable(aux23, "string");

			sprintf(codigoAsm[cantLineaCodAsm++], "invoke lstrcpy, @aux%d, @aux%s",i,vectorTercetos[i].t1); 			
			sprintf(codigoAsm[cantLineaCodAsm++], "invoke lstrcat, @aux%d, @aux%s",i,vectorTercetos[i].t2);
		}
		
		if (strcmp(vectorTercetos[i].operacion, "label")==0) 
		{
			sprintf(codigoAsm[cantLineaCodAsm++], "%s:",vectorTercetos[i].t1);
		}
		
		if (strcmp(vectorTercetos[i].operacion, "jump")==0) 
		{
			sprintf(codigoAsm[cantLineaCodAsm++], "jmp %s",vectorTercetos[i].t1);
		}
		
		if (strcmp(vectorTercetos[i].operacion, "ifnot")==0) 
		{
			sprintf(codigoAsm[cantLineaCodAsm++], "mov eax, [@aux%s]",vectorTercetos[i].t1);
			sprintf(codigoAsm[cantLineaCodAsm++], "cmp eax, 0");
			sprintf(codigoAsm[cantLineaCodAsm++], "je %s",vectorTercetos[i].t2);
		}

		if (strcmp(vectorTercetos[i].operacion, "not")==0) 
		{
			char aux23[100];	
			sprintf(aux23, "@aux%d", i);
			agregarVariable(aux23, "integer");
			
			sprintf(codigoAsm[cantLineaCodAsm++], "mov [@aux%d], 0",i);
			sprintf(codigoAsm[cantLineaCodAsm++], "mov eax, [@aux%s]",vectorTercetos[i].t1);
			sprintf(codigoAsm[cantLineaCodAsm++], "cmp eax, 1");
			sprintf(codigoAsm[cantLineaCodAsm++], "je end_%d",i);
			sprintf(codigoAsm[cantLineaCodAsm++], "mov [@aux%d], 1",i);
			sprintf(codigoAsm[cantLineaCodAsm++], "end_%d:",i);
		}

		if (strcmp(vectorTercetos[i].operacion, "fin")==0) {
			strcpy(codigoAsm[cantLineaCodAsm++], "; Fin del programa"); 
			strcpy(codigoAsm[cantLineaCodAsm++], "invoke getchar"); 
			strcpy(codigoAsm[cantLineaCodAsm++], "invoke getchar"); 
			strcpy(codigoAsm[cantLineaCodAsm++], "invoke ExitProcess, 0"); 
		}
			//sprintf(codigoAsm[cantLineaCodAsm++], "");
	} // for
		

	//============================= Grabacion cod assembler =========================================
	grabarAssembler();
	//=========================================fin grabacion ==================================
}

// Grabacion del assembler generado
void grabarAssembler()
{
	int i;
	FILE* arch = fopen(ENCABEZADO, "w+");

	// Cabecera
	fprintf(arch, "%s\n", "format PE console");
	fprintf(arch, "%s\n", "entry main");
	fprintf(arch, "%s\n", "include 'c:\\fasm\\include\\win32a.inc'");
	fprintf(arch, "\n");
	fprintf(arch, "%s\n" , "section '.data' data readable writable");

	fprintf(arch, "\t%s\n", "@formato_integer db \"%d\", 0");
	fprintf(arch, "\t%s\n", "@formato_real db \"%lf\", 0");
	fprintf(arch, "\t%s\n", "@formato_string db \"%s\", 0");
	fprintf(arch, "\t%s\n", "cr db 13,10,0                    ; retorno de carro");

	fprintf(arch,"\n");

	// Variables 
	for (i = 0; i < cantVarAsm; ++i) {
		fprintf(arch,"\t%s\n", variablesAsm[i]);	
	}
	fprintf(arch,"\n");

	//Seccion codigo
	fprintf(arch, "%s\n", "section '.code' code readable executable" );	
	fprintf(arch, "%s\n", "\tmain:");
	fprintf(arch, "%s\n", "\tfinit");
                
    for (i = 0; i < cantLineaCodAsm; ++i) {
		fprintf(arch,"\t%s\n", codigoAsm[i]);	
	}          
	fprintf(arch,"\n");

	// Imports
	fprintf(arch, "%s\n", "section '.import' import data readable");
	fprintf(arch, "%s\n", "library kernel, 'kernel32.dll',\\");
	fprintf(arch, "%s\n","\tmsvcrt, 'msvcrt.dll'");
	fprintf(arch, "%s\n","import kernel, \\");
	fprintf(arch, "%s\n","\tlstrcat, 'lstrcat',\\");
	fprintf(arch, "%s\n","\tlstrcpy, 'lstrcpy',\\");
	fprintf(arch, "%s\n","\tExitProcess, 'ExitProcess'");
	fprintf(arch, "%s\n","import msvcrt, \\");
	fprintf(arch, "%s\n", "\titoa, '_itoa',\\");
	fprintf(arch, "%s\n", "\tftoa, '_ftoa',\\");
    fprintf(arch, "%s\n", "\tprintf, 'printf',\\");    
    fprintf(arch, "%s\n", "\tgetchar, '_fgetchar',\\");   
	fprintf(arch, "%s\n", "\tscanf, 'scanf'");   

	fclose(arch);
}

// Genera un string del terceto pasado por parametros y lo coloca en el segundo parametro
void toStringTerceto(t_terceto t, char* lineaTerceto) {	
	if(strcmp(t.operacion, "BI")==0) //salto no condicional
		sprintf(lineaTerceto, "[%d] (%s, [%s], -)", t.numeroTerceto, t.operacion, t.t2);
	else if(strcmp(t.t1,"-1")==0 && strcmp(t.t2 , "-1")==0) //terceto de asignacion de memoria
		sprintf(lineaTerceto, "[%d] (%s, _, _)", t.numeroTerceto, t.operacion);
	else if(strcmp(t.t2, "-1")==0) //terceto en el caso cuando se escriben los cmp 
		sprintf(lineaTerceto, "[%d] (%s, [%s], _)", t.numeroTerceto, t.operacion, t.t1);
	else //terceto completo sin problemas
		sprintf(lineaTerceto, "[%d] (%s, [%s], [%s])", t.numeroTerceto, t.operacion, t.t1, t.t2);
}

int addTipo (char* nombreVariable, char* tipo) {
	int pos;
	pos = buscarEnArrayTipos(nombreVariable, tipo);
	
	if (pos >= 0) {
			mostrarError(ERROR_ID_DUPLICADO, NULL);
	}

	if (pos == -1) {
		pos = cantElemTipos++;	
		
		tipos = (struct DiccionarioTipos*) realloc(tipos, cantElemTipos * sizeof(struct DiccionarioTipos));
		
		if (tipos == NULL) {
			mostrarError(ERROR_MEMORIA, "realloc del array de tipos en addTipo()");	
		}
	
		//strcpy(vectorSymbol[pos].nombreVar, nombreVariable);		
		//strcpy(vectorSymbol[pos].tipo, tipo);
		strcpy(tipos[pos].variable, nombreVariable);		
		strcpy(tipos[pos].tipo, tipo);
		
	
		//printf("pos_cant_elementos: %d\n",pos);
		
	}
	
	return pos;
}

int buscarEnArrayTipos(char* _nombre, char* _tipo) {
	int i;
	for ( i = 0; i < cantElemTipos; i++ ) { //recorro el vector
		if (strcmp(tipos[i].variable, _nombre) == 0 && strcmp(tipos[i].tipo, _tipo) == 0) { 
			return i; //ya existe
		}
	}
	
	return -1;
}



int buscarTipoEnArrayTipos(char* _nombre) {
	int i;
	for ( i = 0; i < cantElemTipos; i++ ) { //recorro el vector
		if (strcmp(tipos[i].variable, _nombre) == 0) { 
			return i; //ya existe
		}
	}
	
	return -1;
}
void generarVariablesUsuario()
{	int i;
	for ( i = 0; i < cantElementos; ++i ) // recorro la tabla de simbolos
	{
		if (strcmp(vectorSymbol[i].tipo,"string")==0 || strcmp(vectorSymbol[i].tipo,"integer")==0 ||strcmp(vectorSymbol[i].tipo,"real")==0 )
		{char aux[100]="";
		strcat(aux,"_");
		strcat(aux,vectorSymbol[i].nombreVar);
		agregarVariable(aux, vectorSymbol[i].tipo);
		}
	/*	else	
			agregarVariable(vectorSymbol[i].nombreVar, vectorSymbol[i].tipo);
		*/
		
	}
}

void agregarVariable(char* variable, char* tipo) {
	char valor[35];

	if (strcmp(tipo,"integer")==0 || strcmp(tipo,"CONST_INT")==0) {
		strcpy(valor,"?");
	}
	else if (strcmp(tipo,"real")==0 || strcmp(tipo,"CONST_REAL")==0 ) {
		strcpy(valor,"?");
	}
	else if ((strcmp(tipo,"string")==0 || strcmp(tipo,"CONST_STR")==0 )) {
		strcpy(valor,"255 dup (?)");
	}

    agregarVariableConValor(variable, tipo, valor);
}

void agregarVariableConValor(char* variable, char* tipo, char* valor) {
    char tipoAssembler[20];

 if (strcmp(tipo,"integer")==0 || strcmp(tipo,"CONST_INT")==0) {
    	strcpy(tipoAssembler, "dd");
    }
    else if (strcmp(tipo,"real")==0 || strcmp(tipo,"CONST_REAL")==0) {
    	strcpy(tipoAssembler,"dq");
    }
    else if (strcmp(tipo,"string")==0)
    {
    	strcpy(tipoAssembler,"db");
    }
    else if (strcmp(tipo,"CONST_STR")==0){
    	char auxValor[3]=",0";
    	strcpy(tipoAssembler,"db");
    	strcat(valor, auxValor);	
    }	
    
    char lineaAux[TAM_LINEA_VAR_ASM];
    sprintf(lineaAux, "%s %s %s", variable, tipoAssembler, valor);

    strcpy(variablesAsm[cantVarAsm],lineaAux);
    cantVarAsm++;

    addTipo(variable, tipo);
}
