# foostache

**foostache** is a [domain-specific language](https://en.wikipedia.org/wiki/Domain-specific_language) for specifying a template that can be used to generate [unicode](http://unicode.org/) from [JSON](http://json.org/) inputs.

Jump to the [complete **foostache** specification](docs/specification.md).


## Quick example

### Template

	{{:iterate my_array 1::2}}{{. %5.2f}}{{:before}}[{{:between}}, {{:after}}]{{:end}}

### Input

	{ "my_array": [2.6, 4, 18, 3.51, 42, 96.8] }

### Output

	[ 4.00,  3.51, 96.80]


## Philosophy

There are many open source template languages to choose from, so why did I design a new one? Unfortunately, none of the existing ones matched the rigorous design philosophy I needed to uphold. A template language:

1. should be independent of platform and programming language
2. should keep rendering logic entirely in the template
3. should be agnostic to the nature and syntax of the output

### Why not [**mustache**](https://mustache.github.io/)?

**mustache** users can call custom code by way of attaching functions to the input object. This means the input is not JSON but actually a JavaScript object, which means:

1. **mustache** is language dependent
2. logic may be split between the template and the input

Also, **mustache** assumes the output is HTML and escapes all fields as HTML by default. No other escaping filters, such as [URI encoding](https://en.wikipedia.org/wiki/Percent-encoding) or [JavaScript string encoding](http://www.w3schools.com/js/js_strings.asp), are supported. These would have to be done by custom code, which again makes the templating language language dependent.


## Resources

This project is a specification only.

An [ANTLR4](http://www.antlr.org/) grammar for **foostache** can be found [here](antlr4).

A reference implementation in python is being maintained and can be found [here](https://github.com/ldgabbay/foostache-python).
