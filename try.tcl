
package require ClassyTcl
Class new try
try trace {lappend try}
try class

package require ClassyTcl
Classy::Text .try
Classy::Text .try2

package require ClassyTcl
Classy::Editor .try \
	-loadcommand "wm title . "
Classy::Editor .try2 \
	-loadcommand "wm title . "

source ../widgets/Text.tcl
source ../widgets/Editor.tcl

pack .try

class::reinit
Class classmethod nop {} {}
time {Class nop} 5000

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
time {t try} 5000
Test destroy

set v aaaaaaaaaa
set v $v$v$v$v$v$v$v$v$v$v$v
class::private .try $v
set $v 1

class::private .try t
set t 1
info vars ::class::*

class::setprivate .try t1 1
set v aaaaaaaaaa
set v $v$v$v$v$v$v$v$v$v$v$v
class::setprivate .try $v 1
info vars ::class::*

class::privatevar .try $v
class::getprivate .try t
class::getprivate .try $v


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
