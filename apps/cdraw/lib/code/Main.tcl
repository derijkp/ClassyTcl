proc main args {
set w [mainw .mainw]
zoom_init
select_init
line_init
polygon_init
text_init
rectangle_init
oval_init
arc_init
set w $w.canvas
select_start $w
focus $w
}

