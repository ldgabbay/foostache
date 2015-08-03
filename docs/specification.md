# **foostache** template specification

## Template

A template is simply a *unicode* string that contains zero or more *tags*.

Some of these *tags* define the boundaries of a *block*; the original template is the outer-most *block*.

Each *block* is rendered with respect to a JSON *context*. The outer-most *block*'s context is the original input JSON object.

There is a *context stack*, and some *tags* push new *contexts* onto the stack (i.e. `{{:with}}` and `{{:iterate}}`)


## Tags

### Literal

<b>
`{{"` *literal* `"}}`
</b>

Prints raw text.

Literal is captured non-greedily, so the first `"}}` found will terminate the literal tag.

In pseudocode:

    print literal

### String field

<b>
`{{` [*path*](#path) &nbsp; \[ `|` [*filter_name*](#filter) &nbsp; \]\* `}}`
</b>

Prints a string field.

Take the value of [*path*](#path) (must be a string), apply *filters* (specified by [*filter_name*](#filter)) from left to right, then apply filters from the *filter stack* from top to bottom, then print the result.

In pseudocode:

    x = get_value_of(path)
    assert x is a string
    for filter in (filter_list + filters):
        x = filter(x)
    print x


### Number field

<b>
`{{` [*path*](#path) &nbsp; [*number_format*](#numfmt) &nbsp; \[ `|` [*filter_name*](#filter) &nbsp; \]\* `}}`
</b>

Prints a number field.

Take the value of [*path*](#path) (must be a number), apply [*number_format*](#numfmt), apply *filters* (specified by [*filter_name*](#filter)) from left to right, then apply filters from the *filter stack* from top to bottom, then print the result.

In pseudocode:

    x = get_value_of(path)
    assert x is number
    x = number_to_string(x, number_format)
    for filter in filter_list + filters:
        x = filter(x)
    print x


### Conditional block

<b>
`{{:if` *expression* `}}` *template* <br>
\[ `{{:elseif` *elseif_expression* `}}` *elseif_template* &nbsp; \]\*<br>
\[ `{{:else}}` *else_template* &nbsp; \]<br>
`{{:end}}`
</b>

Conditionally prints different output depending on the value of different expressions.

In pseudocode:

    if eval(expression) == true:
        print render(template)
    else if eval(elseif_expression) == true:
        print render(elseif_template)
    else:
        print render(else_template)


### Context block

<b>
`{{:with` [*path*](#path) `}}` *template* `{{:end}}`
</b>

Pushes the value of [*path*](#path) onto the context stack while rendering the enclosed block.

In pseudocode:

    contexts.push(get_value_of(path))
    print render(template)
    contexts.pop()


### Iteration block

<b>
`{{:iterate` [*path*](#path) [*range*](#range) `}}` *template*<br>
\[ `{{:before}}` *before_template* &nbsp; \]<br>
\[ `{{:after}}` *after_template* &nbsp; \]<br>
\[ `{{:between}}` *between_template* &nbsp; \]<br>
\[ `{{:else}}` *else_template* &nbsp; \]<br>
`{{:end}}`
</b>

Iterates over an array, printing 

In pseudocode:

    x = get_value_of(path)
    assert x is array
    x = array of x's elements specified by range
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


### Filter block

<b>
`{{:filter` [*filter_name*](#filter) `}}` *template* `{{:end}}`
</b>

Pushes [*filter_name*](#filter) onto the *filters* stack while rendering the contained block.

In pseudocode:

    filters.push(filter_name)
    print render(template)
    filters.pop()


### Comment

<b>
`{{!` *comment* `}}`
</b>

Prints nothing, ignoring the enclosed text.

In pseudocode:

    do nothing


## <a name="path"></a>Paths

Paths point to a specific value within the [*context stack*](#ctxs).

* **`.`** &mdash; current context
* **`^`** &mdash; previous context
* **`^^`** &mdash; two contexts ago
* **`^^^^^`** &mdash; five contexts ago
* **`abc`** &mdash; current context as object, value of key `abc`
* **`^abc.xyz`** &mdash; previous context as object, value of key `abc` as object, value of key `xyz`
* **`[0]`** &mdash; current context as array, element 0
* **`^abc[0]`** &mdash; previous context as object, value of key `abc` as array, element 0
* **`^^abc.xyz[0].pdq`** &mdash; *an exercise for the reader*


## <a name="ctxs"></a>Context Stack

The context stack represents a history of input values used to render a template. Normally, the context stack is just once context, being the original JSON input. Sometimes the context will switch, for example when iterating over values within an array. This pushes a new value onto the stack temporarily, for instance the value of the current element in the array.


## <a name="range"></a>Ranges

A range specifies a sequence of indices to apply to an array. The syntax is:

<b>
*start* &nbsp; \[ `:` *stop* &nbsp; \[ `:` *step* &nbsp; \] &nbsp; \]
</b>

Given an array of length *n*:

* *start* is an integer and specifies the first index in the sequence.
* if *start* is blank, it is assumed to be 0.
* if *start* is negative, it is relative to the end of the array. (e.g. -1 is *n*-1, -2 is *n*-2, etc.)
* *stop* is an integer and specifies the index after the last index in the sequence.
* if *stop* is blank or not provided, it is assumed to be *n*.
* if *stop* is negative, it is relative to the end of the array. (e.g. -1 is *n*-1, -2 is *n*-2, etc.)
* *step* is a positive integer and specifies the step size of the iteration.
* if *step* is blank or not provided, it is assumed to be 1.

For example:

* **:** &mdash; 0, 1, 2, ..., *n*-1
* **1:** &mdash; 1, 2, ..., *n*-1
* **2:-1** &mdash; 2, 3, 4, ..., *n*-2
* **1:11:3** &mdash; 1, 4, 7, 10 


## <a name="filter"></a>Filters

Filters are pre-defined by the **foostache** language specification. At this time, the only pre-defined filters are:

* **`html`** &mdash; Escapes text for HTML body text and attribute values. Specifically, this replaces `&`, `<`, `>`, `"`, and `'` with their ampersand equivalents.
* **`uri`** &mdash; As per [the IETF specification](https://tools.ietf.org/html/rfc3986#section-2), this encodes the input unicode field as UTF-8, then percent encodes all reserved characters.


## <a name="filter_stack"></a>Filter Stack

The filter stack represents the sequence of filters that need to be applied to the part of a template currently being rendered. For instance, a block of the template could be contained within an **html** filter, pushing that filter on the stack and forcing all printed fields to be escaped properly for HTML output. Within this, one might wish to show a field as a properly escaped URI field, in which case the **uri** filter would be pushed onto the stack as well.


## <a name="numfmt"></a>Number Formats

A number format specifies how to print a number field. The syntax is:

<b>
`%` \[`0`\] \[ *width* \] ( `d` | \[ `.` *precision* \] `f`)
</b>

* a leading `0` specifies that the number should be padded to the minimum width with zeros.
* *width* is a positive integer specifying the minimum number of characters to be used. 
* *precision* is a positive integer specifying the number of decimal places to render.
* `d` prints the number as an integer, `f` as a floating point number. 

## <a name="expr"></a>Expressions

<b>[*path*](#path)</b><br/>&nbsp; &mdash; value of *path*, must be boolean<br/><br/>
<b>[*path*](#path) `exists`</b><br/>&nbsp; &mdash; whether the value of *path* exists<br/><br/>
<b>[*path*](#path) `is` `string`</b><br/>&nbsp; &mdash; whether the value of *path* is a string<br/><br/>
<b>[*path*](#path) `is` `number`</b><br/>&nbsp; &mdash; whether the value of *path* is a number<br/><br/>
<b>[*path*](#path) `is` `object`</b><br/>&nbsp; &mdash; whether the value of *path* is an object<br/><br/>
<b>[*path*](#path) `is` `array`</b><br/>&nbsp; &mdash; whether the value of *path* is an array<br/><br/>
<b>[*path*](#path) `is` `boolean`</b><br/>&nbsp; &mdash; whether the value of *path* is a boolean<br/><br/>
<b>[*path*](#path) `is` `null`</b><br/>&nbsp; &mdash; whether the value of *path* is null<br/><br/>
<b>`(` [*expression*](#expr) `)`</b><br/>&nbsp; &mdash; result of *expression*<br/><br/>
<b>[*expression*](#expr) `and` [*expression*](#expr)</b><br/>&nbsp; &mdash; logical and of the results of both *expressions*<br/><br/>
<b>[*expression*](#expr) `or` [*expression*](#expr)</b><br/>&nbsp; &mdash; logical or of the results of both *expressions*<br/><br/>
<b>`not` [*expression*](#expr)</b><br/>&nbsp; &mdash; logical not of the result of *expression*<br/><br/>
