#import "deps.typ": elembic as e

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
    namespace: "default",
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

    e.element.declare(
        identifier,
        prefix: "math-block." + namespace,

        fields: (
            e.field("body", e.types.union(str, content), required: true),
            e.field("name", e.types.option(e.types.union(str, content)), default: none),
            e.field("numbering", e.types.option(e.types.union(str, function)), default: numbering),
            e.field("head-fmt", function, default: head-fmt),
            e.field("body-fmt", function, default: body-fmt),
            e.field("ref-fmt", function, default: ref-fmt),
            e.field("style", dictionary, default: (width: 100%, ..style)),
            e.field("meta", dictionary, default: meta.named()),
            e.field("number", e.types.option(str), synthesized: true),
        ),

        parse-args: (default-parser, fields: (:), typecheck: true) => (args, include-required: true) => {
            let named = (:)
            let meta = (:)
            for (key, value) in args.named() {
                if key in fields.user-named-fields.keys() {
                    named.insert(key, value)
                } else {
                    meta.insert(key, value)
                }
            }

            default-parser(arguments(..args.pos(), meta: meta, ..named), include-required: include-required)
        },

        // `count` does not support common counters.
        count: none,

        // `reference` does not pass `supplement` to `custom`.
        labelable: false,
        reference: none,

        synthesize: self => {
            self.number = none
            if counter != none and self.numbering != none {
                let numbers = (counter.get)()
                numbers.at(-1) += 1 // `synthesize` is prior to `display`.

                self.number = std.numbering(self.numbering, ..numbers)
            }

            self
        },

        display: self => {
            if self.number != none {
                (counter.step)()
            }

            [#metadata((self.ref-fmt, display, self.number, self.name, self.meta)) <math-block-meta>]

            block(
                ..self.style,
                (self.head-fmt)(display, self.number, self.name, ..self.meta) + (self.body-fmt)(self.body, ..self.meta),
            )
        },
    )
}

/// - doc (content):
/// -> content
#let math-block-init(doc) = {
    show: e.prepare()

    show ref: el => {
        let eid = e.eid(el.element)
        if eid == none or not eid.starts-with("e_math-block.") {
            return el
        }

        let (ref-fmt, display, number, name, meta) = query(selector(<math-block-meta>).after(el.target)).first().value
        link(el.target, ref-fmt(el.supplement, display, number, name, ..meta))
    }

    doc
}
