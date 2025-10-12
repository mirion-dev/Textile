#import "lib.typ": *
#import "@preview/rich-counters:0.2.2": *

#let counter-theorem = rich-counter(identifier: "theorem")

#let theorem = math-block("Theorem", counter: counter-theorem)
#let proof = math-block("Proof")

#show: math-block-init

#theorem(desc: [Alice])[
    #lorem(30)
] <t1>

#proof(desc: [Bob's Proof])[
    #lorem(30)
] <p1>

#theorem(desc: [Carol's Theorem], numbering: none)[
    #lorem(30)
] <t2>

#proof[
    #lorem(30)
] <p2>

#theorem[
    #lorem(30)
] <t3>

#proof[
    #lorem(30)
] <p3>

The proof of @t1 is trivial.

The theorem becomes trivial with @p1.

The proof of @t2 is trivial.

The theorem becomes trivial with @p2.

The proof of @t3 is trivial.

The theorem becomes trivial with @p3.
