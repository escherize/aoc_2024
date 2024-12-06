import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import glearray.{type Array}
import simplifile.{read}

fn sample_input() {
  "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."
}

pub type Direction {
  Up
  Down
  Left
  Right
}

pub type Cell {
  Wall
  Empty(visited: Bool)
  Guard(Direction)
  Border
}

type Point =
  #(Int, Int)

fn add(a: Point, b: Point) -> Point {
  #(a.0 + b.0, a.1 + b.1)
}

pub type Map =
  Dict(Point, Cell)

pub fn render(c: Cell) -> String {
  case c {
    Wall -> "#"
    Empty(visited: False) -> "."
    Empty(visited: True) -> "X"
    Guard(Up) -> "^"
    Guard(Down) -> "v"
    Guard(Left) -> "<"
    Guard(Right) -> ">"
    Border -> panic as "should not render border"
  }
}

pub fn print_map(m: Map) -> Map {
  let #(w, h) = find_dimensions(m)
  list.map(list.range(0, w), fn(y) {
    list.map(list.range(0, h), fn(x) {
      let c = m |> dict.get(#(x, y)) |> result.unwrap(Border)
      render(c)
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
  io.println("__________________")
  io.println("")
  m
}

pub fn parse_input(input: String) -> Map {
  let lines = string.split(input, "\n")
  let deep =
    list.index_map(lines, fn(line, y) {
      list.index_map(string.split(line, ""), fn(cell, x) {
        let c = case cell {
          "." -> Empty(visited: False)
          "X" -> Empty(visited: True)
          "#" -> Wall
          "^" -> Guard(Up)
          "v" -> Guard(Down)
          "<" -> Guard(Left)
          ">" -> Guard(Right)
          _ -> Border
        }
        #(#(x, y), c)
      })
    })
  deep |> list.flatten |> dict.from_list
}

fn find_dimensions(m: Map) -> #(Int, Int) {
  m
  |> dict.keys
  |> list.fold(#(0, 0), fn(p1: Point, p2: Point) {
    let #(x1, y1) = p1
    let #(x2, y2) = p2
    case x1 + y1 > x2 + y2 {
      True -> p1
      False -> p2
    }
  })
}

fn map_find_one(m: Map, f: fn(Cell) -> Bool) -> Result(#(Point, Cell), Nil) {
  m |> map_find(f) |> list.first
}

fn map_find(m: Map, f: fn(Cell) -> Bool) -> List(#(Point, Cell)) {
  m
  |> dict.to_list
  |> list.filter_map(fn(position_and_cell) {
    let #(position, cell) = position_and_cell
    case f(cell) {
      True -> Ok(#(position, cell))
      False -> Error(Nil)
    }
  })
}

fn turn(d: Direction) -> Direction {
  case d {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn find_guard(m: Map) -> Result(#(Point, Cell), Nil) {
  map_find_one(m, fn(cell) {
    case cell {
      Guard(_) -> True
      _ -> False
    }
  })
}

fn dir_to_vec(dir) {
  case dir {
    Up -> #(0, -1)
    Down -> #(0, 1)
    Left -> #(-1, 0)
    Right -> #(1, 0)
  }
}

fn step(m: Map) -> Result(Map, Map) {
  let assert Ok(#(position, cell)) = m |> find_guard
  case cell {
    Guard(dir) -> {
      let new_position =
        position
        |> add(dir_to_vec(dir))
      let next_cell = m |> dict.get(new_position) |> result.unwrap(Border)
      case next_cell {
        Border -> Error(dict.insert(m, position, Empty(visited: True)))
        Empty(_) -> {
          Ok(
            m
            |> dict.insert(position, Empty(visited: True))
            |> dict.insert(new_position, Guard(dir)),
          )
        }
        Guard(_) -> panic as "only 1 guard"
        Wall ->
          Ok(
            m
            |> dict.upsert(update: position, with: fn(cell) {
              case cell {
                Some(Guard(dir)) -> Guard(turn(dir))
                _ -> panic as "should only be a guard facing dir"
              }
            }),
          )
      }
    }
    _ -> panic as "find_guard should only return a guard"
  }
}

pub fn walk(m: Map) -> Map {
  // print_map(m)
  let next_map = step(m)
  case next_map {
    Ok(m) -> walk(m)
    Error(m) -> m
  }
}

fn input() {
  let assert Ok(o) = read("resources/day_6.txt")
  o
}

pub fn part_one() {
  let m = parse_input(input())
  let final = walk(m)
  final
  |> dict.values
  |> list.filter(fn(cell) {
    case cell {
      Empty(visited: True) -> True
      _ -> False
    }
  })
  |> list.length
  |> io.debug
}
