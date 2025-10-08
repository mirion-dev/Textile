#let normalize-range(range) = {
    if type(range) == array {
        range
    } else {
        (-range, range)
    }
}

#let normalize-tick(tick) = {
    if type(tick) == array {
        tick
    } else {
        (tick, $#tick$)
    }
}

#let absolute(pos) = {
    if type(pos.at(0)) == array {
        let ((x, y), (a, r)) = pos
        (x + r * calc.cos(a), y + r * calc.sin(a))
    } else if type(pos.at(0)) == angle {
        let (a, r) = pos
        (r * calc.cos(a), r * calc.sin(a))
    } else {
        pos
    }
}

#let relative(pos, rel) = {
    let dx = pos.at(0) - rel.at(0)
    let dy = pos.at(1) - rel.at(1)
    (calc.atan2(dx, dy), calc.norm(dx, dy))
}
