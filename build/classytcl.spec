Summary:	Object system, widget set and GUI builder for Tcl
Name:		classytcl
Version:	0.3.12
Release:	1
Copyright:	BSD
Group:	Development/Languages/Tcl
Source:	ClassyTcl-0.3.12.src.tar.gz
URL: http://rrna.uia.ac.be/classytcl
Packager: Peter De Rijk <derijkp@uia.ua.ac.be>
Requires: tcl >= 8.0.4 extral >= 1.1.10
Prefix: /usr/lib /usr/bin
%description
Object system

The first component of ClassyTcl is an object system for Tcl, which has both
a Tcl and a C version available. It doesn't require patches to the Tcl core,
wich makes keeping up with new releases easier. Performance is very
adequate. The C version is gives extra speed, and makes it possible to
implement some methods in C.

Gui Builder

The ClassyTcl Builder can be used to graphically create interfaces. It is
invoked via the cbuild command in the bin directory.

Widget Set
ClassyTcl adds a lot of improvements to Tk, ranging from drag and drop
support (between Tk apps) and a configuration system to a large set of new
widgets and commands, written using the object system. (see further)
While the object system itself only requires Tcl (>8.0), the widgets that
come with it require Tk (of course), and another freely available extension
called ExtraL. ExtraL also does not require compiled code, but can be
speeded up by having it available. Documentation for the widgets is often
somewhat limited, but besides the documentation, you can learn a lot from
sources, the tests and the demos.

%prep
%setup -n ClassyTcl
%build
cd src
./configure --prefix=/usr
make

%install
rm -rf /usr/lib/ClassyTcl-Linux-$RPM_PACKAGE_VERSION/ /usr/doc/classytcl-$RPM_PACKAGE_VERSION
cd src
make install
mkdir /usr/doc/classytcl-$RPM_PACKAGE_VERSION
ln -s /usr/lib/ClassyTcl-Linux-$RPM_PACKAGE_VERSION/help /usr/doc/classytcl-$RPM_PACKAGE_VERSION/help

%files
%doc README
/usr/lib/ClassyTcl-Linux-0.3.12
/usr/bin/cbuild
/usr/bin/convert0.1_to_0.2
/usr/bin/ccalc
/usr/bin/ccenter
/usr/bin/cdraw
/usr/bin/cedit
/usr/bin/cfiles
/usr/bin/ctester
