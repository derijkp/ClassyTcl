#set auto_path {/home/peter/bin /usr/local/lib/tcl8.0 /usr/local/lib /usr/local/lib/tk8.0}
package require Peos
wm withdraw .
eval edit [lsort [glob lib/*.tcl]] [lsort [glob widgets/*.tcl]] \
    [lsort [glob src/*.c]] src/Makefile.in
eval edit try.tcl st [glob tests/*.tcl]
eval edit [lsort [glob lib/*.tcl]] [lsort [glob widgets/*.tcl]] \
    [lsort [glob src/*.c]] src/Makefile.in [glob tests/*.tcl]
