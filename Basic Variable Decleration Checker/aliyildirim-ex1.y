%{
#include <string.h>
#include <stdio.h>
#include "aliyildirim-ex1.h"

void yyerror (const char *s){ printf("ERROR\n"); }

//needed for defining scope starts
int inScope = 0;
// head is for all declared global variables forParameters is all formals
Node *head = NULL;
Node *forParameters = NULL;
// allocating memory for a node and adding to list
Node *makeNode(char *, int);
void addToList(char *, Node**);

// first one checks if that var is declared as globally or locally before
// second one checks if that var came as parameter
int declaredBefore(char *);
int cameAsParameter(char *);

//remove locals from the tail of the head pointer
void deleteLocal();
//remove formals after function is terminated, i.e. clear forParameters ptr.
void deleteFormals(Node**);

int ListIsEmpty(Node *);
void printError(int, int);
void PrintList(Node *);
%}

%union{
  	int scopeStart;
	struct{
		 int line;
		 char *s;
	}str;
}

%token <str> tIDENT
%token tINT tSTRING tRETURN tPRINT
%token tLPAR tRPAR tCOMMA tMOD tASSIGNM tMINUS tPLUS tDIV tSTAR tSEMI tLBRAC tRBRAC
%token tSTRINGVAL tINTVAL

%type <str> decl
%type <str> asgn
%type <str> formalInFuncDef
%type <scopeStart> FuncStart
%start prog

%%

prog: 		stmtlst
;

stmtlst:	stmtlst stmt 
		| stmt       
;

stmt:	        decl
       		|asgn  
		|FuncDefinition 
		|print
;

decl:		type tIDENT tASSIGNM expr tSEMI{ if(declaredBefore($2.s)==0 && cameAsParameter($2.s)==0)
							{addToList($2.s, &head);}
						 else{ printError(2, $2.line); YYABORT;}
						}
					
;

asgn:		tIDENT tASSIGNM expr tSEMI { 	if(declaredBefore($1.s)==0 && cameAsParameter($1.s)==0 ) 
						{  printError(1, $1.line); YYABORT; }
					   } 
;


type:		tINT
		|tSTRING
;

expr:		tIDENT{  if(declaredBefore($1.s)==0 && cameAsParameter($1.s)==0 )
                          { printError(1, $1.line); YYABORT; }
                      }
                |tINTVAL
                |tSTRINGVAL	
       	        |FuncCall
		|expr binOp expr     
;    

binOp:		tMINUS
		|tPLUS
		|tSTAR
		|tDIV
		|tMOD
;

FuncCall:	tIDENT tLPAR exprInFuncCall tRPAR
;

exprInFuncCall	:expr
		|exprInFuncCall tCOMMA expr
;

FuncDefinition:	FuncStart tLBRAC FuncBody tRBRAC
{
	inScope = 0; 
	//PrintList(head);
	if(ListIsEmpty(head)!=1){	
		deleteLocal();
	}
	//PrintList(head);
	//PrintList(forParameters);
	if(ListIsEmpty(forParameters)!=1){
		deleteFormals(&forParameters);
	}
	//PrintList(forParameters);
}
;

FuncStart:      type tIDENT formalInFuncDef tRPAR
{inScope = 1;}
;

formalInFuncDef: tLPAR
		|tLPAR type tIDENT		    
		{if(declaredBefore($3.s)==0 && cameAsParameter($3.s)==0)
			 addToList($3.s,&forParameters); 
		 else{  printError(2, $3.line); YYABORT; } 
		} 
		|formalInFuncDef tCOMMA type tIDENT 
		{if(declaredBefore($4.s)==0 && cameAsParameter($4.s)==0)
                         addToList($4.s, &forParameters);
                 else{  printError(2, $4.line); YYABORT; }
                }
;

FuncBody:	stmtlst return
		|return
;

return:		tRETURN expr tSEMI 
; 

print:		tPRINT tLPAR expr tRPAR tSEMI
;

%%

Node *makeNode(char *x, int local){
        Node * ret = (Node *)malloc (sizeof(Node));
        ret->identifier = x;
        ret-> next = NULL;
	ret-> local= local;
        return ret;
}

void addToList(char *x, Node **ptr){
	Node *temp = (*ptr);
	if(temp == NULL){
		(*ptr) = makeNode(x, inScope);
	}
	else{
		while(temp->next != NULL){
			temp = temp->next;
		}
		temp->next = makeNode(x, inScope);
	}
	//PrintList(*ptr);//printf("%d ", lineNo);
	//printf("new identifier is added to the list\n");
}
 
int declaredBefore(char *x){
	Node *temp = head;
	while(temp != NULL){
		if(strcmp(temp->identifier, x) == 0 ){
			//printf(temp->identifier);
			//printf("\n");
			return 1;
		}
		temp = temp->next;
	}
	return 0;
}

int cameAsParameter(char *x){
	Node *temp = forParameters;
        while(temp != NULL){
                if(strcmp(temp->identifier, x) == 0 ){
                        //printf(temp->identifier);
                        //printf("\n");
                        return 1;
                }
                temp = temp->next;
        }
        return 0;
}

void deleteLocal(){ //delete func must be more complete
	Node *temp = head;
	if(temp != NULL && temp->local == 1){
		head = NULL;
	}
	while(temp!= NULL && temp->next != NULL && temp->next->local!=1){
		temp=temp->next;
	}
	if(temp!=NULL && temp->next != NULL){
		Node *ptr = temp->next;
		free(ptr);
		temp->next = NULL;
	}
	//printf("locals are deleted from list\n");
	//PrintList();
}

void deleteFormals(Node **ptr){
	Node *temp = (*ptr);
	Node *newHead;
	while( temp != NULL )
	{
		newHead = temp->next;
		free(temp);
		temp = newHead;
	}
	*ptr = NULL;
	//printf("formals are deleted from list\n");
        //PrintList();
}

int ListIsEmpty(Node * ptr){
	if(ptr == NULL) return 1;
	else	return 0;
}
void printError( int typeOfError, int line){	
	printf("%d ", line);
	if(typeOfError == 1)
                printf("Undefined Variable\n");
        else
                printf("Redefinition of variable\n");
}

void PrintList(Node *ptr ){
	Node *temp = ptr;
	if(temp == NULL){
		printf("empty list\n");
	}
	while(temp!=NULL){
		printf(temp->identifier);
		printf("\n");
		temp = temp->next;
	}
}

int main() {
	if (yyparse()) {
		return 1;
	}
	else {
		printf("OK\n");
		return 0;
	}
}
