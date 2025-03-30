package main

import "core:testing"
import "core:math"

/*
  add to visited,
  calculate real cost of neig,
  calculate total h + real,
  go to lowest total score


  keep a list of frontier
  keep a list of visited

  at the end find the shortest path by going from the end to the start 
*/

Cell :: struct {
    heuristic: int,
    path_cost: int,
}

Land :: struct {
    cells: []Cell,
    width: int,
    height: int,
    start: int,
    end: int,
    visited: [dynamic]int,
    border: [dynamic]int,
}

pos_to_i :: #force_inline proc (land: Land, pos: [2]int) -> int {
    assert(pos.x * pos.y <= len(land.cells) - 1)
    return pos.x + pos.y * land.width
}

i_to_pos :: #force_inline proc (land: Land, i: int) -> [2]int {
    assert(i <= len(land.cells) - 1)
    return {
        i % land.width,
        i / land.height,
    }
}

dist :: proc (a: [2]int, b: [2]int) -> [2]int {
    return {
        abs(b.x - a.x),
        abs(b.y - a.y),
    }
}

heuristic :: proc (land: Land, at_pos: [2]int) -> int {
    // must never overestimate
    to_end := dist(at_pos, i_to_pos(land ,land.end))
    from_start := dist(i_to_pos(land, land.start), at_pos)
    
    total := to_end + from_start
    dist := math.sqrt(f32(total.x * total.x + total.y * total.y))
    
    return int(dist)
}

new_land :: proc(width: int, height: int, start: [2]int, end: [2]int) -> Land {

    cells := make([]Cell, width * height)
    
    land := Land{
        cells = cells[:],
        width = width,
        height = height,
        visited = make([dynamic]int, 0, (width + height)/2),
        border = make([dynamic]int, 0, (width + height)/2),
    }

    land.start = pos_to_i(land, start)
    land.end = pos_to_i(land, end)
    return land    
}

delete_land :: proc(l: ^Land) {
    delete(l.visited)
    delete(l.border)
    delete(l.cells)
}

@(test)
test_pos_to_i :: proc(t: ^testing.T) {
    l := new_land(10,10,{1,1},{8,8})
    defer delete_land(&l)
    testing.expect(t, l.start == 11)
    testing.expect(t, l.end == 88)
}

@(test)
test_i_to_pos :: proc(t: ^testing.T) {
    l := new_land(10,10,{1,1},{8,8})
    defer delete_land(&l)
    testing.expect(t, i_to_pos(l, 11) == {1,1})
    testing.expectf(t, i_to_pos(l, 88) == {8,8}, "%v", i_to_pos(l, 88))
}

@(test)
test_dist_a_to_b :: proc(t: ^testing.T) {
    l := new_land(10,10,{1,1},{8,8})
    defer delete_land(&l)
    s := i_to_pos(l, l.start)
    e := i_to_pos(l, l.end)
    testing.expect(t, dist(s, e) == {7,7})
    testing.expect(t, dist(e, s) == {7,7})
}

