#import "lib.typ": *

#plot(
    x-range: (-1, 3),
    y-range: (-1, 1),
    {
        let y = .2
        let r = .5
        let a = calc.asin(y / r)
        contour((3, y), (a, r), 360deg - a, (3, -y))
    },
)

#plot(
    x-range: (-1, 4),
    y-range: (-1, 1),
    x-ticks: ((3, $1$),),
    {
        let y1 = .3
        let y2 = .15
        let r1 = .65
        let r2 = .5
        let a11 = calc.asin(y1 / r1)
        let a21 = calc.asin(y1 / r2)
        let a12 = calc.asin(y2 / r1)
        let a22 = calc.asin(y2 / r2)
        contour(
            ((3, 0), (180deg - a21, r2)),
            (a21, r2),
            360deg + a22,
            ((3, 0), (180deg - a12, r1)),
            ((3, 0), -180deg + a11),
            (-a11, r1),
            -360deg - a12,
            ((3, 0), (180deg + a22, r2)),
            ((3, 0), 180deg - a21),
        )
    },
)

#plot(
    x-range: (-3, 3),
    y-range: (-3, 3),
    padding: 1,
    {
        let y = .2
        let r1 = 3
        let r2 = .5
        let a1 = calc.asin(y / r1)
        let a2 = calc.asin(y / r2)
        contour((a1, r1), (a2, r2), 360deg - a2, (-a1, r1), -360deg + a1)

        let k = r1 / 4.5
        let l1 = ($2 pi "i"$, $4 pi "i"$, $space dots.v$, $2N pi "i"$, $(2N+2) pi "i"$)
        let l2 = ($-2 pi "i"$, $-4 pi "i"$, $space dots.v$, $-2N pi "i"$, $-(2N+2) pi "i"$)
        point((0, 0))
        for i in range(5) {
            point((0, k * (i + 1)), label: l1.at(i), anchor: "west")
            point((0, -k * (i + 1)), label: l2.at(i), anchor: "west")
        }
    },
)

#plot(
    x-range: (-1, 3),
    y-range: 3,
    padding: 1,
    {
        let k = 3 / 4.5
        contour(
            (0, 3),
            -90deg,
            (0, -2),
            (k * 1.5, -2),
            ((k * 1.5, -1.5), 90deg),
            (0, -1),
            (pos: (0, -.5), mark: none),
            -270deg,
            (pos: (0, 1), mark: none),
            (pos: (k * .5, 1), mark: none),
            ((k * .5, 1.5), 90deg),
            (pos: (0, 2), mark: none),
            (0, 3),
        )

        let l1 = ($1$, $2$, $dots.c$, $N$, $N+1$)
        let l2 = ($-a$, $-a-1$, $-a-2$, $dots.c$)
        let l3 = ($-b$, $-b-1$, $-b-2$, $dots.c$)
        point((0, 0))
        for i in range(5) {
            point((k * (i + 1), 0), label: l1.at(i), anchor: "north")
        }
        for i in range(4) {
            let dir = if calc.rem(i, 2) == 0 { "south" } else { "north" }
            point((k * (-i + .5), 1.5), label: l2.at(i), anchor: dir)
            point((k * (-i + 1.5), -1.5), label: l3.at(i), anchor: dir)
        }
    },
)
