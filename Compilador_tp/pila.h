#ifndef PILA_H
#define PILA_H

#include <stdlib.h>
#include <string.h>

#define PILA_LLENA -1
#define PILA_VACIA 0
#define TODO_OK 1

typedef struct s_nodo
{
    void *dato;
    struct s_nodo *psig;
}t_nodo;

typedef t_nodo *t_pila;


//Pila
int poner_en_pila(t_pila *,const void * ,int);
int sacar_de_pila(t_pila *,void * ,int);
int tope_pila(const t_pila *,void * ,int);
void vaciar_pila(t_pila *);
int pila_llena(const t_pila *);
int pila_vacia(const t_pila *);
void crear_pila(t_pila *);

#endif