#!/home/peter/dev/ClassyTcl/src/classywish

source tools.tcl

test Widget {init entry} {
	classyclean
	destroy .try
	Widget subclass Test
	Test classmethod init {} {
		super entry
	}
	Test .try
} {::class::Tk_.try}

test Widget {init entry with args} {
	classyclean
	destroy .try
	Widget subclass Test
	Test classmethod init {} {
		super entry $object -textvariable try
	}
	[Test .try] cget -textvariable
} {try}

