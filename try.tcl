package require Class
classyinit test /home/peter/dev/test/

set class {test class}
set object {test object}
set arg {{arg 0} {$arg 1} {arg 2}}
leval try [list $class] [list $object] [lrange $arg 1 end]
eval try [list $class] [list $object] [lrange $arg 1 end]
eval try {$class $object} [lrange $arg 1 end]

package require Class
classyinit test
source makepatch.tcl
text .t -yscrollcommand {.b set} -width 20 -height 10
scrollbar .b -command {.t yview}
pack .t -side left -expand yes -fill both
pack .b -side right -fill y
.t insert end "dfg sgddg sdfgs dfgsdg\nsdfg sdfgsdg sdgsdgsdg sdg sdg sdg df\nsdfga sdgsdfgs gfsdg s\n sdfg sdfgsdf"
