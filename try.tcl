Class subclass Test
Test destroy

Class classmethod try {a} {
	puts "$class:$a"
}
Class method try {a} {
	puts "$class:$object:$a"
}
Class new t
puts [t try 2]
t destroy
Class subclass Test
Test method destroy {} {
	puts "destroy $class:$object"
}
Test new t
puts [t try 2]
Test method try {} {}
time {t try} 1000
Test destroy

Tk appname test
package require ClassyTcl

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
