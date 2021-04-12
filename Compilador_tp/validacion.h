int contTipos = 0;
char tipos[20][40];

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
    exit(1);
}
//-----------------------Funciones para validacion de tipos-----------------------//
int insertarTipo(char tipo[]) {
    strcpy(tipos[contTipos],tipo);
    strcpy(tipos[contTipos+1],"null");
    contTipos++;
    return 0;
}

int validarInt(char entero[]) {
    int casteado = atoi(entero);
    char msg[100];
    if(casteado < -32768 || casteado > 32767) {
        sprintf(msg, "ERROR: Entero %d fuera de rango. Debe estar entre [-32768; 32767]\n", casteado);
        yyerror(msg);
    } else 
	{
		//insertarTipo("int");
        return 0;
    }
}

int validarFloat(char flotante[]) {
    double casteado = atof(flotante);
    casteado = fabs(casteado);
    char msg[300];
    if(casteado < pow(-1.17549,-38) || casteado >  pow(3.40282,38)){
        sprintf(msg, "ERROR: Float %f fuera de rango. Debe estar entre [1.17549e-38; 3.40282e38]\n", casteado);
        yyerror(msg);
    } 
    else 
	{
		//insertarTipo("float");
        return 0;
    }
}

int validarString(char cadena[]) {
    char msg[100];

    if( strlen(cadena) > 32){ //en lugar de 30 verifica con 32 porque el string viene entre comillas
        sprintf(msg, "ERROR: Cadena %s demasiado larga. Maximo 30 caracteres\n", cadena);
        yyerror(msg);
    }
    char sincomillas[31];
    int i;
    for(i=0; i< strlen(cadena) - 2 ; i++) {
            sincomillas[i]=cadena[i+1];
    }
    sincomillas[i]='\0';
	//insertarTipo("string");
    return 0;
}

int validarLongitudId(char cadena[]) {
    char msg[100];
    if( strlen(cadena) > 15){
        sprintf(msg, "ERROR: Id de variable %s demasiado largo. Maximo 15 caracteres.\n", cadena);
        yyerror(msg);
    }
    return 0;
}

//Verificar si un token es palabra reservada
bool validarPalabraReservada(char *nombreToken)
{
	bool marca = false;

	if(strcmp (nombreToken, "if") == 0)
		return true;
	if(strcmp (nombreToken, "else") == 0)
		marca = true;
	if(strcmp (nombreToken, "while") == 0)
		marca = true;
	if(strcmp (nombreToken, "float") == 0)
		marca = true;
	if(strcmp (nombreToken, "string") == 0)
		marca = true;
	if(strcmp (nombreToken, "int") == 0)
		marca = true;
	if(strcmp (nombreToken, "avg") == 0)
		marca = true;
	if(strcmp (nombreToken, "DEFVAR") == 0)
		marca = true;
	if(strcmp (nombreToken, "ENDDEF") == 0)
		marca = true;

	if(marca){
		printf("ERROR: Id de variable %s es una palabra reservada del lenguaje.\n", nombreToken);
		exit(0);
    }
}

 int resetTipos()
{
	contTipos = 0;
	strcpy(tipos[contTipos],"null");
}

int compararTipos(char *a, char *b){
    char auxa[50];
    char auxb[50];
    strcpy(auxa,a);
    strcpy(auxb,b);
    downcase(auxa);
    downcase(auxb);
    printf("Comparando %s y %s\n",auxa,auxb);

    if (strstr(auxa,auxb) != NULL){
        return 0;
    }
    if (strstr(auxb,auxa) != NULL){
        return 0;
    }
    return 1;
}

int validarTipos(char tipo[])
{ //printf("Validando tipos... %s",tipo);
	char msg[100];
	int i ;
    for(i=0; i< contTipos; i++){
         if(compararTipos(tipo,tipos[i])!=0){
            sprintf(msg, "ERROR: Tipos incompatibles %s\n",tipo);
            yyerror(msg);
        } 
    }
    resetTipos();
    return 0;
} 

void validarDefinicionVariable(char cadena[])
{
	if(searchSymbol(cadena) == -1)
	{
		printf("\nVariable %s no declarada previamente. ", cadena);
		system("pause");
		exit(0);
	}
}

//-----------------------Fin de funciones para validacion-----------------------//