#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <conio.h>
#include <stdbool.h>

//Funcion AVG
int contAVG = 0;
float cantAVG = 0;
int avgInd = 0;
int esExpresion = 0;
float acuAvg = 0;
//Asignacion Multiple
int marcaAsig = 0;

int isNot = 0;

char _cte[50];

int nroTerceto = 0; 
int asigIndice = 0, expIndice = 0, terIndice = 0, facIndice = 0, condIndice = 0, condMulIndice = 0;
int expAuxIndice = 0, terAuxIndice = 0, facAuxIndice = 0;
int operacionLogica;
int esCadena = 0;
int topePila = 0;
int pilaSaltos[1000] = {0};
int auxDesapilar;
FILE *intermedia;

//LISTA
struct node {
        int indice;
        char primero[30];
        int segundo;
        int tercero;
		char cuarto[30];
        struct node *next;
} *lista_tercetos;

//TERCETOS	
char* obtenerSalto(int saltoPorFalso)
{	   
	if(saltoPorFalso)
	{
		switch(operacionLogica)
		{
			case IGUAL :				
				return "JNE";				
			case MENOR :				
				return "JAE";				
			case MAYOR : 				
				return "JBE";				
			case MAYOR_IGUAL :				
				return "JB";				
			case MENOR_IGUAL :				
				return "JA";				
			case DISTINTO :				
				return "JE";				
		};
	}
	else
	{
		switch(operacionLogica)
		{
			case IGUAL :				
				return "JE";				
			case MENOR :				
				return "JB";				
			case MAYOR : 				
				return "JA";				
			case MAYOR_IGUAL :				
				return "JAE";				
			case MENOR_IGUAL :				
				return "JBE";				
			case DISTINTO :				
				return "JNE";				
		};
	}
}

char* invertirSalto(char* salto)
{
    if (strcmp(salto,"JNE") == 0)
        return "JE";

    if (strcmp(salto,"JE") == 0)
        return "JNE";

    if (strcmp(salto,"JAE") == 0)
        return "JB";        

    if (strcmp(salto,"JB") == 0)
        return "JAE";        

    if (strcmp(salto,"JBE") == 0)
        return "JA";  

    if (strcmp(salto,"JA") == 0)
        return "JBE";         

          
}

/*THIS FUNCTION ADDS A NODE AT THE LAST OF LINKED LIST */
void append( int indice, char* primero, int segundo, int tercero, char* cuarto )
 {
     struct node *temp,*r;
     /* CREATING A NODE AND ASSIGNING A VALUE TO IT */

       temp= (struct node *)malloc(sizeof(struct node));
       temp->indice=indice;
       strcpy((temp->primero), primero);
       temp->segundo = segundo;
       temp->tercero = tercero;
	   strcpy((temp->cuarto), cuarto);
       r=(struct node *)lista_tercetos;

      if (lista_tercetos == NULL) /* IF LIST IS EMPTY CREATE FIRST NODE */
     {
         lista_tercetos=temp;
         lista_tercetos->next =NULL;
     }
  else
     {        
     /* GO TO LAST AND ADD*/
     while( r->next != NULL)
       r=r->next;
       r->next =temp;
       r=temp;
       r->next=NULL;
     }
  }

int crear_terceto_(char *op)
{
	nroTerceto++;
	fprintf(intermedia, "%d:(%s,_,_)\n", nroTerceto, op);
	append(nroTerceto, op, -1, -1, "");
	return nroTerceto;
}

int crear_terceto(int indice, char *op)
{
	nroTerceto++;
	fprintf(intermedia, "%d:(%s,_,_)\n", nroTerceto, op);
	append(indice, op, -1, -1, "");
	return nroTerceto;
}

int crear_terceto__(char * op, int li, int ld)
{
	nroTerceto++;

	if(li==-1 && ld != -1)
	{
		fprintf(intermedia, "%d:(%s,_,[%d])\n", nroTerceto, op, ld);
		append(nroTerceto, op, -1, ld, "");
	}
	if(li!=-1 && ld == -1)
	{
		fprintf(intermedia, "%d:(%s,[%d],_)\n", nroTerceto, op, li);
		append(nroTerceto, op, li, -1, "");
	}
	if(li!=-1 && ld != -1)
	{
		fprintf(intermedia, "%d:(%s,[%d],[%d])\n", nroTerceto, op, li, ld);	
		append(nroTerceto, op, li, ld, "");
	}	
	return nroTerceto;
} 

int crear_terceto___(char  *op, char * li, int ld)
{
	nroTerceto++;
	fprintf(intermedia, "%d:(%s,%s,[%d])\n", nroTerceto, op, li, ld);
	append(nroTerceto, op, -2, ld, li); //si es -2 analizo el cuarto campo
	return nroTerceto;
} 

void errorLexico(char* error)
{	
	printf("\n ERROR LEXICO: %s \n", error);
	getchar();
	exit(0);
}

//////////////////////LISTA
/*THIS FUNCTION DELETES A NODE */
void delnode(int indice)
{
     struct node *temp, *m;
     temp=lista_tercetos;
     while(temp!=NULL)
     {
       if(temp->indice==indice)
       {
           if(temp==lista_tercetos)
           {
              lista_tercetos=temp->next;
              free(temp);
              return;
           }
           else
           {
              m->next=temp->next;
              free(temp);
              return;
           }
       }
       else
       {
          m=temp;
          temp= temp->next;
       }
     
     }
     printf(" ELEMENT %d NOT FOUND ", indice);
}


/* ADD A NEW NODE AT BEGINNING  */
void addbeg( int indice, char* primero, int segundo, int tercero, char* cuarto)
   {
   /*  CREATING A NODE AND INSERTING VALUE TO IT  */

   struct node *temp;
        temp=(struct node *)malloc(sizeof(struct node));
        temp->indice=indice;
        strcpy((temp->primero), primero);
        temp->segundo = segundo;
        temp->tercero = tercero;
		strcpy((temp->cuarto), cuarto);

       /* IF LIST IS NULL ADD AT BEGINNING  */
        if ( lista_tercetos== NULL)
       {
          lista_tercetos=temp;
          lista_tercetos->next=NULL;
       }
   else
      {
          temp->next=lista_tercetos;
          lista_tercetos=temp;
      }
   }

//THIS FUNCTION COUNTS THE NUMBER OF ELEMENTS IN THE LIST
int count()
 {
   struct node *n;
   int c=0;
   n=lista_tercetos;
    while(n!=NULL)
   {
     n=n->next;
     c++;
   }
  return(c);
 }
   
/*  ADD A NEW NODE AFTER A SPECIFIED NO OF NODES */
void addafter(int indice, char* primero, int segundo, int tercero, char* cuarto, int loc)
{
    int i;
    struct node *temp, *t, *r;
    r = lista_tercetos;       /* here r stores the first location */
    if(loc > count() + 1 || loc <= 0)
	{
        printf(" insertion is not possible : ");
        return;
	}
    if (loc == 1)/* if list is null then add at beginning */
    {
        addbeg(indice, primero, segundo, tercero, cuarto);
        return;
    }
    else
	{
		for(i = 1; i < loc;i++)
		{
            t = r;   /* t will be holding previous value */
            r = r->next;
        }
        temp=(struct node *)malloc(sizeof(struct node));
        temp->indice=indice;
        strcpy((temp->primero), primero);
        temp->segundo = segundo;
        temp->tercero = tercero;
		strcpy((temp->cuarto), cuarto);
        t->next=temp;
        t=temp;
        t->next=r;
        return;
    }
}

/* THIS FUNCTION DISPLAYS THE CONTENTS OF THE LINKED LIST */
void  display(struct node *r)
{
	char auxDisplay[40], auxConversion[10];
    r=lista_tercetos;
    if(r==NULL)
    {
		printf("NO ELEMENT IN THE LIST :");
		return;
    }
    /* traverse the entire linked list */
    while(r!=NULL)
    {
		strcpy(auxDisplay, ""); //limpio el auxiliar
		strcpy(auxConversion, ""); //limpio el auxiliar
		
		sprintf(auxConversion, "%d", r->indice);
		strcat(auxDisplay, auxConversion);
		strcat(auxDisplay, ":(");
		strcat(auxDisplay, (r->primero));
		strcat(auxDisplay, ",");
		if(r->segundo == -1)
		{
			strcat(auxDisplay, "_");
			strcat(auxDisplay, ",");
		}
		else if(r->segundo == -2)
			{
				strcat(auxDisplay, (r->cuarto));
				strcat(auxDisplay, ",");
			}
			else
			{
				sprintf(auxConversion,"%d", r->segundo);
				strcat(auxDisplay, "[");
				strcat(auxDisplay, auxConversion);
				strcat(auxDisplay, "],");
			}
		if(r->tercero == -1)
		{
			strcat(auxDisplay, "_)");
		}	
		else
		{
			sprintf(auxConversion, "%d", r->tercero);
			strcat(auxDisplay, "[");
			strcat(auxDisplay, auxConversion);
			strcat(auxDisplay, "])");
		}
			//printf(" \n %d %s %d %d %s",r->indice, &(r->primero), r->segundo, r->tercero, &(r->cuarto));
			fprintf(intermedia, "%s\n", auxDisplay);
			r=r->next;
	}	
}
  
void generarIntermedia()
{
	intermedia=fopen("intermedia.txt","w+");
    display(lista_tercetos);
}
 
//THIS FUNCTION REVERSES A LINKED LIST
void  reverse(struct node *q)
{
   struct node *m, *n,*l,*s;
   m=q;
   n=NULL;
  while(m!=NULL)
 {
   s=n;
   n=m;
  m=m->next;
  n->next=s;
 }
   lista_tercetos=n;
}

//funcion para apilar los saltos en la pila
void apilar(int nroTercetoApilado)
{
	if(topePila < 999)
	{
		pilaSaltos[topePila] = nroTercetoApilado;
		topePila ++;
	}
}

//funcion para desapilar los saltos en la pila
int desapilar()
{
	int auxPila = 0;
	
	if(topePila > 0)
	{
		auxPila = pilaSaltos[topePila-1];
		topePila --;
	}
	
	return auxPila;
}

/*  Modificar el salto de un terceto (ubicado en el tercer lugar */
void modificarSalto(int tercero, int loc)
{
    int i;
    struct node *temp, *t, *r;
    r = lista_tercetos;       /* here r stores the first location */
    if(loc > count() + 1 || loc <= 0)
	{
        printf(" insertion is not possible : ");
        return;
	}
    for(i = 1; i < loc;i++)
	{
        r = r->next;
    }

    if (isNot == 1)
        strcpy(r->primero,invertirSalto(r->primero));
    r->tercero = tercero;
	
    return;
}FILE *yytfilep;
