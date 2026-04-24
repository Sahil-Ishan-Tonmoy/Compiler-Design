%option noyywrap

%{
#include<bits/stdc++.h>
#include"symbol_info.h"
#define YYSTYPE symbol_info*
#include "y.tab.h"

extern YYSTYPE yylval;
using namespace std;
void yyerror(char *);
string loglist;
extern int lines;
extern ofstream outlog;

%}

/* Regular Definitions */
delim    [ \t\v\r]
ws       {delim}+
newline  \n
letter_  [A-Za-z_]
digit    [0-9]
id       {letter_}({letter_}|{digit})*
float    ({digit}*\.{digit}+|{digit}+\.{digit}*)([eE][-+]?{digit}+)?|{digit}+[eE][-+]?{digit}+

%%

{ws}        { /* ignore whitespace */ }
{newline}   { lines++; }

"for"       { 
                loglist="Line no "+to_string(lines)+": Token <FOR> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "FOR");
                return FOR; 
            }

"while"     { 
                loglist="Line no "+to_string(lines)+": Token <WHILE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "WHILE");
                return WHILE; 
            }

"do"        { 
                loglist="Line no "+to_string(lines)+": Token <DO> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "DO");
                return DO; 
            }

"break"     { 
                loglist="Line no "+to_string(lines)+": Token <BREAK> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "BREAK");
                return BREAK; 
            }

"char"      { 
                loglist="Line no "+to_string(lines)+": Token <CHAR> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "CHAR");
                return CHAR; 
            }

"float"     { 
                loglist="Line no "+to_string(lines)+": Token <FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "FLOAT");
                return FLOAT; 
            }

"double"    { 
                loglist="Line no "+to_string(lines)+": Token <DOUBLE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "DOUBLE");
                return DOUBLE; 
            }

"void"      { 
                loglist="Line no "+to_string(lines)+": Token <VOID> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "VOID");
                return VOID; 
            }

"switch"    { 
                loglist="Line no "+to_string(lines)+": Token <SWITCH> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "SWITCH");
                return SWITCH; 
            }

"case"      { 
                loglist="Line no "+to_string(lines)+": Token <CASE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "CASE");
                return CASE; 
            }

"default"   { 
                loglist="Line no "+to_string(lines)+": Token <DEFAULT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "DEFAULT");
                return DEFAULT; 
            }

"continue"  { 
                loglist="Line no "+to_string(lines)+": Token <CONTINUE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "CONTINUE");
                return CONTINUE; 
            }

"goto"      { 
                loglist="Line no "+to_string(lines)+": Token <GOTO> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "GOTO");
                return GOTO; 
            }

"int"       { 
                loglist="Line no "+to_string(lines)+": Token <INT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "INT");
                return INT; 
            }

"return"    { 
                loglist="Line no "+to_string(lines)+": Token <RETURN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "RETURN");
                return RETURN; 
            }

"if"        { 
                loglist="Line no "+to_string(lines)+": Token <IF> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "IF");
                return IF; 
            }

"else"      { 
                loglist="Line no "+to_string(lines)+": Token <ELSE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "ELSE");
                return ELSE; 
            }

"printf"    { 
                loglist="Line no "+to_string(lines)+": Token <PRINTLN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "PRINTLN");
                return PRINTLN; 
            }

"+"|"-"     {
                symbol_info *s = new symbol_info((string)yytext,"ADDOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <ADDOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return ADDOP;
            }

"*"|"/"|"%" {
                symbol_info *s = new symbol_info((string)yytext,"MULOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <MULOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return MULOP;
            }

"<"|"<="|">"|">="|"=="|"!=" {
                symbol_info *s = new symbol_info((string)yytext,"RELOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <RELOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RELOP;
            }

"++"        { 
                symbol_info *s = new symbol_info((string)yytext,"INCOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <INCOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return INCOP; 
            }

"--"        { 
                symbol_info *s = new symbol_info((string)yytext,"DECOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <DECOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return DECOP; 
            }

"&&"|"||"   { 
                symbol_info *s = new symbol_info((string)yytext,"LOGICOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <LOGICOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LOGICOP; 
            }

"!"         { 
                loglist="Line no "+to_string(lines)+": Token <NOT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "NOT");
                return NOT; 
            }

"["         { 
                loglist="Line no "+to_string(lines)+": Token <LTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "LTHIRD");
                return LTHIRD; 
            }

"]"         { 
                loglist="Line no "+to_string(lines)+": Token <RTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "RTHIRD");
                return RTHIRD; 
            }

","         { 
                loglist="Line no "+to_string(lines)+": Token <COMMA> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "COMMA");
                return COMMA; 
            }

":"         { 
                loglist="Line no "+to_string(lines)+": Token <COLON> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "COLON");
                return COLON; 
            }

"="         { 
                loglist="Line no "+to_string(lines)+": Token <ASSIGNOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "ASSIGNOP");
                return ASSIGNOP; 
            }

"("         { 
                loglist="Line no "+to_string(lines)+": Token <LPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "LPAREN");
                return LPAREN; 
            }

")"         { 
                loglist="Line no "+to_string(lines)+": Token <RPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "RPAREN");
                return RPAREN; 
            }

"{"         { 
                loglist="Line no "+to_string(lines)+": Token <LCURL> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "LCURL");
                return LCURL; 
            }

"}"         { 
                loglist="Line no "+to_string(lines)+": Token <RCURL> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "RCURL");
                return RCURL; 
            }

";"         { 
                loglist="Line no "+to_string(lines)+": Token <SEMICOLON> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                yylval = new symbol_info(yytext, "SEMICOLON");
                return SEMICOLON; 
            }

{float}     {
                symbol_info *s = new symbol_info((string)yytext,"CONST_FLOAT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <CONST_FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return CONST_FLOAT;
            }

{digit}+    {
                symbol_info *s = new symbol_info((string)yytext,"CONST_INT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <CONST_INT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return CONST_INT;
            }

{id}        {
                symbol_info *s = new symbol_info((string)yytext,"ID");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <ID> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return ID;
            }

.           { /* Ignore everything else */ }

%%
