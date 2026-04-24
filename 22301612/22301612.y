%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.
// You can store the pointer to your symbol table in a global variable
// or you can create an object
symbol_table *table;

int lines = 1;

ofstream outlog;

// you may declare other necessary variables here to store necessary info
// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.
string current_type = "";
string current_func_name = "";
int func_start_line = 0;
vector<symbol_info*> current_var_list;
vector<symbol_info*> current_param_list;
vector<string> current_arg_types;
bool entering_func = false;
int error_count = 0;

ofstream error_out;

void yyerror(char *s)
{
	outlog<<"Error at line "<<lines<<": "<<s<<endl<<endl;
}

void semantic_error(string msg) {
    error_count++;
    error_out << "At line no: " << lines << " " << msg << endl << endl;
}

void semantic_warning(string msg) {
    error_count++;
    error_out << "At line no: " << lines << " " << msg << endl << endl;
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		// Print your whole symbol table here
        table->print_all_scopes(outlog);
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->get_name()+"\n"+$2->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name()+"\n"+$2->get_name(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN 
        {
            current_func_name = $2->get_name();
            func_start_line = lines;
            symbol_info* existing = table->lookup($2);
            if (existing != NULL) {
                semantic_error("Multiple declaration of function " + $2->get_name());
            } else {
                symbol_info* func = new symbol_info($2->get_name(), "ID");
                func->set_id_type("Function Definition");
                func->set_data_type($1->get_name());
                for (auto param : current_param_list) {
                    func->add_param(param->get_name(), param->get_data_type());
                }
                table->insert(func);
            }
            entering_func = true;
        } compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<"("+$4->get_name()+")\n"<<$7->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")\n"+$7->get_name(),"func_def");	
			
			current_param_list.clear();
		}
		| type_specifier ID LPAREN RPAREN 
        {
            current_func_name = $2->get_name();
            symbol_info* existing = table->lookup($2);
            if (existing != NULL) {
                semantic_error("Multiple declaration of function " + $2->get_name());
            } else {
                symbol_info* func = new symbol_info($2->get_name(), "ID");
                func->set_id_type("Function Definition");
                func->set_data_type($1->get_name());
                table->insert(func);
            }
            entering_func = true;
        } compound_statement
		{
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<"()\n"<<$6->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+"()\n"+$6->get_name(),"func_def");	
			
			current_param_list.clear();
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->get_name()<<","<<$3->get_name()<<" "<<$4->get_name()<<endl<<endl;
					
			$$ = new symbol_info($1->get_name()+","+$3->get_name()+" "+$4->get_name(),"param_list");
            symbol_info* param = new symbol_info($4->get_name(), "ID");
            param->set_id_type("Variable");
            param->set_data_type($3->get_name());
            current_param_list.push_back(param);
		}
		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->get_name()<<","<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+","+$3->get_name(),"param_list");
            symbol_info* param = new symbol_info("", "ID");
            param->set_data_type($3->get_name());
            current_param_list.push_back(param);
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name(),"param_list");
            symbol_info* param = new symbol_info($2->get_name(), "ID");
            param->set_id_type("Variable");
            param->set_data_type($1->get_name());
            current_param_list.push_back(param);
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"param_list");
            symbol_info* param = new symbol_info("", "ID");
            param->set_data_type($1->get_name());
            current_param_list.push_back(param);
		}
 		;

compound_statement : LCURL 
            {
                table->enter_scope();
                outlog << "New ScopeTable with ID " << table->current_scope_id << " created" << endl << endl;
                if (entering_func) {
                    for(auto param : current_param_list) {
                        if (param->get_name() != "") {
                            bool inserted = table->insert(new symbol_info(*param));
                            if (!inserted) {
                                error_count++;
                                error_out << "At line no: " << func_start_line << " Multiple declaration of variable " << param->get_name() << " in parameter of " << current_func_name << endl << endl;
                                outlog << "At line no: " << func_start_line << " Multiple declaration of variable " << param->get_name() << " in parameter of " << current_func_name << endl << endl;
                            }
                        }
                    }
                    entering_func = false;
                }
            }
            statements RCURL
			{ 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				outlog<<"{\n"+$3->get_name()+"\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n"+$3->get_name()+"\n}","comp_stmnt");
				
                table->print_all_scopes(outlog);
                int removed_id = table->get_current_id();
                table->exit_scope();
                outlog << "Scopetable with ID " << removed_id << " removed" << endl << endl;
 		    }
 		    | LCURL 
            {
                table->enter_scope();
                outlog << "New ScopeTable with ID " << table->current_scope_id << " created" << endl << endl;
                if (entering_func) {
                    for(auto param : current_param_list) {
                        if (param->get_name() != "") {
                            bool inserted = table->insert(new symbol_info(*param));
                            if (!inserted) {
                                error_count++;
                                error_out << "At line no: " << func_start_line << " Multiple declaration of variable " << param->get_name() << " in parameter of " << current_func_name << endl << endl;
                                outlog << "At line no: " << func_start_line << " Multiple declaration of variable " << param->get_name() << " in parameter of " << current_func_name << endl << endl;
                            }
                        }
                    }
                    entering_func = false;
                }
            } 
            RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");
				
                table->print_all_scopes(outlog);
                int removed_id = table->get_current_id();
                table->exit_scope();
                outlog << "Scopetable with ID " << removed_id << " removed" << endl << endl;
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		 {
			outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<";"<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+";","var_dec");
			
            if ($1->get_name() == "void") {
                semantic_error("variable type can not be void");
            } else {
                for(auto var : current_var_list) {
                    var->set_data_type(current_type);
                    bool inserted = table->insert(var);
                    if (!inserted) {
                        semantic_error("Multiple declaration of variable " + var->get_name());
                    }
                }
            }
            current_var_list.clear();
		 }
 		 ;

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;
			
			$$ = new symbol_info("int","type");
            current_type = "int";
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;
			
			$$ = new symbol_info("float","type");
            current_type = "float";
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;
			
			$$ = new symbol_info("void","type");
            current_type = "void";
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
  		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
  		  	outlog<<$1->get_name()+","<<$3->get_name()<<endl<<endl;
            $$ = new symbol_info($1->get_name()+","+$3->get_name(),"dec_list");

            symbol_info* var = new symbol_info($3->get_name(), "ID");
            var->set_id_type("Variable");
            current_var_list.push_back(var);
  		  }
  		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD //array after some declaration
  		  {
  		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
  		  	outlog<<$1->get_name()+","<<$3->get_name()<<"["<<$5->get_name()<<"]"<<endl<<endl;
            $$ = new symbol_info($1->get_name()+","+$3->get_name()+"["+$5->get_name()+"]","dec_list");

            symbol_info* var = new symbol_info($3->get_name(), "ID");
            var->set_id_type("Array");
            var->set_array_size(stoi($5->get_name()));
            current_var_list.push_back(var);
  		  }
  		  |ID
  		  {
  		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
 			outlog<<$1->get_name()<<endl<<endl;
            $$ = new symbol_info($1->get_name(),"dec_list");

            symbol_info* var = new symbol_info($1->get_name(), "ID");
            var->set_id_type("Variable");
            current_var_list.push_back(var);
  		  }
  		  | ID LTHIRD CONST_INT RTHIRD //array
  		  {
  		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 			outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;
            $$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]","dec_list");

            symbol_info* var = new symbol_info($1->get_name(), "ID");
            var->set_id_type("Array");
            var->set_array_size(stoi($3->get_name()));
            current_var_list.push_back(var);
  		  }
  		  ;
 		  

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->get_name()<<"\n"<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+"\n"+$2->get_name(),"stmnts");
	   }
	   ;
	   
statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->get_name()<<endl<<endl;

            $$ = new symbol_info($1->get_name(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->get_name()<<$4->get_name()<<$5->get_name()<<")\n"<<$7->get_name()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->get_name()+$4->get_name()+$5->get_name()+")\n"+$7->get_name(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->get_name()<<")\n"<<$5->get_name()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->get_name()<<")\n"<<$5->get_name()<<"\nelse\n"<<$7->get_name()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name()+"\nelse\n"+$7->get_name(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->get_name()<<")\n"<<$5->get_name()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->get_name()+")\n"+$5->get_name(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->get_name()<<");"<<endl<<endl; 
			
			$$ = new symbol_info("printf("+$3->get_name()+");","stmnt");
            
            symbol_info* found = table->lookup($3);
            if (found == NULL) {
                semantic_error("Undeclared variable " + $3->get_name());
            }
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->get_name()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->get_name()+";","stmnt");
	  }
	  ;
	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->get_name()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->get_name()+";","expr_stmt");
	        }
			;
	  
variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"varbl");
		
        symbol_info* found = table->lookup($1);
        if (found == NULL) {
            semantic_error("Undeclared variable " + $1->get_name());
            $$->set_data_type("error");
        } else {
            if (found->get_id_type() == "Array") {
                semantic_error("variable is of array type : " + $1->get_name());
                $$->set_data_type("error");
            } else {
                $$->set_data_type(found->get_data_type());
            }
        }
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;
		
		$$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]","varbl");
		
        symbol_info* found = table->lookup($1);
        if (found == NULL) {
            semantic_error("Undeclared variable " + $1->get_name());
            $$->set_data_type("error");
        } else {
            if (found->get_id_type() != "Array") {
                semantic_error("variable is not of array type : " + $1->get_name());
            }
            if ($3->get_data_type() != "int") {
                semantic_error("array index is not of integer type : " + $1->get_name());
            }
            $$->set_data_type(found->get_data_type());
        }
	 }
	 ;
	 
expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"expr");
            $$->set_data_type($1->get_data_type());
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<"="<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+"="+$3->get_name(),"expr");
            
            if ($1->get_data_type() == "void" || $3->get_data_type() == "void") {
                semantic_error("operation on void type");
            } else if ($1->get_data_type() == "int" && $3->get_data_type() == "float") {
                semantic_warning("Warning: Assignment of float value into variable of integer type");
            }
            $$->set_data_type($1->get_data_type());
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"lgc_expr");
            $$->set_data_type($1->get_data_type());
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"lgc_expr");
            if ($1->get_data_type() == "void" || $3->get_data_type() == "void") {
                semantic_error("Void function used in expression");
            }
            $$->set_data_type("int");
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"rel_expr");
            $$->set_data_type($1->get_data_type());
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"rel_expr");
            if ($1->get_data_type() == "void" || $3->get_data_type() == "void") {
                semantic_error("Void function used in expression");
            }
            $$->set_data_type("int");
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"simp_expr");
			$$->set_data_type($1->get_data_type());
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"simp_expr");
            if ($1->get_data_type() == "void" || $3->get_data_type() == "void") {
                semantic_error("Void function used in expression");
                $$->set_data_type("error");
            } else if ($1->get_data_type() == "float" || $3->get_data_type() == "float") {
                $$->set_data_type("float");
            } else {
                $$->set_data_type("int");
            }
	      }
		  ;
					
term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"term");
			$$->set_data_type($1->get_data_type());
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"term");
            
            if ($1->get_data_type() == "void" || $3->get_data_type() == "void") {
                semantic_error("operation on void type");
                $$->set_data_type("error");
            } else if ($2->get_name() == "%") {
                if ($1->get_data_type() != "int" || $3->get_data_type() != "int") {
                    semantic_error("Modulus operator on non integer type");
                }
                if ($3->get_name() == "0") {
                    semantic_error("Modulus by 0");
                }
                $$->set_data_type("int");
            } else {
                if ($2->get_name() == "/" && $3->get_name() == "0") {
                    semantic_error("Division by 0"); // Added this one for consistency
                }
                if ($1->get_data_type() == "float" || $3->get_data_type() == "float") {
                    $$->set_data_type("float");
                } else {
                    $$->set_data_type("int");
                }
            }
	 }
     ;

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name(),"un_expr");
            $$->set_data_type($2->get_data_type());
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info("!"+$2->get_name(),"un_expr");
            $$->set_data_type("int");
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"un_expr");
            $$->set_data_type($1->get_data_type());
	     }
		 ;
	
factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
        $$->set_data_type($1->get_data_type());
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->get_name()<<"("<<$3->get_name()<<")"<<endl<<endl;

		$$ = new symbol_info($1->get_name()+"("+$3->get_name()+")","fctr");
        
        symbol_info* found = table->lookup($1);
        if (found == NULL) {
            semantic_error("Undeclared function: " + $1->get_name());
            $$->set_data_type("error");
        } else if (found->get_id_type() != "Function Definition" && found->get_id_type() != "Function Declaration") {
            semantic_error($1->get_name() + " is not a function");
            $$->set_data_type("error");
        } else {
            if (found->get_data_type() == "void") {
                $$->set_data_type("void");
            } else {
                $$->set_data_type(found->get_data_type());
            }

            auto expected_types = found->get_param_types();
            if (current_arg_types.size() != expected_types.size()) {
                semantic_error("Inconsistencies in number of arguments in function call: " + $1->get_name());
            } else {
                for (int i = 0; i < current_arg_types.size(); i++) {
                    if (current_arg_types[i] != expected_types[i]) {
                        // Special check to avoid double error at line 44
                        // The sample only wants "variable is of array type : c"
                        // My code currently reports "argument 2 type mismatch" because current_arg_types[i] is "error" or similar?
                        // Let's check if the argument was an array error.
                        if (current_arg_types[i] != "error") {
                            semantic_error("argument " + to_string(i+1) + " type mismatch in function call: " + $1->get_name());
                        }
                    }
                }
            }
        }
        current_arg_types.clear();
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->get_name()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->get_name()+")","fctr");
        $$->set_data_type($2->get_data_type());
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
        $$->set_data_type("int");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
        $$->set_data_type("float");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->get_name()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1->get_name()+"++","fctr");
        $$->set_data_type($1->get_data_type());
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->get_name()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1->get_name()+"--","fctr");
        $$->set_data_type($1->get_data_type());
	}
	;
	
argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->get_name()<<endl<<endl;
						
					$$ = new symbol_info($1->get_name(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<","<<$3->get_name()<<endl<<endl;
						
				$$ = new symbol_info($1->get_name()+","+$3->get_name(),"arg");
                current_arg_types.push_back($3->get_data_type());
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<endl<<endl;
						
				$$ = new symbol_info($1->get_name(),"arg");
                current_arg_types.push_back($1->get_data_type());
		  }
	      ;
 

%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}

    string student_id = "22301612"; 
	outlog.open(student_id + "_log.txt", ios::trunc);
    error_out.open(student_id + "_error.txt", ios::trunc);
	
    table = new symbol_table(10);
    table->enter_scope();
    outlog << "New ScopeTable with ID 1 created" << endl << endl;

    yyparse();
	
	outlog << "Total lines: " << lines << endl;
    outlog << "Total errors: " << error_count << endl;
    error_out << "Total errors: " << error_count << endl;
	
	outlog.close();
    error_out.close();
	
	fclose(yyin);
	
	return 0;
}