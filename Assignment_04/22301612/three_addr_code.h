#ifndef THREE_ADDR_CODE_H
#define THREE_ADDR_CODE_H

#include "ast.h"
#include <fstream>
#include <string>
#include <map>

using namespace std;

class ThreeAddrCodeGenerator {
private:
    ProgramNode* ast_root;
    ofstream& outcode;
    map<string, string> symbol_to_temp;
    int temp_count;
    int label_count;

public:
    ThreeAddrCodeGenerator(ProgramNode* root, ofstream& out)
        : ast_root(root), outcode(out), temp_count(0), label_count(0) {}

    void generate() {
        if (!ast_root) return;
        outcode << "; --- Generated Three-Address Code ---" << endl;
        ast_root->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << "; --- End of Three-Address Code ---" << endl;
    }

    // You may add helper methods here
};

#endif // THREE_ADDR_CODE_H