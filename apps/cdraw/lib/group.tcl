proc group w {
	global current
	$w group withtag _sel
}

proc ungroup w {
	global current
	$w dtag [$w findgroup $current(cur)]
}
