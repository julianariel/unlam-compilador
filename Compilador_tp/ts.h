//Estructura de datos de la tabla de simbolos
typedef struct symbol {
    char nombre[50];
    char tipo[10];
    char valor[100];
    int longitud;
} symbol;

int pos_st = 0;
symbol nullSymbol;
symbol symbolTable[5000];

/* Funciones para que el bloque DecVar cargue la tabla de símbolos */
char varTypeArray[2][1000][50];
int idPos = 0;
int typePos = 0;
/* Fin funciones para que el bloque DecVar cargue la tabla de símbolos */

char *downcase(char *p){
    char *pOrig = p;
    for ( ; *p; ++p) *p = tolower(*p);
    return pOrig;
}

char *prefix_(char *p, char prefix){

    if (prefix == '&')
        return p;

    int tam = strlen(p);
    p = p + tam ;
    int i;
    for(i=0; i < tam + 1 ; i++){
        *(p+1) = *p;
        p--;
    }
    *(p+1) = prefix;
    return p+1;
}

int searchSymbol(char key[]){
    static int llamada=0;
    llamada++;
    char mynombre[100];
    strcpy(mynombre,key);
    prefix_(downcase(mynombre),'_');
    int i;
    for ( i = 0;  i < pos_st ; i++) {
        if(strcmp(symbolTable[i].nombre, mynombre ) == 0){
            return i;
        }
    }
    return -1;
}

int searchSymbolWP(char key[]){
    static int llamada=0;
    llamada++;
    char mynombre[100];
    strcpy(mynombre,key);
    int i;
    for ( i = 0;  i < pos_st ; i++) {
        if(strcmp(symbolTable[i].nombre, mynombre ) == 0){
            return i;
        }
    }
    return -1;
}

symbol getSymbolWP(char nombre[]){
    int pos = searchSymbolWP(nombre);
    if(pos >= 0) return symbolTable[pos];
    return nullSymbol;
}

symbol getSymbol(char nombre[]){
    int pos = searchSymbol(nombre);
    if(pos >= 0) return symbolTable[pos];
    return nullSymbol;
}

int saveSymbol(char nombre[], char tipo[], char valor[], char prefix ){
	int indice = searchSymbol(nombre);
    if( indice == -1)
	{
		//printf("Variable nueva\n");
		char mynombre[100];
		char type[10];
		strcpy(type,tipo);
		strcpy(mynombre,nombre);
		downcase(type);
		int use_pos = searchSymbol(nombre);
		if ( use_pos == -1){
			use_pos = pos_st;
			pos_st++;
		}
		symbol newSymbol;
		strcpy(newSymbol.nombre, prefix_(downcase(mynombre), prefix));
		strcpy(newSymbol.tipo, type);
		if (valor == NULL){
			strcpy(newSymbol.valor, nombre);
		    newSymbol.longitud = strlen(nombre);

		} else {
			strcpy(newSymbol.valor, valor);
		    newSymbol.longitud = strlen(valor);
		}
		symbolTable[use_pos] = newSymbol;
		newSymbol = nullSymbol;
		
		return 0;
	}
	else
	{
		//printf("La variable ya fue encontrada\n");
		strcpy(symbolTable[indice].valor,valor);
        symbolTable[indice].longitud = strlen(symbolTable[indice].valor);
	}
}

/* Funciones para que finalizado el bloque de declaracion se cargue la tabla de símbolos en la estructura de datos creada */
//Guardar ID en la estructura
void saveId (char *id) {
	int i;
	//Realiza el control de que la variable a agregar en la TS no haya sido ya declarada anteriormente
	 for(i=0; i < idPos; i++ ) {
		if(strcmp(varTypeArray[0][i],id)==0)
		{
			printf("ERROR: El Id de variable %s ya se encuentra declarado.\n", id);
			exit(0);
		}
    }
	strcpy(varTypeArray[0][idPos++],id);
}
//Guardar el tipo en la estructura
void saveType (char *type){
    strcpy(varTypeArray[1][typePos++],type);
}

//Guardar en el vector
void saveIdType() {
    int i;
    for(i=0; i < idPos; i++ ) {
		if(!(*varTypeArray[1][i])){
			strcpy(varTypeArray[1][i],varTypeArray[1][i-1]);
		}
        saveSymbol(varTypeArray[0][i],varTypeArray[1][i], "-", '_');
    }
    idPos=0;
    typePos=0;
}
/* Fin de funciones para que el bloque DecVar cargue la tabla de símbolos */

//-----------------------Guarda la tabla de Simbolos en formato HTML-----------------------//
void writeStyle(FILE *p){
    fprintf(p,"<style>\ntable {\nfont-family: arial, sans-serif;\nborder-collapse: collapse;\nwidth: 100%%;\n}\ntd, th {\nborder: 1px solid #dddddd;\ntext-align: left;\npadding: 8px;\n}\ntr:nth-child(even) {\nbackground-color: #dddddd;\n}\n</style>\n");
}

void writeTupla(FILE *p ,int filas,symbol symbolTable[]){
    int j;
    for(j=0; j < filas; j++ ){
        fprintf(p, "<tr>\n");
        fprintf(p,"\t<th>%s</th>\n",symbolTable[j].nombre);
        fprintf(p,"\t<th>%s</th>\n",symbolTable[j].tipo);
        fprintf(p,"\t<th>%s</th>\n",symbolTable[j].valor);
        fprintf(p,"\t<th>%d</th>\n",symbolTable[j].longitud);
        fprintf(p, "</tr>\n");
    }
}

void writeTable(FILE *p,  int filas, symbol symbolTable[], void (*tupla)(FILE *p ,int filas, symbol symbolTable[])){
    fprintf(p,"<table>\n");
    fprintf(p, "<tr>\n");
    char titulos[4][20] = {"Nombre","Tipo","Valor","Longitud"};
    int j,i;
    for(j=0; j < 4; j++ ){
        fprintf(p,"<th>%s</th>\n",titulos[j]);
    }
    fprintf(p, "</tr>");
    tupla(p,filas,symbolTable);
    fprintf(p,"</table>\n");
}

void writeHeader(FILE *p, char *title, void (*style)(FILE *p)){
fprintf (p,"<!DOCTYPE html>\n<html>\n<head>\n<title>%s</title>\n",title);
style(p);
fprintf (p,"</head>\n<body>");
}

void writeFooter(FILE *p){
fprintf (p,"</body>\n</html>");
}

void symbolTableToHtml(symbol symbolTable[],char * ruta)
{
    FILE  *p = fopen(ruta, "w");
    writeHeader(p, "Tabla de simbolos",writeStyle);
    writeTable(p,pos_st  , symbolTable,writeTupla);
    writeFooter(p);
    fclose(p);
}
//-----------------------Guarda la tabla de Simbolos en formato HTML-----------------------//