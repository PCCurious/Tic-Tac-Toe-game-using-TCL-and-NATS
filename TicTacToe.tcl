package require Tk
package require chatwidget

proc DoDisplay {} {
	wm title . $::S(title)
	frame .ctrl -relief ridge -bd 2 -padx 5 -pady 5
	canvas .c -relief raised -bd 2 -height 500 -width 500 -highlightthickness 0
	pack .c -side top -fill both -expand 1
	pack .ctrl -side top -fill both

	bind all <Key-F2> {console show}
	bind .c <Configure> {ReCenter %W %h %w}
	DoCtrlFrame
}
