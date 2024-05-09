# This is the Main window with the intended game.
# The Tk is the graphical lib for all the UI and the chatwidget is for the chat part
# It's a fork of the tic tac toe by Keith Vetter  Sept 10, 2004

package require Tk
package require chatwidget

# Title of the window and key value pair definition, each unique
array set S {title "Tic Tac Toe" who,1 "X" who,0 "" who,-1 "O" robot "0"}

# Array for the Canvas
array set C {bars black X blue O red win yellow}

namespace eval ::Robot {
	variable skill Smart
}

# Display Creation
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

# Board Creation
proc DrawBoard {{redraw 0}} {
	global S B GAME C

	if {$redraw} { ;# Must redraw as fresh start
		.c delete all ; # Clears the canvas

		# Margins Creation
		set w2 [expr {$B(w2) - 15}]
		set h2 [expr {$B(h2) - 15}]
		set hbar [expr {$h2 / 3.0}]
		set vbar [expr {$w2 / 3.0}]

		# 9 Cell Drawing
		set B(0) [list -$w2   -$h2   -$vbar -$hbar]
		set B(1) [list -$vbar -$h2    $vbar -$hbar]
		set B(2) [list  $vbar -$h2    $w2   -$hbar]
		set B(3) [list -$w2   -$hbar -$vbar  $hbar]
		set B(4) [list -$vbar -$hbar  $vbar  $hbar]
		set B(5) [list  $vbar -$hbar  $w2    $hbar]
		set B(6) [list -$w2    $hbar -$vbar  $h2]
		set B(7) [list -$vbar  $hbar  $vbar  $h2]
		set B(8) [list  $vbar  $hbar  $w2    $h2]
		
		# Rectangle of each cell
		for {set i 0} {$i < 9} {incr i} {
			.c create rect $B($i) -tag b$i -fill {} -outline {}
			.c bind b$i <Button-1> [list DoClick $i]
			set B($i) [ShrinkBox $B($i) 25]
		}
		
		# Bars drawing
		.c create line -$w2 $hbar $w2 $hbar -tag bar
		.c create line -$w2 -$hbar $w2 -$hbar -tag bar
		.c create line $vbar -$h2 $vbar $h2 -tag bar
		.c create line -$vbar -$h2 -$vbar $h2 -tag bar
		.c itemconfig bar -width 20 -fill $::C(bars) -capstyle round
	}
	.new config -state [expr {$GAME(tcnt) == 0 ? "disabled" : "normal"}]

	for {set i 0} {$i < 9} {incr i} {
		.c itemconfig b$i -fill {}              ;# Erase any win lines
		DrawXO $GAME(board,$i) $i
	}
	foreach i $GAME(win) {                      ;# Do we have a winner???
		.c itemconfig b$i -fill $C(win)
	}
}
# Control frame with the buttons, computer settings, status of the game
proc DoCtrlFrame {} {
	button .new -text "New Game" -command NewGame -bd 4
	.new configure -font "[font actual [.new cget -font]] -weight bold"
	option add *Button.font [.new cget -font]
	label .status -textvariable S(msg) -font {Times 36 bold} -bg white \
		-bd 5 -relief ridge
	button .about -text About -command \
		[list tk_messageBox -message "$::S(title)\nby Keith Vetter, Sept 2004"]

	frame .r -bd 2 -relief ridge
	pack .r -side bottom
	label .r.lc -text "Computer" -font [.new cget -font]
	label .r.lrobot -text "Plays: "
	spinbox .r.robot -values {O None X} -textvariable S(robot) -wrap 1 \
		-width 6 -justify center -command ::Robot::IsTurn
	label .r.llevel -text "Level: "
	spinbox .r.level -values {Smart Random} -textvariable ::Robot::skill \
		-wrap 1 -width 8 -justify center
	grid .r.lc - -row 0
	grid .r.lrobot .r.robot -sticky we
	grid .r.llevel .r.level -sticky we


	pack .status -in .ctrl -side right -fill both -expand 1
	pack .r -in .ctrl -side right -fill both -padx 5
	pack .new .about -in .ctrl -side top -fill x -pady 2
}
proc ShrinkBox {xy d} {
	foreach {x y x1 y1} $xy break
	return [list [expr {$x+$d}] [expr {$y+$d}] [expr {$x1-$d}] [expr {$y1-$d}]]
}

# Recenter -- keeps 0,0 at the center of the canvas during resizing
proc ReCenter {W h w} {                   ;# Called by configure event
	set ::B(h2) [expr {$h / 2}]
	set ::B(w2) [expr {$w / 2}]
	$W config -scrollregion [list -$::B(w2) -$::B(h2) $::B(w2) $::B(h2)]
	DrawBoard 1
}

# DrawXO -- draws appropriate mark in a given cell
proc DrawXO {who where} {
	global S B C

	if {$S(who,$who) eq "X"} {
		foreach {x0 y0 x1 y1} $B($where) break
		.c create line $x0 $y0 $x1 $y1 -width 20 -fill $C(X) -capstyle round \
			-tag xo$where
		.c create line $x0 $y1 $x1 $y0 -width 20 -fill $C(X) -capstyle round \
			-tag xo$where
	} elseif {$S(who,$who) eq "O"} {
		.c create oval $B($where) -width 20 -outline $C(O) -tag xo$where
	} else {
		.c delete xo$where
	}
}

# InitGame -- resets all variables to start a new game
proc InitGame {} {
	global GAME S

	set GAME(state) play
	set GAME(turn) 1
	set GAME(tcnt) 0
	set GAME(win) {}
	for {set i 0} {$i < 9} {incr i} {
		set GAME(board,$i) 0
	}
	set S(msg) "X starts"
}

# NewGame -- starts a new game
proc NewGame {} {
	InitGame
	DrawBoard
	if {$::S(who,$::GAME(turn)) == $::S(robot)} {
		after idle ::Robot::Go
	}
}

# DoClick -- handles button click in a cell
proc DoClick {where} {
	global GAME S

	if {$GAME(state) ne "play"} return          ;# Game over
	if {$GAME(board,$where) != 0} return        ;# Not empty
	set GAME(board,$where) $GAME(turn)
	set GAME(turn) [expr {- $GAME(turn)}]
	incr GAME(tcnt)
	set S(msg) "$S(who,$GAME(turn))'s turn"

	set n [WhoWon]                              ;# Do we have a winner???
	if {$n != 0} {
		set GAME(state) finished
		set GAME(win) [lrange $n 1 end]
		set S(msg) "$S(who,[lindex $n 0]) Wins!"
		} elseif {$GAME(tcnt) == 9} {               ;# Is the game a draw???
		set GAME(state) finished
		set S(msg) "Draw"
	}
	DrawBoard
	if {$S(who,$GAME(turn)) == $S(robot)} {
		after idle ::Robot::Go
	}
}

# WhoWon -- determines if anyone has won the game
proc WhoWon {} {
	foreach {a b c} {0 1 2 3 4 5 6 7 8 0 3 6 1 4 7 2 5 8 0 4 8 2 4 6} {
		set who $::GAME(board,$a)
		if {$who == 0} continue
		if {$who != $::GAME(board,$b) || $who != $::GAME(board,$c)} continue
		return [list $who $a $b $c]
	}
	return 0
}

# ::Robot::Go -- gets and does robot's move
proc ::Robot::Go {} {
	variable skill
	if {$::GAME(state) ne "play"} return        ;# Game over
	set move [::Robot::$skill]
	if {$move == {}} return
	::DoClick $move
}
proc ::Robot::Random {} {                       ;# Picks a random move
set empty {}
for {set i 0} {$i < 9} {incr i} {
	if {$::GAME(board,$i) == 0} {
		lappend empty $i
	}
}
return [lindex $empty [expr {int(rand() * [llength $empty])}]]
}

# ::Robot::Smart -- does winning move if possible, blocks if necessary
# or does a random move
proc ::Robot::Smart {} {
	global GAME

	set blockers {}
	foreach {aa bb cc} {0 1 2 3 4 5 6 7 8 0 3 6 1 4 7 2 5 8 0 4 8 2 4 6} {
		set a $GAME(board,$aa)
		set b $GAME(board,$bb)
		set c $GAME(board,$cc)
		if {$a * $b * $c != 0} continue         ;# No empty slots
		if {$a + $b + $c == 2*$GAME(turn)} {    ;# Winning move
		if {$a == 0} { return $aa}
		if {$b == 0} { return $bb}
		if {$c == 0} { return $cc}
		error "no empty spot"               ;# Can't happen
	}
	if {$a + $b + $c == -2*$GAME(turn)} {   ;# Blocking move
	if {$a == 0} { lappend blockers $aa}
	if {$b == 0} { lappend blockers $bb}
	if {$c == 0} { lappend blockers $cc}
}
}
if {$blockers != {}} {
	return [lindex $blockers [expr {int(rand() * [llength $blockers])}]]
}
return [::Robot::Random]
}

# ::Robot::IsTurn -- called when who robot is changes and we may need to move
proc ::Robot::IsTurn {} {
	if {$::S(who,$::GAME(turn)) == $::S(robot)} {
		after idle ::Robot::Go
	}
}

InitGame
DoDisplay
NewGame
