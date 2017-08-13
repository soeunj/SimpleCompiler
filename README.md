# SimpleCompiler
Compiler for integer operation

This is the midterm project for Compiler course at Chungbuk National University.

The method of compiling and executing the project:
- Execute Flex.
  creating lexical analyzer source using LEX.BAT.
C> LEX cbu
- Execute Bison.
  creating syntactic analyzer and code generator source using YACC.BAT.
C> YACC cbu 
- Compile cbu compiler source(cbu.c, cbulex.c).
  compiling cbu.c and cbulex.c in Visual C++.
- Create cbu compiler.
  creating cbu.exe which is cbu compiler.
- Test the compiler.
  C> cbu < sample.cbu
  C> asm3 < a.asm
  C> machine2 a.run

The process of the project:
- Recognizing sentence as token unit in Lex.
- Setting priority of operator.
- Creating parse tree using tokens based on the integer operation grammar.
- Showing the result.
