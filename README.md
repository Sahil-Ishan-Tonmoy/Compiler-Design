# Compiler Design - Version 1.3 (Assignment 4)

## Accomplishments
- Implemented **Three-Address Code (TAC) Generation**.
- Developed an **Abstract Syntax Tree (AST)** structure to represent the program's hierarchy.
- Created a recursive code generation system that traverses the AST to produce intermediate TAC output.
- Managed temporary variable generation and label handling for control flow structures.

## How it was Accomplished
- **AST Construction**: Designed a C++ class hierarchy for AST nodes and modified the parser to build the tree during the syntax analysis phase.
- **Recursive Generation**: Implemented a `generate_code()` visitor pattern where each node generates its own TAC instructions and manages its results.
- **Symbol Mapping**: Utilized a temporary variable manager to map high-level variable names to intermediate code registers.
- **Labeling Logic**: Developed a label generator to facilitate assembly-like jumps for `if` statements and loops.
