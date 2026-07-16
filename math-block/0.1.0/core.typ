/// - display (str, content):
/// - number (str, none):
/// - desc (str, content, none):
/// - meta (any):
/// -> content
#let default-head-fmt(display, number, desc, meta) = {
    if number != none {
        if desc != none {
            [*#display #number* (#desc)*.* ]
        } else {
            [*#display #number.* ]
        }
    } else if desc != none {
        [*#desc.* ]
    } else {
        [*#display.* ]
    }
}

/// - body (str, content):
/// - meta (any):
/// -> content
#let default-body-fmt(body, meta) = body

/// - supplement (str, content, auto):
/// - display (str, content):
/// - number (str, none):
/// - desc (str, content, none):
/// - meta (any):
/// -> content
#let default-ref-fmt(supplement, display, number, desc, meta) = {
    if supplement != auto {
        supplement
    } else if number != none {
        [#display #number]
    } else if desc != none {
        desc
    } else {
        display
    }
}

/// - identifier (str):
/// - namespace (str):
/// - display (str, content, auto):
/// - counter (dictionary, none):
/// - numbering (str, function, none):
/// - meta (any):
/// - head-fmt (function):
/// - body-fmt (function):
/// - ref-fmt (function):
/// - style (arguments):
/// -> function
#let math-block(
    identifier,
    namespace: "default",
    display: auto,
    counter: none,
    numbering: "1.1",
    meta: none,
    head-fmt: default-head-fmt,
    body-fmt: default-body-fmt,
    ref-fmt: default-ref-fmt,
    ..style,
) = {
    if display == auto {
        display = identifier
    }

    (
        body,
        desc: none,
        numbering: numbering,
        meta: meta,
        head-fmt: head-fmt,
        body-fmt: body-fmt,
        ref-fmt: ref-fmt,
        ..extra-style,
    ) => figure(
        kind: "math-block",
        supplement: namespace + "." + identifier,
        outlined: false,
        {
            if counter != none and numbering != none {
                (counter.step)()
            }

            context {
                let number = none
                if counter != none and numbering != none {
                    number = (counter.display)(numbering)
                }

                [#metadata((ref-fmt, display, number, desc, meta)) <math-block-meta>]

                block(
                    width: 100%,
                    ..style,
                    ..extra-style,
                    head-fmt(display, number, desc, meta) + body-fmt(body, meta),
                )
            }
        },
    )
}

/// - doc (content):
/// -> content
#let math-block-init(doc) = {
    show figure.where(kind: "math-block"): set align(left)
    show ref: el => {
        if el.element == none or el.element.func() != figure or el.element.kind != "math-block" {
            return el
        }

        let metadata = query(selector(<math-block-meta>).after(el.target)).first()
        let (ref-fmt, display, number, desc, meta) = metadata.value
        link(metadata.location(), ref-fmt(el.supplement, display, number, desc, meta))
    }
    doc
}
