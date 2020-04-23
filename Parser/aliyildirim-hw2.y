%{
	#include <stdio.h>
	void yyerror(const char *msg)
	{ printf("ERROR\n"); }
%}

%token tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE
%token tREALVECTORTYPE tREALMATRIXTYPE tIF tENDIF
%token tTRANSPOSE tEQ tLT tGT tAND tDOTPROD tNE
%token tLTE tGTE tOR
%token tIDENT tINTNUM tREALNUM

%left '-' '+'
%left '*' '/' 
%left tDOTPROD tTRANSPOSE
%%

prog	:stmtlst
;
stmtlst :stmt
        |stmtlst stmt
;

stmt    :decl
        |asgn
	|if
;

decl    :type asgn
;

type:		tINTTYPE
		|tINTVECTORTYPE
        	|tINTMATRIXTYPE
		|tREALTYPE
		|tREALVECTORTYPE
        	|tREALMATRIXTYPE
;

asgn	:vars '=' expr ';'
;

vars    :tIDENT
        |vars ',' tIDENT
;

transpose       :tTRANSPOSE '(' expr ')'
;

expr	:value
        |vectorLit
        |matrixLit
	|transpose
	|expr '-' expr
        |expr '+' expr 
	|expr '*' expr
	|expr '/' expr
	|expr tDOTPROD expr	
;

if      :tIF '(' bool  ')' stmtlst tENDIF
;

bool	:comp
	|bool tAND comp
	|bool tOR comp
;

comp 	:tIDENT relation tIDENT
;

relation        :tLT
                |tGT
                |tNE
                |tLTE
                |tGTE
                |tEQ
;

vectorLit       : '[' row ']'
;

matrixLit       : '[' rows ';' row ']'
;

row     :value
        |row ',' value
;

rows    :row
        |rows ';' row
;

value: 		tINTNUM
        	|tREALNUM
        	|tIDENT
;
%%
int main() {
	if (yyparse()) {
		return 1;
	}
	else {
		printf("OK\n");
		return 0;
	}
}
