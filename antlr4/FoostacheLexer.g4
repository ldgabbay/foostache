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
WS : [ \t\r\n]+ -> skip ;

OPENQS: '"' -> pushMode(inQuotedString) ;

AFTER : ':after' ;
BEFORE : ':before' ;
BETWEEN : ':between' ;
ELSE : ':else' ;
ELSEIF : ':elseif' ;
END : ':end' ;
ESCAPE : ':escape' ;
FILTER : ':filter' ;
IF : ':if' ;
ITERATE : ':iterate' ;
WITH : ':with' ;

TYPE : 'string' | 'number' | 'object' | 'array' | 'boolean' | 'null' ;
AND : 'and' ;
EXISTS : 'exists' ;
IS : 'is' ;
NOT : 'not' ;
OR : 'or' ;

LPAREN : '(' ;
RPAREN : ')' ;
DOT : '.' ;
LBRACKET : '[' ;
RBRACKET : ']' ;
CARET : '^' ;
COLON : ':' ;

PIPE : '|' ;
PERCENT : '%' -> pushMode(inNumSpec) ;

INTEGER : '0' | ('-'? [1-9][0-9]*) ;
ID : [a-zA-Z0-9_]+ ;


mode inNumSpec;

ZERO : '0' ;
DOTN : '.' ;
PINTEGERN : [1-9][0-9]* ;
NUMBER_SPECIFIER : ( 'd' | 'f' ) -> popMode ;

// PINTEGER : [1-9][0-9]* ;
// NUMBER_FORMAT : '%' '0'? PINTEGER? (DOT PINTEGER)? ('d' | 'f' | 'e') ;


mode inQuotedString;

fragment
HEXDIGIT : [0-9a-fA-F] ;

ESCCHARQS : '\\' ( '"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' | 'u' HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT ) ;

CLOSEQS: '"' -> popMode ;
CHARQS: . ;

// STRING: '"' (ESC| ~('\\' | '"'))*? '"' ;
