## Usage

When applying a JSON object to a template:

* the JSON object is pushed onto the (initially empty) context stack
* the escape stack is empty

## Template Body

* The template is unicode.
* The escape pattern `{{` starts tag parsing.
* To embed `{{` in the template, use `{{{{`

## Tag Body

* Tags are of the form `{{`...`}}`
* The escape pattern is `}}`
* To embed `}}` in the tag body, use `}}}}` (even if inside double quotes)

## Tags

### escape the escape

**
`{{{{`
**

    print `{{`

### string field

**
`{{` *path* [ `|` *escape_list* ] `}}`
**

    x = resolve(contexts, path)
    assert x is string
    for escape in escape_list + escapes:
        x = escape(x)
    print x

### number field

**
`{{` *path* [ *number_format* ] [ `|` *escape_list* ] `}}`
**

    x = resolve(contexts, path)
    assert x is number
    x = number_to_string(x, number_format)
    for escape in escape_list + escapes:
        x = escape(x)
    print x


### if-elif-else-end

**
`{{:if` *expression* `}}` *template* <br>
[ `{{:elif` *elif_expression* `}}` *elif_template* ]\*<br>
[ `{{:else}}` *else_template* ]<br>
`{{:end}}`
**

    if eval(expression) == true:
        print render(template)
    else if eval(elif_expression) == true:
        print render(elif_template)
    else:
        print render(else_template)


### change context

**
`{{:with` *path* `}}` *template*<br>
`{{:end}}`
**

    contexts.push(path)
    print render(template)
    contexts.pop()


### iterate

**
`{{:iterate` *path* *range* `}}` *template*<br>
[ `{{:before}}` *before_template* ]<br>
[ `{{:after}}` *after_template* ]<br>
[ `{{:between}}` *between_template* ]<br>
[ `{{:else}}` *else_template* ]<br>
`{{:end}}`
**

    x = resolve(contexts, path)
    assert x is array
    x = array of x's elements specified by range, out-of-bound indices ignored
    if x.length == 0:
        print render(else_template)
    else:
        print render(before_template)
        contexts.push(x[0])
        print render(template)
        contexts.pop()
        for e in x[1:]:
            print render(between_template)
            contexts.push(e)
            print render(template)
            contexts.pop()
        print render(after_template)


### escape

**
`{{:escape` *escape_type* `}}` *template* `{{:end}}`
**

    escapes.push(escape_type)
    render(template)
    escapes.pop()


### comment

**
`{{!` *text* `}}`
**

    print ""


## Paths

* **`.`** &mdash; current context
* **`^`** &mdash; previous context
* **`^^`** &mdash; two contexts ago
* **`^^^^^`** &mdash; five contexts ago
* **`abc`** &mdash; current context as object, value of key `abc`
* **`^abc.xyz`** &mdash; previous context as object, value of key `abc` as object, value of key `xyz`
* **`[0]`** &mdash; current context as array, element 0
* **`^abc[0]`** &mdash; previous context as object, value of key `abc` as array, element 0
* **`^^abc.xyz[0].pdq`** &mdash; *an exercise for the reader*


## Ranges

For an array of length *n*:

* **:** &mdash; 0, 1, 2, ..., *n*-1
* **1:** &mdash; 1, 2, ..., *n*-1
* **0,3,5** &mdash; 0, 3, 5
* **2:-1** &mdash; 2, 3, 4, ..., *n*-2
* **-2,-1,:-2** &mdash; *n*-2, *n*-1, 0, 1, 2, ..., *n*-3

## Grammar

    PATH
        : CONTEXT_PATH
        | SPECIFIED_PATH
        ;

    CONTEXT_PATH
        : .
        | PARENT_PATH
        ;

    PARENT_PATH
        : ^
        | PARENT_PATH ^
        ;

    SPECIFIED_PATH
        : SCOPES
        | PARENT_PATH SCOPES
        ;

    SCOPES
        : FIRST_SCOPE LATER_SCOPES
        ;

    LATER_SCOPES
        : /* empty */
        | LATER_SCOPES LATER_SCOPE
        ;

    LATER_SCOPE
        : . IDENTIFIER
        | [ INDEX ]
        ;

    FIRST_SCOPE
        : IDENTIFIER
        | [ INDEX ]
        ;

    IDENTIFIER
        : [_a-zA-Z0-9]+
        : " CHARS "
        ;

    CHARS
        : /* empty */
        : CHARS CHAR
        ;

    CHAR
        : [^"\]
        | \ "
        | \ \
        | \ /
        | \ b
        | \ f
        | \ n
        | \ r
        | \ t
        | \ u [0-9a-fA-F]{4}
        ;

    INDEX
        : 0
        | [1-9] [0-9]*
        ;

    EXPRESSION
        : PATH
        | PATH exists
        | PATH is string
        | PATH is number
        | PATH is object
        | PATH is array
        | PATH is boolean
        | PATH is null
        | ( EXPRESSION )
        | EXPRESSION and EXPRESSION
        | EXPRESSION or EXPRESSION
        | not EXPRESSION
        ;

