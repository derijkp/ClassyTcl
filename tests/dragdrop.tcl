#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
wm geometry . 200x200
bindtags . {. Wish8.0 all}
catch {eval destroy [winfo children .]}
catch {Classy::DragDrop destroy}
set object Classy::DragDrop
label .b -text "Drag from here"
set num 0
proc getf {} {incr ::num ; return "getf $::num"}
bind .b <<Drag>> {
	DragDrop start %X %Y try -image [Classy::geticon file] \
		-types {
			url/url somefile
			text {some text}
		} \
		-ftypes {
			f1 getf
			image {Classy::geticon file}
		}
	DragDrop bind <<Drag-Move>> {Classy::DragDrop configure -transfer move}
	DragDrop bind <<Drag-Link>> {Classy::DragDrop configure -transfer link}
}
bind .b <<AdjustDrag>> {puts adjust;DragDrop start %X %Y adjust}
pack .b
Classy::Selector .select -type color
.select set blue
pack .select
Classy::Text .text -width 10 -height 5
pack .text -side bottom -fill x
entry .e
pack .e -side bottom
bind .e <<Drag-Motion>> {puts "dragging %x %y"}
bind .e <<Drag-Enter>> {puts enter;DragDrop configure -cursor hand1}
bind .e <<Drag-Leave>> {puts leave;DragDrop configure -cursor hand2}
bind .e <<Drop>> {.e delete 0 end;.e insert end [DragDrop get]}
entry .e2
pack .e2 -side bottom
bind .e2 <<Drop>> {.e2 delete 0 end;.e2 insert end [DragDrop get f1]}
bind .e2 <<Drag>> {
	puts ok;DragDrop start %X %Y entry -image {}
}
#	exec ${::class::dir}/experiment/dragdrop.test &
#testsummarize

Classy::Entry .ce -label try
pack .ce
.ce set try
bind .ce <<Drag>> {DragDrop start %X %Y [.ce get];break}
