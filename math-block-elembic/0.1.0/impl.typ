#import "@preview/elembic:1.1.1" as e

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

#let default-ref-fmt = (display, number, desc) => {
    if number != none {
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
    style: (:),
) = {
    if display == auto {
        display = identifier
    }

    e.element.declare(
        identifier,
        prefix: namespace,

        fields: (
            e.field("body", content, required: true),
            e.field("desc", e.types.option(content), default: none),
            e.field("numbering", e.types.option(str), default: numbering),
            e.field("head-fmt", e.types.any, default: head-fmt),
            e.field("body-fmt", e.types.any, default: body-fmt),
            e.field("ref-fmt", e.types.any, default: ref-fmt),
            e.field("style", e.types.dict(e.types.any), default: style),
            e.field("number", e.types.option(str), synthesized: true),
        ),

        synthesize: self => {
            self.number = none
            if counter != none and self.numbering != none {
                let numbers = (counter.get)()
                numbers.at(-1) += 1
                self.number = std.numbering(self.numbering, ..numbers)
            }

            self
        },

        display: self => {
            if self.number != none {
                (counter.step)()
            }

            block(
                width: 100%,
                ..self.style,
                (self.head-fmt)(display, self.number, self.desc) + (self.body-fmt)(self.body),
            )
        },

        reference: (
            custom: self => {
                link(self.label, (self.ref-fmt)(display, self.number, self.desc))
            },
        ),
    )
}

#let math-block-init = doc => {
    show: e.prepare()
    doc
}
