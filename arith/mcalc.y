/* Calculadora infixa */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *oper(char op, char *l, char *r) {
    char *res = malloc(strlen(l)+strlen(r)+6);
    sprintf(res, "(%c %s %s)", op, l, r);

    return res;
}

char *dup(char *orig) {
    char *res = malloc(strlen(orig)+1);
    strcpy(res,orig);

    return res;
}

// função responsável por "traduzir" um novo fluxo de controle
// no caso, apenas traduz-se o if
char *newflow(char *cond, char *t, char *f) {
    char *res = malloc(strlen(cond) + strlen(t) + strlen(f) + 16);
    sprintf(res, "(if %s %s %s)", cond, t, f);

    return res;
}

// função responsável por "traduzir" um função
char *funcall(char *name, char *arg) {
    char *res = malloc(strlen(name) + strlen(arg) + 16);
    sprintf(res, "(call %s %s)", name, arg);

    return res;
}

int yylex();

void yyerror(char *);
%}

%union {
    char *val;
}

// tokens recebidos da analise léxica do Flex
%token	<val> NUM FUNC
%token  IF THEN ELSE ADD SUB MUL DIV PRINT OPEN CLOSE
%type	<val> exp

%left ADD SUB
%left MUL DIV
%left NEG

/* Gramatica */
%%

input:
        | 		exp     { puts($1); }
        | 		error  	{ fprintf(stderr, "Entrada inválida\n"); }
;

exp: 			NUM 		{ $$ = dup($1); }
        | 		exp ADD exp	{ $$ = oper('+', $1, $3); }
        | 		exp SUB exp	{ $$ = oper('-', $1, $3); }
        | 		exp MUL exp	{ $$ = oper('*', $1, $3); }
        | 		exp DIV exp	{ $$ = oper('/', $1, $3); }
        | 		SUB exp %prec NEG  { $$ = oper('~', $2, ""); }
        | 		OPEN exp CLOSE	{ $$ = dup($2); }
        | 		IF exp THEN exp { $$ = newflow($2, $4, NULL); }
        | 		IF exp THEN exp ELSE exp { $$ = newflow($2, $4, $6); }
        | 		FUNC OPEN exp CLOSE	{ $$ = funcall($1, $3); }
;

%%

void yyerror(char *s) {
  fprintf(stderr,"%s\n",s);
}
