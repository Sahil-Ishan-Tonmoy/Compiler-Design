# Compiler Design - Version 1.2 (Assignment 3)

## Accomplishments
- Implemented a robust **Semantic Analyzer**.
- Added **Type Checking** for expressions, ensuring compatibility between different data types (e.g., int, float).
- Developed **Function Call Validation**, checking for undeclared functions, parameter count mismatches, and type inconsistencies.
- Integrated comprehensive **Error Reporting** for semantic issues such as redeclaration, undeclared variables, and illegal operations.

## How it was Accomplished
- **Metadata Storage**: Expanded the `symbol_info` class to store type information, function signatures, and parameter details.
- **Bison Integration**: Added logic to Bison reduction actions to perform post-order traversal type checking and validation.
- **Error Management**: Created a dedicated `semantic_error` system to log detailed diagnostic messages to `error.txt`.
- **Function Mapping**: Implemented signature verification by comparing caller argument lists against the definition stored in the Symbol Table.
