#ClassyTcl misc configuration file

Classy::configmisc {Misc settings} {
	{patch Tk} *PatchTk 1 {select 0 1} {patch Tk to to use virtual events. This will be only be really activated after a restart of the program (0/1)}
	Menutype *MenuType top {select popup top} {Menutype: can be popup or top}
	{Scrollbar position} *ScrollSide right {select left right} {Scrollbar position (left/right)}
}

Classy::configmisc Dialogs {
	{Color select} *GetColor Peos {select Peos Tk} {type of color selection dialog (Tk/Peos)}
	{Select File} *SelectFile Win {select Win Peos} {type of Select File dialog used when running Windows (Win/Peos)}
	{#Save File} *SaveFile Win {select Win Peos} {type of Save File dialog used when running Windows (Win/Peos)}
	{#Font select} *GetFont Win {select Win Peos} {type of font selection dialog when running Windows (Win/Peos)}
}

Classy::configmisc {Relief and borders} {
	{Border width} *borderWidth 1 int {Default Border width color}
	{#Menu border width} *Menu.BorderWidth 1 int {Default Menu border width color}
	{Scrollbar width} *Scrollbar.width 10 int {Default Scrollbar width color}
	{Highlight thickness} *HighlightThickness 1 int {Default Highlight thickness color}
	{Frame highlight thickness} *Frame.HighlightThickness 0 int {Default Frame highlight thickness color}
	{Toplevel highlight thickness} *Toplevel.HighlightThickness 0 int {Default Toplevel highlight thickness color}
	{Button padx} *Button.padX 1 int {Default Button padx color}
	{Button pady} *Button.padY 1 int {Default Button pady color}
	{Menu button padx} *MenuButton.padX 1 int {Default Menu button padx color}
	{Menu button pady} *MenuButton.padY 1 int {Default Menu button pady color}
	{Checkbutton anchor} *Checkbutton.anchor w {select n ne e se s sw w nw center} {Default Checkbutton anchor color}
	{Option box border width} *Peos__OptionBox.BorderWidth 2 int {Default Option box border width color}
	{Option box relief} *Peos__OptionBox.Relief groove {select raised sunken flat ridge solid groove} {Default Option box relief color}
}

