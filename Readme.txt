ClassyTcl
========= Object system, widget set and GUI builder for Tcl/Tk
        by Peter De Rijk (Universiteit Antwerpen) 

What is ClassyTcl
-----------------
Object system
The first component of ClassyTcl is an object system for Tcl, which 
has both a Tcl and a C version available. It doesn't require patches 
to the Tcl core, making keeping up with new releases easier. Performance 
is very adequate. The C version is gives extra speed, and makes it 
possible to implement some methods in C (usually also for performance reasons).

GUI Builder


Widget set
Included in the distribution is a large set of new widgets, written using
the object system. While the object system itself only requires Tcl (>=8.0),
the widgets that come with it require Tk (of course), and another freely
available extension called ExtraL. ExtraL also does not require compiled code, 
but can be speeded up by having it available. In the widget set you will find:
Tk improvements
 - Classy::Entry : entry with label, constraints, command
 - Classy::NumEntry : numerical entry
 - Classy::FileEntry " Classy::Entry with file browse button
 - Classy::Text : text with undo/redo and linking (~multiple views)
 - Classy::Canvas : Canvas with undo/redo, rotate, save and load, zoom
 - Classy::Toplevel : toplevel that can places itself gracefully, can remember its geometry, 
                      can have a command executed upon destruction
 - Classy::ListBox
 - Classy::Message
 - Classy::RepeatButton
 - Classy::ScrolledFrame
 - Classy::ScrolledText
Common Tools
 - Classy::DragDrop
 - Classy::DynaMenu
 - Classy::DynaTool
 - Classy::Balloon: balloon help
 - Classy::Default
 - Classy::DefaultMenu
 - Classy::Help
 - Classy::Paned
 - Classy::Config
New widgets
 - Classy::Editor
 - Classy::NoteBook
 - Classy::OptionBox
 - Classy::OptionMenu
 - Classy::CmdWidget
 - Classy::Browser: 
 - Classy::Fold
 - Classy::Table
 - Classy::Tree
 - Classy::TreeWidget
 - Classy::WindowBuilder
 - Classy::HTML
 - Classy::ChartGrid
 - Classy::BarChart
 - Classy::LineChart
 - Classy::MultiFrame
 - Classy::MultiListbox
 - Classy::Progress
Dialogs
 - Classy::Dialog : inteligent dialog placing, easy adding of buttons
 - Classy::savefile
 - Classy::selectfile
 - Classy::getcolor
 - Classy::getfont
 - Classy::yorn
 - Classy::InputDialog
 - Classy::SaveDialog
 - Classy::SelectDialog
 - Classy::yornDialog
 - Classy::BarChartDialog
 - Classy::LineChartDialog
 - Classy::ProgressDialog
Selectors
 - Classy::Selector : multi-type selector
 - Classy::FileSelect : class used by selectfile
 - Classy::FontSelect : class used by getfont
 - Classy::ColorSelect : class used in getcolor
 - Classy::ColorEntry
 - Classy::ColorHSV
 - Classy::ColorRGB
 - Classy::ColorSample

Unfortunately documentation is often somewhat limited, but
besides the documentation, you can learn a lot from sources.

Installation
------------
You should be able to obtain the latest versions of ClassyTcl and ExtraL
on our server rrna.uia.ac.be via WWW or anonymous ftp (directory /pub/tcl).
Both Extral and ClassyTcl are implemented as loadable packages. The ClassyTcl
object systen can be used by putting the directories (after unpacking) 
somewhere appropriate and using the command
package require Class
To use the widgets that come with the distribution, use the command
package require ClassyTcl
after naming the application (tk appname ?name?). The application name
will be used for managing defaults and configuration options.

To make the compiled version from the sources:
go to the src directory and type
./configure --with-tcl=<path of tcl distribution>
Then run make. This should produce the loadable module. The build.tcl and
buildwin.tcl files are a tool to make a nice package in a different
directory.

How to contact me
-----------------
I will do my best to reply as fast as I can to any problems, etc.
However, the development of ClassyTcl is only my only task,
which is why my response might not be always as fast as you would
like.

Peter De Rijk
University of Antwerp (UIA)
Department of Biochemistry
Universiteitsplein 1
B-2610 Antwerp

tel.: 32-03-820.23.16
fax: 32-03-820.22.48
E-mail: derijkp@uia.ua.ac.be
web: http://rrna.uia.ac.be/~peter/personal/peter.html

Legalities
----------

ClassyTcl is Copyright Peter De Rijk, University of Antwerp (UIA), 1998. The
following terms apply to all files associated with the software unless
explicitly disclaimed in individual files.

The author hereby grant permission to use, copy, modify, distribute,
and license this software and its documentation for any purpose, provided
that existing copyright notices are retained in all copies and that this
notice is included verbatim in any distributions. No written agreement,
license, or royalty fee is required for any of the authorized uses.
Modifications to this software may be copyrighted by their authors
and need not follow the licensing terms described here, provided that
the new terms are clearly indicated on the first page of each file where
they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.
