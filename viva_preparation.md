# Viva Preparation: Lexical and Syntax Analyzer LAB

This document explains exactly what was accomplished in this assignment, comparing the original files (`old.l` and `old.y`) with the final implemented files, and answers common conceptual questions you might face during your viva.

## What You Accomplished
In this assignment, you built a **Scanner (Lexical Analyzer using Flex)** and a **Parser (Syntax Analyzer using Bison/Yacc)** for a subset of the C language.

The original files provided merely supported a tiny fragment of functionality (basic arithmetic, `if/else`, and integers). You extended both files to support variables, mathematical operators, relational operators, logic operators (`&&`, `||`), function declarations, scoping patterns, floats, arrays, loops (`for`, `while`, `do`), and standard program structure.

---

## 1. Lexer Changes (`lex_analyzer.l` vs `old.l`)

### What is the Lexer?
The lexer scans the raw text of the input source code character by character and groups them into meaningful **Tokens**. It then returns these tokens to the Parser.

### What Was Added:
1. **New Keywords:** Added missing keywords such as `for`, `while`, `do`, `break`, `char`, `float`, `double`, `void`, `switch`, `case`, `default`, `continue`, `goto`.
   - *Example:* `"while" { return WHILE; }`
2. **Floating Point Support (`CONST_FLOAT`):** The original file only matched `{digit}+` for integers. We added a Regular Expression to match floating-point numbers (e.g., `3.14`, `3.14e-10`):
   - `float    ({digit}*\.{digit}+|{digit}+\.{digit}*)([eE][-+]?{digit}+)?|{digit}+[eE][-+]?{digit}+`
3. **New Operators & Punctuators:**
   - Increments/Decrements (`++`, `--`)
   - Logical Operators (`&&`, `||`, `!`)
   - Array brackets and delimiters (`[`, `]`, `:`, `,`)
4. **Fixing Token Value Passing (`yylval`):** 
   - **Crucial Fix:** The original lexer did not allocate memory for all tokens using `symbol_info`. This caused a **segmentation fault** when the parser tried to read the string value (lexeme) of keywords or brackets.
   - We fixed this by ensuring *every* token instantiates a new `symbol_info` object and assigns it to `yylval` before returning.
   - *Example Fix:* `yylval = new symbol_info(yytext, "INT"); return INT;`

---

## 2. Parser Changes (`syntax_analyzer.y` vs `old.y`)

### What is the Parser?
The parser receives the stream of Tokens from the Lexer and checks if they form valid statements according to a set of **Context-Free Grammar (CFG)** rules. 

### What Was Added:
1. **New Tokens Declared:** Added `%token` declarations at the top for all the new keywords and operators returned by the lexer (e.g., `%token FLOAT VOID WHILE FOR LOGICOP...`).
2. **Implementing the CFG:** The original file only had rudimentary rules for `start`, `statement`, and `expression`. We completely overhauled it using the grammar provided in `Lab1_C_Syntax_Analyzer_Grammar.pdf`.
   - **Program Structure:** Added `program`, `unit`, `func_definition`, `var_declaration` to support global variables, multiple functions, and parameters.
   - **Control Flow:** Added grammar rules for `WHILE` and `FOR` loops.
   - **Expressions:** Added intermediate non-terminals like `logic_expression`, `rel_expression`, `simple_expression`, `term`, `unary_expression`, and `factor` to correctly enforce standard **Operator Precedence**.
3. **Resolving Ambiguity (Dangling Else):**
   - The grammar had an ambiguity where an `if` statement without an `else` conflicts with an `if-else` statement. 
   - We resolved this Shift/Reduce conflict conceptually using Bison's precedence declarations: 
     `%nonassoc LOWER_THAN_ELSE`
     `%nonassoc ELSE`
   - We then applied `%prec LOWER_THAN_ELSE` to the `if` rule so Bison knows to prioritize shifting the `ELSE` token when encountered.
4. **Semantic Actions (Output Generation):**
   - For every single grammar rule, we added C++ block actions `{ ... }` to print to `my_log.txt`:
     1. The rule matched (e.g., `statement : PRINTLN LPAREN ID RPAREN SEMICOLON`)
     2. The actual code string reconstructed using the attributes (`$1->getname()`, `$2->getname()`, etc.) passed via `yylval` from the lexer.

---

## 3. Why `a.out` instead of `a.exe`?

During Windows/native compilation, GCC outputs executable files with the `.exe` extension by default (`a.exe`).

However, the compilation script (`script.sh`) was run inside **WSL (Windows Subsystem for Linux)** using `bash`. 
In Linux environments, GCC compiles C/C++ code into the standard Linux Executable and Linkable Format (ELF). By default, if you don't specify an output filename with the `-o` flag (e.g., `g++ y.o l.o -o my_parser`), GCC automatically names the executable **`a.out`** (which historically stands for "assembler output").

Thus, because we compiled the code in a Linux environment (WSL), the resulting binary was called `a.out`, and we had to execute it using `./a.out input.txt`.

---

---

## 4. Token Group Implementation Examples

The assignment required matching different types of tokens. Here is one example from each major group showing how it is handled in the **Lexer (.l file)** and the **Parser (.y file)**.

### a) Keywords
**Example:** `for`
- **Lexer `lex_analyzer.l`:**
  ```lex
  "for"       { 
                  yylval = new symbol_info(yytext, "FOR");
                  loglist="Line no "+to_string(lines)+": Token <FOR> Lexeme "+yytext+" found\n\n";
                  outlog<<loglist;
                  return FOR; 
              }
  ```
  *Explanation:* Matches the exact string `"for"`. Allocates a `symbol_info` object to pass the string `"for"` to the parser via `yylval`, logs the token, and returns the token id `FOR`.
- **Parser `syntax_analyzer.y`:**
  ```yacc
  %token FOR
  // ...
  statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement
      {
          outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
          outlog<<$1->getname()<<" "<<$2->getname()<<" "<<$3->getname()<<" "<<$4->getname()<<$5->getname()<<$6->getname()<<$7->getname()<<endl<<endl;
          $$ = new symbol_info($1->getname()+" "+$2->getname()+" "+$3->getname()+" "+$4->getname()+$5->getname()+$6->getname()+$7->getname(),"statement");
      }
  ```
  *Explanation:* Declares `FOR` as a terminal token. Uses `FOR` in a Grammar formulation representing standard C 'for loops'. Notice how it extracts the `"for"` string from the Lexer using `$1->getname()`.

### b) Operators & Punctuators
**Example:** Logical OR `||` and Logical AND `&&`
- **Lexer `lex_analyzer.l`:**
  ```lex
  "&&"|"||"   { 
                  yylval = new symbol_info(yytext, "LOGICOP");
                  loglist="Line no "+to_string(lines)+": Token <LOGICOP> Lexeme "+yytext+" found\n\n";
                  outlog<<loglist;
                  return LOGICOP; 
              }
  ```
  *Explanation:* Uses the `|` regex OR to match either `&&` or `||`. The exact string matched revolves in `yytext` so we can pass it dynamically. Both return the same token class: `LOGICOP`.
- **Parser `syntax_analyzer.y`:**
  ```yacc
  %token LOGICOP
  // ...
  logic_expression : rel_expression LOGICOP rel_expression
      {
          // Semantic action logic concatenating the expressions with the matched LOGICOP
      }
  ```
  *Explanation:* Groups relational expressions structurally around any logical operator.

### c) Constants (Variables & Values)
**Example:** Floating Point Literals `CONST_FLOAT`
- **Lexer `lex_analyzer.l`:**
  ```lex
  float_regex  ({digit}*\.{digit}+|{digit}+\.{digit}*)([eE][-+]?{digit}+)?|{digit}+[eE][-+]?{digit}+
  
  {float_regex} {
                  yylval = new symbol_info(yytext, "CONST_FLOAT");
                  loglist="Line no "+to_string(lines)+": Token <CONST_FLOAT> Lexeme "+yytext+" found\n\n";
                  outlog<<loglist;
                  return CONST_FLOAT;
              }
  ```
  *Explanation:* A complex regex defined at the top of the file used to match fractions, decimals, and scientific (exponential) notation.
- **Parser `syntax_analyzer.y`:**
  ```yacc
  %token CONST_FLOAT
  // ...
  factor : CONST_FLOAT
      {
          outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
          outlog<<$1->getname()<<endl<<endl;
          $$ = new symbol_info($1->getname(),"factor");
      }
  ```
  *Explanation:* Defines a floating point number as the deepest, most atomic element of an expression (a `factor`), ensuring math executes in proper order.

### d) Identifiers
**Example:** Variables, function names `ID`
- **Lexer `lex_analyzer.l`:**
  ```lex
  letter_  [A-Za-z_]
  digit    [0-9]
  id       {letter_}({letter_}|{digit})*

  {id}        {
                  yylval = new symbol_info(yytext, "ID");
                  // logging omitted
                  return ID;
              }
  ```
  *Explanation:* Enforces that an identifier (variable name) can be alphanumeric but MUST start with a letter or underscore (`letter_`).
- **Parser `syntax_analyzer.y`:**
  ```yacc
  %token ID
  // ...
  variable : ID
  ```
  *Explanation:* Defines that a basic variable constitutes an identifier terminal `ID`.

---

## 5. More Conceptual Viva Questions

**Q: How does the Lexer communicate with the Parser?**
**A:** The parser calls the `yylex()` function generated by Flex. The lexer reads characters, matches a regular expression, and returns an Integer representing the Token id (e.g. `105` for `WHILE`). It also passes additional metadata strings (like the actual matched string text) to the parser via a global variable named `yylval`.

**Q: What is `yytext`?**
**A:** `yytext` is a global pointer managed by Flex that points to the exact string of characters currently matched by a Regular Expression rule in the lexer.

**Q: What is the purpose of `symbol_info`?**
**A:** `symbol_info` is a custom C++ class used to encapsulate token data (like its name/lexeme and its type). Because a token returned as just an "integer ID" doesn't carry the actual string content (like the variable's name or the number's value), we pass a pointer to a `symbol_info` object through `yylval` so the parser can retrieve the exact text to print the original code strings.

**Q: Why do we have `simple_expression`, `term`, and `factor` instead of just one big `expression` rule?**
**A:** Breaking down mathematical expressions strictly into multiple nested non-terminals (Expression -> Logic -> Relational -> Simple Add/Sub -> Term Mul/Div -> Factor atomic elements) is how we enforce **Operator Precedence** in Context-Free Grammars. It ensures that standard multiplication evaluates deeper in the parse tree (and thus earlier) than addition.

**Q: What is a Shift/Reduce Conflict? How did you fix it for If-Else?**
**A:** A shift/reduce conflict occurs when the parser reads a token and doesn't know whether to delay evaluating by matching more tokens (shift) or instantly convert the current stack using a matching grammar rule (reduce). For the dangling-else ambiguity, we used Bison's `%nonassoc` precedence directives to give `ELSE` a higher precedence, instructing the parser to always shift `else` and bind it to the nearest `if`.

**Q: Why did you get a Segmentation Fault during testing, and how was it resolved?**
**A:** The Yacc semantic actions were trying to concatenate the string values of all tokens using `$1->getname()`. However, the older provided lexer file never initialized `yylval` (which points to the `symbol_info` object) for certain keywords like `int`. Therefore, `yylval` was `NULL`. When the parser tried to access `$1->getname()` on a null pointer, memory crashed. We fixed it by using a script to allocate a `new symbol_info` for *all* tokens inside the lexer before they return.

**Q: What is the difference between Terminal and Non-Terminal?**
**A:** Terminals are the absolute smallest atomic tokens returned by the lexer (like `ID`, `IF`, `CONST_INT`). Non-terminals are complex structures built by grouping terminals and other non-terminals together in the parser grammar (like `statement`, `func_definition`, `expression`).
