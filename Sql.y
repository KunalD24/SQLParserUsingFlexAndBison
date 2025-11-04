%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
    char* type;
    char* value;
    struct Node* left;
    struct Node* right;
} Node;

Node* makeNode(char* type, char* value, Node* left, Node* right);
void printTree(Node* root);
void yyerror(const char* s);
int yylex();
Node* root = NULL;
%}

%union {
    char* str;
    struct Node* node;
}

%token SELECT FROM WHERE
%token ID NUMBER STAR
%token EQUALS SEMICOLON

%type <node> statement select_clause from_clause where_clause condition
%type <str> ID NUMBER STAR

%start statement

%%

statement:
      select_clause from_clause where_clause SEMICOLON {
          root = makeNode("STATEMENT", NULL, $1, makeNode("FROM_WHERE", NULL, $2, $3));
          printf("AST: ");
          printTree(root);
          printf("\n");
      }
;

select_clause:
      SELECT ID {
          $$ = makeNode("SELECT", $2, NULL, NULL);
      }
    | SELECT STAR {
          $$ = makeNode("SELECT", "*", NULL, NULL);
      }
;

from_clause:
      FROM ID {
          $$ = makeNode("FROM_CLAUSE", $2, NULL, NULL);
      }
;

where_clause:
      WHERE condition {
          $$ = makeNode("WHERE", NULL, $2, NULL);
      }
;

condition:
      ID EQUALS NUMBER {
          char buf[128];
          snprintf(buf, sizeof(buf), "%s = %s", $1, $3);
          $$ = makeNode("CONDITION", strdup(buf), NULL, NULL);
      }
;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}

Node* makeNode(char* type, char* value, Node* left, Node* right) {
    Node* n = malloc(sizeof(Node));
    n->type = strdup(type);
    n->value = value ? strdup(value) : NULL;
    n->left = left;
    n->right = right;
    return n;
}

void printTree(Node* root) {
    if (!root) return;
    printf("(%s", root->type);
    if (root->value) printf(":%s", root->value);
    if (root->left) { printf(" "); printTree(root->left); }
    if (root->right) { printf(" "); printTree(root->right); }
    printf(")");
}

int main() {
    printf("Enter SQL statements (Ctrl+D to exit):\n");
    yyparse();
    return 0;
}
