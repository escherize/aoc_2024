import gleam/int

//import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile.{read}

pub fn parse_numbers(input: String) -> Result(#(Int, Int), String) {
  let parts = string.split(input, " ")
  let cleaned_parts = list.filter(parts, fn(s) { s != "" })

  case cleaned_parts {
    [first, second] ->
      case int.parse(first), int.parse(second) {
        Ok(num1), Ok(num2) -> Ok(#(num1, num2))
        Error(_), Ok(_) -> Error("Left is unparseable")
        _, Error(_) -> Error("Right is unparseable")
      }
    _ -> Error("Input does not contain exactly two numbers")
  }
}

pub fn part_one() -> String {
  let assert Ok(input) = read("resources/day_1.txt")
  let parsed_result =
    input
    |> string.split("\n")
    |> list.filter_map(parse_numbers)

  let left = parsed_result |> list.map(fn(x) { x.0 }) |> list.sort(int.compare)
  let right = parsed_result |> list.map(fn(x) { x.1 }) |> list.sort(int.compare)

  list.map2(left, right, fn(a, b) { int.absolute_value(a - b) })
  |> list.fold(0, int.add)
  |> int.to_string
}

//x//////////////////////////////////////////////// Part 2

pub fn part_two() -> String {
  let assert Ok(input) = read("resources/day_1.txt")
  let parsed_result =
    input
    |> string.split("\n")
    |> list.filter_map(parse_numbers)

  let seen = parsed_result |> list.map(fn(x) { x.0 }) |> set.from_list
  let right = parsed_result |> list.map(fn(x) { x.1 })

  list.fold(right, 0, fn(acc, x) {
    case set.contains(seen, x) {
      False -> acc
      True -> acc + x
    }
  })
  |> int.to_string
}
