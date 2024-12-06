import gleam/int
import gleam/list
import gleam/order.{Gt, Lt}
import gleam/set
import gleam/string
import simplifile.{read}

fn sample_input() {
  "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"
}

// an order looks like this: "47|61"
fn parse_order(input: String) -> #(String, String) {
  case input |> string.split("|") {
    [a, b] -> #(a, b)
    _ -> panic as "Invalid order"
  }
}

// orders looks like: "47|61\n97|13\n97|61"
fn parse_updates(input: String) {
  input
  |> string.split("\n")
  |> list.filter(fn(line) { line != "" })
  |> list.map(fn(line) {
    line
    |> string.split(",")
  })
}

fn ordered_correctly(orders, item: a, remaining: List(a)) {
  list.all(remaining, fn(after) { set.contains(orders, #(item, after)) })
}

fn verify_update(orders, update) {
  case update {
    [] -> True
    [_item] -> True
    [item, ..remaining] -> {
      // io.debug(#("item:", item, "remaining:", remaining))
      ordered_correctly(orders, item, remaining)
      && verify_update(orders, remaining)
    }
  }
  // |> io.debug
}

pub fn parse_input(input: String) {
  case input |> string.split("\n\n") {
    [orders, updates] -> {
      let orders =
        orders |> string.split("\n") |> list.map(parse_order) |> set.from_list
      let updates = parse_updates(updates)
      #(orders, updates)
    }
    _ -> panic as "Invalid input"
  }
}

pub fn input() {
  let assert Ok(o) = read("resources/day_5.txt")
  //  io.debug(o |> string.length)
  o
}

fn do_mid_point(l: List(a), n: Int) {
  case l {
    [head, ..tail] -> {
      case n {
        0 -> head
        _ -> do_mid_point(tail, n - 1)
      }
    }
    _ -> panic as "Invalid list"
  }
}

fn mid_point(l: List(a)) {
  do_mid_point(l, list.length(l) / 2)
}

fn to_int(s: String) {
  case s |> int.parse {
    Ok(i) -> i
    Error(_) -> panic as "Invalid int"
  }
}

pub fn part_one() {
  let #(orders, updates) = parse_input(sample_input())
  // io.debug(#("orders", orders))
  // io.debug(#("updates", updates))
  updates
  |> list.filter(verify_update(orders, _))
  |> list.map(mid_point)
  // |> io.debug
  |> list.map(to_int)
  |> int.sum
}

// Part 2

// Bogo sort took too long, lmao
fn bogo_reorder(orders, update) {
  let new_update = list.shuffle(update)
  case verify_update(orders, new_update) {
    True -> new_update
    False -> bogo_reorder(orders, update)
  }
}

fn reorder(orders, update) {
  list.sort(update, fn(a, b) {
    case set.contains(orders, #(a, b)) {
      True -> Lt
      False -> Gt
    }
  })
}

pub fn part_two() {
  let #(orders, updates) = parse_input(input())
  // io.debug(#("orders", orders))
  // io.debug(#("updates", updates))
  updates
  |> list.filter(fn(update) {
    case verify_update(orders, update) {
      True -> False
      False -> True
    }
  })
  |> list.map(reorder(orders, _))
  |> list.map(mid_point)
  // |> io.debug
  |> list.map(to_int)
  |> int.sum
}
