if ![info exists home(Edit)] {
set home(Edit) $pwd
proc Edit {args} {
    global home
    if ![running Edit] {
        exec $home(Edit)/edit.tcl $args &
    } else {
        send Edit edit $args
    }
}

addactions {
    c {Edit $dir/$file}
    h {Edit $dir/$file}
    txt {Edit $dir/$file}
    itk {Edit $dir/$file}
    tcl {Edit $dir/$file}
}
addfileicon c $pwd/icons/file_txt.gif $pwd/icons/small_txt.gif
addfileicon h $pwd/icons/file_txt.gif $pwd/icons/small_txt.gif
addfileicon txt $pwd/icons/file_txt.gif $pwd/icons/small_txt.gif
addfileicon tcl $pwd/icons/file_txt.gif $pwd/icons/small_txt.gif
addfileicon itk $pwd/icons/file_txt.gif $pwd/icons/small_txt.gif
}