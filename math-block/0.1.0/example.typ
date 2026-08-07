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

#theorem(prefix: "*")[
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
