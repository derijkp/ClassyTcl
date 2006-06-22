#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"

source tools.tcl

test class {subclass and destroy} {
	Class subclass Test
	Test destroy
} {}

test class {destroy instance} {
	catch {Base destroy}
	Class subclass Base
	Base new try
	try destroy
	try
} {invalid command name "try"} 1

test class {instances destroyed} {
	catch {Base destroy}
	Class subclass Base
	Base new try
	Base destroy
	try
} {invalid command name "try"} 1

test class {destroy subclasses} {
	catch {Base destroy}
	Class subclass Base
	Base subclass Test
	Base destroy
	Test
} {invalid command name "Test"} 1

test class {destroy instances from subclass} {
	clean
	Base method try {a} {return $a}
	Base subclass Subclass
	Subclass new subclass
	subclass destroy
	subclass try
} {invalid command name "subclass"} 1

test class {destroy instances from subclasses} {
	clean
	Base method try {a} {return $a}
	Base subclass Subclass
	Subclass new subclass
	Base destroy
	subclass try
} {invalid command name "subclass"} 1

test class {find subclasses} {
	clean
	Base subclass Test
	Base info subclasses
} {Test}

test class {create object 2 times} {
	clean
	Base new try
	Base new try
} {command "try" exists} 1

test class {create object with short name} {
	clean
	Base new t
} {t}

test class {object destroy and recreate} {
	clean
	Base new try
	try destroy
	Base new try
} {try}

test class {object destroy and test command} {
	clean
	Base new try
	try destroy
	info command try
} {}

test class {Base destroy -> children destroyed?} {
	clean
	Base new try
	Base destroy
	info command try
} {}

test class {Base destroy -> destroy method executed ?} {
	clean
	set ::temp 0
	Base method destroy {} {set ::temp 1}
	Base new try
	try destroy
	set ::temp
} {1}

test class {destroy method error} {
	clean
	set ::temp 0
	Base method destroy {} {error "test error" ; set ::temp 1}
	Base new try
	try destroy
	set ::temp
} {"test error" in destroy method of object "try" for class "Base"} 1

test class {destroy method error -> object destroyed?} {
	clean
	set ::temp 0
	Base method destroy {} {error "test error" ; set ::temp 1}
	Base new try
	catch {try destroy}
	try info class
} {invalid command name "try"} 1

test class {object destroy in method} {
	clean
	Base method try {} {
		$object destroy
	}
	Base new try
	try try
	info command try
} {}

test class {object destroy in destroy} {
	clean
	Base subclass Test
	Test method destroy {} {
		$object destroy
	}
	Test new try
	# this will give an error, but should destroy the object anyway
	catch {try destroy}
	info command try
} {}

test class {destroy method info} {
	clean
	Base method destroy {} {puts destroyed}
	Base info method body destroy
} {puts destroyed}

test class {init method info} {
	clean
	Base method init {} {puts init}
	Base info method body init
} {puts init}

#test class {rename to {} destroys?} {
#	clean
#	Base new try
#	try private try 1
#	rename try {}
#	getprivate try try
#} {can't read "::Class::try,,v,try": no such variable} 1

test class {nop} {
	clean
	Base method nop {} {}
	Base new try
	puts [time {try nop} 1000]
} {}

test class {args} {
	clean
	Base method try {a} {return "$object:$a"}
	Base new try
	puts [time {try try 1} 1000]
	try try 1
} {try:1}

test class {object class} {
	clean
	Base new try
	try info class
} {Base}

# source tools.tcl
test class {3} {
	clean
	Base new try
	try
} {wrong # args: should be "try cmd args"} 1

test class {object command} {
	clean
	Base new try
	try destroy
	info command try
} {}

test class {don't overwrite objects} {
	clean
	Base new try
	Base new try
} {command "try" exists} 1

test class {don't overwrite commands} {
	clean
	proc Test {} {}
	set result [catch {Base subclass Test} temp]
	lappend result $temp
	set result
} {1 {command "Test" exists}}

test class {silently ignore require to subclass the same class again (good for reloading files)} {
	clean
	Base subclass Test
	Base subclass Test
} {Test}

test class {delete child classes when destroyed ?} {
	clean
	Base subclass Test
	Test subclass Try
	Test destroy
	Base subclass Try
} {Try}

test class {subclass parent} {
	clean
	Base subclass Subclass
	Subclass info parent
} {Base}

test class {subclass cmd} {
	clean
	Base subclass Subclass
	Subclass
} {wrong # args: should be "Subclass cmd args"} 1

test class {subclass methods} {
	clean
	Base subclass Subclass
	Subclass info methods
} {changeclass destroy info private trace}

test class {try method} {
	clean
	Base method addclass {} {}
	Base info methods
} {addclass changeclass destroy info private trace}

test class {do not show _method} {
	clean
	Base method _test {} {}
	Base info methods
} {changeclass destroy info private trace}

test class {do not show _method for instance} {
	clean
	Base method _test {} {}
	Base new try
	try try
} {bad option "try": must be changeclass, destroy, info, private, trace} 1

test class {subclass destroy: test command} {
	clean
	Base subclass Test
	Test destroy
	Test
} {invalid command name "Test"} 1

test class {subclass with instance destroy: test command} {
	clean
	Base subclass Test
	Test new try
	Test destroy
	try
} {invalid command name "try"} 1

test class {subclass with instance destroy: test children} {
	clean
	Base subclass Test
	Test new try
	Test destroy
	Base info children
} {}

test class {subclass with instance and subclass destroy: test children} {
	clean
	Base subclass Test
	Test new try
	Test subclass Test2
	Test destroy
	Base info children
} {}

test class {subclass destroy: test method} {
	clean
	Base subclass Test
	Test destroy
	Test method nop {} {}
} {invalid command name "Test"} 1

test class {Base destroy: destroyed subclass?} {
	clean
	Base subclass Subclass
	Base destroy
	Subclass
} {invalid command name "Subclass"} 1

test class {add method} {
	clean
	Base method nop {} {}
	Base info methods
} {changeclass destroy info nop private trace}

test class {add method: works?} {
	clean
	Base method try {} {return ok}
	Base new base
	base try
} {ok}

test class {add method: works with arguments} {
	clean
	Base method try {a} {return $a}
	Base new base
	base try ok
} {ok}

test class {add method: wrong # arguments} {
	clean
	Base method try {a} {return $a}
	Base new base
	base try
} {wrong # args: should be "base try a"} 1

test class {subclass inherits new methods} {
	clean
	Base method nop {} {}
	Base subclass Subclass
	Subclass info methods
} {changeclass destroy info nop private trace}

test class {inherit method: works?} {
	clean
	Base method try {} {return ok}
	Base subclass Subclass
	Subclass new subclass
	subclass try
} {ok}

test class {inherit method: works with arguments} {
	clean
	Base method try {a} {return $a}
	Base subclass Subclass
	Subclass new subclass
	subclass try ok
} {ok}

test class {inherit method: works with defaults} {
	clean
	Base method try {a {b 1}} {return "$a $b"}
	Base subclass Subclass
	Subclass new subclass
	subclass try ok
} {ok 1}

source tools.tcl
test class {inherit classmethod: works?} {
	clean
	Base classmethod try {} {return ok}
	Base subclass Subclass
	Subclass try
} {ok}

test class {inherit classmethod: works with arguments} {
	clean
	Base classmethod try {a} {return $a}
	Base subclass Subclass
	Subclass try ok
} {ok}

test class {inherit classmethod: works with defaults} {
	clean
	Base classmethod try {a {b 1}} {return "$a $b"}
	Base subclass Subclass
	Subclass try ok
} {ok 1}

test class {inherit method: wrong # arguments} {
	clean
	Base method try {a} {return $a}
	Base subclass Subclass
	Subclass new subclass
	subclass try
} {wrong # args: should be "subclass try a"} 1

test class {new} {
	clean
	Base subclass Subclass
	Base new try
	Base new try2
	Base info children
} {try try2}

test class {redefining init} {
	clean
	Base subclass Test
	Test method init {} {
		lappend ::test 1
		super init
	}
	Test subclass Test2
	Test2 method init {} {
		lappend ::test 2
		super init
	}
	set test {}
	Test2 new try
	set ::test
} {2 1}

test class {create other object in init with super} {
	clean
	Base subclass Test
	Test method init {} {
		Base new $object.try
		super init
	}
	Test subclass Test2
	Test2 method init {} {
		super init
	}
	Test2 new try
	try.try info class
} {Base}

test class {error in init} {
	clean
	Base subclass Test
	Test method init {} {
		error error
	}
	Test new try
} {error} 1

test class {redefining init: test class} {
	clean
	Base subclass Test
	Test method init {} {
		return [list [super init] 1]
	}
	Test subclass Test2
	Test2 method init {} {
		return [list [super init] 2]
	}
	Test2 new try
	try info class
} {Test2}

test class {redefining init: error in init} {
	clean
	Base subclass Test
	Test method init {} {
		error "test error"
	}
	Test new try
} {test error} 1

test class {redefining init: error in init -> test object} {
	clean
	Base subclass Test
	Test method init {} {
		error "test error"
	}
	catch {Test new try}
	try
} {invalid command name "try"} 1

test class {redefining 2 inits: error in init} {
	clean
	Base subclass Test
	Test method init {} {
		error "test error"
	}
	Test subclass Test2
	Test2 method init {} {
		return [list [super init] 2]
	}
	Test2 new try
} {test error} 1

test class {method} {
	clean
	Base subclass Test
	Test method try {} {return try}
	Test new try
	try try
} {try}

test class {redefine destroy: check redefinition} {
	clean
	Base subclass Test
	Test method destroy {} {set ::c ok}
	Test new try
	set ::c ""
	try destroy
	set ::c
} {ok}

test class {redefine destroy: check destruction} {
	clean
	Base subclass Test
	Test method destroy {} {set ::c ok}
	Test new try
	try destroy
	try
} {invalid command name "try"} 1

test class {redefine destroy: error in destruction} {
	clean
	Base subclass Test
	Test method destroy {} {return ok}
	Test new try
	try destroy
	try
} {invalid command name "try"} 1

test class {redefine destroy: give arguments error} {
	clean
	Base subclass Test
	Test method destroy {test} {return ok}
} {destroy method cannot have arguments} 1

test class {redefine destroy: multiple} {
	clean
	Base subclass Test
	Test method destroy {} {set ::test "[set ::test] ok1"}
	Test subclass Test2
	Test2 method destroy {} {set ::test ok2}
	Test2 new try
	set test ""
	try destroy
	set ::test
} {ok2 ok1}

test class {set private vars in new} {
	clean
	Base subclass Test
	Test method init {} {
		private $object a b
		set a t1
		set b t2
	}
	Test method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Test method nop {} {}
	Test method test {} {
		private $object a b
		return "$a $b"
	}
	Test new try
	try test
} {t1 t2}

test class {set private vars in method} {
	clean
	Base subclass Test
	Test method init {} {
		private $object a b
		set a t1
		set b t2
	}
	Test method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Test method nop {} {}
	Test method test {} {
		private $object a b
		return "$a $b"
	}
	Test new try
	try try 8 9
	try test
} {8 9}

test class {test method arguments: too many} {
	clean
	Base method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Base new base
	base try 1 1 1
} {wrong # args: should be "base try ai bi"} 1

test class {test method arguments: not enough} {
	clean
	Base method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Base new base
	base try 1
} {wrong # args: should be "base try ai bi"} 1

test class {test method arguments: ok} {
	clean
	Base method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Base new base
	base try 1 1
} {1}

test class {test class variables} {
	clean
	Base private a 1
	Base method set {val} {
		private $class a
		set a $val
	}
	Base method test {} {
		private $class a
		return $a
	}
	Base new try1
	Base new try2
	try1 set 1
	try2 set 2
	try1 test
} {2}

test class {delete method: works?} {
	clean
	Base method try {} {return ok}
	Base deletemethod try
	Base info methods
} {changeclass destroy info private trace}

test class {delete method: propagate works?} {
	clean
	Base method try {} {return ok}
	Base subclass Test
	Base deletemethod try
	Test info methods
} {changeclass destroy info private trace}

test class {delete classmethod: propagate works?} {
	clean
	Base classmethod try {} {return ok}
	Base subclass Test
	Base deleteclassmethod try
	Test info classmethods
} {classmethod deleteclassmethod deletemethod destroy info method new private subclass trace}

test class {info classmethods with pattern} {
	clean
	Base classmethod try {} {return ok}
	Base info classmethods try
} {try}

test class {delete class method: works?} {
	clean
	Base classmethod try {} {return ok}
	Base deleteclassmethod try
	Base info classmethods try
} {}

test class {list class private} {
	clean
	Base private try 1
	Base private try2 1
	Base private
} {try try2}

test class {class private} {
	clean
	Base private try 1
	Base private try
} {1}

test class {class private non existing} {
	clean
	Base private try
} {"Base" does not have a private variable "try"} 1

test class {inherit class private} {
	clean
	Base private try 1
	Base subclass Test
	Test method get {} {getprivate $class try}
	Test new try
	try get
} {1}

test class {override class private} {
	clean
	Base private try 1
	Base subclass Test
	Test private try 2
	Test method get {} {getprivate $class try}
	Test new try
	try get
} {2}

test class {override class private} {
	clean
	Base method get {} {getprivate $class try}
	Base private try 1
	Base subclass Test
	Test private try 2
	Base new try
	try get
} {1}

test class {class private array} {
	clean
	Base private try(a) 1
	Base private try(a)
} {1}

test class {class private array with multiple values} {
	clean
	Base private try(a) 1
	Base private try(b) 2
	Base classmethod test {} {
		private $class try try
		return "$try(a) $try(b)"
	}
	Base test
} {1 2}

test class {class private array with multiple values} {
	clean
	Base private try(a) 1
	Base private try(b) 2
	Base classmethod test {} {
		private $class try try
		return "$try(a) $try(b)"
	}
	Base test
} {1 2}

test class {inherit class private array with multiple values} {
	clean
	Base private try(a) 1
	Base private try(b) 2
	Base subclass Test
	Test classmethod test {} {
		private $class try try
		return "$try(a) $try(b)"
	}
	Test test
} {1 2}

test class {classdestroy} {
	clean
	Base subclass Test
	Test classmethod destroy {} {
		set ::c 2
	}
	set ::c 1
	Test destroy
	set ::c
} {2}

test class {classmethod} {
	clean
	Base classmethod test {} {
		return ok
	}
	Base info classmethods
} {classmethod deleteclassmethod deletemethod destroy info method new private subclass test trace}

test class {classmethod, method} {
	clean
	Base classmethod test {} {
		return ok
	}
	Base info methods
} {changeclass destroy info private trace}

test class {classdestroy different from destroy: class} {
	clean
	Base subclass Test
	Test classmethod destroy {} {
		set ::c class
	}
	Test method destroy {} {
		set ::c instance
	}
	set ::c 1
	Test destroy
	set ::c
} {class}

test class {classdestroy different from destroy: instance} {
	clean
	Base subclass Test
	Test classmethod destroy {} {
		set ::c class
	}
	Test method destroy {} {
		set ::c instance
	}
	set ::c 1
	Test new try
	try destroy
	set ::c
} {instance}

test class {error in method} {
	clean
	Base method try {} {error try}
	Base new try
	try try
} {try} 1

test class {error in method} {
	clean
	Base method try {} {return -code error try}
	Base new try
	try try
} {try} 1

test class {instance in namespace} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Base new ::try::try
	::try::try info class
} {Base}

test class {instance in namespace: not in main} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Base new ::try::try
	try info class
} {invalid command name "try"} 1

test class {instance in namespace: destroy} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Base new ::try::try
	Base destroy
	try::try class
} {invalid command name "try::try"} 1

test class {instance in namespace: using variables} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Base method set {arg} {setprivate $object try $arg}
	Base method get {} {getprivate $object try}
	Base new ::try::try
	try::try set ok
	try::try get
} {ok}

test class {instance in namespace: using variables, call from namespace} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Base method set {arg} {setprivate $object try $arg}
	Base method get {} {getprivate $object try}
	Base new ::try::try
	try::try set ok
	namespace eval try {try get}
} {ok}

test class {instance in namespace: using variables, different in ::} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Base method set {arg} {setprivate $object try $arg}
	Base method get {} {getprivate $object try}
	Base new ::try::try
	Base new try
	try set try
	try::try set ok
	try get
} {try}

test class {class in namespace} {
	clean
	namespace eval ::try {}
	Base subclass ::try::Test
	::try::Test method try {} {return ok}
	::try::Test new try
	try try
} {ok}

test class {class in namespace: destroy} {
	clean
	namespace eval ::try {}
	Base subclass ::try::Test
	::try::Test new try
	Base destroy
	try::Test class
} {invalid command name "try::Test"} 1

test class {class in namespace: variables} {
	clean
	namespace eval ::try {}
	Base subclass ::try::Test
	::try::Test method set {arg} {setprivate $object try $arg}
	::try::Test method get {} {getprivate $object try}
	::try::Test new try
	try set ok
	try get
} {ok}

test class {class in namespace: methods} {
	clean
	namespace eval ::try {}
	Base subclass ::try::Test
	::try::Test method set {arg} {setprivate $object try $arg}
	::try::Test method get {} {getprivate $object try}
	::try::Test info methods
} {changeclass destroy get info private set trace}

test class {class and instance in namespace: variables} {
	clean
	namespace eval ::try {}
	Base subclass ::try::Test
	::try::Test method set {arg} {setprivate $object try $arg}
	::try::Test method get {} {getprivate $object try}
	::try::Test new try::try
	try::try set ok
	try::try get
} {ok}

test class {propagate method to non existing} {
	clean
	Base subclass Test
	Base method try {} {return ok}
	Test new try
	try try
} {ok}

test class {propagate classmethod to non existing} {
	clean
	Base subclass Test
	Base classmethod try {} {return ok}
	Base try
} {ok}

test class {propagate method to overwrite} {
	clean
	Base method try {} {return notok}
	Base subclass Test
	Base method try {} {return ok}
	Test new try
	try try
} {ok}

test class {propagate classmethod to overwrite} {
	clean
	Base classmethod try {} {return notok}
	Base subclass Test
	Base classmethod try {} {return ok}
	Base try
} {ok}

test class {propagate method: dont overwrite new methods} {
	clean
	Base subclass Test
	Test method try {} {return Test}
	Base method try {} {return Base}
	Test new try
	try try
} {Test}

test class {propagate classvars} {
	clean
	Base private try notok
	Base subclass Test
	Base private try ok
	Test private try
} {ok}

test class {propagate classvars: dont overwrite newly defined} {
	clean
	Base subclass Test
	Test private try Test
	Base private try Base
	Test private try
} {Test}

test class {test super args} {
	clean
	Base subclass Test
	Test method init {args} {
		set ::test $args
		return $args
	}
	Test subclass Test2
	Test2 method init {args} {
		return [super init data]
	}
	Test2 subclass Test3
	Test3 method init {args} {
		return [super init]
	}
	set ::test try
	Test3 new try
	set ::test
} {data}

test class {super in method} {
	clean
	Base method try {a} {
		return {t 1}
	}
	Base subclass Subclass
	Subclass subclass SubSubclass
	SubSubclass method try {a b} {
		return [list [super try $a] $b]
	}
	SubSubclass new try
	try try 1 2
} {{t 1} 2}

test class {super in method calling super} {
	clean
	Base method try {a} {
		return [list t $a]
	}
	Base subclass Subclass
	Subclass method try {a} {
		return [list [super try $a] $a]
	}
	Subclass subclass SubSubclass
	SubSubclass method try {a b} {
		return [list [super try $a] $b]
	}
	SubSubclass new try
	try try 1 2
} {{{t 1} 1} 2}

test class {test super calling non-existing method} {
	clean
	Base subclass SubClass
	SubClass method try {a b} {
		return [list [super try $a] $b]
	}
	SubClass new try
	try try 1 2
} {No method "try" defined for super of try (at class "Base")} 1

test class {super in classmethod} {
	clean
	Base classmethod try {a} {
		return {t 1}
	}
	Base subclass Subclass
	Subclass subclass SubSubclass
	SubSubclass classmethod try {a b} {
		return [list [super try $a] $b]
	}
	SubSubclass try 1 2
} {{t 1} 2}

test class {super in classmethod calling super} {
	clean
	Base classmethod try {a} {
		return [list t $a]
	}
	Base subclass Subclass
	Subclass classmethod try {a} {
		return [list [super try $a] $a]
	}
	Subclass subclass SubSubclass
	SubSubclass classmethod try {a b} {
		return [list [super try $a] $b]
	}
	SubSubclass try 1 2
} {{{t 1} 1} 2}

test class {test super calling non-existing classmethod} {
	clean
	Base subclass SubClass
	SubClass classmethod try {a b} {
		return [list [super try $a] $b]
	}
	SubClass try 1 2
} {No classmethod "try" defined for super of SubClass (at class "Base")} 1

test class {class info error} {
	clean
	Base info e
} {wrong option "e" must be parent, class, children, subclasses, methods, method, classmethods or classmethod} 1

test class {object info error} {
	clean
	Base new try
	try info children
} {wrong option "children" must be parent, class, methods or method} 1

test class {method introspection: args} {
	clean
	Base method test {{a 1}} {puts $a}
	Base classmethod test {{a 1}} {puts $a}
	Base info method args test
} {a}

test class {method introspection: body} {
	clean
	Base method test {{a 1}} {puts $a}
	Base classmethod test {{a 1}} {puts $a}
	Base info method body test
} {puts $a}

test class {method introspection: default} {
	clean
	Base method test {{a 1}} {puts $a}
	Base classmethod test {{a 1}} {puts $a}
	Base info method default test a try
} {1}

test class {classmethod introspection: args} {
	clean
	Base method test {{a 1}} {puts $a}
	Base classmethod test {{a 1}} {puts $a}
	Base info classmethod args test
} {a}

test class {classmethod introspection: body} {
	clean
	Base method test {{a 1}} {puts $a}
	Base classmethod test {{a 1}} {puts $a}
	Base info classmethod body test
} {puts $a}

test class {classmethod introspection: default} {
	clean
	Base method test {{a 1}} {puts $a}
	Base classmethod test {{a 1}} {puts $a}
	Base info classmethod default test a try
} {1}

test class {trace object} {
	clean
	catch {rename try {}}
	Base new try
	set ::try ""
	try trace {lappend ::try}
	try info class
	try trace {}
	try info class
	set ::try
} {{try info class} {try trace {}}}

test class {trace object level} {
	clean
	catch {rename try {}}
	Base new try
	set ::try ""
	proc trytrace args {lappend ::try [info level] $args}
	try trace trytrace
	try info class
	try trace {}
	try info class
	rename trytrace {}
	set ::try
} {3 {{try info class}} 3 {{try trace {}}}}

test class {trace class} {
	clean
	set ::try ""
	Base trace {lappend ::try}
	Base info class
	Base trace {}
	Base info class
	set ::try
} {{Base info class} {Base trace {}}}

test class {trace class level} {
	clean
	set ::try ""
	proc trytrace args {lappend ::try [info level] $args}
	Base trace trytrace
	Base info class
	Base trace {}
	Base info class
	rename trytrace {}
	set ::try
} {3 {{Base info class}} 3 {{Base trace {}}}}

test class {namespace of init} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method init {} {
		super init
		set ::temp [namespace current]
	}
	Try .try
	set ::temp
} {::Class}

test class {info method args} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test {a b c} {}
	Try .try
	Try info method args test
} {a b c}

test class {info method args inherited} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test {a b c} {}
	Try subclass Test
	Test info method args test
} {a b c}

test class {info method body inherited} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test {a b c} {puts ok}
	Try subclass Test
	Test info method body test
} {puts ok}

test class {info method default inherited} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test {a b {c try}} {puts ok}
	Try subclass Test
	Test info method default test c v
	set v
} try

test class {info method all} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test {a b {c try}} {puts ok}
	set result ""
	lappend result [Try info method args test]
	lappend result [Try info method body test]
	Try info method default test c v
	lappend result $v
} {{a b c} {puts ok} try}

test class {info classmethod all} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try classmethod test {a b {c try}} {puts ok}
	set result ""
	lappend result [Try info classmethod args test]
	lappend result [Try info classmethod body test]
	Try info classmethod default test c v
	lappend result $v
} {{a b c} {puts ok} try}

test class {info classmethod all inherited} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try classmethod test {a b {c try}} {puts ok}
	Try subclass Test
	set result ""
	lappend result [Test info classmethod args test]
	lappend result [Test info classmethod body test]
	Test info classmethod default test c v
	lappend result $v
} {{a b c} {puts ok} try}

test class {method with argument with no name} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test {try {}} {}
} {procedure "Try,,m,test" has argument with no name} 1

test class {classmethod with argument with no name} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try classmethod test {try {}} {}
} {procedure "Try,,cm,test" has argument with no name} 1

test class {method definition error -> old still exists?} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try method test a {return $a}
	catch {Try method test {try {}} {}}
	Try new try
	try test 1
} {1}

test class {classmethod definition error -> old still exists?} {
	clean
	catch {Try destroy}
	Class subclass Try
	Try classmethod test a {return $a}
	catch {Try classmethod test {try {}} {}}
	Try test 1
} {1}

test class {bugfix: super in methods} {
	clean
	Class subclass Test
	Test subclass STest
	Class method amethod {} {
	 return Class
	}
	Test method amethod {} {
		return [list Test [super amethod]]
	}
	STest new stest 
	stest amethod
} {Test Class}

test class {bugfix: super in classmethods} {
	clean
	Class subclass Test
	Test subclass STest
	Class classmethod amethod {} {
	 return Class
	}
	Test classmethod amethod {} {
		return [list Test [super amethod]]
	}
	STest amethod
} {Test Class}

test class {check two auto named objects} {
	clean
	Class subclass Test
	set result [Test new]
	lappend result [Test new #auto]
	lappend result [Test new]
	set result
} {::Class::o1 ::Class::o2 ::Class::o3}

test class {changeclass} {
	clean
	Class subclass Test
	Test subclass STest
	Test method amethod {} {
		return Test
	}
	STest method amethod {} {
		return STest
	}
	set object [Test new]
	set result [$object amethod]
	$object changeclass STest
	lappend result [$object amethod]
} {Test STest}

#test class {info args init} {
#	clean
#	catch {Try destroy}
#	Class subclass Try
#	Try info classmethod args init
#} {}
#
#test class {info args init a} {
#	clean
#	catch {Try destroy}
#	Class subclass Try
#	Try method init {a} {puts $a}
#	Try info classmethod args init
#} {a}
#
#test class {info args destroy} {
#	clean
#	catch {Try destroy}
#	Class subclass Try
#	Try info method args destroy
#} {}

testsummarize
