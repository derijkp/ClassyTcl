## ---- Basic Font definitions ----
## Default {defintition for default font} font
option add *DefaultFont {helvetica 10} widgetDefault
## {Default bold} {defintition for default bold font} font
option add *DefaultBoldFont {helvetica 10 bold} widgetDefault
## {Default italic} {defintition for default italic font} font
option add *DefaultItalicFont {helvetica 10 italic} widgetDefault
## {Default bold-italic} {defintition for default bold-italic font} font
option add *DefaultBoldItalicFont {helvetica 10 bold italic} widgetDefault
## {Default non proportional} {defintition for default non proportional font} font
option add *DefaultNonpropFont {courier 10} widgetDefault

## ---- Basic Fonts ----
## Font {basic font class} font
option add *Font DefaultFont widgetDefault
## font {basic font} font
option add *font DefaultFont widgetDefault
## BoldFont {basic bold font class} font
option add *BoldFont DefaultBoldFont widgetDefault
## ItalicFont {basic italic font class} font
option add *ItalicFont DefaultItalicFont widgetDefault
## BoldItalicFont {basic bold-italic font class} font
option add *BoldItalicFont DefaultBoldItalicFont widgetDefault
## NonPropFont {basic non-proportional font class} font
option add *NonPropFont DefaultNonpropFont widgetDefault

## ---- Widget Fonts ----
## {Button Font} {font used on buttons} font
option add *Button.font DefaultFont widgetDefault
## {Menu Font} {font used in menus} font
option add *Menu.font DefaultBoldItalicFont widgetDefault
## {Menubutton font} {font used in menu buttons} font
option add *Menubutton.font DefaultBoldItalicFont widgetDefault
## {Scale Font} {font used in scales} font
option add *Scale.font DefaultBoldItalicFont widgetDefault
## {Text font} {font used in text widgets} font
option add *Text.font DefaultNonpropFont widgetDefault
