#include<bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name;
    string type;

    // Write necessary attributes to store what type of symbol it is (variable/array/function)
    string id_type; // e.g., "Variable", "Array", "Function Definition", "Function Declaration"
    // Write necessary attributes to store the type/return type of the symbol (int/float/void/...)
    string data_type; // e.g., "int", "float", "void"
    // Write necessary attributes to store the parameters of a function
    vector<string> param_names;
    vector<string> param_types;
    // Write necessary attributes to store the array size if the symbol is an array
    int array_size;

    // Pointer for hash table collision chaining
    symbol_info* next;

public:
    symbol_info(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->id_type = "";
        this->data_type = "";
        this->array_size = 0;
        this->next = NULL;
    }
    string get_name()
    {
        return name;
    }
    string get_type()
    {
        return type;
    }
    void set_name(string name)
    {
        this->name = name;
    }
    void set_type(string type)
    {
        this->type = type;
    }
    // Write necessary functions to set and get the attributes
    string get_id_type() { return id_type; }
    void set_id_type(string id_type) { this->id_type = id_type; }

    string get_data_type() { return data_type; }
    void set_data_type(string data_type) { this->data_type = data_type; }

    int get_array_size() { return array_size; }
    void set_array_size(int array_size) { this->array_size = array_size; }

    vector<string>& get_param_names() { return param_names; }
    void add_param(string name, string type) {
        param_names.push_back(name);
        param_types.push_back(type);
    }
    vector<string>& get_param_types() { return param_types; }

    symbol_info* get_next() { return next; }
    void set_next(symbol_info* next) { this->next = next; }
    ~symbol_info()
    {
        // Write necessary code to deallocate memory, if necessary
    }
};