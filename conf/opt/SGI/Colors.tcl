#ClassyTcl color configuration file

Classy::configcolor {Basic colors} {
	Background *Background lightgray {Default background color}
	{Dark backgound} *darkBackground gray {Default dark background color}
	{Light backgound} *lightBackground #dfdfdf {Default dark background color}
	Foreground *Foreground black {Default foreground color}
	{Active background} *activeBackground gray {Default active background color}
	{Active foreground} *activeForeground black {Default active foreground color}
	{Disabled foreground} *disabledForeground gray55 {Default Disabled foreground color}
	{Selection background} *selectBackground lightblue {Default Selection background color}
	{Selection foreground} *selectForeground black {Default Selection foreground color}
	{Select color} *selectColor yellow {Default Select color}
	{Highlight background} *highlightBackground Background {Default Highlight background color}
	{Highlight color} *highlightColor black {Default Highlight color}
	Colorlist *ColorList {{blue cyan green yellow orange red magenta}
{blue3 cyan3 green3 yellow3 orange3 red3 magenta3}
{black gray20 gray40 gray50 gray60 gray80 white}} {list of colors as used the getcolor}
}

Classy::configcolor {Widget Colors} {
	{Entry background} *Entry.background rosybrown {Entry background color}
	{Text background} *Text.background rosybrown {Text background color}
	{Listbox background} *Listbox.background lightBackground {Listbox background color}
	{Scale foreground} *Scale.foreground black {Scale foreground color}
	{Scale active foreground} *Scale.activeForeground Background {Scale active foreground color}
	{Scale background} *Scale.background Background {Scale background color}
	{Scale slider foreground} *Scale.sliderForeground Background {Scale slider foreground color}
	{Scale slider background} *Scale.sliderBackground lightBackground {Scale slider background color}
	{Scrollbar foreground} *Scrollbar.foreground Background {Scrollbar foreground color}
	{Scrollbar active foreground} *Scrollbar.activeForeground Background {Scrollbar active foreground color}
	{Scrollbar background} *Scrollbar.background lightBackground {Scrollbar background color}
	{Label background} *label.background darkBackground {Label background color}
}

