#ClassyTcl font configuration file

Classy::configfont {Basic Fonts} {
	Font *Font {helvetica 10} {basic font}
	BoldFont *BoldFont {helvetica 10 bold} {basic bold font class}
	ItalicFont *ItalicFont {helvetica 10 italic} {basic italic font class}
	BoldItalicFont *BoldItalicFont {helvetica 10 bold italic} {basic bold-italic font class}
	NonPropFont *NonPropFont {courier 10} {basic non-proportional font class}
}

Classy::configfont {Widget Fonts} {
	{#Button Font} *Button.font Font {font used on buttons}
	{#Menu Font} *Menu.font BoldItalicFont {font used in menus}
	{#Menubutton font} *Menubutton.font BoldItalicFont {font used in menu buttons}
	{#Scale Font} *Scale.font BoldItalicFont {font used in scales}
	{#Text font} *Text.font NonPropFont {font used in text widgets}
	{#Tree font} *treeFont Font {default font used for text in a tree}
	{#Browser font} *Classy::Browser.font BoldFont {font used for names in the browser widget}
	{#Browser data font} *Classy::Browser.dataFont Font {font used for data in the browser widget}
	{#LargeBrowser font} *Classy::LargeBrowser.font BoldFont {font used for names in the browser widget}
	{#LargeBrowser data font} *Classy::LargeBrowser.dataFont Font {font used for data in the browser widget}
}
