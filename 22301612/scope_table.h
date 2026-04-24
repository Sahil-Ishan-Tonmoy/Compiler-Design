#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        unsigned long hash = 0;
        for (int i = 0; i < name.length(); i++) {
            hash += name[i];
        }
        return hash % bucket_count;
    }

public:
    scope_table();
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope);
    scope_table *get_parent_scope();
    int get_unique_id();
    symbol_info *lookup_in_scope(symbol_info* symbol);
    bool insert_in_scope(symbol_info* symbol);
    bool delete_from_scope(symbol_info* symbol);
    void print_scope_table(ofstream& outlog);
    ~scope_table();

    // you can add more methods if you need
};

// complete the methods of scope_table class
scope_table::scope_table()
{
    bucket_count = 0;
    unique_id = 0;
    parent_scope = NULL;
}

scope_table::scope_table(int bucket_count, int unique_id, scope_table *parent_scope)
{
    this->bucket_count = bucket_count;
    this->unique_id = unique_id;
    this->parent_scope = parent_scope;
    table.resize(bucket_count);
}

scope_table *scope_table::get_parent_scope()
{
    return parent_scope;
}

int scope_table::get_unique_id()
{
    return unique_id;
}

symbol_info *scope_table::lookup_in_scope(symbol_info* symbol)
{
    int index = hash_function(symbol->get_name());
    for (symbol_info* current : table[index]) {
        if (current->get_name() == symbol->get_name()) {
            return current;
        }
    }
    return NULL;
}

bool scope_table::insert_in_scope(symbol_info* symbol)
{
    if (lookup_in_scope(symbol) != NULL) {
        return false; // Already exists
    }
    int index = hash_function(symbol->get_name());
    table[index].push_back(symbol);
    return true;
}

bool scope_table::delete_from_scope(symbol_info* symbol)
{
    int index = hash_function(symbol->get_name());
    auto& bucket = table[index];
    for (auto it = bucket.begin(); it != bucket.end(); ++it) {
        if ((*it)->get_name() == symbol->get_name()) {
            bucket.erase(it);
            return true;
        }
    }
    return false;
}

scope_table::~scope_table()
{
    for (int i = 0; i < bucket_count; ++i) {
        for (symbol_info* symbol : table[i]) {
            delete symbol; // Deallocate symbol_info objects
        }
    }
}

void scope_table::print_scope_table(ofstream& outlog)
{
    outlog << "ScopeTable # "+ to_string(unique_id) << endl;

    //iterate through the current scope table and print the symbols and all relevant information
    for (int i = 0; i < bucket_count; i++) {
        if (table[i].empty()) continue;
        
        outlog << i << " --> " << endl;
        for (symbol_info* sym : table[i]) {
            outlog << "< " << sym->get_name() << " : " << sym->get_type() << " >" << endl;
            if (sym->get_id_type() != "") {
                outlog << sym->get_id_type() << endl;
            }
            if (sym->get_id_type() == "Array") {
                outlog << "Type: " << sym->get_data_type() << endl;
                outlog << "Size: " << sym->get_array_size() << endl << endl;
            } else if (sym->get_id_type() == "Variable") {
                outlog << "Type: " << sym->get_data_type() << endl << endl;
            } else if (sym->get_id_type() == "Function Definition" || sym->get_id_type() == "Function Declaration") {
                outlog << "Return Type: " << sym->get_data_type() << endl;
                outlog << "Number of Parameters: " << sym->get_param_names().size() << endl;
                outlog << "Parameter Details: ";
                auto names = sym->get_param_names();
                auto types = sym->get_param_types();
                for (int p = 0; p < names.size(); ++p) {
                    if (p > 0) outlog << ", ";
                    outlog << types[p] << " " << names[p];
                }
                outlog << endl;
            }
        }
    }
    outlog << endl;
}