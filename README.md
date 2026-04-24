# Compiler Design Project

This repository documents the step-by-step development of a C-subset compiler, covering every phase from lexical analysis to intermediate code generation.

## 🎓 Student Information
- **Student ID**: 22301612

## 🚀 Project Overview
This project is a multi-phase compiler implementation built using **Flex**, **Bison**, and **C++**. The compiler is designed to parse a subset of the C language and generate Three-Address Code (TAC).

## 📂 Version History (Branches)
Explore the development milestones by switching to the respective branches:

| Version | Assignment | Key Features |
| :--- | :--- | :--- |
| [**Version 1.0**](https://github.com/Sahil-Ishan-Tonmoy/Compiler-Design/tree/Version_1.0) | Assignment 1 | Basic Lexer & Syntax Analyzer core. |
| [**Version 1.1**](https://github.com/Sahil-Ishan-Tonmoy/Compiler-Design/tree/Version_1.1) | Assignment 2 | Symbol Table & Nested Scope Management. |
| [**Version 1.2**](https://github.com/Sahil-Ishan-Tonmoy/Compiler-Design/tree/Version_1.2) | Assignment 3 | Semantic Analysis & Type Checking. |
| [**Version 1.3**](https://github.com/Sahil-Ishan-Tonmoy/Compiler-Design/tree/Version_1.3) | Assignment 4 | AST Construction & Three-Address Code (TAC) Generation. |

## 🛠️ Technologies Used
- **Flex**: Fast Lexical Analyzer Generator.
- **Bison**: GNU Parser Generator (Yacc-compatible).
- **C++**: Core logic and data structures (Symbol Table, AST).
- **Shell (Bash)**: Automation scripts for compilation.

## ⚙️ How to Run
To run any specific version of the compiler:
1. Switch to the desired branch.
2. Ensure you have `flex`, `bison`, and `g++` installed.
3. Run the provided script (within the assignment folder):
   ```bash
   bash script.sh
   ```
4. The output logs (e.g., `my_log.txt`, `error.txt`) will be generated in the specified directory.

---
*Developed as part of the Compiler Design (CSE420) Course.*
