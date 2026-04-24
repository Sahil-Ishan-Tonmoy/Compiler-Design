# Compiler Design - Version 1.0 (Assignment 1)

## Accomplishments
- Implemented a basic **Lexical Analyzer** using Flex to recognize keywords (`int`, `return`, `if`, etc.), variables (IDs), integer constants, and common operators.
- Developed an initial **Syntax Analyzer** using Bison with grammar rules for a subset of the C language.
- Enabled basic parsing of statement blocks, function definitions, mathematical expressions, and control flow (if-else).
- Configured logging of parse tree steps to `my_log.txt`.

## How it was Accomplished
- **Flex Lexer**: Defined regular expressions and semantic actions to tokenize core C elements.
- **Bison Parser**: Mapped context-free grammar rules for the language subset and linked them to the lexer.
- **Build Automation**: Created a shell script (`script.sh`) to automate the Flex/Bison compilation and linking process using `g++`.
- **WSL Integration**: Adapted the build process for a Linux-like environment (WSL) to produce standard `a.out` binaries.
