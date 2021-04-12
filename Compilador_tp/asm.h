
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "constantes.h"
#include "pila.h"

FILE * pfASM; //Final.asm
t_pila pila;  //Pila saltos
t_pila pVariables;  //Pila variables

void imprimirFuncString(){
    
    int c;
    FILE *file;

    file = fopen("string.asm", "r");
    if (file) {
        fprintf(pfASM,"\n");
        while ((c = getc(file)) != EOF)
            fprintf(pfASM,"%c",c);
        fprintf(pfASM,"\n\n");
        fclose(file);
    }

}

void generarEncabezado(){
    //Encabezado del archivo
    fprintf(pfASM, "\nINCLUDE macros.asm\t\t ;incluye macros\n");
    fprintf(pfASM, "INCLUDE number.asm\t\t ;incluye el asm para impresion de numeros\n");
    //fprintf(pfASM, "INCLUDE string.asm\t\t ;incluye el asm para manejo de strings\n");    		 
    fprintf(pfASM, "\n.MODEL LARGE ; tipo del modelo de memoria usado.\n");
    fprintf(pfASM, ".386\n");
    fprintf(pfASM, ".STACK 200h ; bytes en el stack\n");              
}


void generarDatos(){
    int i = 0;
    symbol elemento;
    char aux[STR_VALUE];
    //Encabezado del sector de datos
    fprintf(pfASM, "\t\n.DATA ; comienzo de la zona de datos.\n");    
    fprintf(pfASM, "\tTRUE equ 1\n");
    fprintf(pfASM, "\tFALSE equ 0\n");
    fprintf(pfASM, "\tMAXTEXTSIZE equ %d\n",COTA_STR);
    

    //Recorrer tabla de simbolos y armar el sector .data
    for(i = 0; i < pos_st; i++){
        elemento = symbolTable[i];   
        int empty = 0;
        if (strcmp(elemento.valor, "-") == 0)
            empty = 1;
             
        if (strcmp(elemento.tipo, "int") == 0 ) {                      
            fprintf(pfASM, "\t");            
            if (empty == 0)
                fprintf(pfASM, "%s dd %.6f\n",elemento.nombre,atof(elemento.valor));   
            else
                fprintf(pfASM, "%s dd %.6f\n",elemento.nombre, 0);   
        }    

        if (strcmp(elemento.tipo, "float") == 0 ) {                      
            fprintf(pfASM, "\t");
            if (empty == 0)
                fprintf(pfASM, "%s dd %.10f\n",elemento.nombre,atof(elemento.valor));
            else
                fprintf(pfASM, "%s dd %.10f\n",elemento.nombre, 0);
                
        }

        if (strcmp(elemento.tipo, "string") == 0 ) {   
                fprintf(pfASM, "\t");
                if(empty == 1)
                    fprintf(pfASM, "%s db MAXTEXTSIZE dup(?), '$'\n", elemento.nombre, elemento.valor, (COTA_STR - elemento.longitud));
                else
                    fprintf(pfASM, "%s db %s, '$', %d dup(?)\n", elemento.nombre, elemento.valor, (COTA_STR - elemento.longitud));
                    
        }
    }    
}

void imprimirInstrucciones(struct node* terc, int nTerc){
    char tConst,tConst2;
    char aux[STR_VALUE];
    char aux2[STR_VALUE] = "";
    char last[STR_VALUE] = "";
    char concat[STR_VALUE];
    symbol simbolo,simbolo2;
    int fromJump = 0;
    char etiq[40];
    //Verificar operación e imprimir instrucciones. 


    if (strcmp(terc->primero, ":=") == 0){
        fprintf(pfASM,"\t;ASIGNACIÓN\n");
        if(sacar_de_pila(&pVariables,aux,255) != PILA_VACIA)
        {            
            simbolo = getSymbolWP(aux);

            if(strcmp(simbolo.tipo, "string") == 0){
                fprintf(pfASM, "\tmov ax,@DATA\n");
                fprintf(pfASM, "\tmov es,ax\n");
                fprintf(pfASM, "\tmov si,OFFSET %s ;apunta el origen al auxiliar\n",aux);
                fprintf(pfASM, "\tmov di,OFFSET %s ;apunta el destino a la cadena\n",terc->cuarto);
                fprintf(pfASM, "\tcall COPIAR ;copia los string\n\n");
            }else{
                fprintf(pfASM, "\tfld %s\n",aux);
                fprintf(pfASM, "\tfstp %s\n\n",terc->cuarto);
            }
            
        }        
    }

    if (strcmp(terc->primero, "+") == 0){
        fprintf(pfASM,"\t;SUMA\n");
        if(sacar_de_pila(&pVariables,aux,255) != PILA_VACIA)
        {
            if(sacar_de_pila(&pVariables,aux2,255) != PILA_VACIA)
            {
                fprintf(pfASM, "\tfld %s\n",aux);
                fprintf(pfASM, "\tfld %s\n",aux2);
                fprintf(pfASM, "\tfadd\n");
                //fprintf(pfASM, "\tlocal %s\n",aux); // Variable local en vez de los aux de arriba

                //guardar valor en aux
                if(strcmp(aux,"&aux2") == 0){
                    fprintf(pfASM, "\tfstp &aux3\n\n");                    
                    poner_en_pila(&pVariables,"&aux3",255);
                }else{
                    fprintf(pfASM, "\tfstp &aux2\n\n");                    
                    poner_en_pila(&pVariables,"&aux2",255);
                }
            }                
        }     
    }

    if (strcmp(terc->primero, "-") == 0){
        fprintf(pfASM,"\t;RESTA\n");
        if(sacar_de_pila(&pVariables,aux,255) != PILA_VACIA)
        {
            if(sacar_de_pila(&pVariables,aux2,255) != PILA_VACIA)
            {
                fprintf(pfASM, "\tfld %s\n",aux2);
                fprintf(pfASM, "\tfld %s\n",aux);
                fprintf(pfASM, "\tfsub\n");
                //fprintf(pfASM, "\tlocal %s\n",aux); // Variable local en vez de los aux de arriba

                //guardar valor en aux
                if(strcmp(aux,"&aux2") == 0){
                    fprintf(pfASM, "\tfstp &aux3\n\n");                    
                    poner_en_pila(&pVariables,"&aux3",255);
                }else{
                    fprintf(pfASM, "\tfstp &aux2\n\n");                    
                    poner_en_pila(&pVariables,"&aux2",255);
                }
            }                
        }     
    }

    if (strcmp(terc->primero, "*") == 0){
        fprintf(pfASM,"\t;MULTIPLICACION\n");
        if(sacar_de_pila(&pVariables,aux,255) != PILA_VACIA)
        {
            if(sacar_de_pila(&pVariables,aux2,255) != PILA_VACIA)
            {
                fprintf(pfASM, "\tfld %s\n",aux);
                fprintf(pfASM, "\tfld %s\n",aux2);
                fprintf(pfASM, "\tfmul\n");
                //fprintf(pfASM, "\tlocal %s\n",aux); // Variable local en vez de los aux de arriba

                //guardar valor en aux
                if(strcmp(aux,"&aux2") == 0){
                    fprintf(pfASM, "\tfstp &aux3\n\n");                    
                    poner_en_pila(&pVariables,"&aux3",255);
                }else{
                    fprintf(pfASM, "\tfstp &aux2\n\n");                    
                    poner_en_pila(&pVariables,"&aux2",255);
                }
            }                
        }     
    }

    if (strcmp(terc->primero, "/") == 0){
        fprintf(pfASM,"\t;DIVISION\n");
        if(sacar_de_pila(&pVariables,aux,255) != PILA_VACIA)
        {
            if(sacar_de_pila(&pVariables,aux2,255) != PILA_VACIA)
            {
                fprintf(pfASM, "\tfld %s\n",aux2);
                fprintf(pfASM, "\tfld %s\n",aux);
                fprintf(pfASM, "\tfdiv\n");
                //fprintf(pfASM, "\tlocal %s\n",aux); // Variable local en vez de los aux de arriba

                //guardar valor en aux
                if(strcmp(aux,"&aux2") == 0){
                    fprintf(pfASM, "\tfstp &aux3\n\n");                    
                    poner_en_pila(&pVariables,"&aux3",255);
                }else{
                    fprintf(pfASM, "\tfstp &aux2\n\n");                    
                    poner_en_pila(&pVariables,"&aux2",255);
                }
            }                
        }     
    }    

    if (strcmp(terc->primero, "WRITE") == 0){

        fprintf(pfASM,"\t;WRITE\n");

        if(terc->segundo != -2)
            sacar_de_pila(&pVariables,aux,255);
        else
            sprintf(aux,"%s",terc->cuarto);         

        simbolo = getSymbolWP(aux);

        if(strcmp(simbolo.tipo, "string") == 0){
            fprintf(pfASM,"\tdisplayString %s\n",aux);
            fprintf(pfASM, "\tnewLine 1\n\n"); 
        }

        if(strcmp(simbolo.tipo, "int") == 0){
            fprintf(pfASM,"\tDisplayFloat %s 0\n",aux);
            fprintf(pfASM, "\tnewLine 1\n\n"); 
        }

        if(strcmp(simbolo.tipo, "float") == 0){
            fprintf(pfASM,"\tDisplayFloat %s 2\n",aux);
            fprintf(pfASM, "\tnewLine 1\n\n"); 
        }
    }

    if (strcmp(terc->primero, "READ") == 0){

        fprintf(pfASM,"\t;READ\n");

        sprintf(aux,"%s",terc->cuarto);            
        simbolo = getSymbolWP(aux);

        if(strcmp(simbolo.tipo, "string") == 0){
            fprintf(pfASM,"\tgetString %s\n\n",aux);
        }

        if(strcmp(simbolo.tipo, "int") == 0){
            fprintf(pfASM,"\tGetInteger %s\n\n",aux);
        }

        if(strcmp(simbolo.tipo, "float") == 0){
            fprintf(pfASM,"\tGetFloat %s\n\n",aux);
        }
    }

    if (strcmp(terc->primero, "CMP") == 0){
        fprintf(pfASM,"\t;CMP\n");
        if(sacar_de_pila(&pVariables,aux,255) != PILA_VACIA)
        {
            if(sacar_de_pila(&pVariables,aux2,255) != PILA_VACIA)
            {
                fprintf(pfASM, "\tfld %s\n",aux);
                fprintf(pfASM, "\tfld %s\n",aux2);                    
                fprintf(pfASM, "\tfcomp\n");
                fprintf(pfASM, "\tfstsw ax\n");
                fprintf(pfASM, "\tfwait\n");
                fprintf(pfASM, "\tsahf\n\n");                            
            }
        } 
    }      
    if (strcmp(terc->primero, "JBE") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tjbe %s\n",aux);
    }

    if (strcmp(terc->primero, "JE") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tje %s\n",aux);
    }

    if (strcmp(terc->primero, "JNE") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tjne %s\n",aux);
    }

    if (strcmp(terc->primero, "JB") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tjb %s\n",aux);
    }

    if (strcmp(terc->primero, "JA") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tja %s\n",aux);
    }

    if (strcmp(terc->primero, "JAE") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tjae %s\n",aux);
    }    

    if (strcmp(terc->primero, "JMP") == 0){

        sprintf(aux,"ETIQUETA%d", terc->tercero);
        fprintf(pfASM, "\tjmp %s\n",aux);
    }

    if (strcmp(terc->primero, "ETIQUETA") == 0){
        sprintf(aux,"ETIQUETA%d:",terc->indice);                            
        fprintf(pfASM,"ETIQUETA%d:\n",terc->indice);  
    } 
    else {

        if (terc->segundo == -1 && terc->tercero == -1){
            sprintf(aux,"%s",terc->primero);            
            poner_en_pila(&pVariables,&aux,255);
        }          
    }


            
}



void generarCodigo(){

    struct node *r;
    r=lista_tercetos;
    if(r==NULL)
    {
		printf("NO ELEMENT IN THE LIST :");
		return;
    }

    int i = 0;

    //Encabezado del sector de codigo
    fprintf(pfASM, "\n.CODE ;Comienzo de la zona de codigo\n");

    //Imprimo funciones de manejo de strings
    imprimirFuncString();

    //Inicio codigo usuario
    fprintf(pfASM, "START: ;Código assembler resultante de compilar el programa fuente.\n");
    fprintf(pfASM, "\tmov AX,@DATA ;Inicializa el segmento de datos\n");
    fprintf(pfASM, "\tmov DS,AX\n");
    fprintf(pfASM, "\tfinit\n\n");

    //Recorrer e imprimir assembler
    if(r)
	{        
        //Recorrer lista            
		while(r)
		{
            //Imprimir assembler            
            imprimirInstrucciones(r,i);

            //Pasar al siguiente terceto
            r = r->next;
            i++;
        }                
    }

}

void generarFin(){
    //Fin de ejecución
    //fprintf(pfASM, "\n;\n");
    fprintf(pfASM, "\nTERMINAR: ;Fin de ejecución.\n");

    fprintf(pfASM, "\tmov ax, 4C00h ; termina la ejecución.\n");
    fprintf(pfASM, "\tint 21h; syscall\n");
    fprintf(pfASM, "\nEND START;final del archivo.");    
}



void generarASM(){ 
    //Abrir archivo
    pfASM = fopen("Final.asm","wt+");

    //Crear pilas para sacar los tercetos.
    crear_pila(&pila);
    crear_pila(&pVariables);

    //Copiar tercetos
    //lista_terceto = &lTercetos;

    //Generar archivo ASM
    fprintf(pfASM, ";\n;FINAL.ASM\n;\n");

    generarEncabezado();
    generarDatos();    
    generarCodigo();    
    generarFin();

    //Cerrar archivo
    fclose(pfASM);
}
