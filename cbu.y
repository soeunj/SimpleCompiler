%{
#define MSDOS
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG	0

#define	 MAXSYM	200
#define	 MAXSYMLEN	100
#define	 MAXTSYMLEN	50
#define	 MAXTSYMBOL	MAXSYM/2


int tsymbolcnt=0;
int errorcnt=0;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;

void	dwgen();
int	gentemp();
void	assgnstmt(int, int);
void	numassgn(int, int);
void	addstmt(int, int, int);
void	substmt(int, int, int);
void	mulstmt(int, int, int);
void	divstmt(int, int, int);
void	modstmt(int, int, int);
void	sqrstmt(int, int, int);
int	insertsym(char *);
%}

%token	ADD SUB VAR MUL DIV MOD OPEN CLOSE ASSGN ID NUM STMTEND START END
%right ASSGN
%left ADD SUB
%left MUL DIV MOD

%%
program	: START stmt_list END		{ if (errorcnt==0) dwgen(); }
	;

stmt_list: 	stmt_list stmt 	
	|	/* null */
	| 	error STMTEND	{ errorcnt++; yyerrok;}
	;

stmt	: 	VAR ID ASSGN expr STMTEND	{ $$=$2; assgnstmt($2, $4);}
	|	ID ASSGN expr STMTEND	{ $$=$1; assgnstmt($1, $3);}
	;

expr	: 	
	|	expr ADD expr	{ $$=gentemp(); addstmt($$, $1, $3); }
	|	expr SUB expr	{ $$=gentemp(); substmt($$, $1, $3); }
	|	expr MUL expr	{ $$=gentemp(); mulstmt($$, $1, $3); }
	|	expr DIV expr	{ $$=gentemp(); divstmt($$, $1, $3);}
	|	expr MOD expr	{ $$=gentemp(); modstmt($$, $1, $3); }
	|	OPEN expr CLOSE	{ $$=gentemp(); assgnstmt($$, $2); }
	|	term
	;

term	:	ID	
	|	NUM		{ $$=gentemp(); numassgn($$, $1); }
	;


%%
main() 
{
	printf("\Simple Compiler\n");
	printf("(C) Copyright by So Eun Jang (thdmsdia@gmail.com), 2016.\n");

	fp=fopen("a.asm", "w");
	
	yyparse();

	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.asm'.\n");}
}

yyerror(s)
char *s;
{
	printf("%s (line %d)\n", s, lineno);
}


void numassgn(idx, num)
int idx;
int num;
{
	fprintf(fp, "$ -- NUM ASSIGNMENT STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[idx]); 
	fprintf(fp, "PUSH %d\n", num); 
	fprintf(fp, ":=\n");
}
void assgnstmt(left, right)
int left;
int right;
{	
	fprintf(fp, "$ -- ID ASSIGNMENT STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[left]); 
	fprintf(fp, "RVALUE %s\n", symtbl[right]); 
	fprintf(fp, ":=\n");
}

void addstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- ADD STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "+\n");
	fprintf(fp, ":=\n");
}

void substmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- SUB STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "-\n");
	fprintf(fp, ":=\n");
}
void mulstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- MUL STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "*\n");
	fprintf(fp, ":=\n");
}

void divstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- DIV STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "/\n");
	fprintf(fp, ":=\n");
}
void modstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- MOD STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "%\n");
	fprintf(fp, ":=\n");
}

void sqrstmt(t, first, second)
int t;
int first;
int second;
{
	fprintf(fp, "$ -- SQR STMT --\n");
	fprintf(fp, "LVALUE %s\n", symtbl[t]); 
	fprintf(fp, "RVALUE %s\n", symtbl[first]); 
	fprintf(fp, "RVALUE %s\n", symtbl[second]); 
	fprintf(fp, "*\n");
	fprintf(fp, ":=\n");
}

int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}

void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++) 
		fprintf(fp, "DW %s\n", symtbl[i]);
	fprintf(fp, "END\n");
}

