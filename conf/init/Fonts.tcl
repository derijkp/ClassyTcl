## ---- Basic Fonts ----
## Font {basic font} font
Classy::setfont *Font {helvetica 10}
## BoldFont {basic bold font class} font
Classy::setfont *BoldFont {helvetica 10 bold}
## ItalicFont {basic italic font class} font
Classy::setfont *ItalicFont {helvetica 10 italic}
## BoldItalicFont {basic bold-italic font class} font
Classy::setfont *BoldItalicFont {helvetica 10 bold italic}
## NonPropFont {basic non-proportional font class} font
Classy::setfont *NonPropFont {courier 10}

## ---- Widget Fonts ----
## {Button Font} {font used on buttons} font
Classy::setfont *Button.font Font
## {Menu Font} {font used in menus} font
Classy::setfont *Menu.font BoldItalicFont
## {Menubutton font} {font used in menu buttons} font
Classy::setfont *Menubutton.font BoldItalicFont
## {Scale Font} {font used in scales} font
Classy::setfont *Scale.font BoldItalicFont
## {Text font} {font used in text widgets} font
Classy::setfont *Text.font NonPropFont
## {Browser font} {font used for names in the browser widget} font
Classy::setfont *Classy::Browser.font BoldFont
## {Browser data font} {font used for data in the browser widget} font
Classy::setfont *Classy::Browser.dataFont Font
