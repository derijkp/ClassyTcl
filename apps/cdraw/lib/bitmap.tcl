#Functions

proc bitmap_insert {w {file {}}} {
global current
set x [$w canvasx [expr {[winfo width $w]/2.0}]]
set y [$w canvasy [expr {[winfo height $w]/2.0}]]
$w addbitmap $x $y $file
}

