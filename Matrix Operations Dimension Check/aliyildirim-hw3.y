%{
#include <stdio.h>
#include "aliyildirim-hw3.h"

void yyerror (const char *s){ printf("ERROR\n"); }

TreeNode * mkRow();
TreeNode * mkVector(TreeNode * );
TreeNode * mkScalar();
TreeNode * mkMatrix(TreeNode * );
TreeNode * Mult(TreeNode*, TreeNode *);
TreeNode * MultiplicationCheck(TreeNode*, TreeNode*);
TreeNode * Trans(TreeNode * t);
void Print(int, int);
TreeNode * rootPtr;
extern int lineNo;
%}

%union {
	 struct TreeNode *treeptr;
}

%token tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE tREALVECTORTYPE tREALMATRIXTYPE tTRANSPOSE tIDENT tDOTPROD 
%token tIF tENDIF tAND tOR tGT tLT tGTE tLTE tNE tEQ

%token <treeptr>  tINTNUM
%token <treeptr>  tREALNUM

%type <treeptr> matrixLit vectorLit expr rows row value transpose

%left '='
%left tOR
%left tAND
%left tEQ tNE
%left tLTE tGTE tLT tGT
%left '+' '-'
%left '*' '/'
%left tDOTPROD
%left '(' ')'
%left tTRANSPOSE

%start prog

%%


prog: 		stmtlst 
;

stmtlst:	stmtlst stmt 
		| stmt       
;

stmt:	       decl
       		|asgn
            	| if   
;

decl:		type vars '=' expr ';'
;

asgn:		tIDENT '=' expr ';'
;

if:		tIF '(' bool ')' stmtlst tENDIF
;

type:		tINTTYPE
		| tINTVECTORTYPE
            	| tINTMATRIXTYPE
            	| tREALTYPE
            	| tREALVECTORTYPE    
            	| tREALMATRIXTYPE
;

vars:		vars ',' tIDENT
		| tIDENT
;

expr:		value		
		| vectorLit		
		| matrixLit
       	        | expr	'*' expr  {  $$ = MultiplicationCheck($1, $3); if ($$ == NULL) YYABORT; }
		| expr	'/' expr  {  if($3->ptr->expr1.column == $3->ptr->expr1.row) { $$ = MultiplicationCheck($1, $3); if ($$ == NULL) YYABORT; }
				     else { Print(2,lineNo); YYABORT;  }
				  }
           	| expr	'+' expr  {if (($1->ptr->expr1.column != $3->ptr->expr1.column) ||
						 ($1->ptr->expr1.row != $3->ptr->expr1.row))
					 { Print(2,lineNo); YYABORT; } 
				   else { $$->ptr->expr1.row = $1->ptr->expr1.row; $$->ptr->expr1.column = $1->ptr->expr1.column;  }	
		                  }
           	| expr	'-' expr  {if (($1->ptr->expr1.column != $3->ptr->expr1.column) ||
                                                 ($1->ptr->expr1.row != $3->ptr->expr1.row)) 
					 { Print(2,lineNo); YYABORT;  }
                                   else { $$->ptr->expr1.row = $1->ptr->expr1.row; $$->ptr->expr1.column = $1->ptr->expr1.column;  }
				  }
                | expr tDOTPROD expr	{if($1->ptr->expr1.scalar == 1 || $3->ptr->expr1.scalar == 1)
				        	{ Print(2,lineNo); YYABORT; }
					 if (($1->ptr->expr1.column != $3->ptr->expr1.column) ||
                                             ($1->ptr->expr1.row !=1) || ($3->ptr->expr1.row !=1 )) 
					 { Print(2,lineNo); YYABORT; }
                                  	 else { $$->ptr->expr1.row = 0; $$->ptr->expr1.column = 0; $$->ptr->expr1.scalar=1; }
                                 	}		
	        | transpose     
;    

transpose: 	tTRANSPOSE '(' expr ')' { $$ = Trans($3); } 
;

vectorLit:	'[' row ']'	 {	$$ = mkVector($2);
	                                // printf("row: "); printf("%d", $$->ptr->expr1.row);
					//printf("col: "); printf("%d", $$->ptr->expr1.column);
				 }
;

row:		row ',' value    {	$$->ptr->expr1.column++; $$->ptr->expr1.scalar=0;}  
		| value	  	 { 	$$ = mkRow();	 }	

matrixLit: 	'[' rows ']'     {      $$ = mkMatrix($2); 
				        //printf("row: "); printf("%d", $$->ptr->expr1.row);
                                        //printf("col: "); printf("%d", $$->ptr->expr1.column);
				 }
;

rows:		row ';' row      {     if ($1->ptr->expr1.column == $3->ptr->expr1.column) 
					{ $$->ptr->expr1.row = 2;
					  $$->ptr->expr1.column = $1->ptr->expr1.column;
					  $$->ptr->expr1.scalar=0;
	                     		  //printf("scalar value: "); printf("%d",$$->ptr->expr1.scalar);
					  //printf("row: "); printf("%d", $$->ptr->expr1.row);
                                          //printf("col: "); printf("%d", $$->ptr->expr1.column);
					}
					else{ Print(1,lineNo); YYABORT;}
				 }				
		| rows ';' row   {     if ($1->ptr->expr1.column == $3->ptr->expr1.column)
                                        { $$->ptr->expr1.row++; 
					  $$->ptr->expr1.column = $1->ptr->expr1.column;
                                          $$->ptr->expr1.scalar=0;
                                          //printf("scalar value: "); printf("%d",$$->ptr->expr1.scalar);
					  // printf("row: "); printf("%d", $$->ptr->expr1.row);
                                          // printf("col: "); printf("%d", $$->ptr->expr1.column);
                                        }
                                        else{ Print(1,lineNo); YYABORT;}
                                 }

;

value:		tINTNUM     { $$ = mkScalar(); }
		| tREALNUM  { $$ = mkScalar(); }
;

bool: 		comp
		| bool tAND bool
		| bool tOR bool
;

comp:		tIDENT relation tIDENT
;

relation:		tGT
			| tLT
			| tGTE
		        | tLTE
			| tEQ
			| tNE
;

%%

TreeNode * mkScalar () { // 0x0 dimension means scalar for our code
	TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
        ret->ptr->expr1.column = 0;
        ret->ptr->expr1.row = 0;
        ret->ptr->expr1.scalar = 1;
	return (ret);
}

TreeNode * mkRow () {
        TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
        ret->ptr->expr1.column = 1;
        ret->ptr->expr1.row = 1;
        ret->ptr->expr1.scalar = 0;
        return (ret);
}

TreeNode * mkVector( TreeNode * t)
{
        TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
        ret->ptr->expr1.column = t->ptr->expr1.column;
        ret->ptr->expr1.row = 1;
        ret->ptr->expr1.scalar = 0;
        return (ret);
}

TreeNode * mkMatrix(TreeNode * t)
{
        TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
        ret->ptr->expr1.column = t->ptr->expr1.column;
        ret->ptr->expr1.row = t->ptr->expr1.row;
        ret->ptr->expr1.scalar = 0;
        return (ret);

}

TreeNode * MultiplicationCheck(TreeNode * t1, TreeNode * t3)
{
	TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
	if(t1->ptr->expr1.scalar == 1 && t3->ptr->expr1.scalar == 1) //for scalars, can be written easier
        { ret = Mult(t1, t3); ret->ptr->expr1.scalar = 1; }
        else if (t1->ptr->expr1.column != t3->ptr->expr1.row)
        { if(t1->ptr->expr1.scalar == 1)
          { ret->ptr->expr1.row = t3->ptr->expr1.row; ret->ptr->expr1.column = t3->ptr->expr1.column; ret->ptr->expr1.scalar=0;}
          else if(t3->ptr->expr1.scalar == 1)
          { ret->ptr->expr1.row = t1->ptr->expr1.row; ret->ptr->expr1.column = t1->ptr->expr1.column; ret->ptr->expr1.scalar=0;}
          else {printf("ERROR 2: "); printf("%d", lineNo); printf(" dimension mismatch.\n"); return NULL;}
        }
        else {ret = Mult(t1, t3); ret->ptr->expr1.scalar = 0;}//means these are mxn and nxk matrices
        
	return (ret);
}

TreeNode * Mult(TreeNode *t1, TreeNode *t2)
{
        TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
        ret->ptr->expr1.column = t2->ptr->expr1.column;
        ret->ptr->expr1.row = t1->ptr->expr1.row;
        return (ret);
}

TreeNode * Trans(TreeNode *t)
{
	TreeNode * ret = (TreeNode *)malloc (sizeof(TreeNode));
        ret->ptr = (Expr *)malloc (sizeof(Expr));
	ret->ptr->expr1.column = t->ptr->expr1.row;
	ret->ptr->expr1.row    = t->ptr->expr1.column;
	ret->ptr->expr1.scalar = t->ptr->expr1.scalar;
	return (ret);
}
void Print(int typeOfError, int lineNo)
{
	if (typeOfError == 1) 		{ printf("ERROR 1: "); printf("%d", lineNo); printf(" inconsistent matrix size.\n"); }
	else if (typeOfError == 2) 	{ printf("ERROR 2: "); printf("%d", lineNo); printf(" dimension mismatch.\n"); }
}
int main ()
{
   if (yyparse()) {
   // parse error
        return 1;
   }
   else {
   // successful parsing
      printf("OK\n");
      return 0;
   }
}

