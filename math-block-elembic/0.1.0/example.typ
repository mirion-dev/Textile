#import "lib.typ": *
#import "@preview/rich-counters:0.2.2": *

#let counter-theorem = rich-counter(identifier: "theorem")

#let theorem = math-block("Theorem", counter: counter-theorem)
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

#theorem(label: <t3>)[
    #lorem(30)
]

#proof(label: <p3>)[
    #lorem(30)
]

The proof is trivial with @t1.

The theorem is trivial with @p1.

The proof is trivial with @t2.

The theorem is trivial with @p2.

The proof is trivial with @t3.

The theorem is trivial with @p3.
