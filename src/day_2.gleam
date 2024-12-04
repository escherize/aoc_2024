import gleam/int

import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn is_safe(report) {
  let windowed = list.window_by_2(report)

  let inc_or_dec =
    list.all(windowed, fn(t) { t.0 < t.1 })
    || list.all(windowed, fn(t) { t.0 > t.1 })

  let small_changes =
    list.all(windowed, fn(t) {
      let o = int.absolute_value(t.0 - t.1)
      1 <= o && o <= 3
    })
  inc_or_dec && small_changes
}

fn parse_line(line) {
  string.split(line, " ")
  |> list.map(int.parse)
  |> result.all
}

pub fn part_one() {
  let assert Ok(input) = read("resources/day_2.txt")
  input
  |> string.split("\n")
  |> list.filter_map(parse_line)
  |> list.filter(is_safe)
  |> list.length
}

// Part 2:

fn drop_index(l, i) {
  list.concat([list.take(l, i), list.drop(l, i + 1)])
}

pub fn dampen(l) {
  let len = list.length(l)
  list.map(list.range(0, len - 1), drop_index(l, _))
}

pub fn part_two() {
  let assert Ok(input) = read("resources/day_2.txt")
  let lines =
    input
    |> string.split("\n")
    |> list.filter_map(parse_line)
  list.filter(lines, fn(line) {
    list.any(in: dampen(line), satisfying: is_safe)
  })
  |> list.length
}
