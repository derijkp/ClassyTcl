#!/bin/sh
# the next line restarts using wish \
exec tclsh8.0 "$0" "$@"

source tools.tcl

test class {create object 2 times} {
	clean
	Class new try
	Class new try
} {command "try" exists} 1

test class {create object with short name} {
	clean
	Class new t
} {t}

test class {object destroy and recreate} {
	clean
	Class new try
	try destroy
	Class new try
} {try}

test class {object destroy and test command} {
	clean
	Class new try
	try destroy
	try
} {invalid command name "try"} 1

test class {Class destroy -> children destroyed?} {
	clean
	Class new try
	Class destroy
	try
} {invalid command name "try"} 1

test class {nop} {
	clean
	Class method nop {} {}
	Class new try
	puts [time {try nop} 1000]
} {}

test class {args} {
	clean
	Class method try {a} {return "$object:$a"}
	Class new try
	puts [time {try try 1} 1000]
	try try 1
} {try:1}

test class {object class} {
	clean
	Class new try
	try class
} {Class}

test class {object command} {
	clean
	Class new try
	try
} {no value given for parameter "cmd" to "try"} 1

test class {object command} {
	clean
	Class new try
	try destroy
	try
} {invalid command name "try"} 1

test class {don't overwrite objects} {
	clean
	Class new try
	Class new try
} {command "try" exists} 1

test class {don't overwrite classes} {
	clean
	Class subclass Test
	Class subclass Test
} {command "Test" exists} 1

test class {delete child classes when destroyed ?} {
	clean
	Class subclass Test
	Class destroy
	Class subclass Test
} {Test}

test class {subclass parent} {
	clean
	Class subclass Subclass
	Subclass parent
} {Class}

test class {subclass cmd} {
	clean
	Class subclass Subclass
	Subclass
} {no value given for parameter "cmd" to "Subclass"} 1

test class {subclass methods} {
	clean
	Class subclass Subclass
	Subclass method
} {class destroy private}

test class {try method} {
	clean
	Class method addclass {} {}
	Class method
} {addclass class destroy private}

test class {do not show _method} {
	clean
	Class method _test {} {}
	Class method
} {class destroy private}

test class {do not show _method for instance} {
	clean
	Class method _test {} {}
	Class new try
	try try
} {bad option "try": must be class, destroy, private} 1

test class {subclass destroy: test command} {
	clean
	Class subclass Test
	Test destroy
	Test
} {invalid command name "Test"} 1

test class {subclass with instance destroy: test command} {
	clean
	Class subclass Test
	Test new try
	Test destroy
	try
} {invalid command name "try"} 1

test class {subclass with instance destroy: test children} {
	clean
	Class subclass Test
	Test new try
	Test destroy
	Class children
} {}

test class {subclass with instance and subclass destroy: test children} {
	clean
	Class subclass Test
	Test new try
	Test subclass Test2
	Test destroy
	Class children
} {}

test Class {subclass destroy: test method} {
	clean
	Class subclass Test
	Test destroy
	Test method nop {} {}
} {invalid command name "Test"} 1

test class {Class destroy: destroyed subclass?} {
	clean
	Class subclass Subclass
	Class destroy
	Subclass
} {invalid command name "Subclass"} 1

test class {add method} {
	clean
	Class method nop {} {}
	Class method
} {class destroy nop private}

test class {add method: works?} {
	clean
	Class method try {} {return ok}
	Class try
} {ok}

test class {add method: works with arguments} {
	clean
	Class method try {a} {return $a}
	Class try ok
} {ok}

test class {add method: wrong # arguments} {
	clean
	Class method try {a} {return $a}
	Class try
} {wrong # args: should be "Class try a"} 1

test class {subclass inherits new methods} {
	clean
	Class method nop {} {}
	Class subclass Subclass
	Subclass method
} {class destroy nop private}

test class {inherit method: works?} {
	clean
	Class method try {} {return ok}
	Class subclass Subclass
	Subclass try
} {ok}

test class {inherit method: works with arguments} {
	clean
	Class method try {a} {return $a}
	Class subclass Subclass
	Subclass try ok
} {ok}

test class {inherit method: works with defaults} {
	clean
	Class method try {a {b 1}} {return "$a $b"}
	Class subclass Subclass
	Subclass try ok
} {ok 1}

test class {inherit classmethod: works?} {
	clean
	Class classmethod try {} {return ok}
	Class subclass Subclass
	Subclass try
} {ok}

test class {inherit classmethod: works with arguments} {
	clean
	Class classmethod try {a} {return $a}
	Class subclass Subclass
	Subclass try ok
} {ok}

test class {inherit classmethod: works with defaults} {
	clean
	Class classmethod try {a {b 1}} {return "$a $b"}
	Class subclass Subclass
	Subclass try ok
} {ok 1}

test class {inherit method: wrong # arguments} {
	clean
	Class method try {a} {return $a}
	Class subclass Subclass
	Subclass try
} {wrong # args: should be "Subclass try a"} 1

test class {new} {
	clean
	Class subclass Subclass
	Class new try
	Class new try2
	Class children
} {try try2}

test class {redefining init} {
	clean
	Class subclass Test
	Test classmethod init {} {
		return [list [super] 1]
	}
	Test subclass Test2
	Test2 classmethod init {} {
		return [list [super] 2]
	}
	Test2 new try
} {{try 1} 2}

test class {error in init} {
	clean
	Class subclass Test
	Test classmethod init {} {
		error error
	}
	Test new try
} {init of class Test failed: error} 1

test class {redefining init: test class} {
	clean
	Class subclass Test
	Test method init {} {
		return [list [super] 1]
	}
	Test subclass Test2
	Test2 method init {} {
		return [list [super] 2]
	}
	Test2 new try
	try class
} {Test2}

test class {redefining init: 1 of 2} {
	clean
	Class subclass Test
	Test classmethod init {} {
		return [list [super] 1]
	}
	Test subclass Test2
	Test2 new try
} {try 1}

test class {redefining init: error in init} {
	clean
	Class subclass Test
	Test classmethod init {} {
		error "test error"
	}
	Test new try
} {init of class Test failed: test error} 1

test class {redefining init: error in init -> test object} {
	clean
	Class subclass Test
	Test classmethod init {} {
		error "test error"
	}
	catch {Test new try}
	try
} {invalid command name "try"} 1

test class {redefining 2 inits: error in init} {
	clean
	Class subclass Test
	Test classmethod init {} {
		error "test error"
	}
	Test subclass Test2
	Test2 classmethod init {} {
		return [list [super] 2]
	}
	Test2 new try
} {init of class Test failed: test error} 1

test Class {method} {
	clean
	Class subclass Test
	Test method try {} {return try}
	Test try
} {try}

test Class {redefine destroy: check redefinition} {
	clean
	Class subclass Test
	Test method destroy {} {set ::c ok}
	Test new try
	set ::c ""
	try destroy
	set ::c
} {ok}

test Class {redefine destroy: check destruction} {
	clean
	Class subclass Test
	Test method destroy {} {set ::c ok}
	Test new try
	try destroy
	try
} {invalid command name "try"} 1

test Class {redefine destroy: error in destruction} {
	clean
	Class subclass Test
	Test method destroy {} {return ok}
	Test new try
	try destroy
	try
} {invalid command name "try"} 1

test Class {redefine destroy: give arguments error} {
	clean
	Class subclass Test
	Test method destroy {test} {return ok}
} {destroy method cannot have arguments} 1

test Class {redefine destroy: multiple} {
	clean
	Class subclass Test
	Test method destroy {} {set ::test "[set ::test] ok1"}
	Test subclass Test2
	Test2 method destroy {} {set ::test ok2}
	Test2 new try
	set test ""
	try destroy
	set ::test
} {ok2 ok1}

test Class {set private vars in new} {
	clean
	Class subclass Test
	Test classmethod init {} {
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

test Class {set private vars in method} {
	clean
	Class subclass Test
	Test classmethod init {} {
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

test Class {test method arguments: too many} {
	clean
	Class method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Class try 1 1 1
} {wrong # args: should be "Class try ai bi"} 1

test Class {test method arguments: not enough} {
	clean
	Class method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Class try 1
} {wrong # args: should be "Class try ai bi"} 1

test Class {test method arguments: ok} {
	clean
	Class method try {ai bi} {
		private $object a b
		set a $ai
		set b $bi
	}
	Class try 1 1
} {1}

test Class {test class variables} {
	clean
	Class private a 1
	Class method set {val} {
		private $class a
		set a $val
	}
	Class method test {} {
		private $class a
		return $a
	}
	Class new try1
	Class new try2
	try1 set 1
	try2 set 2
	try1 test
} {2}

test class {delete method: works?} {
	clean
	Class method try {} {return ok}
	Class deletemethod try
	Class new try
} {try}

test class {delete class method: works?} {
	clean
	Class classmethod try {} {return ok}
	Class deleteclassmethod try
	Class classmethod try
} {}

test class {list class private} {
	clean
	Class private try 1
	Class private try2 1
	Class private
} {try try2}

test class {class private} {
	clean
	Class private try 1
	Class private try
} {1}

test class {class private non existing} {
	clean
	Class private try
} {"Class" does not have a private variable "try"} 1

test class {inherit class private} {
	clean
	Class private try 1
	Class subclass Test
	Test method get {} {getprivate $class try}
	Test get
} {1}

test class {override class private} {
	clean
	Class private try 1
	Class subclass Test
	Test private try 2
	Test method get {} {getprivate $class try}
	Test get
} {2}

test class {override class private} {
	clean
	Class method get {} {getprivate $class try}
	Class private try 1
	Class subclass Test
	Test private try 2
	Class get
} {1}

test class {class private array} {
	clean
	Class private try(a) 1
	Class private try(a)
} {1}

test class {class private array with multiple values} {
	clean
	Class private try(a) 1
	Class private try(b) 2
	Class method test {} {
		private $class try try
		return "$try(a) $try(b)"
	}
	Class test
} {1 2}

test class {class private array with multiple values} {
	clean
	Class private try(a) 1
	Class private try(b) 2
	Class method test {} {
		private $class try try
		return "$try(a) $try(b)"
	}
	Class test
} {1 2}

test class {inherit class private array with multiple values} {
	clean
	Class private try(a) 1
	Class private try(b) 2
	Class subclass Test
	Test method test {} {
		private $class try try
		return "$try(a) $try(b)"
	}
	Test test
} {1 2}

test class {classdestroy} {
	clean
	Class subclass Test
	Test classmethod destroy {} {
		set ::c 2
	}
	set ::c 1
	Test destroy
	set ::c
} {2}

test class {classmethod} {
	clean
	Class classmethod test {} {
		return ok
	}
	Class classmethod
} {children classmethod deleteclassmethod deletemethod destroy method new parent private subclass test}

test class {classmethod, method} {
	clean
	Class classmethod test {} {
		return ok
	}
	Class method
} {class destroy private}

test class {classdestroy different from destroy: class} {
	clean
	Class subclass Test
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
	Class subclass Test
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
	Class method try {} {error try}
	Class new try
	try try
} {try} 1

test class {error in method} {
	clean
	Class method try {} {return -code error try}
	Class new try
	try try
} {try} 1

test class {instance in namespace} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Class new ::try::try
	::try::try class
} {Class}

test class {instance in namespace: not in main} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Class new ::try::try
	try class
} {invalid command name "try"} 1

test class {instance in namespace: destroy} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Class new ::try::try
	Class destroy
	try::try class
} {invalid command name "try::try"} 1

test class {instance in namespace: using variables} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Class method set {arg} {setprivate $object try $arg}
	Class method get {} {getprivate $object try}
	Class new ::try::try
	try::try set ok
	try::try get
} {ok}

test class {instance in namespace: using variables, call from namespace} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Class method set {arg} {setprivate $object try $arg}
	Class method get {} {getprivate $object try}
	Class new ::try::try
	try::try set ok
	namespace eval try {try get}
} {ok}

test class {instance in namespace: using variables, different in ::} {
	clean
	namespace eval ::try {}
	catch {::try::try destroy}
	Class method set {arg} {setprivate $object try $arg}
	Class method get {} {getprivate $object try}
	Class new ::try::try
	Class new try
	try set try
	try::try set ok
	try get
} {try}

test class {class in namespace} {
	clean
	namespace eval ::try {}
	Class subclass ::try::Test
	::try::Test method try {} {return ok}
	::try::Test new try
	try try
} {ok}

test class {class in namespace: destroy} {
	clean
	namespace eval ::try {}
	Class subclass ::try::Test
	::try::Test new try
	Class destroy
	try::Test class
} {invalid command name "try::Test"} 1

test class {class in namespace: variables} {
	clean
	namespace eval ::try {}
	Class subclass ::try::Test
	::try::Test method set {arg} {setprivate $object try $arg}
	::try::Test method get {} {getprivate $object try}
	::try::Test new try
	try set ok
	try get
} {ok}

test class {class in namespace: methods} {
	clean
	namespace eval ::try {}
	Class subclass ::try::Test
	::try::Test method set {arg} {setprivate $object try $arg}
	::try::Test method get {} {getprivate $object try}
	::try::Test method
} {class destroy get private set}

test class {class and instance in namespace: variables} {
	clean
	namespace eval ::try {}
	Class subclass ::try::Test
	::try::Test method set {arg} {setprivate $object try $arg}
	::try::Test method get {} {getprivate $object try}
	::try::Test new try::try
	try::try set ok
	try::try get
} {ok}

test class {propagate method to non existing} {
	clean
	Class subclass Test
	Class method try {} {return ok}
	Test try
} {ok}

test class {propagate method to overwrite} {
	clean
	Class method try {} {return notok}
	Class subclass Test
	Class method try {} {return ok}
	Test try
} {ok}

test class {propagate method: dont overwrite new methods} {
	clean
	Class subclass Test
	Test method try {} {return Test}
	Class method try {} {return Class}
	Test try
} {Test}

test class {propagate classvars} {
	clean
	Class private try notok
	Class subclass Test
	Class private try ok
	Test private try
} {ok}

test class {propagate classvars: dont overwrite newly defined} {
	clean
	Class subclass Test
	Test private try Test
	Class private try Class
	Test private try
} {Test}

test class {trace object} {
	clean
	Class new try
	set ::try ""
	class::traceobject try {append ::try} 3
	try class
	class::untraceobject try
	try class
	set ::try
} {$object class 
}

testsummarize
catch {unset errors}
