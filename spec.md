## Usage

When applying a JSON object to a template:

* the JSON object is pushed onto the (initially empty) context stack
* the escape stack is empty

## Template Body

* The template is unicode.
* The pattern `{{` opens a tag.

## Tag Body

* Tags are of the form `{{`...`}}`
* The pattern `}}` closes a tag.

## Tags

### literal

<b>
`{{"` *literal* `"}}`
</b>

    print literal

### string field

<b>
`{{` *path* [ `|` *filter_name* ]\* `}}`
</b>

    x = resolve(contexts, path)
    assert x is string
    for filter in filter_list + filters:
        x = filter(x)
    print x

### number field

<b>
`{{` *path* *number_format* [ `|` *filter_name* ]\* `}}`
</b>

number_format is '%' '0'? NUMBER? ('d'|'f'|'e')

    x = resolve(contexts, path)
    assert x is number
    x = number_to_string(x, number_format)
    for filter in filter_list + filters:
        x = filter(x)
    print x


### if-elseif-else-end

<b>
`{{:if` *expression* `}}` *template* <br>
[ `{{:elseif` *elseif_expression* `}}` *elseif_template* ]\*<br>
[ `{{:else}}` *else_template* ]<br>
`{{:end}}`
</b>

    if eval(expression) == true:
        print render(template)
    else if eval(elseif_expression) == true:
        print render(elseif_template)
    else:
        print render(else_template)


### change context

<b>
`{{:with` *path* `}}` *template*<br>
`{{:end}}`
</b>

    contexts.push(path)
    print render(template)
    contexts.pop()


### iterate

<b>
`{{:iterate` *path* *range* `}}` *template*<br>
[ `{{:before}}` *before_template* ]<br>
[ `{{:after}}` *after_template* ]<br>
[ `{{:between}}` *between_template* ]<br>
[ `{{:else}}` *else_template* ]<br>
`{{:end}}`
</b>

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


### filter

<b>
`{{` `|` *filter_name* `}}` *template* `{{:end}}`
</b>

    filters.push(filter_name)
    print render(template)
    filters.pop()


### comment

<b>
`{{!` *text* `}}`
</b>

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

