import gleam/int.{absolute_value}
import gleam/list.{
  all, any, drop, filter, filter_map, flatten, length, map, range, take,
  window_by_2,
}
import gleam/result
import gleam/string.{split}
import simplifile.{read}

fn is_safe(report) {
  let windowed = window_by_2(report)

  let inc_or_dec =
    all(windowed, fn(t) { t.0 < t.1 }) || all(windowed, fn(t) { t.0 > t.1 })

  let small_changes_only =
    all(windowed, fn(t) {
      let o = absolute_value(t.0 - t.1)
      1 <= o && o <= 3
    })
  inc_or_dec && small_changes_only
}

fn parse_line(line) {
  split(line, " ") |> map(int.parse) |> result.all
}

pub fn part_one() {
  let assert Ok(input) = read("resources/day_2.txt")
  input |> split("\n") |> filter_map(parse_line) |> filter(is_safe) |> length
}

// Part 2:

fn drop_index(l, i) {
  flatten([take(l, i), drop(l, i + 1)])
}

pub fn dampen(l) {
  let len = length(l)
  map(range(0, len - 1), drop_index(l, _))
}

pub fn part_two() {
  let assert Ok(input) = read("resources/day_2.txt")
  let lines = input |> split("\n") |> filter_map(parse_line)
  filter(lines, fn(line) { any(in: dampen(line), satisfying: is_safe) })
  |> length
}
