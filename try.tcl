package require Class
classyinit test /home/peter/dev/test/

set class {test class}
set object {test object}
set arg {{arg 0} {$arg 1} {arg 2}}
leval try [list $class] [list $object] [lrange $arg 1 end]
eval try [list $class] [list $object] [lrange $arg 1 end]
eval try {$class $object} [lrange $arg 1 end]
