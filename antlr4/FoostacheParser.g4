parser grammar FoostacheParser;

options { tokenVocab=FoostacheLexer; }

template
    : statements EOF
    ;

statements
    : statement*
    ;

statement
    : rawText
    | OPENL literalText? CLOSEL
    | stringField
    | numberField
    | ifBlock
    | withBlock
    | iterateBlock
    | escapeBlock
    ;

rawText
    : TEXT+
    ;

literalText
    : TEXTL+
    ;

stringField
    : OPEN WS* path ( WS+ PIPE WS* filterName=ID )* WS* CLOSE
    ;

numberField
    : OPEN WS* path WS+ numberFormat=NUMBER_FORMAT ( WS+ PIPE WS* filterName=ID )* WS* CLOSE
    ;

// numberFormat
//     : PERCENT (flags=ZERO)? (width=PINTEGER)? (DOT precision=PINTEGER)? specifier=NUMBER_SPECIFIER
//     ;

ifBlock
    : ifTag statements elseifBlock* elseBlock? OPEN END CLOSE
    ;

ifTag
    : OPEN IF WS+ expression WS* CLOSE
    ;

elseifBlock
    : elseifTag statements
    ;

elseifTag
    : OPEN ELSEIF WS+ expression WS* CLOSE
    ;

elseBlock
    : OPEN ELSE CLOSE statements
    ;

expression
    : path
    | path WS+ EXISTS
    | path WS+ IS WS+ TYPE
    | LPAREN WS* expression WS* RPAREN
    | expression WS+ AND WS+ expression
    | expression WS+ OR WS+ expression
    | NOT WS+ expression
    ;

path
    : DOT
    | CARET* ((objectKey | LBRACKET arrayIndex RBRACKET) ((DOT objectKey) | (LBRACKET arrayIndex RBRACKET))*)?
    ;

objectKey
    : ID
    | STRING
    ;

arrayIndex
    : INTEGER
    ;

withBlock
    : OPEN WITH WS+ path WS* CLOSE statements OPEN END CLOSE
    ;

iterateBlock
    : OPEN ITERATE WS+ path WS+ indexRange WS* CLOSE statements iterateClause* OPEN END CLOSE
    ;

indexRange
    : start=INTEGER? ( COLON stop=INTEGER? ( COLON step=PINTEGER )? )?
    ;

iterateClause
    : iterateBeforeClause
    | iterateAfterClause
    | iterateBetweenClause
    | iterateElseClause
    ;

iterateBeforeClause
    : OPEN BEFORE CLOSE statements
    ;

iterateAfterClause
    : OPEN AFTER CLOSE statements
    ;

iterateBetweenClause
    : OPEN BETWEEN CLOSE statements
    ;

iterateElseClause
    : OPEN ELSE CLOSE statements
    ;

escapeBlock
    : OPEN PIPE WS* filterName=ID WS* CLOSE statements OPEN END CLOSE
    ;
