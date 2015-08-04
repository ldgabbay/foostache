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
    | literal
    | stringField
    | numberField
    | ifBlock
    | withBlock
    | iterateBlock
    | filterBlock
    ;

rawText
    : TEXT+
    ;

literal
    : OPENL literalText CLOSEL
    ;

literalText
    : TEXTL*
    ;

stringField
    : OPEN WS* path ( WS* inlineFilter )* WS* CLOSE
    ;

numberField
    : OPEN WS* path WS+ numberFormat ( WS* inlineFilter )* WS* CLOSE
    ;

inlineFilter
    : PIPE WS* ID
    ;

numberFormat
    : PERCENT (flags=ZERO)? (width=PINTEGERN)? (DOTN precision=PINTEGERN)? specifier=NUMBER_SPECIFIER
    ;

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
    : path                                          # boolExpression
    | path WS+ EXISTS                               # existsExpression
    | path WS+ IS WS+ TYPE                          # typeExpression
    | NOT WS+ expression                            # notExpression
    | expr1=expression WS+ AND WS+ expr2=expression # andExpression
    | expr1=expression WS+ OR WS+ expr2=expression  # orExpression
    | LPAREN WS* expression WS* RPAREN              # parenExpression
    ;

path
    : DOT
    | CARET* ((objectKey | LBRACKET arrayIndex RBRACKET) ((DOT objectKey) | (LBRACKET arrayIndex RBRACKET))*)?
    ;

objectKey
    : ID                                            # idObjectKey
    | OPENQS (CHARQS | ESCCHARQS)* CLOSEQS          # qsObjectKey
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
    : INTEGER? indexRangeB?
    ;

indexRangeB
    : COLON INTEGER? indexRangeC?
    ;

indexRangeC
    : COLON INTEGER
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

filterBlock
    : OPEN FILTER WS* filterName=ID WS* CLOSE statements OPEN END CLOSE
    ;
