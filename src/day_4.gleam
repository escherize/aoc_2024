// import gleam/io
import gleam/list
import gleam/result
import gleam/string
import glearray.{type Array}
import simplifile.{read}

fn sample_input() {
  "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"
}

pub type Grid =
  Array(Array(String))

pub type Vec2d {
  Vec2d(x: Int, y: Int)
}

fn get_grid(g: Grid, p: Vec2d) -> Result(String, Nil) {
  use row <- result.try(glearray.get(g, p.y))
  glearray.get(row, p.x)
}

fn add(a: Vec2d, b: Vec2d) -> Vec2d {
  Vec2d(x: a.x + b.x, y: a.y + b.y)
}

fn mul(a: Vec2d, b: Int) -> Vec2d {
  Vec2d(x: a.x * b, y: a.y * b)
}

// A program is a start location, and a direction to march in. It can be used to
// read from a grid by marching in the direction and reading the values at each
// step.
pub type Program {
  Program(start: Vec2d, direction: Vec2d)
}

pub fn to_coords(p: Program) -> List(Vec2d) {
  list.map(list.range(0, 3), fn(i) { add(p.start, mul(p.direction, i)) })
}

pub fn is_xmas(s: String) -> Bool {
  s == "XMAS"
}

pub fn read_xmas(g: Grid, p: Program) -> Bool {
  let coords = to_coords(p)
  let found =
    coords
    |> list.filter_map(fn(p) { get_grid(g, p) })
    |> string.join("")

  // io.debug(found)

  found |> is_xmas
}

pub fn parse_input(input: String) -> Grid {
  input
  |> string.split("\n")
  |> list.map(fn(row) { row |> string.split("") |> glearray.from_list })
  |> glearray.from_list
}

pub fn cartesian_product(list1: List(a), list2: List(b)) -> List(#(a, b)) {
  list.flatten(list.map(list1, fn(x) { list.map(list2, fn(y) { #(x, y) }) }))
}

pub fn input() {
  let assert Ok(o) = read("resources/day_4.txt")
  //  io.debug(o |> string.length)
  o
}

pub fn part_one() {
  let g = parse_input(input())
  read_xmas(g, Program(start: Vec2d(x: 0, y: 0), direction: Vec2d(x: 1, y: 0)))
  let directions = {
    let n = Vec2d(x: 0, y: -1)
    let s = Vec2d(x: 0, y: 1)
    let e = Vec2d(x: 1, y: 0)
    let w = Vec2d(x: -1, y: 0)
    [n, s, e, w, add(n, e), add(n, w), add(s, e), add(s, w)]
  }
  let x_size = g |> glearray.length
  let y_size = {
    let assert Ok(row_one) = g |> glearray.get(0)
    row_one |> glearray.length
  }
  let start_positions =
    cartesian_product(list.range(0, x_size), list.range(0, y_size))
    |> list.map(fn(p) { Vec2d(x: p.0, y: p.1) })

  let programs =
    cartesian_product(start_positions, directions)
    |> list.map(fn(p) { Program(start: p.0, direction: p.1) })

  //io.debug(programs |> list.length)

  programs
  // |> io.debug
  |> list.filter(read_xmas(g, _))
  |> list.length
}

// Part 2

pub fn part_two() {
  sample_input()
}
