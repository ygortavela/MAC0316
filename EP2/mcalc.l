D [0-9]
E [Ee][+-]?{D}+

%{
#include <math.h>
#include "mcalc.tab.h"

%}


%%
{D}*[.]?{D}+{E}?	{ yylval.val = yytext; return NUM; }

[ \t\n]+	/* pula espacos em branco */

#.*		/* comentarios simples */

[(]		{ return OPEN; }
[)]		{ return CLOSE; }
[+]		{ return ADD; }
[-]		{ return SUB; }
[*]		{ return MUL; }
[/]		{ return DIV; }
"if"    { return IF; }
"then"  { return THEN; }
"else"  { return ELSE; }
"half"	{ yylval.val = "half"; return FUNC; }
"cube"	{ yylval.val = "cube"; return FUNC; }
"factorial"	{ yylval.val = "factorial"; return FUNC; }

.	{  fprintf(stderr, "Entrada ignorada\n-->%s\n", yytext); }

%%

/* Local Variables: */
/* mode: c */
/* End: */
