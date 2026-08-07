/// A simple wrapper for the `state` function, inspired by React Hook.
#let use-state(key, init) = {
    let used-state = state(key, init)
    return (
        (..args) => {
            let arg = args.pos().at(0, default: none)
            if arg == none {
                used-state.final()
            } else if type(arg) == function {
                used-state.at(arg())
            } else {
                used-state.at(arg)
            }
        },
        value => used-state.update(value),
    )
}

/// Code from: [jbirnick](https://github.com/jbirnick/typst-rich-counters)
/// Modified by: [OrangeX4](https://github.com/OrangeX4)
/// License: MIT
/// I need a patched version of `rich-counter` to support the `zero-fill` and `leading-zero` options. And we can update the arguments by set-inherited-levels, set-inherited-from, set-zero-fill, and set-leading-zero functions.

/// Create a richer counter that can inherit from other counters and display the counter value. Returns a dictionary of functions to interact with the counter like `at`, `get-inherited-levels` and `set-inherited-levels`.
///
/// - identifier (str): Unique identifier for the counter.
/// - inherited-levels (int): Number of heading levels to inherit from. Default is 0, which will inherit from the inherited-from counter if it is a dictionary.
/// - inherited-from (counter): Counter to inherit from. Default is heading.
/// - zero-fill (bool): Whether to zero-fill the numbering. Default is false.
/// - leading-zero (bool): Whether to remove the leading zero. Default is false.
#let richer-counter(
    identifier: none,
    inherited-levels: 0,
    inherited-from: heading,
    zero-fill: false,
    leading-zero: false,
) = {
    // this can equip `headings` and similar objects with the richer-counter functions
    // that are needed for recursive evaluation
    let richer-wrapper(key) = {
        let at(loc) = {
            let cntr = counter(key)
            if loc == none { cntr.final() } else { cntr.at(loc) }
        }
        let last-update-location(level, before-key) = {
            if key == heading {
                let occurrences = if before-key == none { query(selector(key)) } else {
                    query(selector(key).before(before-key))
                }
                for occurrence in occurrences.rev() {
                    if occurrence.level <= level {
                        return occurrence.location()
                    }
                }
            } else {
                // best guess: just take the last occurrence of the element
                // WARNING: this can be wrong for certain elements, especially if Typst introduces more queryable/locatable elements
                let occurrences = if before-key == none { query(selector(key)) } else {
                    query(selector(key).before(before-key))
                }
                if occurrences.len() == 0 {
                    return none
                } else {
                    return occurrences.last().location()
                }
            }
        }

        return (at: at, get-inherited-levels: () => 0, last-update-location: last-update-location)
    }

    // oop-style state management
    let (get-inherited-from, set-inherited-from) = use-state("richer-inherited-from:" + identifier, inherited-from)
    let richer-inherited-levels = state("richer-inherited-levels:" + identifier, inherited-levels)
    let get-inherited-levels(..args) = {
        // small hack to allow for inheritance of richer-counter
        let arg = args.pos().at(0, default: none)
        let value = if arg == none {
            richer-inherited-levels.final()
        } else {
            richer-inherited-levels.at(arg)
        }
        if type(get-inherited-from()) == dictionary and value == 0 {
            return (get-inherited-from().get-inherited-levels)() + 1
        }
        return value
    }
    let set-inherited-levels(value) = richer-inherited-levels.update(value)
    let (get-zero-fill, set-zero-fill) = use-state("richer-zero-fill:" + identifier, zero-fill)
    let (get-leading-zero, set-leading-zero) = use-state("richer-leading-zero:" + identifier, leading-zero)

    // get the parent richer-counter
    let parent-richer-counter() = if type(get-inherited-from(here())) == dictionary {
        get-inherited-from(here())
    } else {
        richer-wrapper(get-inherited-from(here()))
    }

    // `step` method for this richer-counter
    let step(depth: 1) = [
        #metadata((
            kind: "richer-counter:step",
            identifier: identifier,
            value: depth,
        ))
        #label("richer-counter:step:" + identifier)
    ]

    // `update` method for this richer-counter
    // only support array of integers as counter value
    let update(counter-value) = {
        assert(
            type(counter-value) == array and counter-value.all(v => type(v) == int),
            message: "Counter value for '" + identifier + "' must be an array of integers, e.g. (1, 2).",
        )
        [
            #metadata((
                kind: "richer-counter:update",
                identifier: identifier,
                value: counter-value,
            ))
            #label("richer-counter:update:" + identifier)
        ]
    }

    // find updates of own partial (!) counter in certain range
    let updates-during(after-key, before-key) = {
        let query-for = selector(label("richer-counter:step:" + identifier)).or(selector(label(
            "richer-counter:update:" + identifier,
        )))

        if after-key == none and before-key == none {
            return query(query-for)
        } else if after-key == none {
            return query(query-for.before(before-key))
        } else if before-key == none {
            return query(query-for.after(after-key))
        } else {
            return query(query-for.after(after-key).before(before-key))
        }
    }

    // find last update of this total (!) counter up to a certain level and before a certain location
    let last-update-location(level, before-key) = {
        let parent-last-update-location = (parent-richer-counter().last-update-location)(
            get-inherited-levels(here()),
            before-key,
        )
        let updates = updates-during(parent-last-update-location, before-key)

        for update in updates.rev() {
            let kind = update.value.kind
            if kind == "richer-counter:step" {
                if update.value.value <= level - get-inherited-levels(here()) {
                    return update.location()
                }
            } else if kind == "richer-counter:update" {
                if update.value.value.len() < level {
                    return update.location()
                }
            }
        }

        return parent-last-update-location
    }

    // compute value of the counter after the given updates, starting from 0
    let compute-counter(updates) = {
        let value = (0,)
        for update in updates {
            let kind = update.value.kind
            if kind == "richer-counter:step" {
                let level = update.value.value
                while value.len() < level { value.push(0) }
                while value.len() > level { let _ = value.pop() }
                value.at(level - 1) += 1
            } else if kind == "richer-counter:update" {
                let inherited-levels = get-inherited-levels(here())
                let counter-value = update.value.value
                counter-value = counter-value.slice(calc.min(inherited-levels, counter-value.len()))
                value = if counter-value.len() == 0 {
                    (0,)
                } else {
                    counter-value
                }
            }
        }

        return value
    }

    // `at` method for this richer-counter
    let at(key) = {
        // get inherited numbers
        let num-parent = (parent-richer-counter().at)(key)
        let inherited-levels = get-inherited-levels(here())
        while get-zero-fill(here()) and num-parent.len() < inherited-levels { num-parent.push(0) }
        while num-parent.len() > inherited-levels { let _ = num-parent.pop() }
        if not get-leading-zero(here()) and num-parent.at(0, default: none) == 0 {
            num-parent = num-parent.slice(1)
        }

        // get numbers of own partial counter
        let updates = updates-during((parent-richer-counter().last-update-location)(inherited-levels, key), key)
        let num-self = compute-counter(updates)

        return num-parent + num-self
    }

    // `get` method for this richer-counter
    let get() = { at(here()) }

    // `final` method for this richer-counter
    let final() = { at(none) }

    // `display` method for this richer-counter
    let display(..args) = {
        if args.pos().len() == 0 {
            numbering("1.1", ..get())
        } else {
            numbering(args.pos().first(), ..get())
        }
    }

    return (
        step: step,
        update: update,
        at: at,
        get: get,
        final: final,
        display: display,
        get-inherited-levels: get-inherited-levels,
        set-inherited-levels: set-inherited-levels,
        get-inherited-from: get-inherited-from,
        set-inherited-from: set-inherited-from,
        get-zero-fill: get-zero-fill,
        set-zero-fill: set-zero-fill,
        get-leading-zero: get-leading-zero,
        set-leading-zero: set-leading-zero,
        last-update-location: last-update-location,
    )
}
