## ---- Basic Font definitions ----
## Default {defintition for default font}
option add *DefaultFont {helvetica 10} widgetDefault
## {Default bold} {defintition for default bold font}
option add *DefaultBoldFont {helvetica 10 bold} widgetDefault
## {Default italic} {defintition for default italic font}
option add *DefaultItalicFont {helvetica 10 italic} widgetDefault
## {Default bold-italic} {defintition for default bold-italic font}
option add *DefaultBoldItalicFont {helvetica 10 bold italic} widgetDefault
## {Default non proportional} {defintition for default non proportional font}
option add *DefaultNonpropFont {courier 10} widgetDefault

## ---- Basic Fonts ----
## Font {basic font class}
option add *Font DefaultFont widgetDefault
## font {basic font}
option add *font DefaultFont widgetDefault
## BoldFont {basic bold font class}
option add *BoldFont DefaultBoldFont widgetDefault
## ItalicFont {basic italic font class}
option add *ItalicFont DefaultItalicFont widgetDefault
## BoldItalicFont {basic bold-italic font class}
option add *BoldItalicFont DefaultBoldItalicFont widgetDefault
## NonPropFont {basic non-proportional font class}
option add *NonPropFont DefaultNonpropFont widgetDefault

## ---- Widget Fonts ----
## {Button Font} {font used on buttons}
option add *Button.font DefaultFont widgetDefault
## {Menu Font} {font used in menus}
option add *Menu.font DefaultBoldItalicFont widgetDefault
## {Menubutton font} {font used in menu buttons}
option add *Menubutton.font DefaultBoldItalicFont widgetDefault
## {Scale Font} {font used in scales}
option add *Scale.font DefaultBoldItalicFont widgetDefault
## {Text font} {font used in text widgets}
option add *Text.font DefaultNonpropFont widgetDefault

