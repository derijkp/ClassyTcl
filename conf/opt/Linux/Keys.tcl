## ---- Mouse Buttons ----
## Action {Action Button (select, invoke button, ...)}
setevent <<Action>> <1>
## Adjust {Adjust Button (Alternative action, eg. X copy, invoke button without closing dialog, ...)}
setevent <<Adjust>> <2>
## Menu {Menu Button (popup associated popup menu)}
setevent <<Menu>> <3>

## ---- Edit ----
## Cut {Cut key}
setevent <<Cut>> <Alt-x>
## Copy {Copy key}
setevent <<Copy>> <Alt-c>
## Paste {Paste key}
setevent <<Paste>> <Alt-v>
## Undo {Undo key}
setevent <<Undo>> <Alt-u>
## Redo {Redo key}
setevent <<Redo>> <Alt-U>
## Insert {Insert key}
setevent <<Insert>> <Insert>
## Empty {Empty key}
setevent <<Empty>> <Control-u>
## Delete {Delete key}
setevent <<Delete>> <Delete>
## BackSpace {BackSpace key}
setevent <<BackSpace>> <BackSpace>

## ---- Select ----
## SelectAll {SelectAll key}
setevent <<SelectAll>> <Alt-a>
## SelectNone {SelectNone key}
setevent <<SelectNone>> <Alt-z>
## StartSelect {StartSelect key}
setevent <<StartSelect>> <Control-space>
## EndSelect {EndSelect key}
setevent <<EndSelect>> <Control-Alt-space>

## ---- File ----
## Load {Load key}
setevent <<Load>> <Alt-o>
## LoadNext {LoadNext key}
setevent <<LoadNext>> <Control-Alt-o>
## Save {Save key}
setevent <<Save>> <Alt-s>
## SaveAs {SaveAs key}
setevent <<SaveAs>> <Alt-S>
## Quit {Quit key}
setevent <<Quit>> <Alt-q>
## Reopen {Reopen key}
setevent <<Reopen>> <Alt-r>
## Macro {Macro key}
setevent <<Macro>> <Alt-m>

## ---- Find ----
## Goto {Goto key}
setevent <<Goto>> <Alt-j>
## Find {Find key}
setevent <<Find>> <Alt-F>
## FindNext {FindNext key}
setevent <<FindNext>> <Alt-f>
## FindPrev {FindPrev key}
setevent <<FindPrev>> <Alt-b>
## ReplaceFindNext {ReplaceFindNext key}
setevent <<ReplaceFindNext>> <Alt-g>
## FindFunction {FindFunction key}
setevent <<FindFunction>> <Control-Alt-f>

## ---- Misc ----
## Help {Help key}
setevent <<Help>> <F1>
## Format {Format key}
setevent <<Format>> <Control-Alt-j>
## Print {Print key}
setevent <<Print>> <Control-p>
## Escape {Escape key}
setevent <<Escape>> <Escape>
## KeyMenu {KeyMenu key}
setevent <<KeyMenu>> <Alt-m>
## Default {Default key}
setevent <<Default>> <Alt-d>
## Complete {Complete key}
setevent <<Complete>> <Control-Tab>
## Complete {Complete file key}
#setevent <<CompleteFile>> <Control-Shift-f>
## Complete {Complete key}
#setevent <<CompleteTab>> <Control-Shift-v>
## FocusNext {FocusNext key}
setevent <<FocusNext>> <Tab>
## FocusPrev {FocusPrev key}
setevent <<FocusPrev>> <Shift-Tab>
## MarkerSet {MarkerSet key}
setevent <<MarkerSet>> <Alt-w>
## MarkerSelect {MarkerSelect key}
setevent <<MarkerSelect>> <Alt-Shift-w>
## MarkerCurrent {MarkerCurrent key}
setevent <<MarkerCurrent>> <Control-w>
## MarkerPrev {MarkerPrev key}
setevent <<MarkerPrev>> <Control-Shift-w>
## IndentIn {IndentIn key}
setevent <<IndentIn>> <Alt-i>
## IndentOut {IndentOut key}
setevent <<IndentOut>> <Alt-I>
## Connect {Connect key}
setevent <<Connect>> <Control-C>
## Execute {Execute key}
setevent <<Execute>> <Alt-e>
## HistoryUp {HistoryUp key}
setevent <<HistoryUp>> <Alt-Up>
## HistoryDown {HistoryDown key}
setevent <<HistoryDown>> <Alt-Down>

## ---- Movement ----
## Up {Up key}
setevent <<Up>> <Up>
## Down {Down key}
setevent <<Down>> <Down>
## Left {Left key}
setevent <<Left>> <Left>
## Right {Right key}
setevent <<Right>> <Right>
## Home {Home key}
setevent <<Home>> <Home> <Alt-Left>
## End {End key}
setevent <<End>> <End> <Alt-Right>
## Top {Top key}
setevent <<Top>> <Control-Home>
## Bottom {Bottom key}
setevent <<Bottom>> <Control-End>
## PageTop {PageTop key}
setevent <<PageTop>> <Alt-Up>
## PageBottom {PageBottom key}
setevent <<PageBottom>> <Alt-Down>
## PageUp {PageUp key}
setevent <<PageUp>> <Prior>
## PageDown {PageDown key}
setevent <<PageDown>> <Next>
## WordLeft {WordLeft key}
setevent <<WordLeft>> <Control-Left>
## WordRight {WordRight key}
setevent <<WordRight>> <Control-Right>
## ParaUp {ParaUp key}
setevent <<ParaUp>> <Control-Up>
## ParaDown {ParaDown key}
setevent <<ParaDown>> <Control-Down>

## ---- Movement with selection ----
## SelectUp {SelectUp key}
setevent <<SelectUp>> <Shift-Up>
## SelectDown {SelectDown key}
setevent <<SelectDown>> <Shift-Down>
## SelectLeft {SelectLeft key}
setevent <<SelectLeft>> <Shift-Left>
## SelectRight {SelectRight key}
setevent <<SelectRight>> <Shift-Right>
## SelectHome {SelectHome key}
setevent <<SelectHome>> <Shift-Home> <Shift-Alt-Left>
## SelectEnd {SelectEnd key}
setevent <<SelectEnd>> <Shift-End> <Shift-Alt-Right>
## SelectTop {SelectTop key}
setevent <<SelectTop>> <Shift-Control-Home>
## SelectBottom {SelectBottom key}
setevent <<SelectBottom>> <Shift-Control-End>
## SelectPageTop {SelectPageTop key}
setevent <<SelectPageTop>> <Shift-Alt-Up>
## SelectPageBottom {SelectPageBottom key}
setevent <<SelectPageBottom>> <Shift-Alt-Down>
## SelectPageUp {SelectPageUp key}
setevent <<SelectPageUp>> <Shift-Prior>
## SelectPageDown {SelectPageDown key}
setevent <<SelectPageDown>> <Shift-Next>
## SelectWordLeft {SelectWordLeft key}
setevent <<SelectWordLeft>> <Shift-Control-Left>
## SelectWordRight {SelectWordRight key}
setevent <<SelectWordRight>> <Shift-Control-Right>
## SelectParaUp {SelectParaUp key}
setevent <<SelectParaUp>> <Shift-Control-Up>
## SelectParaDown {SelectParaDown key}
setevent <<SelectParaDown>> <Shift-Control-Down>

## ---- Scroll ----
## ScrollPageUp {ScrollPageUp key}
setevent <<ScrollPageUp>> <Control-Prior> <Control-Alt-Up>
## ScrollPageDown {ScrollPageDown key}
setevent <<ScrollPageDown>> <Control-Next> <Control-Alt-Down>
