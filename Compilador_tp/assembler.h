#define TAM_LINEA_TERCETO	200
#define ERROR_ID_NO_DECLARADO -101
#define ENCABEZADO "Final.asm"
#define TAM_LINEA_VAR_ASM		100
#define TAM_LINEA_COD_ASM		150
#define CANT_LINEAS_VAR_ASM		300
#define CANT_LINEAS_COD_ASM		700


char codigoAsm[CANT_LINEAS_COD_ASM][TAM_LINEA_COD_ASM];			// HACERLO DINAMICO!!!pORQUE SOLO SOPORTA 21 LINEAS DE CODIGO
int cantLineaCodAsm = 0;
int cantVarAsm = 0;
char aux4[40];
char aux5[40];
char auxAsignacionID[30];	

//Genera el codigo assembler del programa
void generarAssembler(){
	int i;
	char lineaTerceto[TAM_LINEA_TERCETO];
	
	generarVariablesUsuario();  			
	

	for (i=0; i < nroTerceto; i++) 
	{ 
		if(Simbolos[i].numeroTerceto==75)
			{
				strcpy(Simbolos[i].t1,"main_else_1");
			}
		toStringTerceto(Simbolos[i], lineaTerceto);
		sprintf(codigoAsm[cantLineaCodAsm++],";%s", lineaTerceto);

		if (Simbolos[i].operacion[0]=='_' && strcmp(Simbolos[i].t1, "-1")==0 && strcmp(Simbolos[i].t2,"-1")==0 )
		//Constantes	
		{	
			int pos = buscarEnVector(Simbolos[i].operacion);
			if ( pos == -1 ) {
				printf("operacion: %s\n",Simbolos[i].operacion);
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
		else if (strcmp(Simbolos[i].operacion,"fin")!=0 
				 && strcmp(Simbolos[i].t1,"-1")==0 && strcmp(Simbolos[i].t2,"-1")==0
				 /* 
				 && strncmp(Simbolos[i].operacion,"label_end_if_", sizeof("label_end_if_")-1)!=0
				 && strncmp(Simbolos[i].operacion,"main_endif_", sizeof("main_endif_")-1)!=0
				 && strncmp(Simbolos[i].operacion,"main_else_", sizeof("main_else_")-1)!=0
				 && strncmp(Simbolos[i].operacion,"main_while_", sizeof("main_while_")-1)!=0  
				 && strncmp(Simbolos[i].operacion,"main_endwhile_", sizeof("main_endwhile_")-1)!=0 
				 && strncmp(Simbolos[i].operacion,"ifnot ", sizeof("ifnot ")-1)!=0 
				 */
				 && strcmp(Simbolos[i].operacion,"label")!=0 ) 
		//Variables
		{	
		
			int pos = buscarEnVector(Simbolos[i].operacion);
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

		if (strcmp(Simbolos[i].operacion,":=")==0) 
		{
			char nombre[35];
			char nombre2[35];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
			strcpy(nombre2,Simbolos[atoi(Simbolos[i].t2)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			int pos2 = buscarEnVector(nombre2); // busca en la tabla de simbolos
			char aux2[3];
			char aux[100];
			if (strcmp(vectorSymbol[pos].tipo, "integer")==0 && strcmp(vectorSymbol[pos2].tipo, "real")!=0)
			{	
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t2);			
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%s], eax", Simbolos[i].t1);			
				
            } 
			else
				{	
					if(strcmp(vectorSymbol[pos].tipo, "integer")==0 && strcmp(vectorSymbol[pos2].tipo, "real")==0)
						{sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, dword [@aux%s]", Simbolos[i].t2);			
						 sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%s], eax", Simbolos[i].t1);			
						}
					else
						{		
								if (strcmp(vectorSymbol[pos].tipo, "real")==0) 
								{
									sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, dword [@aux%s]", Simbolos[i].t2);
									sprintf(codigoAsm[cantLineaCodAsm++],"mov ebx, dword [@aux%s + 4]", Simbolos[i].t2);
									sprintf(codigoAsm[cantLineaCodAsm++],"mov dword [@aux%s], eax", Simbolos[i].t1);
									sprintf(codigoAsm[cantLineaCodAsm++],"mov dword [@aux%s + 4], ebx", Simbolos[i].t1);
								} 
								else 
								{
									sprintf(codigoAsm[cantLineaCodAsm++],"invoke lstrcpy, @aux%s, @aux%s", Simbolos[i].t1, Simbolos[i].t2);
								}
						}
				}
			  
		}
		
		if (strcmp(Simbolos[i].operacion,"WRITE")==0) 
		{
			char nombre[35];
			Simbolos[i].t1;
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			
			
			char aux[250]="";

			 if (strcmp(vectorSymbol[pos].tipo, "integer")==0
			 	 || strcmp(vectorSymbol[pos].tipo, "CONST_INT")==0) {

                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, @formato_integer, dword [@aux%s]", Simbolos[i].t1);
                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, cr");
             } else if (strcmp(vectorSymbol[pos].tipo, "real")==0 
             		    || strcmp(vectorSymbol[pos].tipo, "CONST_REAL")==0 ) { 
                    	sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, @formato_real, dword [@aux%s], \\", Simbolos[i].t1);
						sprintf(codigoAsm[cantLineaCodAsm++],"\tdword [@aux%s + 4]", Simbolos[i].t1);
						sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, cr");
             } else {
                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, @formato_string, @aux%s", Simbolos[i].t1);
                        sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke printf, cr");
             }
			
		}
		if (strcmp(Simbolos[i].operacion,"READ")==0) 
		{
			char nombre[35];
			Simbolos[i].t1;
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
			int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			
			if (strcmp(vectorSymbol[pos].tipo, "integer")==0) 
				sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke scanf,  @formato_integer, @aux%s", Simbolos[i].t1);
			else 
				if (strcmp(vectorSymbol[pos].tipo, "real")==0) 
					sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke scanf, @formato_real, @aux%s", Simbolos[i].t1);
				else 
					if (strcmp(vectorSymbol[pos].tipo, "string")==0) 
						sprintf(codigoAsm[cantLineaCodAsm++],"cinvoke scanf, @formato_string, @aux%s", Simbolos[i].t1);
		}	

		if (strcmp(Simbolos[i].operacion,"+")==0 || strcmp(Simbolos[i].operacion,"-")==0 || strcmp(Simbolos[i].operacion,"*")==0) 
		{			
			// Busqueda de valor y tipo del primer operando de la operacion
			char nombreVarBusq[35];	
			sprintf(nombreVarBusq, "@aux%s", Simbolos[i].t1);
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
					
				if(strcmp(Simbolos[i].operacion,"+")==0)
					strcpy(operacion,"add");	
				else
					if(strcmp(Simbolos[i].operacion,"-")==0)
						strcpy(operacion,"sub");
					else	
						strcpy(operacion,"imul");


				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"%s eax, [@aux%s]", operacion, Simbolos[i].t2);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], eax", i);
						
            } 
			else if (strcmp(tipos[pos].tipo, "real")==0 
				     || strcmp(tipos[pos].tipo, "CONST_REAL")==0) 
			{
					char operacion[50];
					operacion[0]='\0';			
					if(strcmp(Simbolos[i].operacion,"+")==0)
						strcpy(operacion,"faddp");
					else 
						if(strcmp(Simbolos[i].operacion,"-")==0)
							strcpy(operacion,"fsubp");
						else	
							strcpy(operacion,"fmulp");
					

					sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", Simbolos[i].t1);
					sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", Simbolos[i].t2);
					sprintf(codigoAsm[cantLineaCodAsm++],"%s st1, st0", operacion);
					sprintf(codigoAsm[cantLineaCodAsm++],"fstp [@aux%d]", i);
        	}
		}
		
			
		if (strcmp(Simbolos[i].operacion,"/")==0) 
		{
			// Busqueda de valor y tipo del primer operando de la operacion
			char nombreVarBusq[35];	
			sprintf(nombreVarBusq, "@aux%s", Simbolos[i].t1);
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
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov ebx, [@aux%s]", Simbolos[i].t2);
				sprintf(codigoAsm[cantLineaCodAsm++],"idiv ebx");
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], eax", i);
			}
			else if (strcmp(tipos[pos].tipo, "real")==0
				|| strcmp(tipos[pos].tipo, "CONST_REAL")==0 )
			{
				sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", Simbolos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"fld [@aux%s]", Simbolos[i].t2);
				sprintf(codigoAsm[cantLineaCodAsm++],"fdivp st1, st0");
				sprintf(codigoAsm[cantLineaCodAsm++],"fstp [@aux%d]", i);

        	}
		}

		if (strcmp(Simbolos[i].operacion,"and")==0 || strcmp(Simbolos[i].operacion,"or")==0) 
		{
			// printf("OPERACION ES: %s\n",Simbolos[i].operacion);
			// printf("I ES: %d\n",i);

		    char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
			//int pos = buscarEnVector(nombre); // busca en la tabla de simbolos
			char auxNombre[100];
			auxNombre[0]='\0';
			char aux4[6];
			sprintf(auxNombre, "@aux%d", i);
		
            agregarVariable(auxNombre, "integer");	// agrega variable a la lista de variables auxiliares


		    if (strcmp(Simbolos[i].operacion,"and")==0) {
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 0", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 0");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t2);	
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 0");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);	
            	sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 1", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"end_%d:", i);
		    } 
		    else if (strcmp(Simbolos[i].operacion,"or")==0) {
				sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 1", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t1);
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 1");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"mov eax, [@aux%s]", Simbolos[i].t2);	
				sprintf(codigoAsm[cantLineaCodAsm++],"cmp eax, 1");
				sprintf(codigoAsm[cantLineaCodAsm++],"je end_%d", i);	
            	sprintf(codigoAsm[cantLineaCodAsm++],"mov [@aux%d], 0", i);
				sprintf(codigoAsm[cantLineaCodAsm++],"end_%d:", i);		    	
		    }
	    }

		if (strcmp(Simbolos[i].operacion,"<>")==0 )  //BNE
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
                sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"je cmp_");
				sprintf(aux4,"%d",Simbolos[i].numeroTerceto);
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
		
		if (strcmp(Simbolos[i].operacion,"==")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"jne cmp_");
				sprintf(aux4,"%d",Simbolos[i].numeroTerceto);
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
		
		if (strcmp(Simbolos[i].operacion,">")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);

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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"jb cmp_");
				sprintf(aux4,"%d",Simbolos[i].numeroTerceto);
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
		
		if (strcmp(Simbolos[i].operacion,">=")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"jb cmp_");
				sprintf(aux4,"%d",Simbolos[i].numeroTerceto);
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
		
		if (strcmp(Simbolos[i].operacion,"<")==0 )  
		{
			char nombre[35];
			char aux[100];
			char operacion[50];
			strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
			   
				aux[0]='\0';
				strcpy(aux,"cmp eax, [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
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
				sprintf(aux4, "%s", Simbolos[i].t1);
				strcat(aux,aux4);
				strcat(aux,"]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				aux[0]='\0';
				strcpy(aux,"fcomp [@aux");
				sprintf(aux4, "%s", Simbolos[i].t2);
				strcat(aux,aux4);
				strcat(aux, "]");
				sprintf(codigoAsm[cantLineaCodAsm++],aux);
						
				sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	            sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
				
				aux[0]='\0';
				strcpy(aux,"ja cmp_");
				sprintf(aux4,"%d",Simbolos[i].numeroTerceto);
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
		
		if (strcmp(Simbolos[i].operacion,"<=")==0 )  
			{
				char nombre[35];
				char aux[100];
				char operacion[50];
				strcpy(nombre,Simbolos[atoi(Simbolos[i].t1)].operacion);
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
					sprintf(aux4, "%s", Simbolos[i].t1);
					strcat(aux,aux4);
					strcat(aux,"]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
				   
					aux[0]='\0';
					strcpy(aux,"cmp eax, [@aux");
					sprintf(aux4, "%s", Simbolos[i].t2);
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
					sprintf(aux4, "%s", Simbolos[i].t1);
					strcat(aux,aux4);
					strcat(aux,"]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
							
					aux[0]='\0';
					strcpy(aux,"fcomp [@aux");
					sprintf(aux4, "%s", Simbolos[i].t2);
					strcat(aux,aux4);
					strcat(aux, "]");
					sprintf(codigoAsm[cantLineaCodAsm++],aux);
							
					sprintf(codigoAsm[cantLineaCodAsm++],"fnstsw ax");
	                sprintf(codigoAsm[cantLineaCodAsm++],"sahf");
					
					aux[0]='\0';
					strcpy(aux,"ja cmp_");
					sprintf(aux4,"%d",Simbolos[i].numeroTerceto);
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
		
		
			
		if (strcmp(Simbolos[i].operacion, "++")==0) 
		{	
			char aux23[100];	
			sprintf(aux23, "@aux%d", i);
			agregarVariable(aux23, "string");

			sprintf(codigoAsm[cantLineaCodAsm++], "invoke lstrcpy, @aux%d, @aux%s",i,Simbolos[i].t1); 			
			sprintf(codigoAsm[cantLineaCodAsm++], "invoke lstrcat, @aux%d, @aux%s",i,Simbolos[i].t2);
		}
		
		if (strcmp(Simbolos[i].operacion, "label")==0) 
		{
			sprintf(codigoAsm[cantLineaCodAsm++], "%s:",Simbolos[i].t1);
		}
		
		if (strcmp(Simbolos[i].operacion, "jump")==0) 
		{
			sprintf(codigoAsm[cantLineaCodAsm++], "jmp %s",Simbolos[i].t1);
		}
		
		if (strcmp(Simbolos[i].operacion, "ifnot")==0) 
		{
			sprintf(codigoAsm[cantLineaCodAsm++], "mov eax, [@aux%s]",Simbolos[i].t1);
			sprintf(codigoAsm[cantLineaCodAsm++], "cmp eax, 0");
			sprintf(codigoAsm[cantLineaCodAsm++], "je %s",Simbolos[i].t2);
		}

		if (strcmp(Simbolos[i].operacion, "not")==0) 
		{
			char aux23[100];	
			sprintf(aux23, "@aux%d", i);
			agregarVariable(aux23, "integer");
			
			sprintf(codigoAsm[cantLineaCodAsm++], "mov [@aux%d], 0",i);
			sprintf(codigoAsm[cantLineaCodAsm++], "mov eax, [@aux%s]",Simbolos[i].t1);
			sprintf(codigoAsm[cantLineaCodAsm++], "cmp eax, 1");
			sprintf(codigoAsm[cantLineaCodAsm++], "je end_%d",i);
			sprintf(codigoAsm[cantLineaCodAsm++], "mov [@aux%d], 1",i);
			sprintf(codigoAsm[cantLineaCodAsm++], "end_%d:",i);
		}

		if (strcmp(Simbolos[i].operacion, "fin")==0) {
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
	//for (i = 0; i < cantVarAsm; ++i) {
	//	fprintf(arch,"\t%s\n", variablesAsm[i]);	
	//}
	//fprintf(arch,"\n");

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