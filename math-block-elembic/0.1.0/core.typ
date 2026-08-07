#import "deps.typ": elembic as e

/// - display (str, content):
/// - number (str, none):
/// - desc (str, content, none):
/// - meta (arguments):
/// -> content
#let default-head-fmt(display, number, desc, ..meta) = {
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
/// - meta (arguments):
/// -> content
#let default-body-fmt(body, ..meta) = body

/// - display (str, content):
/// - number (str, none):
/// - desc (str, content, none):
/// - meta (arguments):
/// -> content
#let default-ref-fmt(display, number, desc, ..meta) = {
    if number != none {
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
/// - head-fmt (function):
/// - body-fmt (function):
/// - ref-fmt (function):
/// - style (dictionary):
/// - meta (arguments):
/// -> function
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
    ..meta,
) = {
    if display == auto {
        display = identifier
    }

    e.element.declare(
        identifier,
        prefix: namespace,

        fields: (
            e.field("body", e.types.union(str, content), required: true),
            e.field("desc", e.types.option(e.types.union(str, content)), default: none),
            e.field("numbering", e.types.option(e.types.union(str, function)), default: numbering),
            e.field("head-fmt", function, default: head-fmt),
            e.field("body-fmt", function, default: body-fmt),
            e.field("ref-fmt", function, default: ref-fmt),
            e.field("style", dictionary, default: style),
            e.field("meta", dictionary, default: meta.named()),
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
                (self.head-fmt)(display, self.number, self.desc, ..self.meta) + (self.body-fmt)(self.body, ..self.meta),
            )
        },

        reference: (
            custom: self => {
                link(self.label, (self.ref-fmt)(display, self.number, self.desc, ..self.meta))
            },
        ),
    )
}

/// - doc (content):
/// -> content
#let math-block-init(doc) = {
    show: e.prepare()
    doc
}
