#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------

if ![string_equal [Classy::HTML private type] tkhtml] break
if ![llength [info commands html]] {
	load $::class::tkhtmllib
}

bind HtmlClip <<Action>> {[winfo parent %W] geturl [[winfo parent %W] linkat %x %y]}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::HTML method init {args} {
	super init html
#	super init
	html $object.html
	bindtags $object [list $object Classy::HTML . all]
	private $object w
	set w [Classy::window $object]
#	set w $object.html

	# REM Initialise options and variables
	# ------------------------------------
	private $object control options
	setprivate $object options(-url) "file:/"
	setprivate $object tempfile [tempfile]
	setprivate $object currentquery ""
	set control(history) ""
	set control(forward) ""
	set control(back) ""

	# REM Create bindings
	# --------------------
	$w configure \
		-hyperlinkcommand [list $object geturl] \
		-imagecommand [list $object _getimage] \
		-formcommand [list $object _form] \
		-scriptcommand [list $object _script]
	$w token handler BODY [list $object _body]
	$object clearcache

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

Classy::HTML method destroy {} {
	private $object w
	$w _clear
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::HTML chainoptions {$object}

#doc {HTML options -url} option {-url url Url} descr {
#}
Classy::HTML addoption -url {url Url {}} {
	set value [$object geturl $value]
}

#doc {HTML options -indent} option {-indent indent Indent} descr {
#}
Classy::HTML addoption -indent {indent Indent {}} {
	html::set_indent $object $value
}

#doc {HTML options -update} option {-update update Update} descr {
#}
Classy::HTML addoption -update {update Update {}} {
	html::set_state $object -update $value
}

#doc {HTML options -tab} option {-tab tab Tab} descr {
#}
Classy::HTML addoption -tab {tab Tab {}} {
	html::set_state $object -tab $value
}

#doc {HTML options -unknown} option {-unknown unknown Unknown} descr {
#}
Classy::HTML addoption -unknown {unknown Unknown {}} {
	html::set_state $object -unknown $value
}

#doc {HTML options -size} option {-size size Size} descr {
#}
Classy::HTML addoption -size {size Size {}} {
	html::set_state $object -size $value
}

#doc {HTML options -symbols} option {-symbols symbols Symbols} descr {
#}
Classy::HTML addoption -symbols {symbols Symbols {}} {
	html::set_state $object -symbols $value
}

#doc {HTML options -tagmap} option {-tagmap tagMap TagMap} descr {
#}
Classy::HTML addoption -tagmap {tagMap TagMap {}}

#doc {HTML options -insertmap} option {-insertmap insertMap InsertMap} descr {
#}
Classy::HTML addoption -insertmap {insertMap InsertMap {}}

#doc {HTML options -errorcommand} option {-errorcommand errorCommand Command} descr {
#}
Classy::HTML addoption -errorcommand {errorCommand Command {}}

#doc {HTML options -state} option {-state state State} descr {
#}
Classy::HTML addoption -state {state State {}}

#doc {HTML options -wrap} option {-wrap wrap Wrap} descr {
#}
Classy::HTML addoption -wrap {wrap Wrap {}} {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML chainallmethods {$object} text

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML method geturl {url {query {}}} {
	private $object control options currentquery html w source
	Classy::busy add $object
	set url [$object fullurl $url]
	# if it is the same url as the current, don't reload
	# --------------------------------------------------
	set base $url
	set currentbase $options(-url)
	set fragment ""
	set currentfragment ""
	regexp {([^#]*)#(.+)} $url dummy base fragment
	regexp {([^#]*)#(.+)} $options(-url) dummy currentbase currentfragment
	if ![info exists control(reload)] {
		if {"$query" == ""} {
			if {"$currentbase" == "$base"} {
				if {"$currentfragment" != "$fragment"} {
					if {"$fragment" != ""} {$object yview $fragment}
					if [info exists control(direction)] {
						unset control(direction)
					} else {
						if {"$query" != ""} {
							set keep [list $options(-url) $currentquery]
						} else {
							set keep $options(-url)
						}
						lappend control(back) $keep
						set control(forward) ""
						list_unshift control(history) $keep
						set control(history) [lrange $control(history) 0 50]
					}
					set options(-url) $url
				}
				set currentquery $query
				Classy::busy remove $object
				return $url
			}
		}
	}
	# get the html data according to protocol
	# ---------------------------------------
	foreach {protocol host file fragment} [$object spliturl $url] break
	if [string_equal $protocol http] {
		set code [catch {
			$object _async_httpget -query $query $url
		} result]
	} else {
		set code [catch {set source [$object getdata -query $query -typevar type $url]} result]
	}
	if $code {
		private $object options
		if {"$options(-errorcommand)" == ""} {
			Classy::busy remove $object
			return -code $code $result
		} else {
			set code [catch {eval $options(-errorcommand) {$url $query $result}} result]
			Classy::busy remove $object
			return -code $code $result
		}
	}
	# adjust controls
	# ---------------
	if [info exists control(reload)] {
		unset control(reload)
	} elseif [info exists control(direction)] {
		unset control(direction)
	} else {
		if {"$query" != ""} {
			set keep [list $options(-url) $currentquery]
		} else {
			set keep $options(-url)
		}
		lappend control(back) $keep
		set control(forward) ""
		list_unshift control(history) $keep
		set control(history) [lrange $control(history) 0 50]
	}
	set options(-url) $url
	# render
	# ------
	$w configure -base $url
	foreach {option attr} {
		-bg Background
		-fg Foreground
		-visitedcolor Foreground
		-unvisitedcolor Foreground
	} {
		$w configure $option [option get $object Classy::HTML $attr]
	}
	$object _clear
	if ![string_equal $protocol http] {
		if {"$type" == "text/html"} {
			$w parse $source
		} else {
			$w parse <pre>$source</pre>
		}
		if [string length $fragment] {
			$w yview $fragment
		}
	}
	set currentquery $query
	Classy::busy remove $object
}

#doc {HTML command reload} cmd {
#pathname reload 
#} descr {
#}
Classy::HTML method reload {} {
	private $object options control currentquery
	set control(reload) 1
	$object geturl $options(-url) $currentquery
}

#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML method back {} {
	private $object options control
	if {"$control(back)" == ""} return
	set url [list_pop control(back)]
	lappend control(forward) $options(-url)
	set control(direction) 1
	if ![regexp ^data: $url] {
		set query [lindex $url 1]
		set url [lindex $url 0]
	} else {
		set query {}
	}
	$object geturl $url $query
}

#doc {HTML command forward} cmd {
#pathname forward 
#} descr {
#}
Classy::HTML method forward {} {
	private $object options control
	if {"$control(forward)" == ""} return
	set url [list_pop control(forward)]
	lappend control(back) $options(-url)
	set control(direction) 1
	if ![regexp ^data: $url] {
		set query [lindex $url 1]
		set url [lindex $url 0]
	} else {
		set query {}
	}
	$object geturl $url $query
}

#doc {HTML command history} cmd {
#pathname history
#} descr {
#}
Classy::HTML method history {} {
	private $object control
	return $control(history)
}

Classy::HTML method _setimage {handle url} {
	private $object tempfile

	set url [$object fullurl $url]

	# if doesn't exists yet, load
	# ---------------------------
	set image ::html::image_$url
	if {"[info commands $image]" == ""} {
		# get the html data according to protocol
		# ---------------------------------------
		if ![regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file] {
			error "error in url format of \"$url\""
		}
		set type photo
		if {[file extension $image] == ".bmp"} {set type bitmap}
		switch $protocol {
			http {
				package require http
				set id [http::geturl $url]
				set data [http::data $id]
				unset $id
				set f [open $tempfile w]
				puts -nonewline $f $data
				close $f
				image create $type $image -file $tempfile
				file delete $tempfile
			}
			file {
				image create $type $image -file $file
			}
			ftp {
				error "not yet"
			}
			default {
				error "unsupported protocol"
			}
		}
	}
	::html::got_image $handle $image
}

#doc {HTML command fullurl} cmd {
#pathname fullurl url
#} descr {
#}
Classy::HTML method fullurl {url} {
	private $object options

	# make url fully specified
	# ------------------------
	if [regexp ^# $url] {
		set base $options(-url)
		regexp {([^#]*)#(.+)} $options(-url) dummy base fragment
		return $base$url
	}
	regsub {/[^/]*$} $options(-url) {} dir
	switch -regexp $url {
		{^(http|ftp|file|data)://} {
		}
		{^(http|ftp|file|data):/} {
			regsub {^(http|ftp|file|data):/} $url {\0/localhost/} url
		}
		{^file:} {
			regsub {^file:} $url {file://localhost/} url
		}
		^/ {
			regexp {^([^:]*)://([^/]+)(/.*)$} $options(-url) dummy protocol host file
			set url $protocol://$host$url
		}
		default {
			set url $dir/$url
		}
	}
	return $url
}

#doc {HTML command spliturl} cmd {
#pathname spliturl url
#} descr {
# splits the given url into a list containing {protocol host file name}
#}
Classy::HTML method spliturl {url} {
	set part {}
	set url [$object fullurl $url]
	regexp {([^#]*)#(.+)} $url dummy url part
	regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file
	return [list $protocol $host $file $part]
}

#doc {HTML command load} cmd {
#pathname load file
#} descr {
#}
Classy::HTML method load {file} {
	if {"[file pathtype $file]" != "absolute"} {
		set file [file join [pwd] $file]
	}
	$object geturl file:$file
}

#doc {HTML command set} cmd {
#pathname set html
#} descr {
#}
Classy::HTML method set {html} {
	$object geturl "data://localhost/$html"
}

#doc {HTML command linkat} cmd {
#pathname linkat x y
#} descr {
# returns the link (href) at position x,y.
# This is used in comination with bindlink to change the behaviour
# of links.
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML method linkat {x y} {
	private $object w
	$w href $x $y
}

#doc {HTML command bindlink} cmd {
#pathname bindlink ?event? ?sequence?
#} descr {
# binds action to a certain event happening on a link
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML method bindlink {args} {
	bind $object.x $args
}

#doc {HTML command source} cmd {
#pathname source
#} descr {
# returns current source
#}
Classy::HTML method source {} {
	private $object source
	return $source
}

#doc {HTML command clearcache} cmd {
#pathname clearcache
#} descr {
# clears the image cache
#}
Classy::HTML method clearcache {} {
	private $object cachedata cache
	set cache(dir) [file join $::Classy::dir(user) HTML-cache]
	if ![file exists $cache(dir)] {
		file mkdir $cache(dir)
	} else {
		catch {eval file delete -force [glob [file join $cache(dir) *]]}
	}
	set cache(pos) 1
	catch {unset cachedata}
}

#doc {HTML command getdata} cmd {
#pathname getdata ?options? url
#} descr {
# gets data from a certain url
#}
Classy::HTML method getdata {args} {
	set opt(-typevar) ::class::temp
	set opt(-query) {}
	cmd_args "$object getdata" {
		-typevar {any "set given variable to type of data obtained"}
		-channel {any "Save data to channel instead of returning it"}
		-query {any "query data"}
	} url $args
	set query $opt(-query)
	if ![regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file] {
		error "error in url format of \"$url\""
	}
	upvar $opt(-typevar) type
	switch $protocol {
		http {
			set base $url
			regexp {([^#]*)#(.+)} $url dummy base fragment
			package require http
			if {"$query" == ""} {
				set id [http::geturl $base]
			} else {
				set id [http::geturl $base -query $query]
			}
			set data [http::data $id]
			array set state [set [set id](meta)]
			if [info exists state(Content-Type)] {
				set type [string trimright [string trimleft $state(Content-Type)]]
			} else {
				set type text/html
			}
			unset $id
		}
		file {
			if {"$::tcl_platform(platform)" == "windows"} {
				regsub {^/([A-Za-z]:/)} $file {\1} file
			}
			set data [file_read -translation binary $file]
			if [regexp {html?$} $file] {
				set type text/html
			} else {
				set type unknown/unknown
			}
		}
		data {
			set data [string range $file 1 end]
			set type text/html
		}
		ftp {
			error "not yet"
		}
		default {
			error "unsupported protocol"
		}
	}
	return $data
}

Classy::HTML method _clear {} {
	private $object w imgstoget
	$w clear
	foreach image [info commands ::class::${object}_*] {
		image delete $image
	}
	set imgstoget {}
}

Classy::HTML method _getimage {args} {
	private $object cachedata cache imgstoget
	foreach {src width height attrs} $args break
	set info(width) 0
	set info(height) 0
    array set info $attrs
    set src [$object fullurl $src]
	set imagename ::class::${object}_${src}
	if [llength [info commands $imagename]] {return $imagename}
	if [info exists cachedata($src)] {
		if ![catch {image create photo $imagename -file $cachedata($src)} image] {
			return $image
		}
	}
	foreach {protocol host file fragment} [$object spliturl $src] break
	if [string_equal $protocol http] {
		lappend imgstoget $src
		if ![isint $info(width)] {set info(width) 0}
		if ![isint $info(height)] {set info(height) 0}
		image create photo $imagename -width $info(width) -height $info(height)
	} else {
		set data [$object getdata $src]
		if [catch {image create photo $imagename -data $data} image] {
			return {}
		} else {
			return $image
		}
	}
}

Classy::HTML method _script {args} {
	error "No scripts supported jet"
}

Classy::HTML method _body {args} {
	private $object w
	foreach {tag attrs} $args break
	array set info $attrs
	foreach {option attr} {
		-bg bgcolor
		-fg text
		-visitedcolor vlink
		-unvisitedcolor link
	} {
		if [info exists info($attr)] {
			$w configure $option $info($attr)
		}
	}
}

Classy::HTML method _form {args} {
	putsvars args
	foreach {n cmd w attrs} $args break
	array set info $attrs
	switch $cmd {
		input {
			if {[info exists info(size)]} {return [entry $w -width $info(size) -bg white]}
			if {[info exists info(type)]} {return [button $w -text $info(value)]}
			label $w -text "form"
		}
    }
}

Classy::HTML method _async_httpget {args} {
	private $object currenttype
	package require http
	set opt(-query) {}
	cmd_args "$object getdata" {
		-query {any "query data"}
	} url $args
	set query $opt(-query)
	foreach {protocol host file fragment} [$object spliturl $url] break
	if {"$query" == ""} {
		set id [http::geturl http://$host/$file \
			-command [list $object _async_httpget_done] \
			-handler [list $object _async_httpget_handler]]
	} else {
		set id [http::geturl http://$host$file \
			-command [list $object _async_httpget_done] \
			-handler [list $object _async_httpget_handler] \
			-query $query]
	}
	array set state [set [set id](meta)]
	if [info exists state(Content-Type)] {
		set currenttype [string trimright [string trimleft $state(Content-Type)]]
	} else {
		set currenttype text/html
	}
	if ![string_equal $currenttype text/html] {
	    $w parse $html <pre>
	}
}

Classy::HTML method _async_httpget_handler {sock token} {
	private $object w
    upvar #0 $token state
    set html [read $sock $state(-blocksize)]
    $w parse $html
	update idletasks
	return
}

Classy::HTML method _async_httpget_done {token} {
	private $object currenttype imgstoget cache cachedata
	if ![string_equal $currenttype text/html] {
	    $w parse $html </pre>
	}
	upvar #0 $token state
	catch {unset state}
	# get images
	foreach image $imgstoget {
		if [info exists cachedata($image)] {
			set file $cachedata($image)
		} else {
			set file $cache(pos)
			set cachedata($image) $file
			incr cache(pos)
		}
		set f [open $file w]
		http::geturl $image -channel $f -command [list $object _async_getimage_done $image $f]
	}
	set imgstoget {}
	return
}

Classy::HTML method _async_getimage_done {image f token} {
	private $object cachedata
	close $f
	set imagename ::class::${object}_${image}
	$imagename	blank
	$imagename	read $cachedata($image)
}
