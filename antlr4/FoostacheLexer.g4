lexer grammar FoostacheLexer;

/* scanner rules */

COMMENT : '{{!' .*? '}}' -> skip ;
OPENL : '{{"' -> pushMode(inLiteral) ;
OPEN : '{{' -> pushMode(inTag) ;
TEXT : . ;


mode inLiteral;

CLOSEL : '"}}' -> popMode ;
TEXTL : . ;


mode inTag;

CLOSE : '}}' -> popMode ;
WS : [ \t\r\n];

STRING: '"' (ESC| ~('\\' | '"'))*? '"' ;

fragment
ESC : '\\' ( '"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' | 'u' HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT ) ;

fragment
HEXDIGIT : [0-9a-fA-F] ;

TYPE : 'string' | 'number' | 'object' | 'array' | 'boolean' | 'null' ;

LPAREN : '(' ;
RPAREN : ')' ;
DOT : '.' ;
ELSE : ':else' ;
ELSEIF : ':elseif' ;
END : ':end' ;
ESCAPE : ':escape' ;
IF : ':if' ;
WITH : ':with' ;
LBRACKET : '[' ;
RBRACKET : ']' ;
CARET : '^' ;
AND : 'and' ;
EXISTS : 'exists' ;
IS : 'is' ;
NOT : 'not' ;
OR : 'or' ;
ITERATE : ':iterate' ;
BEFORE : ':before' ;
AFTER : ':after' ;
BETWEEN : ':between' ;
FILTER : ':filter' ;
COLON : ':' ;

PIPE : '|' ;
// PERCENT : '%' ;
// ZERO : '0' ;
// NUMBER_SPECIFIER : 'd' | 'f' | 'e' ;

NUMBER_FORMAT : '%' '0'? PINTEGER? (DOT PINTEGER)? ('d' | 'f' | 'e') ;

PINTEGER : [1-9][0-9]* ;
INTEGER : '0' | ('-'? [1-9][0-9]*) ;
ID : [a-zA-Z0-9_]+ ;
