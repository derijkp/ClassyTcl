## ---- Edit ----
## Cut {Cut key} key
setevent <<Cut>> <Alt-x>
## Copy {Copy key} key
setevent <<Copy>> <Alt-c>
## Paste {Paste key} key
setevent <<Paste>> <Alt-v>
## Undo {Undo key} key
setevent <<Undo>> <Alt-u>
## Redo {Redo key} key
setevent <<Redo>> <Alt-U>
## Insert {Insert key} key
setevent <<Insert>> <Insert>
## Empty {Empty key} key
setevent <<Empty>> <Control-u>
## Delete {Delete key} key
setevent <<Delete>> <Delete>
## BackSpace {BackSpace key} key
setevent <<BackSpace>> <BackSpace>
## Transpose {Transpose key: switches the letters before and after the cursor} key
setevent <<Transpose>> <Control-t>
## DeleteEnd {Delete from cursor to end} key
setevent <<DeleteEnd>> <Control-k>

## ---- Select ----
## SelectAll {SelectAll key} key
setevent <<SelectAll>> <Alt-a>
## SelectNone {SelectNone key} key
setevent <<SelectNone>> <Alt-z>
## StartSelect {StartSelect key} key
setevent <<StartSelect>> <Control-space>
## EndSelect {EndSelect key} key
setevent <<EndSelect>> <Control-Shift-space>

## ---- File ----
## Load {Load key} key
setevent <<Load>> <Alt-o>
## LoadNext {LoadNext key} key
setevent <<LoadNext>> <Control-Alt-o>
## Save {Save key} key
setevent <<Save>> <Alt-s>
## SaveAs {SaveAs key} key
setevent <<SaveAs>> <Alt-S>
## Quit {Quit key} key
setevent <<Quit>> <Alt-q>
## Reopen {Reopen key} key
setevent <<Reopen>> <Alt-r>
## Macro {Macro key} key
setevent <<Macro>> <Alt-m>

## ---- Find ----
## Goto {Goto key} key
setevent <<Goto>> <Alt-j>
## Find {Find key} key
setevent <<Find>> <Alt-F>
## FindNext {FindNext key} key
setevent <<FindNext>> <Alt-f>
## FindPrev {FindPrev key} key
setevent <<FindPrev>> <Alt-b>
## ReplaceFindNext {ReplaceFindNext key} key
setevent <<ReplaceFindNext>> <Alt-g>
## FindFunction {FindFunction key} key
setevent <<FindFunction>> <Control-Alt-f>

## ---- Control ----
## Escape {Escape key} key
setevent <<Escape>> <Escape>
## Return {Return key} key
setevent <<Return>> <Return>
## Invoke {Invoke key} key
setevent <<Invoke>> <space>
## KeyMenu {KeyMenu key} key
setevent <<KeyMenu>> <Alt-m>
## Default {Default key} key
setevent <<Default>> <Alt-d>
## Complete {Complete key} key
#setevent <<CompleteTab>> <Control-Shift-v>
## FocusNext {FocusNext key} key
setevent <<FocusNext>> <Tab>
## FocusPrev {FocusPrev key} key
setevent <<FocusPrev>> <Shift-Tab>
## TextFocusNext {TextFocusNext key} key
setevent <<TextFocusNext>> <Control-Tab>
## TextFocusPrev {TextFocusPrev key} key
setevent <<TextFocusPrev>> <Shift-Tab>

## ---- Misc ----
## Help {Help key} key
setevent <<Help>> <F1>
## Format {Format key} key
setevent <<Format>> <Control-Alt-j>
## Print {Print key} key
setevent <<Print>> <Control-p>
## MarkerSet {MarkerSet key} key
setevent <<MarkerSet>> <Alt-w>
## MarkerSelect {MarkerSelect key} key
setevent <<MarkerSelect>> <Alt-Shift-w>
## MarkerCurrent {MarkerCurrent key} key
setevent <<MarkerCurrent>> <Control-w>
## MarkerPrev {MarkerPrev key} key
setevent <<MarkerPrev>> <Control-Shift-w>
## IndentIn {IndentIn key} key
setevent <<IndentIn>> <Alt-i>
## IndentOut {IndentOut key} key
setevent <<IndentOut>> <Alt-I>
## Connect {Connect key} key
setevent <<Connect>> <Control-c>
## {Execute command} {Execute command key} key
setevent <<ExecuteCmd>> <Alt-e>
## HistoryUp {HistoryUp key} key
setevent <<HistoryUp>> <Alt-Up>
## HistoryDown {HistoryDown key} key
setevent <<HistoryDown>> <Alt-Down>

## ---- Movement ----
## Up {Up key} key
setevent <<Up>> <Up>
## Down {Down key} key
setevent <<Down>> <Down>
## Left {Left key} key
setevent <<Left>> <Left>
## Right {Right key} key
setevent <<Right>> <Right>
## Home {Home key} key
setevent <<Home>> <Home> <Alt-Left>
## End {End key} key
setevent <<End>> <End> <Alt-Right>
## Top {Top key} key
setevent <<Top>> <Control-Home>
## Bottom {Bottom key} key
setevent <<Bottom>> <Control-End>
## PageTop {PageTop key} key
setevent <<PageTop>> <Alt-Up>
## PageBottom {PageBottom key} key
setevent <<PageBottom>> <Alt-Down>
## PageUp {PageUp key} key
setevent <<PageUp>> <Prior>
## PageDown {PageDown key} key
setevent <<PageDown>> <Next>
## WordLeft {WordLeft key} key
setevent <<WordLeft>> <Control-Left>
## WordRight {WordRight key} key
setevent <<WordRight>> <Control-Right>
## ParaUp {ParaUp key} key
setevent <<ParaUp>> <Control-Up>
## ParaDown {ParaDown key} key
setevent <<ParaDown>> <Control-Down>

## ---- Movement with selection ----
## SelectUp {SelectUp key} key
setevent <<SelectUp>> <Shift-Up>
## SelectDown {SelectDown key} key
setevent <<SelectDown>> <Shift-Down>
## SelectLeft {SelectLeft key} key
setevent <<SelectLeft>> <Shift-Left>
## SelectRight {SelectRight key} key
setevent <<SelectRight>> <Shift-Right>
## SelectHome {SelectHome key} key
setevent <<SelectHome>> <Shift-Home> <Shift-Alt-Left>
## SelectEnd {SelectEnd key} key
setevent <<SelectEnd>> <Shift-End> <Shift-Alt-Right>
## SelectTop {SelectTop key} key
setevent <<SelectTop>> <Shift-Control-Home>
## SelectBottom {SelectBottom key} key
setevent <<SelectBottom>> <Shift-Control-End>
## SelectPageTop {SelectPageTop key} key
setevent <<SelectPageTop>> <Shift-Alt-Up>
## SelectPageBottom {SelectPageBottom key} key
setevent <<SelectPageBottom>> <Shift-Alt-Down>
## SelectPageUp {SelectPageUp key} key
setevent <<SelectPageUp>> <Shift-Prior>
## SelectPageDown {SelectPageDown key} key
setevent <<SelectPageDown>> <Shift-Next>
## SelectWordLeft {SelectWordLeft key} key
setevent <<SelectWordLeft>> <Shift-Control-Left>
## SelectWordRight {SelectWordRight key} key
setevent <<SelectWordRight>> <Shift-Control-Right>
## SelectParaUp {SelectParaUp key} key
setevent <<SelectParaUp>> <Shift-Control-Up>
## SelectParaDown {SelectParaDown key} key
setevent <<SelectParaDown>> <Shift-Control-Down>

## ---- Scroll ----
## ScrollPageUp {ScrollPageUp key} key
setevent <<ScrollPageUp>> <Control-Prior> <Control-Alt-Up>
## ScrollPageDown {ScrollPageDown key} key
setevent <<ScrollPageDown>> <Control-Next> <Control-Alt-Down>

