proc main args {
	global data 
	mainw .mainw
	set data(level) 0
	set data(t,0) plus
	set data(new) 0
	set data(mem) 0
	set data(units) deg
	set data(inv) 0
	.mainw.entry nocmdset 0

}

Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	button $object.button33 \
		-text button
	
	Classy::NumEntry $object.entry \
		-command {invoke value {setval [expr $value]}} \
		-width 4
	grid $object.entry -row 0 -column 0 -columnspan 5 -sticky nesw
	button $object.n0 \
		-text 0
	grid $object.n0 -row 9 -column 1 -sticky nesw
	button $object.n1 \
		-text 1
	grid $object.n1 -row 8 -column 1 -sticky nesw
	button $object.n4 \
		-text 4
	grid $object.n4 -row 7 -column 1 -sticky nesw
	button $object.n7 \
		-text 7
	grid $object.n7 -row 6 -column 1 -sticky nesw
	button $object.is \
		-command {buttonpress =} \
		-text =
	grid $object.is -row 9 -column 4 -sticky nesw
	button $object.plusminus \
		-text +/-
	grid $object.plusminus -row 9 -column 3 -sticky nesw
	button $object.dec \
		-text .
	grid $object.dec -row 9 -column 2 -sticky nesw
	button $object.n2 \
		-text 2
	grid $object.n2 -row 8 -column 2 -sticky nesw
	button $object.n3 \
		-text 3
	grid $object.n3 -row 8 -column 3 -sticky nesw
	button $object.n5 \
		-text 5
	grid $object.n5 -row 7 -column 2 -sticky nesw
	button $object.n6 \
		-text 6
	grid $object.n6 -row 7 -column 3 -sticky nesw
	button $object.n8 \
		-text 8
	grid $object.n8 -row 6 -column 2 -sticky nesw
	button $object.n9 \
		-text 9
	grid $object.n9 -row 6 -column 3 -sticky nesw
	button $object.plus \
		-text +
	grid $object.plus -row 8 -column 4 -sticky nesw
	button $object.minus \
		-text -
	grid $object.minus -row 7 -column 4 -sticky nesw
	button $object.times \
		-text *
	grid $object.times -row 6 -column 4 -sticky nesw
	button $object.div \
		-text /
	grid $object.div -row 5 -column 4 -sticky nesw
	button $object.parenr \
		-text )
	grid $object.parenr -row 5 -column 3 -sticky nesw
	button $object.tan \
		-text tan
	grid $object.tan -row 3 -column 3 -sticky nesw
	button $object.cec \
		-text CE/C
	grid $object.cec -row 2 -column 3 -sticky nesw
	button $object.ac \
		-text AC
	grid $object.ac -row 2 -column 4 -sticky nesw
	button $object.drg \
		-text DRG
	grid $object.drg -row 3 -column 4 -sticky nesw
	button $object.pow \
		-text y^x
	grid $object.pow -row 4 -column 4 -sticky nesw
	button $object.parenl \
		-text (
	grid $object.parenl -row 5 -column 2 -sticky nesw
	button $object.cos \
		-text cos
	grid $object.cos -row 3 -column 2 -sticky nesw
	button $object.sqrt \
		-text SQRT
	grid $object.sqrt -row 2 -column 2 -sticky nesw
	button $object.pow2 \
		-text x^2
	grid $object.pow2 -row 2 -column 1 -sticky nesw
	button $object.sin \
		-text sin
	grid $object.sin -row 3 -column 1 -sticky nesw
	button $object.ee \
		-text EE
	grid $object.ee -row 4 -column 1 -sticky nesw
	button $object.fac \
		-text x!
	grid $object.fac -row 5 -column 1 -sticky nesw
	button $object.over \
		-text 1/x
	grid $object.over -row 2 -column 0 -sticky nesw
	button $object.inv \
		-text INV
	grid $object.inv -row 3 -column 0 -sticky nesw
	button $object.e \
		-text e
	grid $object.e -row 4 -column 0 -sticky nesw
	button $object.pi \
		-text PI
	grid $object.pi -row 5 -column 0 -sticky nesw
	button $object.sto \
		-text STO
	grid $object.sto -row 6 -column 0 -sticky nesw
	button $object.rcl \
		-text RCL
	grid $object.rcl -row 7 -column 0 -sticky nesw
	button $object.sum \
		-text SUM
	grid $object.sum -row 8 -column 0 -sticky nesw
	button $object.exc \
		-text EXC
	grid $object.exc -row 9 -column 0 -sticky nesw
	button $object.log10 \
		-text log
	grid $object.log10 -row 4 -column 2 -sticky nesw
	button $object.log \
		-text ln
	grid $object.log -row 4 -column 3 -sticky nesw
	frame $object.opt  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.opt -row 1 -column 0 -columnspan 5 -sticky nesw
	label $object.opt.label \
		-anchor w \
		-font {courier 10} \
		-text {    DEG}
	grid $object.opt.label -row 0 -column 0 -sticky nesw
	button $object.opt.button1 \
		-text button
	
	button $object.opt.button2 \
		-command {Classy::Config dialog} \
		-text cnf
	grid $object.opt.button2 -row 0 -column 1 -sticky nesw
	button $object.opt.button3 \
		-command exit \
		-text exit
	grid $object.opt.button3 -row 0 -column 2 -sticky nesw
	grid columnconfigure $object.opt 0 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
# ClassyTcl Initialise
set ::work 0
	# Parse this
	$object configure \
		-destroycommand "exit"
	$object.n0 configure \
		-background [Classy::realcolor lightBackground]
	$object.n1 configure \
		-background [Classy::realcolor lightBackground]
	$object.n4 configure \
		-background [Classy::realcolor lightBackground]
	$object.n7 configure \
		-background [Classy::realcolor lightBackground]
	$object.is configure \
		-background [Classy::realcolor darkBackground]
	$object.plusminus configure \
		-background [Classy::realcolor darkBackground]
	$object.dec configure \
		-background [Classy::realcolor lightBackground]
	$object.n2 configure \
		-background [Classy::realcolor lightBackground]
	$object.n3 configure \
		-background [Classy::realcolor lightBackground]
	$object.n5 configure \
		-background [Classy::realcolor lightBackground]
	$object.n6 configure \
		-background [Classy::realcolor lightBackground]
	$object.n8 configure \
		-background [Classy::realcolor lightBackground]
	$object.n9 configure \
		-background [Classy::realcolor lightBackground]
	$object.plus configure \
		-background [Classy::realcolor darkBackground]
	$object.minus configure \
		-background [Classy::realcolor darkBackground]
	$object.times configure \
		-background [Classy::realcolor darkBackground]
	$object.div configure \
		-background [Classy::realcolor darkBackground]
	$object.parenr configure \
		-background [Classy::realcolor darkBackground]
	$object.tan configure \
		-background [Classy::realcolor darkBackground]
	$object.cec configure \
		-background [Classy::realcolor orange]
	$object.ac configure \
		-background [Classy::realcolor orange]
	$object.drg configure \
		-background [Classy::realcolor darkBackground]
	$object.pow configure \
		-background [Classy::realcolor darkBackground]
	$object.parenl configure \
		-background [Classy::realcolor darkBackground]
	$object.cos configure \
		-background [Classy::realcolor darkBackground]
	$object.sqrt configure \
		-background [Classy::realcolor darkBackground]
	$object.pow2 configure \
		-background [Classy::realcolor darkBackground]
	$object.sin configure \
		-background [Classy::realcolor darkBackground]
	$object.ee configure \
		-background [Classy::realcolor darkBackground]
	$object.fac configure \
		-background [Classy::realcolor darkBackground]
	$object.over configure \
		-background [Classy::realcolor darkBackground]
	$object.inv configure \
		-background [Classy::realcolor darkBackground]
	$object.e configure \
		-background [Classy::realcolor darkBackground]
	$object.pi configure \
		-background [Classy::realcolor darkBackground]
	$object.sto configure \
		-background [Classy::realcolor darkBackground]
	$object.rcl configure \
		-background [Classy::realcolor darkBackground]
	$object.sum configure \
		-background [Classy::realcolor darkBackground]
	$object.exc configure \
		-background [Classy::realcolor darkBackground]
	$object.log10 configure \
		-background [Classy::realcolor darkBackground]
	$object.log configure \
		-background [Classy::realcolor darkBackground]
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTcl Finalise
foreach w [winfo children $object] {
	if ![inlist [list $object.entry $object.label $object.opt] $w] {
		$w configure -command [list buttonpress $w]
	}
}
$object.entry set 0
set data(new) 1
	return $object
}

proc buttonpress w {
global data
set window .mainw
regexp {[^.]+$} $w button
set labelw $window.opt.label
if [regexp {^n([0-9])$} $button temp num] {
	if {[$window.entry get] == 0} {setval {}}
	if $data(new) {
		setval {}
		set data(new) 0
	}
	$window.entry insert end $num
	$window.entry constrain
} elseif {"$button" == "ac"} {
	unset data
	set data(level) 0
	set data(t,0) plus
	set data(new) 0
	set data(mem) 0
	set data(units) deg
	set data(inv) 0
	setval 0
	$labelw configure -text "    DEG"
} elseif {"$button" == "cec"} {
	foreach name [array names data v,*] {
		catch {unset data($name)}
	}
	foreach name [array names data a,*] {
		catch {unset data($name)}
	}
	set data(t,0) plus
	set data(level) 0
	setval 0
	set data(new) 1
} elseif {"$button" == "inv"} {
	if $data(inv) {
		set data(inv) 0
		$labelw configure -text "    [string range [$labelw cget -text] 4 end]"
	} else {
		set data(inv) 1
		$labelw configure -text "INV [string range [$labelw cget -text] 4 end]"
	}
} else {
	set value [$window.entry get]
	if [info exists data(v,$data(level))] {
		set prevv $data(v,$data(level))
		set preva $data(a,$data(level))
		set prevt $data(t,$data(level))
		set prev 1
	} else {
		set prevt plus
		set prev 0
	}
	switch $button {
		is {
			while {$data(level) != 0} {
				calc
				decrlevel
			}
			calc
			catch {unset data(v,0)}
			catch {unset data(a,0)}
			set data(t,0) plus
			$labelw configure -text [string range [$labelw cget -text] 0 17]
		}
		parenl {
			if {$data(level) == 0} {
				$labelw configure -text "[string range [$labelw cget -text] 0 17] ()"
			}
			incr data(level)
			set data(t,$data(level)) paren
		}
		parenr {
			calc
			decrlevel
			if {$data(level) == 0} {
				$labelw configure -text [string range [$labelw cget -text] 0 17]
			}
		}
		plusminus {
			set value $value
			if [regexp {E\+} $value] {
				regsub {E\+} $value {E-} value
			} elseif [regexp {E-} $value] {
				regsub {E-} $value {E+} value
			} else {
				catch {expr {-$value}} value
			}
			setval $value
		}
		dec {
			$window.entry insert end .
		}
		ee {
			$window.entry insert end E+
		}
		sin - cos - tan {
			switch $data(units) {
				deg {
					set value [expr {$value*acos(-1)/180.0}]
				}
				grad {
					set value [expr {$value*acos(-1)/200.0}]
				}
			}
			if !$data(inv) {
				setval [expr "${button}($value)"]
			} else {
				setval [expr "a${button}($value)"]
			}
			set data(new) 1
		}
		log10 {
			if !$data(inv) {
				setval [expr "log10($value)"]
			} else {
				setval [expr {pow(10,$value)}]
			}
			set data(new) 1
		}
		log {
			if !$data(inv) {
				setval [expr "log($value)"]
			} else {
				setval [expr {pow(,$value)}]
			}
			set data(new) 1
		}
		sqrt {
			if !$data(inv) {
				setval [expr "sqrt($value)"]
			} else {
				setval [expr {pow($value,2)}]
			}
			set data(new) 1
		}
		pow2 {
			if !$data(inv) {
				setval [expr {pow($value,2)}]
			} else {
				setval [expr {sqrt($value)}]
			}
			set data(new) 1
		}
		fac {
			set r 1
			for {set i 2} {$i<=$value} {incr i} {
				set r [expr {$r*$i}]
			}
			setval $r
			set data(new) 1
		}
		over {
			setval [expr {1.0/$value}]
			set data(new) 1
		}
		pi {
			setval [expr acos(-1)]
			set data(new) 1
		}
		e {
			setval [expr pow(1000,1/(log(1000)))]
			set data(new) 1
		}
		sto {
			set data(mem) $value
			set data(new) 1
		}
		rcl {
			setval $data(mem)
			set data(new) 1
		}
		sum {
			set data(mem) [expr {$data(mem)+$value}]
			set data(new) 1
		}
		exc {
			set temp $value
			setval $data(mem)
			set data(mem) $temp
			set data(new) 1
		}
		plus {
			if ![inlist {plus minus paren} $data(t,$data(level))] {
				while 1 {
					calc
					decrlevel
					if {$data(level) == 0} break
					if [inlist {plus minus paren} $data(t,$data(level))] break
				}
			}
			calc
			set data(v,$data(level)) [$window.entry get]
			set data(a,$data(level)) $button
			set data(new) 1
		}
		minus {
			if ![inlist {plus minus paren} $data(t,$data(level))] {
				while 1 {
					calc
					decrlevel
					if {$data(level) == 0} break
					if [inlist {plus minus paren} $data(t,$data(level))] break
				}
			}
			calc
			set data(v,$data(level)) [$window.entry get]
			set data(a,$data(level)) $button
			set data(new) 1
		}
		times {
			if [inlist {plus minus paren} $prevt] {
				incr data(level)
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(t,$data(level)) times
				set data(new) 1
			} else {
				if {"$prevt" == "pow"} {
					calc
					decrlevel
					calc
					set data(v,$data(level)) [$window.entry get]
					set data(a,$data(level)) $button
					set data(new) 1
				}
				calc
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(new) 1
			}
		}
		div {
			if [inlist {plus minus paren} $prevt] {
				incr data(level)
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(t,$data(level)) times
				set data(new) 1
			} else {
				if {"$prevt" == "pow"} {
					calc
					decrlevel
					calc
					set data(v,$data(level)) [$window.entry get]
					set data(a,$data(level)) $button
					set data(new) 1
				}
				calc
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(new) 1
			}
		}
		pow {
			if [inlist {plus minus times div paren} $prevt] {
				incr data(level)
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(t,$data(level)) times
				set data(new) 1
			} else {
				calc
				set data(v,$data(level)) [$window.entry get]
				set data(a,$data(level)) $button
				set data(new) 1
			}
		}
		drg {
			switch $data(units) {
				deg {
					$labelw configure -text "        RAD      [string range [$labelw cget -text] 18 end]"
					set data(units) rad
					if $data(inv) {
						setval [expr {$value*acos(-1)/180.0}]
						set data(new) 1
					}
				}
				rad {
					$labelw configure -text "            GRAD [string range [$labelw cget -text] 18 end]"
					set data(units) grad
					if $data(inv) {
						setval [expr {$value*200.0/acos(-1)}]
						set data(new) 1
					}
				}
				grad {
					$labelw configure -text "    DEG          [string range [$labelw cget -text] 18 end]"
					set data(units) deg
					if $data(inv) {
						setval [expr {$value*180.0/200}]
						set data(new) 1
					}
				}
			}
		}
	}
}
if {("$button"!="inv") && ($data(inv))} {
	set data(inv) 0
	$labelw configure -text "    [string range [$labelw cget -text] 4 end]"
}
}

proc calc {} {
	global data
	set level $data(level)
	set window .mainw
	set value [$window.entry get]
	if [info exists data(v,$level)] {
		set prevv $data(v,$level)
		set preva $data(a,$level)
		set prevt $data(t,$level)
		set prev 1
	} else {
		set prev 0
	}
	if !$prev {
		catch {expr {$value}} r
		$window.entry set $r
		set data(new) 1
	} else {
		switch $preva {
			plus {catch {expr {$prevv+$value}} r}
			minus {catch {expr {$prevv-$value}} r}
			times {catch {expr {$prevv*$value}} r}
			div {catch {expr {$prevv/double($value)}} r}
			pow {catch {expr {pow($prevv,$value)}} r}
		}
		$window.entry set $r
		set data(new) 1
		unset data(v,$level)
		unset data(a,$level)
	}
	
}

proc decrlevel {} {
global data
if {$data(level) == 0} return
set level $data(level)
catch {unset data(v,$level)}
catch {unset data(a,$level)}
catch {unset data(t,$level)}
incr data(level) -1
}

proc setval value {
regsub {0+$} $value {} value
regsub {\.$} $value {} value
.mainw.entry nocmdset $value
}

