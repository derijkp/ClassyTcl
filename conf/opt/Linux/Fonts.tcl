## ---- Basic Fonts ----
## Font {basic font} font
option add *Font {helvetica 10} widgetDefault
## BoldFont {basic bold font class} font
option add *BoldFont {helvetica 10 bold} widgetDefault
## ItalicFont {basic italic font class} font
option add *ItalicFont {helvetica 10 italic} widgetDefault
## BoldItalicFont {basic bold-italic font class} font
option add *BoldItalicFont {helvetica 10 bold italic} widgetDefault
## NonPropFont {basic non-proportional font class} font
option add *NonPropFont {courier 10} widgetDefault

## ---- Widget Fonts ----
## {Button Font} {font used on buttons} font
option add *Button.font [option get . Font Font] widgetDefault
## {Menu Font} {font used in menus} font
option add *Menu.font [option get . BoldItalicFont BoldItalicFont] widgetDefault
## {Menubutton font} {font used in menu buttons} font
option add *Menubutton.font [option get . BoldItalicFont BoldItalicFont] widgetDefault
## {Scale Font} {font used in scales} font
option add *Scale.font [option get . BoldItalicFont BoldItalicFont] widgetDefault
## {Text font} {font used in text widgets} font
option add *Text.font [option get . NonPropFont NonPropFont] widgetDefault

