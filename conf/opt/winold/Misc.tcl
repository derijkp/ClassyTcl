## ---- Misc settings ----
## {patch Tk} {patch Tk to to use virtual events. (0/1)} {select 0 1}
option add *Patchtk 1 widgetDefault
## Menutype {Menutype: can be popup or top} {select popup top}
option add *MenuType top widgetDefault
## {Scrollbar position} {Scrollbar position (left/right)} {select left right}
option add *ScrollSide right widgetDefault
## Toolbars {Do you want toolbars} {select 0 1}
option add *ToolBar 1 widgetDefault

## ---- Dialogs ----
## {Color select} {type of color selection dialog (Tk/Peos)} {select Peos Tk}
option add *GetColor Peos widgetDefault
## {Select File} {type of Select File dialog used when running Windows (Win/Peos)} {select Win Peos}
option add *SelectFile Win widgetDefault
## {Save File} {type of Save File dialog used when running Windows (Win/Peos)} {select Win Peos}
option add *SaveFile Win widgetDefault
## {Font select} {type of font selection dialog when running Windows (Win/Peos)} {select Win Peos}
option add *GetFont Win widgetDefault

## ---- Relief and borders ----
## {Border width} {Default Border width color}
#option add *borderWidth 1 widgetDefault
## {Menu border width} {Default Menu border width color}
##option add *Menu.BorderWidth 1 widgetDefault
## {Scrollbar width} {Default Scrollbar width color}
#option add *Scrollbar.width 10 widgetDefault
## {Highlight thickness} {Default Highlight thickness color}
#option add *HighlightThickness 1 widgetDefault
## {Frame highlight thickness} {Default Frame highlight thickness color}
#option add *Frame.HighlightThickness 0 widgetDefault
## {Toplevel highlight thickness} {Default Toplevel highlight thickness color}
#option add *Toplevel.HighlightThickness 0 widgetDefault
## {Button padx} {Default Button padx color}
#option add *Button.padX 1 widgetDefault
## {Button pady} {Default Button pady color}
#option add *Button.padY 1 widgetDefault
## {Menu button padx} {Default Menu button padx color}
#option add *MenuButton.padX 1 widgetDefault
## {Menu button pady} {Default Menu button pady color}
#option add *MenuButton.padY 1 widgetDefault
## {Checkbutton anchor} {Default Checkbutton anchor color}
#option add *Checkbutton.anchor w widgetDefault
## {Option box border width} {Default Option box border width color}
#option add *Peos__OptionBox.BorderWidth 2 widgetDefault
## {Option box relief} {Default Option box relief color}
#option add *Peos__OptionBox.Relief groove widgetDefault
