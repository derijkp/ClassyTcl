#ClassyTcl misc configuration file

Classy::configmisc {Misc settings} {
	{patch Tk} *PatchTk 1 bool {patch Tk to use virtual events. This will be only be really activated after a restart of the program (0/1)}
	{bgerror} *Bgerror Classy {select Classy Tk} {patch Tk to use a different bgerror routine. This will be only be really activated after a restart of the program}
	Menutype *MenuType top {select popup top} {Menutype: can be popup or top}
	{Scrollbar position} *ScrollSide right {select left right} {Scrollbar position (left/right)}
}

Classy::configmisc Dialogs {
	{Color select} *GetColor Classy {select Classy Tk} {type of color selection dialog}
	{Select File} *SelectFile Win {select Win Classy} {type of Select File dialog used when running Windows}
	{Save File} *SaveFile Win {select Win Classy} {type of Save File dialog used when running Windows}
	{Font select} *GetFont Win {select Win Classy} {type of font selection dialog when running Windows}
}

Classy::configmisc {Relief and borders} {
	{#Border width} *borderWidth 1 int {Default Border width color}
	{#Menu border width} *Menu.BorderWidth 1 int {Default Menu border width color}
	{Option box border width} *Classy::OptionBox.BorderWidth 1 int {Default Option box border width color}
	{Option box relief} *Classy::OptionBox.Relief groove relief {Default Option box relief color}
	{#Scrollbar width} *Scrollbar.width 10 int {Default Scrollbar width color}
	{#Highlight thickness} *HighlightThickness 1 int {Default Highlight thickness color}
	{#Frame highlight thickness} *Frame.HighlightThickness 0 int {Default Frame highlight thickness color}
	{#Toplevel highlight thickness} *Toplevel.HighlightThickness 0 int {Default Toplevel highlight thickness color}
	{#Button padx} *Button.padX 1 int {Default Button padx color}
	{#Button pady} *Button.padY 1 int {Default Button pady color}
	{#Menu button padx} *MenuButton.padX 1 int {Default Menu button padx color}
	{#Menu button pady} *MenuButton.padY 1 int {Default Menu button pady color}
	{Checkbutton anchor} *Checkbutton.anchor w anchor {Default Checkbutton anchor color}
}

Classy::configmisc Other {
	Papersizes *PaperSizes {
User      "595p 842p"
Letter    "612p 792p"
Tabloid   "792p 1224p"
Ledger    "1224p 792p"
Legal     "612p 1008p"
Statement "396p 612p"
Executive "540p 720p"
A0        "2380p 3368p"
A1        "1684p 2380p"
A2        "1190p 1684p"
A3        "842p 1190p"
A4        "595p 842p"
A5        "420p 595p"
B4        "729p 1032p"
B5        "516p 729p"
Folio     "612p 936p"
Quarto    "610p 780p"} text {possible papersizes}
}
