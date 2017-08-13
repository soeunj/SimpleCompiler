%{
#include <string.h>
#include <math.h>
#include "cbu.h"
#define MAXSYM	200
#define	MAXSYMLEN	100
char symtbl[MAXSYM][MAXSYMLEN];
int lineno=1;
int insertsym();
int maxsym=0;
char s[30];

%}
sp		[ \t]
ws		{sp}+
nl		\n
eletter		[A-Za-z]
hletter		[\xb0-\xfe][\xa0-\xfe]
letter		({eletter}|{hletter})
digit		[0-9]
id		{letter}({letter}|{digit})*
%%
{ws}		{/* do nothing */}
{nl}		{lineno++; }
\(		{return(OPEN); }
\)		{return(CLOSE); }
int		{return(VAR); }
\+		{return(ADD); }
\-		{return(SUB); }
\*		{return(MUL); }
\/		{return(DIV); }
\%		{return(MOD); }
=		{return(ASSGN); }
;		{return(STMTEND); }
Ω√¿€		{return(START);}
≥°		{return(END);}
{id}		{strncpy(s, yytext, yyleng); s[yyleng]='\0'; yylval=insertsym(s); return(ID);}
{digit}+		{sscanf(yytext, "%d", &yylval); return(NUM);}
.		{printf("invalid token %s\n", yytext); }
%%

int insertsym(s)
char *s;
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}