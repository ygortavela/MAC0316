D [0-9]
E [Ee][+-]?{D}+
alpha	[A-Za-z]+

%{
#include <math.h>
#include "mcalc.tab.h"
#include <string.h>

%}


%%
{D}*[.]?{D}+{E}?	{ yylval.val = yytext; return NUM; }

[ \t\n]+	/* pula espacos em branco */

#.*		/* comentarios simples */

[(]		{ return OPEN; }
[)]		{ return CLOSE;}
[{]     { return OPENC; }
[}]     { return CLOSEC; }
[+]		{ return ADD; }
[-]		{ return SUB; }
[*]		{ return MUL; }
[/]		{ return DIV; }
[:]     { return COLON; }
[;]		{ return SCOLON; }
[=]		{ return ATTR;}
"if"    { return IF; }
"then"  { return THEN; }
"else"  { return ELSE; }
"let"				{ return LET; }
"fn"				{ return FUNC; }
"return"            { return END; }
"lambda"            { return LAMBDA; }
{alpha}	{ yylval.val = strdup(yytext); return SYM; }

.	{  fprintf(stderr, "Entrada ignorada\n-->%s\n", yytext); }

%%

/* Local Variables: */
/* mode: c */
/* End: */
