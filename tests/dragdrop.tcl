#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
catch {eval destroy [winfo children .]}
catch {Classy::DragDrop destroy}
set object Classy::DragDrop
label .b -text Test 
proc getf {} {return getf}
bind .b <<Action-Motion>> {
	DragDrop start .b try -image [Classy::geticon file] \
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
bind .b <<Adjust-Motion>> {puts adjust;DragDrop start .b adjust}
pack .b
entry .e
pack .e -side bottom
bind .e <<Drag-Motion>> {puts "dragging %x %y"}
bind .e <<Drag-Enter>> {puts enter;DragDrop configure -cursor hand1}
bind .e <<Drag-Leave>> {puts leave;DragDrop configure -cursor hand2}
bind .e <<Drop>> {.e delete 0 end;.e insert end [DragDrop get]}
entry .e2
pack .e2 -side bottom
bind .e2 <<Drop>> {.e2 delete 0 end;.e2 insert end [DragDrop get f1]}
bind .e2 <<Action-Motion>> {
	puts ok;DragDrop start .e2 entry -image {}
}

#	exec ${::class::dir}/experiment/dragdrop.test &
#testsummarize

