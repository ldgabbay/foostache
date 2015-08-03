This is a sample template that demonstrates all of the features of foostache.

Here's an empty literal:                 "{{""}}"
Here's a literal:                        "{{"{{"}}"
Here's a string field:                   {{str}}
Here's a string field for URI:           {{str|uri}}
Here's a string field for HTML:          {{str|html}}
Here's HTML, URI:                        {{str|html|uri}}
Here's URI, HTML:                        {{str|uri|html}}
Here's a number field %5d:               {{ num %5d }}
Here's a number field %07.2f:            {{ num %07.2f }}
Here's a conditional:                    {{:if bool}}bool was true{{:elseif bool2}}bool2 was true{{:else}}neither bool nor bool2 was true{{:end}}
Here's another conditional:              {{:if not bool and bool2}}not bool and bool2{{:end}}
Here's a change in context:              {{:with sub}}sub.foo = {{foo}}{{:end}}
Here's back to normal:                   foo = {{foo}}
Here's an array index:                   {{ arr[0] }}
Here's an array iterator:                {{:iterate arr }}{{.}}{{:before}}[{{:between}}, {{:after}}]{{:else}}n/a{{:end}}
Here's an array iterator over 1::2 :     {{:iterate arr 1::2 }}{{.}}{{:before}}[{{:between}}, {{:after}}]{{:else}}n/a{{:end}}
Here's a filter block:                   {{:filter html}}{{str}}{{:end}}
Here's a comment:                        You are {{!not }}a good programmer.
