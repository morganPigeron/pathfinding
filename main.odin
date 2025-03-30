package main

import "core:fmt"
import "core:log"
import rl "vendor:raylib"

main :: proc () {

    context.logger = log.create_console_logger()
    
    land := new_land(10,10,{1,1},{8,8})
    defer delete_land(&land)

    land2 := new_land(10,10,{1,4},{8,4})
    defer delete_land(&land2)

    land3 := new_land(10,10,{4,1},{4,8})
    defer delete_land(&land3)

    land4 := new_land(10,10,{8,8},{1,1})
    defer delete_land(&land4)

    rl.SetConfigFlags({.WINDOW_RESIZABLE});
    rl.InitWindow(800, 600, "A*")
    
    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        {
            if rl.IsKeyPressed(.SPACE) {
                step(&land)
                step(&land2)
                step(&land3)
                step(&land4)
            }
        }
        {
            rl.BeginDrawing()
            defer rl.EndDrawing()

            rl.ClearBackground(rl.RAYWHITE)

            screen_size :[2]f32 = {
                f32(rl.GetScreenWidth()),
                f32(rl.GetScreenHeight()),
            }

            map_size := screen_size * 0.5
            map_top_left :[2]f32 = {0,0}

            draw_map(
                land,
                map_top_left,
                map_size,
            )
            draw_map(
                land2,
                map_top_left + {map_size.x,0},
                map_size,
            )
            draw_map(
                land3,
                map_top_left + {0,map_size.y},
                map_size,
            )
            draw_map(
                land4,
                map_top_left + map_size,
                map_size,
            )
            
            rl.DrawFPS(10,10)
        }
    }
}

draw_map :: proc(land: Land, map_top_left: [2]f32, map_size: [2]f32) {

    //draw background
    rl.DrawRectangleRec(
        {
            map_top_left.x,
            map_top_left.y,
            map_size.x,
            map_size.y,
        },
        rl.BLACK,
    )

    //draw each cells
    for cell, i in land.cells {

        padding :f32 = 2
        cell_size := 
            map_size / {f32(land.width),f32(land.height)} - padding

        p := i_to_pos(land, i)
        cell_pos := [2]f32{ f32(p.x), f32(p.y) }
        offset := cell_pos * (cell_size + padding) + (padding * 0.5)
        cell_top_left := map_top_left + offset

        cell_color :rl.Color 
        if i == land.start {
            cell_color = rl.GREEN
        } else if i == land.end {
            cell_color = rl.RED
        } else {
            cell_color = rl.WHITE
        } 

        for index in land.border {
            if index == i {
                cell_color = rl.GRAY
            }
        }
        
        rl.DrawRectangleRec(
            {
                cell_top_left.x,
                cell_top_left.y,
                cell_size.x,
                cell_size.y,
            },
            cell_color,
        )

        rl.DrawText(
            fmt.ctprintf("h: %v", cell.heuristic),
            i32(cell_top_left.x + padding),
            i32(cell_top_left.y + padding),
            2,
            rl.BLACK
        )
    }

}
