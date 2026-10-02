/// - display (str, content):
/// - number (str, none):
/// - name (str, content, none):
/// - meta (arguments):
/// -> content
#let default-head-fmt(display, number, name, ..meta) = {
    if number != none {
        if name != none {
            [*#display #number* (#name)*.* ]
        } else {
            [*#display #number.* ]
        }
    } else if name != none {
        [*#name.* ]
    } else {
        [*#display.* ]
    }
}

/// - body (str, content):
/// - meta (arguments):
/// -> content
#let default-body-fmt(body, ..meta) = body

/// - supplement (str, content, auto):
/// - display (str, content):
/// - number (str, none):
/// - name (str, content, none):
/// - meta (arguments):
/// -> content
#let default-ref-fmt(supplement, display, number, name, ..meta) = {
    if supplement != auto {
        supplement
    } else if number != none {
        [#display #number]
    } else if name != none {
        name
    } else {
        display
    }
}

/// - identifier (str):
/// - namespace (str):
/// - display (str, content, auto):
/// - counter (dictionary, none):
/// - numbering (str, function, none):
/// - head-fmt (function, auto):
/// - body-fmt (function, auto):
/// - ref-fmt (function, auto):
/// - style (dictionary):
/// - meta (arguments):
/// -> function
#let math-block(
    identifier,
    namespace: "math-block.default",
    display: auto,
    counter: none,
    numbering: "1.1",
    head-fmt: auto,
    body-fmt: auto,
    ref-fmt: auto,
    style: (:),
    ..meta,
) = {
    if display == auto {
        display = identifier
    }

    if head-fmt == auto {
        head-fmt = default-head-fmt
    } else {
        head-fmt = head-fmt(default-head-fmt)
    }

    if body-fmt == auto {
        body-fmt = default-body-fmt
    } else {
        body-fmt = body-fmt(default-body-fmt)
    }

    if ref-fmt == auto {
        ref-fmt = default-ref-fmt
    } else {
        ref-fmt = ref-fmt(default-ref-fmt)
    }

    let default-style = style
    let default-meta = meta

    (
        body,
        name: none,
        numbering: numbering,
        head-fmt: head-fmt,
        body-fmt: body-fmt,
        ref-fmt: ref-fmt,
        style: (:),
        ..meta,
    ) => figure(
        kind: "math-block",
        supplement: namespace + "." + identifier,
        outlined: false,
        {
            if counter != none and numbering != none {
                (counter.step)()
            }

            let style = (width: 100%, ..default-style, ..style)
            let meta = (:..default-meta.named(), ..meta.named())

            context {
                let number = none
                if counter != none and numbering != none {
                    number = (counter.display)(numbering)
                }

                [#metadata((ref-fmt, display, number, name, meta)) <math-block-meta>]

                align(left, block(..style, head-fmt(display, number, name, ..meta) + body-fmt(body, ..meta)))
            }
        },
    )
}

/// - doc (content):
/// -> content
#let math-block-init(doc) = {
    show ref: el => {
        if el.element == none or el.element.func() != figure or el.element.kind != "math-block" {
            return el
        }

        let (ref-fmt, display, number, name, meta) = query(selector(<math-block-meta>).after(el.target)).first().value
        link(el.target, ref-fmt(el.supplement, display, number, name, ..meta))
    }

    doc
}
