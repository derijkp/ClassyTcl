proc main args {
	global data 
	mainw
	set data(level) 0
	set data(t,0) plus
	set data(new) 0
	set data(mem) 0
	set data(units) deg
	set data(inv) 0
	.mainw.entry nocmdset 0

}

proc mainw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .mainw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window 
	button $window.button33 \
		-text button
	
	Classy::NumEntry $window.entry \
		-command {invoke value {setval [expr $value]}} \
		-width 4
	grid $window.entry -row 0 -column 0 -columnspan 5 -sticky nesw
	button $window.n0 \
		-text 0
	grid $window.n0 -row 9 -column 1 -sticky nesw
	button $window.n1 \
		-text 1
	grid $window.n1 -row 8 -column 1 -sticky nesw
	button $window.n4 \
		-text 4
	grid $window.n4 -row 7 -column 1 -sticky nesw
	button $window.n7 \
		-text 7
	grid $window.n7 -row 6 -column 1 -sticky nesw
	button $window.is \
		-command {buttonpress =} \
		-text =
	grid $window.is -row 9 -column 4 -sticky nesw
	button $window.plusminus \
		-text +/-
	grid $window.plusminus -row 9 -column 3 -sticky nesw
	button $window.dec \
		-text .
	grid $window.dec -row 9 -column 2 -sticky nesw
	button $window.n2 \
		-text 2
	grid $window.n2 -row 8 -column 2 -sticky nesw
	button $window.n3 \
		-text 3
	grid $window.n3 -row 8 -column 3 -sticky nesw
	button $window.n5 \
		-text 5
	grid $window.n5 -row 7 -column 2 -sticky nesw
	button $window.n6 \
		-text 6
	grid $window.n6 -row 7 -column 3 -sticky nesw
	button $window.n8 \
		-text 8
	grid $window.n8 -row 6 -column 2 -sticky nesw
	button $window.n9 \
		-text 9
	grid $window.n9 -row 6 -column 3 -sticky nesw
	button $window.plus \
		-text +
	grid $window.plus -row 8 -column 4 -sticky nesw
	button $window.minus \
		-text -
	grid $window.minus -row 7 -column 4 -sticky nesw
	button $window.times \
		-text *
	grid $window.times -row 6 -column 4 -sticky nesw
	button $window.div \
		-text /
	grid $window.div -row 5 -column 4 -sticky nesw
	button $window.parenr \
		-text )
	grid $window.parenr -row 5 -column 3 -sticky nesw
	button $window.tan \
		-text tan
	grid $window.tan -row 3 -column 3 -sticky nesw
	button $window.cec \
		-text CE/C
	grid $window.cec -row 2 -column 3 -sticky nesw
	button $window.ac \
		-text AC
	grid $window.ac -row 2 -column 4 -sticky nesw
	button $window.drg \
		-text DRG
	grid $window.drg -row 3 -column 4 -sticky nesw
	button $window.pow \
		-text y^x
	grid $window.pow -row 4 -column 4 -sticky nesw
	button $window.parenl \
		-text (
	grid $window.parenl -row 5 -column 2 -sticky nesw
	button $window.cos \
		-text cos
	grid $window.cos -row 3 -column 2 -sticky nesw
	button $window.sqrt \
		-text SQRT
	grid $window.sqrt -row 2 -column 2 -sticky nesw
	button $window.pow2 \
		-text x^2
	grid $window.pow2 -row 2 -column 1 -sticky nesw
	button $window.sin \
		-text sin
	grid $window.sin -row 3 -column 1 -sticky nesw
	button $window.ee \
		-text EE
	grid $window.ee -row 4 -column 1 -sticky nesw
	button $window.fac \
		-text x!
	grid $window.fac -row 5 -column 1 -sticky nesw
	button $window.over \
		-text 1/x
	grid $window.over -row 2 -column 0 -sticky nesw
	button $window.inv \
		-text INV
	grid $window.inv -row 3 -column 0 -sticky nesw
	button $window.e \
		-text e
	grid $window.e -row 4 -column 0 -sticky nesw
	button $window.pi \
		-text PI
	grid $window.pi -row 5 -column 0 -sticky nesw
	button $window.sto \
		-text STO
	grid $window.sto -row 6 -column 0 -sticky nesw
	button $window.rcl \
		-text RCL
	grid $window.rcl -row 7 -column 0 -sticky nesw
	button $window.sum \
		-text SUM
	grid $window.sum -row 8 -column 0 -sticky nesw
	button $window.exc \
		-text EXC
	grid $window.exc -row 9 -column 0 -sticky nesw
	button $window.log10 \
		-text log
	grid $window.log10 -row 4 -column 2 -sticky nesw
	button $window.log \
		-text ln
	grid $window.log -row 4 -column 3 -sticky nesw
	frame $window.opt  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.opt -row 1 -column 0 -columnspan 5 -sticky nesw
	label $window.opt.label \
		-anchor w \
		-font {courier 10} \
		-text {    DEG}
	grid $window.opt.label -row 0 -column 0 -sticky nesw
	button $window.opt.button1 \
		-text button
	
	button $window.opt.button2 \
		-command {Classy::Config dialog} \
		-text cnf
	grid $window.opt.button2 -row 0 -column 1 -sticky nesw
	button $window.opt.button3 \
		-command exit \
		-text exit
	grid $window.opt.button3 -row 0 -column 2 -sticky nesw
	grid columnconfigure $window.opt 0 -weight 1

	# End windows
# ClassyTcl Initialise
set ::work 0
	# Parse this
	$window configure \
		-destroycommand "exit"
	$window.n0 configure \
		-background [Classy::realcolor lightBackground]
	$window.n1 configure \
		-background [Classy::realcolor lightBackground]
	$window.n4 configure \
		-background [Classy::realcolor lightBackground]
	$window.n7 configure \
		-background [Classy::realcolor lightBackground]
	$window.is configure \
		-background [Classy::realcolor darkBackground]
	$window.plusminus configure \
		-background [Classy::realcolor darkBackground]
	$window.dec configure \
		-background [Classy::realcolor lightBackground]
	$window.n2 configure \
		-background [Classy::realcolor lightBackground]
	$window.n3 configure \
		-background [Classy::realcolor lightBackground]
	$window.n5 configure \
		-background [Classy::realcolor lightBackground]
	$window.n6 configure \
		-background [Classy::realcolor lightBackground]
	$window.n8 configure \
		-background [Classy::realcolor lightBackground]
	$window.n9 configure \
		-background [Classy::realcolor lightBackground]
	$window.plus configure \
		-background [Classy::realcolor darkBackground]
	$window.minus configure \
		-background [Classy::realcolor darkBackground]
	$window.times configure \
		-background [Classy::realcolor darkBackground]
	$window.div configure \
		-background [Classy::realcolor darkBackground]
	$window.parenr configure \
		-background [Classy::realcolor darkBackground]
	$window.tan configure \
		-background [Classy::realcolor darkBackground]
	$window.cec configure \
		-background [Classy::realcolor orange]
	$window.ac configure \
		-background [Classy::realcolor orange]
	$window.drg configure \
		-background [Classy::realcolor darkBackground]
	$window.pow configure \
		-background [Classy::realcolor darkBackground]
	$window.parenl configure \
		-background [Classy::realcolor darkBackground]
	$window.cos configure \
		-background [Classy::realcolor darkBackground]
	$window.sqrt configure \
		-background [Classy::realcolor darkBackground]
	$window.pow2 configure \
		-background [Classy::realcolor darkBackground]
	$window.sin configure \
		-background [Classy::realcolor darkBackground]
	$window.ee configure \
		-background [Classy::realcolor darkBackground]
	$window.fac configure \
		-background [Classy::realcolor darkBackground]
	$window.over configure \
		-background [Classy::realcolor darkBackground]
	$window.inv configure \
		-background [Classy::realcolor darkBackground]
	$window.e configure \
		-background [Classy::realcolor darkBackground]
	$window.pi configure \
		-background [Classy::realcolor darkBackground]
	$window.sto configure \
		-background [Classy::realcolor darkBackground]
	$window.rcl configure \
		-background [Classy::realcolor darkBackground]
	$window.sum configure \
		-background [Classy::realcolor darkBackground]
	$window.exc configure \
		-background [Classy::realcolor darkBackground]
	$window.log10 configure \
		-background [Classy::realcolor darkBackground]
	$window.log configure \
		-background [Classy::realcolor darkBackground]
# ClassyTcl Finalise
foreach w [winfo children $window] {
	if ![inlist [list $window.entry $window.label $window.opt] $w] {
		$w configure -command [list buttonpress $w]
	}
}
$window.entry set 0
set data(new) 1
	return $window
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



