# **foostache** template specification

Sections:

* [Template](#template)
* [Tags](#tags)
* [Paths](#paths)
* [Context Stack](#context-stack)
* [Ranges](#ranges)
* [Filters](#filters)
* [Filter Stack](#filter-stack)
* [Number Formats](#number-formats)
* [Expressions](#expressions)
* [Keywords](#keywords)


## Template

A template is simply a *unicode* string that contains **foostache** markup in the form of [*tags*](#tags).


## Tags

Supported tag types:

* [Literal](#literal)
* [String field](#string-field)
* [Number field](#number-field)
* [Conditional block](#conditional-block)
* [Context block](#context-block)
* [Iteration block](#iteration-block)
* [Filter block](#filter-block)
* [Comment](#comment)

### Literal

<b>
`{{"` *literal* `"}}`
</b>

Prints raw text.

The text between `{{"` and `"}}` is printed exactly as it appears and not interpreted as **foostache** markup. The first `"}}` found will terminate the literal.

In pseudocode:

```
print literal
```


### String field

<b>
`{{` [*path*](#paths) &nbsp; \[ `|` [*filter*](#filters) &nbsp; \]\* `}}`
</b>

Prints a string field.

Take the value of [*path*](#paths) (which must be a string), apply each [*filter*](#filters) from left to right, apply filters from the [*filter stack*](#filter-stack) from top to bottom, print the result.

In pseudocode:

```
x = get_value_of(path)
assert x is a string
for filter in (filter_list + filters):
    x = filter(x)
print x
```


### Number field

<b>
`{{` [*path*](#paths) &nbsp; [*number_format*](#number-formats) &nbsp; \[ `|` [*filter*](#filters) &nbsp; \]\* `}}`
</b>

Prints a number field.

Take the value of [*path*](#paths) (which must be a number), apply [*number_format*](#number-formats), apply each [*filter*](#filters) from left to right, apply filters from the [*filter stack*](#filter-stack) from top to bottom, print the result.

In pseudocode:

```
x = get_value_of(path)
assert x is a number
x = number_to_string(x, number_format)
for filter in (filter_list + filters):
    x = filter(x)
print x
```


### Conditional block

<b>
`{{:if` [*expression*](#expressions) `}}` [*template*](#template) <br>
\[ `{{:elseif` [*elseif_expression*](#expressions) `}}` [*elseif_template*](#template) &nbsp; \]\*<br>
\[ `{{:else}}` [*else_template*](#template) &nbsp; \]<br>
`{{:end}}`
</b>

Conditionally prints different output depending on the value of different expressions.

In pseudocode:

```
if eval(expression) == True:
    print render(template)
else if eval(elseif_expression) == True:
    print render(elseif_template)
else:
    print render(else_template)
```


### Context block

<b>
`{{:with` [*path*](#paths) `}}` [*template*](#template) `{{:end}}`
</b>

Pushes the value of [*path*](#paths) onto the context stack while rendering the enclosed block.

In pseudocode:

```
contexts.push(get_value_of(path))
print render(template)
contexts.pop()
```


### Iteration block

<b>
`{{:iterate` [*path*](#paths) &nbsp; \[ &nbsp; [*range*](#ranges) &nbsp; \] `}}` [*template*](#template)<br>
\[ `{{:before}}` [*before_template*](#template) &nbsp; \]<br>
\[ `{{:after}}` [*after_template*](#template) &nbsp; \]<br>
\[ `{{:between}}` [*between_template*](#template) &nbsp; \]<br>
\[ `{{:else}}` [*else_template*](#template) &nbsp; \]<br>
`{{:end}}`
</b>

Prints the elements in the value of [*path*](#paths) (which must be an array).

In pseudocode:

```
x = get_value_of(path)
assert x is an array
x = [x[i] for i in range]
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
```


### Filter block

<b>
`{{:filter` [*filter*](#filters) `}}` [*template*](#template) `{{:end}}`
</b>

Pushes [*filter*](#filters) onto the [*filter stack*](#filter-stack) while rendering [*template*](#template).

In pseudocode:

```
filters.push(filter)
print render(template)
filters.pop()
```


### Comment

<b>
`{{!` *comment* `}}`
</b>

Prints nothing, ignoring the enclosed text.

In pseudocode:

```
pass
```


## Paths

Paths point to a specific value within the [*context stack*](#context-stack).

* **`.`** &mdash; current context
* **`^`** &mdash; previous context
* **`^^`** &mdash; two contexts ago
* **`^^^^^`** &mdash; five contexts ago
* **`abc`** &mdash; current context as object, value of key `abc`
* **`^abc.xyz`** &mdash; previous context as object, value of key `abc` as object, value of key `xyz`
* **`[0]`** &mdash; current context as array, element 0
* **`^abc[0]`** &mdash; previous context as object, value of key `abc` as array, element 0
* **`^^abc.xyz[0].pdq`** &mdash; *an exercise for the reader*


## Context Stack

The context stack represents a history of input values used to render a template. Normally, the context stack is just one context, being the original JSON input. Sometimes the context will switch, for example when iterating over values within an array. This pushes a new value onto the stack temporarily, for instance the value of the current element in the array.


## Ranges

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


## Filters

Filters are pre-defined by the **foostache** language specification. Supported filters are:

* **`html`** &mdash; Escapes text for HTML body text and attribute values. Specifically, this replaces `&`, `<`, `>`, `"`, and `'` with their ampersand equivalents.
* **`uri`** &mdash; As per [the IETF specification](https://tools.ietf.org/html/rfc3986#section-2), this encodes the input unicode field as UTF-8, then percent encodes all reserved characters.


## Filter Stack

The filter stack represents the sequence of filters that need to be applied to the part of a template currently being rendered. For instance, a block of the template could be contained within an **html** filter, pushing that filter on the stack and forcing all printed fields to be escaped properly for HTML output. Within this, one might wish to show a field as a properly escaped URI field, in which case the **uri** filter would be pushed onto the stack as well.


## Number Formats

A number format specifies how to print a number field. The syntax is:

<b>
`%` \[`0`\] \[ *width* \] ( `d` | \[ `.` *precision* \] `f`)
</b>

* a leading `0` specifies that the number should be padded to the minimum width with zeros.
* *width* is a positive integer specifying the minimum number of characters to be used. 
* *precision* is a positive integer specifying the number of decimal places to render.
* `d` prints the number as an integer, `f` as a floating point number. 

## Expressions

<b>[*path*](#paths)</b><br/>&nbsp; &mdash; value of *path*, must be boolean<br/><br/>
<b>[*path*](#paths) `exists`</b><br/>&nbsp; &mdash; whether the value of *path* exists<br/><br/>
<b>[*path*](#paths) `is` `string`</b><br/>&nbsp; &mdash; whether the value of *path* is a string<br/><br/>
<b>[*path*](#paths) `is` `number`</b><br/>&nbsp; &mdash; whether the value of *path* is a number<br/><br/>
<b>[*path*](#paths) `is` `object`</b><br/>&nbsp; &mdash; whether the value of *path* is an object<br/><br/>
<b>[*path*](#paths) `is` `array`</b><br/>&nbsp; &mdash; whether the value of *path* is an array<br/><br/>
<b>[*path*](#paths) `is` `boolean`</b><br/>&nbsp; &mdash; whether the value of *path* is a boolean<br/><br/>
<b>[*path*](#paths) `is` `null`</b><br/>&nbsp; &mdash; whether the value of *path* is null<br/><br/>
<b>`(` [*expression*](#expressions) `)`</b><br/>&nbsp; &mdash; result of *expression*<br/><br/>
<b>[*expression*](#expressions) `and` [*expression*](#expressions)</b><br/>&nbsp; &mdash; logical and of the results of both *expressions*<br/><br/>
<b>[*expression*](#expressions) `or` [*expression*](#expressions)</b><br/>&nbsp; &mdash; logical or of the results of both *expressions*<br/><br/>
<b>`not` [*expression*](#expressions)</b><br/>&nbsp; &mdash; logical not of the result of *expression*<br/><br/>

## Keywords

These keywords are reserved and cannot be used as unquoted object keys.

* `and`
* `array`
* `boolean`
* `exists`
* `is`
* `not`
* `null`
* `number`
* `object`
* `or`
* `string`
