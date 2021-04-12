#include "pila.h"
void crear_pila(t_pila * pp){
    *pp = NULL;
}

int pila_vacia(const t_pila *pp){
    return !(*pp);
}

int pila_llena(const t_pila *pp)
{
    t_nodo *aux = (t_nodo*)malloc(sizeof(t_nodo));
    free(aux);
    return !aux;

}

int poner_en_pila(t_pila * pp,const void *dato ,int tam)
{
    t_nodo *nue = (t_nodo*)malloc(sizeof(t_nodo));
    if(!nue)
        return PILA_LLENA;
    nue->dato = malloc(tam);
    memcpy(nue->dato,dato,tam);
    nue->psig = *pp;
    *pp = nue;

    return TODO_OK;
}

int sacar_de_pila(t_pila *pp, void *dato,int tam){
    t_nodo *aux = *pp;
    if(!*pp)
        return PILA_VACIA;
    memcpy(dato,aux->dato,tam);
    *pp = aux->psig;
    free(aux->dato);
    free(aux);
    return TODO_OK;
}

int tope_pila(const t_pila *pp, void *dato ,int tam)
{
    if(!*pp)
        return PILA_VACIA;
    memcpy(dato,(*pp)->dato,tam);
    return TODO_OK;
}

void vaciar_pila(t_pila *pp){
    t_nodo *aux;
    while(*pp)
    {
        aux = *pp;
        *pp = (*pp)->psig;
        free(aux);
    }
}
