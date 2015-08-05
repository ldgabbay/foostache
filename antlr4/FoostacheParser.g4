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
    : OPEN path ( inlineFilter )* CLOSE
    ;

numberField
    : OPEN path numberFormat ( inlineFilter )* CLOSE
    ;

inlineFilter
    : PIPE ID
    ;

numberFormat
    : PERCENT (flags=ZERO)? (width=PINTEGERN)? (DOTN precision=PINTEGERN)? specifier=NUMBER_SPECIFIER
    ;

ifBlock
    : ifTag statements elseifBlock* elseBlock? OPEN END CLOSE
    ;

ifTag
    : OPEN IF expression CLOSE
    ;

elseifBlock
    : elseifTag statements
    ;

elseifTag
    : OPEN ELSEIF expression CLOSE
    ;

elseBlock
    : OPEN ELSE CLOSE statements
    ;

expression
    : path                                     # boolExpression
    | path EXISTS                              # existsExpression
    | path IS TYPE                             # typeExpression
    | NOT expression                           # notExpression
    | expr1=expression AND expr2=expression    # andExpression
    | expr1=expression OR expr2=expression     # orExpression
    | LPAREN expression RPAREN                 # parenExpression
    ;

path
    : DOT # dotPath
    | CARET* ((objectKey | LBRACKET arrayIndex RBRACKET) ((DOT objectKey) | (LBRACKET arrayIndex RBRACKET))*)? # caretPath
    ;

objectKey
    : ID                                            # idObjectKey
    | OPENQS (CHARQS | ESCCHARQS)* CLOSEQS          # qsObjectKey
    ;

arrayIndex
    : INTEGER
    ;

withBlock
    : OPEN WITH path CLOSE statements OPEN END CLOSE
    ;

iterateBlock
    : OPEN ITERATE path indexRange CLOSE statements iterateClause* OPEN END CLOSE
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
    : OPEN FILTER filterName=ID CLOSE statements OPEN END CLOSE
    ;
