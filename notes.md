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





http://www.jeffknupp.com/blog/2013/08/16/open-sourcing-a-python-project-the-right-way/


## weaknesses

1. escaping enforced and limited
2. looping construct missing pre, mid, and post constructs
3. no way to escape {{ & }} delimiters
4. no way to select list range for loop

## questions

1. what structural variability is permissible?
    - can the type of a field be unknown
    - can fields be optional
    - can lists be of unexpected sizes


### `{{` `:define` name `}}` template `{{` `:end` define `}}`
{{> name}}



{{:escape escape_type}}template{{:end}}

    escapes.push(escape_type)
    render(context, template)
    escapes.pop()







### import

**
`{{>` *uri* `}}`
**

    render(load_uri_as_string(uri))








## new proposal

context is an array/stack, when started it's a single object wrapped in an array
escapes is an array/stack, default empty, maintains ordered stack of transformations that must happen
path can be absolute or relative to another path, e.g. ., ^, ^^, a.b.c, ^a.b.c, ^^a.b.c
path:
    key -> yield context[key] (treating context as object)
    [index] -> yield context[index] (treating context as array)
    ^^ -> yield previous previous context
    ^ -> yield previous context
    . -> yield context

.
^
^^
a
^a
^[0]
^a[0]
[0]
a.b
a.b.c
a.b.c
a[2].c

escape sequences:
"\."
"\^"
"\["
"\ "
"\\"



path starters:
    ptr = context (default)
^   ptr = previous context
^^  ptr = previous previous context

.key    ptr = ptr[key] (as object)
[index] ptr = ptr[index] (as array)



JSON only supports a few types:
    string
    number
    object
    array
    boolean (true/false)
    null


resolve(context, path):

    switch id:
        simple identifier:
            context[0].id
        ../xyz:
            resolve(shift context, id)

