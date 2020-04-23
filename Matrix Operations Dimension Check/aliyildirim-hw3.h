#ifndef __EX4_H
#define __EX4_H

typedef struct Expr1Node {
	int row  ;
	int column ;
	int scalar ;
}Expr1Node;

typedef union {
  Expr1Node expr1;
}Expr;

typedef struct TreeNode {
        Expr *ptr;
}TreeNode;

#endif
