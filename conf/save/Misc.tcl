## ---- Misc settings ----
## {patch Tk} {patch Tk to to use virtual events. This will be only be really activated after a restart of the program (0/1)} {select 0 1}
Classy::setoption *PatchTk 1
## Menutype {Menutype: can be popup or top} {select popup top}
Classy::setoption *MenuType top
## {Scrollbar position} {Scrollbar position (left/right)} {select left right}
Classy::setoption *ScrollSide right

## ---- Dialogs ----
## {Color select} {type of color selection dialog (Tk/Peos)} {select Peos Tk}
Classy::setoption *GetColor Peos
## {Select File} {type of Select File dialog used when running Windows (Win/Peos)} {select Win Peos}
#Classy::setoption *SelectFile Win
## {Save File} {type of Save File dialog used when running Windows (Win/Peos)} {select Win Peos}
#Classy::setoption *SaveFile Win
## {Font select} {type of font selection dialog when running Windows (Win/Peos)} {select Win Peos}
#Classy::setoption *GetFont Win

## ---- Relief and borders ----
## {Border width} {Default Border width color}
Classy::setoption *borderWidth 1
## {Menu border width} {Default Menu border width color}
#Classy::setoption *Menu.BorderWidth 1
## {Scrollbar width} {Default Scrollbar width color}
Classy::setoption *Scrollbar.width 10
## {Highlight thickness} {Default Highlight thickness color}
Classy::setoption *HighlightThickness 1
## {Frame highlight thickness} {Default Frame highlight thickness color}
Classy::setoption *Frame.HighlightThickness 0
## {Toplevel highlight thickness} {Default Toplevel highlight thickness color}
Classy::setoption *Toplevel.HighlightThickness 0
## {Button padx} {Default Button padx color}
Classy::setoption *Button.padX 1
## {Button pady} {Default Button pady color}
Classy::setoption *Button.padY 1
## {Menu button padx} {Default Menu button padx color}
Classy::setoption *MenuButton.padX 1
## {Menu button pady} {Default Menu button pady color}
Classy::setoption *MenuButton.padY 1
## {Checkbutton anchor} {Default Checkbutton anchor color}
Classy::setoption *Checkbutton.anchor w
## {Option box border width} {Default Option box border width color}
Classy::setoption *Peos__OptionBox.BorderWidth 2
## {Option box relief} {Default Option box relief color}
Classy::setoption *Peos__OptionBox.Relief groove
