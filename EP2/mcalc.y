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

char *def(char *name, char *arg ,char *expr) {
    char *res = malloc(strlen(name) + strlen(arg) + strlen(expr)   + 16);
    sprintf(res, "(def %s %s %s)", name, arg , expr);

    return res;
}

char *fundef(char *arg, char *body) {
    char *res = malloc(strlen(arg) + strlen(body)+ 8);
    sprintf(res, "(func %s %s)", arg, body);

    return res;
}

char *set(char *var, char *value) {
    char *res = malloc(strlen(var) + strlen(value)+ 8);
    sprintf(res, "(:= %s %s)", var, value);

    return res;
}

char *sequence(char *expr1, char *expr2) {
    char *res = malloc(strlen(expr1) + strlen(expr2)+ 8);
    sprintf(res, "(seq %s %s)", expr1, expr2);

    return res;
}

int yylex();

void yyerror(char *);
%}

%union {
    char *val;
}

// tokens recebidos da analise léxica do Flex
%token	<val> NUM FUNC SYM
%token  IF THEN ELSE ADD SUB MUL DIV PRINT OPEN CLOSE LET COLON ATTR END  LAMBDA SCOLON OPENC CLOSEC
%type	<val> exp call attr type closure

%left ADD SUB
%left MUL DIV
%left NEG

/* Gramatica */
%%

input:
        | 		exp     { puts($1); }
        | 		error  	{ fprintf(stderr, "Entrada inválida\n"); }
;

exp: 	        END exp SCOLON {$$ = dup($2);}
        |       NUM 		{ $$ = dup($1); }
        |       attr         {$$ = dup($1);}
        |       SYM         {$$ = dup($1);}
        | 		exp ADD exp	{ $$ = oper('+', $1, $3); }
        | 		exp SUB exp	{ $$ = oper('-', $1, $3); }
        | 		exp MUL exp	{ $$ = oper('*', $1, $3); }
        | 		exp DIV exp	{ $$ = oper('/', $1, $3); }
        | 		SUB exp %prec NEG  { $$ = oper('~', $2, ""); }
        | 		OPEN exp CLOSE	{ $$ = dup($2); }
        | 		IF exp THEN exp ELSE exp { $$ = newflow($2, $4, $6); }
        | 		call OPEN exp CLOSE	{ $$ = funcall($1, $3); }
        |       FUNC SYM OPEN SYM CLOSE OPENC exp CLOSEC exp  { $$ = def($2, "0", $7);}
;

call:           SYM         { $$ = dup($1); }
        |       closure
;

attr:           LET SYM ATTR type SCOLON exp                 { $$ = def($2, $4, $6); }
        |       SYM ATTR type SCOLON exp                       { $$ = sequence(set($1 ,$3), $5);}
;

type:           exp
        |       closure
;

closure:        OPEN LAMBDA SYM COLON exp CLOSE { $$ = fundef($3, $5); }
;



%%

void yyerror(char *s) {
  fprintf(stderr,"%s\n",s);
}
