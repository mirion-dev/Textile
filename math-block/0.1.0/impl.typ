#let default-head-fmt = (display, number, desc) => {
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

#let default-body-fmt = body => body

#let default-ref-fmt = (supplement, display, number, desc) => {
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

#let math-block(
    identifier,
    namespace: "default",
    display: auto,
    counter: none,
    numbering: "1.1",
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

                [#metadata((ref-fmt, display, number, desc)) <math-block-meta>]

                block(
                    width: 100%,
                    ..style,
                    ..extra-style,
                    head-fmt(display, number, desc) + body-fmt(body),
                )
            }
        },
    )
}

#let math-block-init = doc => {
    show figure.where(kind: "math-block"): set align(left)
    show ref: el => {
        if el.element.func() != figure or el.element.kind != "math-block" {
            return el
        }

        let meta = query(selector(<math-block-meta>).after(el.target)).first()
        let (ref-fmt, display, number, desc) = meta.value
        link(meta.location(), ref-fmt(el.supplement, display, number, desc))
    }
    doc
}
