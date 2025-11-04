%{
#include "Sql.tab.h"
#include <string.h>
#include <ctype.h>
%}

%%

"SELECT"    { return SELECT; }
"FROM"      { return FROM; }
"WHERE"     { return WHERE; }
[a-zA-Z_][a-zA-Z0-9_\\.]*   { yylval.str = strdup(yytext); return ID; }
[0-9]+                      { yylval.str = strdup(yytext); return NUMBER; }
"*"                         { return STAR; }
"="                         { return EQUALS; }
";"                         { return SEMICOLON; }
[ \t\r\n]+                  { }
.                           { return yytext[0]; }

%%

int yywrap(void) { return 1; }