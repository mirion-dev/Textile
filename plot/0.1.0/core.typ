#import "utils.typ": *
#import "@preview/cetz:0.4.2": canvas, draw

#let plot(
    objects,
    unit-length: 3em,
    x-range: (0, 1),
    y-range: (0, 1),
    padding: .5,
    x-label: $x$,
    y-label: $y$,
    x-ticks: none,
    y-ticks: none,
    tick-size: .2,
    tick-padding: .1,
) = align(
    center,
    canvas(
        length: unit-length,
        {
            let (x-min, x-max) = normalize-range(x-range)
            let (y-min, y-max) = normalize-range(y-range)
            tick-padding += tick-size / 2
            draw.line((x-min - padding, 0), (x-max + padding, 0), mark: (end: "stealth", fill: black))
            draw.line((0, y-min - padding), (0, y-max + padding), mark: (end: "stealth", fill: black))
            draw.content((x-max + padding, 0), x-label, anchor: "north-east", padding: (tick-padding, 0))
            draw.content((0, y-max + padding), y-label, anchor: "north-west", padding: (0, tick-padding))

            if x-ticks != none {
                for x in x-ticks {
                    let (x, label) = normalize-tick(x)
                    draw.line((x, -tick-size / 2), (x, tick-size / 2))
                    draw.content((x, 0), label, anchor: "north", padding: tick-padding)
                }
            }

            if y-ticks != none {
                for y in y-ticks {
                    let (y, label) = normalize-tick(y)
                    draw.line((-tick-size / 2, y), (tick-size / 2, y))
                    draw.content((0, y), label, anchor: "east", padding: tick-padding)
                }
            }

            objects
        },
    ),
)

#let point(pos, size: .08, label: none, anchor: "south", padding: .2) = {
    pos = absolute(pos)
    draw.circle(pos, radius: size, fill: black, stroke: none)
    if label != none {
        draw.content(pos, label, anchor: anchor, padding: padding)
    }
}

#let contour(..path) = {
    let prev = absolute(path.at(0))
    for pos in path.pos().slice(1) {
        let style = (mark: (end: "stealth", fill: black, offset: 50%), shorten-to: none) + path.named()
        if type(pos) == dictionary {
            let temp = pos.remove("pos")
            style += pos
            pos = temp
        }

        if type(pos) == angle or type(pos.at(1)) == angle {
            let (center, stop) = if type(pos) == angle {
                ((0, 0), pos)
            } else {
                (absolute(pos.at(0)), pos.at(1))
            }

            let (start, radius) = relative(prev, center)
            draw.arc((to: center, rel: (start, radius)), start: start, stop: stop, radius: radius, ..style)
            prev = absolute((center, (stop, radius)))
        } else {
            pos = absolute(pos)
            draw.line(prev, pos, ..style)
            prev = pos
        }
    }
}
