# Compiler Design - Version 1.1 (Assignment 2)

## Accomplishments
- Integrated a **Symbol Table** and **Scope Management** system.
- Enhanced the Syntax Analyzer to handle nested scopes and variable declarations with scoping rules.
- Implemented `enter_scope()` and `exit_scope()` logic to track variables across different blocks.
- Added support for array declarations and function definitions with parameter tracking within the symbol table.

## How it was Accomplished
- **Symbol Table Implementation**: Developed a robust C++ data structure consisting of `symbol_info`, `scope_table`, and `symbol_table` classes.
- **Nested Scoping**: Implemented a linked-list of scope tables to manage variable visibility and lifetime across different block levels.
- **Semantic Actions**: Embedded C++ code within Bison rules to perform real-time table insertions and scope transitions during parsing.
- **Enhanced Tokenization**: Updated the Lexer to pass detailed symbol information to the parser using `yylval`.
