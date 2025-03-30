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

step :: proc (l: ^Land) {

    // check initial state
    if len(l.visited) == 0 && len(l.border) == 0 {
        // set start as visited and found neighbors
        append(&l.visited, l.start)
        l.cells[l.start].path_cost = 0
        l.cells[l.start].heuristic = heuristic(l^, i_to_pos(l^, l.start))

        buffer :[8]int
        append(&l.border, ..find_neighbor(l^, l.start, &buffer))

        for b in l.border {
            l.cells[b].heuristic = heuristic(l^, i_to_pos(l^, b))
        }
        
    } else { 
        //next := find_next_to_visit(l)
    }
    
    
    
}

find_next_to_visit :: proc (land: Land) -> (result: int) {
    
    if len(land.border) == 0 {
        result = 0
    } else {
        result = land.border[0]
        for index in land.border[1:] {
            
        }
    }
    
    return 
}

find_neighbor :: proc (land: Land, index: int, buffer: ^[8]int) -> []int {
    center := i_to_pos(land, index)
    count := 0
    
    // top left
    if center.x > 0 && center.y > 0 {
        buffer[count] = pos_to_i(land, center + {-1,-1})
        count += 1
    }
    // top
    if center.y > 0 {
        buffer[count] = pos_to_i(land, center + {0,-1})
        count += 1
    }
    // top right
    if center.x < land.width - 1 && center.y > 0 {
        buffer[count] = pos_to_i(land, center + {1,-1})
        count += 1
    }
    // left
    if center.x > 0 {
        buffer[count] = pos_to_i(land, center + {-1,0})
        count += 1
    }
    // right
    if center.x < land.width - 1 {
        buffer[count] = pos_to_i(land, center + {1,0})
        count += 1
    }
    // bottom left
    if center.x > 0 && center.y < land.height - 1 {
        buffer[count] = pos_to_i(land, center + {-1,1})
        count += 1
    }
    // bottom
    if  center.y < land.height - 1 {
        buffer[count] = pos_to_i(land, center + {0,1})
        count += 1
    }
    // bottom right
    if center.x < land.width - 1 && center.y < land.height - 1 {
        buffer[count] = pos_to_i(land, center + {1,1})
        count += 1
    }

    return buffer[:min(count, 8)]
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
    // must never overestimate heuristique to work
    to_end     := dist(at_pos, i_to_pos(land ,land.end  ))
    from_start := dist(at_pos, i_to_pos(land, land.start))
    
    total := to_end + from_start
    dist := total.x * total.x + total.y * total.y
    
    return dist
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

