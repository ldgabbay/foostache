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

OPENQS: '"' -> pushMode(inQuotedString) ;

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
PERCENT : '%' -> pushMode(inNumSpec);

// NUMBER_FORMAT : '%' '0'? PINTEGER? (DOT PINTEGER)? ('d' | 'f' | 'e') ;

// PINTEGER : [1-9][0-9]* ;
INTEGER : '0' | ('-'? [1-9][0-9]*) ;
ID : [a-zA-Z0-9_]+ ;


mode inNumSpec;

ZERO : '0' ;
DOTN : '.' ;
PINTEGERN : [1-9][0-9]* ;
NUMBER_SPECIFIER : ( 'd' | 'f' | 'e' ) -> popMode ;


mode inQuotedString;

fragment
HEXDIGIT : [0-9a-fA-F] ;

ESCCHARQS : '\\' ( '"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' | 'u' HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT ) ;

CLOSEQS: '"' -> popMode ;
CHARQS: . ;

// STRING: '"' (ESC| ~('\\' | '"'))*? '"' ;
