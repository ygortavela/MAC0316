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
[+]		{ return ADD; }
[-]		{ return SUB; }
[*]		{ return MUL; }
[/]		{ return DIV; }
[;]		{ return END; }
[:]		{ return COLON;}
[=]		{ return ATTR;}
"if"    { return IF; }
"then"  { return THEN; }
"else"  { return ELSE; }
"half"	{ yylval.val = "half"; return FUNC; }
"cube"	{ yylval.val = "cube"; return FUNC; }
"factorial"	{ yylval.val = "factorial"; return FUNC; }
"let"				{return LET;}
"fn"				{return FUNC;}
"return"            {return RET;}
{alpha}	{ yylval.val = strdup(yytext); return SYM;}

.	{  fprintf(stderr, "Entrada ignorada\n-->%s\n", yytext); }

%%

/* Local Variables: */
/* mode: c */
/* End: */
