package main

import "core:fmt"
import "core:log"
import rl "vendor:raylib"
import "core:math"

main :: proc () {

    context.logger = log.create_console_logger()
    
    land := new_land(10,10,{1,1},{8,8})
    defer delete_land(&land)

    rl.SetConfigFlags({.WINDOW_RESIZABLE});
    rl.InitWindow(800, 600, "A*")
    
    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {

        screen_size :[2]f32 = {
            f32(rl.GetScreenWidth()),
            f32(rl.GetScreenHeight()),
        }

        map_size := screen_size
        map_top_left :[2]f32 = {0,0}
        
        {
            
            if rl.IsKeyPressed(.SPACE) {
                step(&land)
            }
            
            if rl.IsMouseButtonPressed(.LEFT) {
                m := rl.GetMousePosition()
                
                if m.x < map_size.x && m.y < map_size.y {
                    p :[2]int = {
                        int(math.floor(m.x / (map_size.x / f32(land.width)))),
                        int(math.floor(m.y / (map_size.y / f32(land.height)))),
                    } 
                    toggle_block(&land, pos_to_i(land, p))
                }
            }
        }
        {
            rl.BeginDrawing()
            defer rl.EndDrawing()

            rl.ClearBackground(rl.RAYWHITE)

            draw_map(
                land,
                map_top_left,
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
        } else if cell.blocked {
            cell_color = rl.ORANGE
        } else if cell.is_solution {
            cell_color = rl.BLUE
        } else {
            cell_color = rl.WHITE
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

        for index in land.border {
            if index == i {
                rl.DrawRectangleLinesEx(
                    {
                        cell_top_left.x,
                        cell_top_left.y,
                        cell_size.x,
                        cell_size.y,
                    },
                    2,
                    rl.BLUE,
                )
            }
        }
        
        for index in land.visited {
            if index == i {
                rl.DrawRectangleLinesEx(
                    {
                        cell_top_left.x,
                        cell_top_left.y,
                        cell_size.x,
                        cell_size.y,
                    },
                    2,
                    rl.PURPLE,
                )
            }
        }

        text_top_left := cell_top_left
        font_height :f32 = 8
        rl.DrawText(
            fmt.ctprintf("id: %v", i),
            i32(text_top_left.x + padding),
            i32(text_top_left.y + padding),
            2,
            rl.BLACK
        )

        text_top_left.y += font_height
        rl.DrawText(
            fmt.ctprintf("h: %v", cell.heuristic),
            i32(text_top_left.x + padding),
            i32(text_top_left.y + padding),
            2,
            rl.BLACK
        )

        text_top_left.y += font_height
        rl.DrawText(
            fmt.ctprintf("p: %v", cell.path_cost),
            i32(text_top_left.x + padding),
            i32(text_top_left.y + padding),
            2,
            rl.BLACK
        )
    }

}
