#import "lib.typ": *
#import "@local/richer-counters:0.1.0": *

#let counter-theorem = richer-counter(identifier: "theorem")

#let theorem = math-block(
    "Theorem",
    counter: counter-theorem,
    head-fmt: (display, number, desc, prefix: none) => default-head-fmt(prefix + display, number, desc, none),
)
#let proof = math-block("Proof")

#show: math-block-init

#theorem(label: <t1>, desc: [Alice])[
    #lorem(30)
]

#proof(label: <p1>, desc: [Bob's Proof])[
    #lorem(30)
]

#theorem(label: <t2>, desc: [Carol's Theorem], numbering: none)[
    #lorem(30)
]

#proof(label: <p2>)[
    #lorem(30)
]

#theorem(label: <t3>, meta: (prefix: "*"))[
    #lorem(30)
]

#proof(label: <p3>)[
    #lorem(30)
]

The proof of @t1 is trivial.

The theorem becomes trivial with @p1.

The proof of @t2 is trivial.

The theorem becomes trivial with @p2.

The proof of @t3 is trivial.

The theorem becomes trivial with @p3.
