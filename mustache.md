# mustache

## syntax

context is an object

render(context, template)

{{id}}

    html_escape(context.id)

{{{id}}}

    context.id

{{& id}}

    html_unescape(context.id)

{{#id}}template{{/id}}

    switch context.id
        undefined:
        false:
        []:
            empty string
        true:
            template
        [...]:
            for e in context.id:
                render(e, template)
        function:
            context.id()(template, function(text) { return render(context, text); })
        {...}:
            render(context.id, template)

{{^id}}text{{/id}}

    switch context.id
        undefined:
        false:
        []:
            text
        otherwise:
            empty string

{{! text}}

    empty string

{{> name}}

    render(context, load_file_as_string("name.mustache"))

{{=any_start any_stop=}}

    changes delimiter from {{ & }} to any_start & any_stop. cannot contain whitespace or =
