Summary:	Object system for Tcl
Name:		classytcl
Version:	0.4.1
Release:	1
Copyright:	BSD
Group:	Development/Languages/Tcl
Source:	ClassyTcl-0.4.1.src.tar.gz
URL: http://rrna.uia.ac.be/classytcl
Packager: Peter De Rijk <derijkp@uia.ua.ac.be>
Requires: tcl >= 8.0.4 extral >= 1.1.19
Prefix: /usr/lib /usr/bin
%description
ClassyTcl is a dynamically loadable object system for Tcl. A 
Tcl-only as well as a C implementation 
is available. It also doesn't require patches to the Tcl core, so
keeping up with new releases should be easy. Performance is very
adequate. The C version is gives extra speed, and makes it possible
to implement some methods in C.

In contrast to other Tcl object systems for Tcl, it is not modeled after 
the object system designed for a completely different language such a C. 
IMHO, it better follows the Tcl philosophy. The system is simple, but 
flexible. Classes and objects are dynamic, and can easily be queried, 
changed and debugged at runtime.

%prep
%setup -n ClassyTcl
%build
cd build
./configure --prefix=/usr --disable-stubs
make

%install
cd build
make install
rm -rf /usr/doc/classytcl-$RPM_PACKAGE_VERSION
mkdir /usr/doc/classytcl-$RPM_PACKAGE_VERSION
ln -s /usr/lib/Class0.4/help /usr/doc/classytcl-$RPM_PACKAGE_VERSION/help
ln -s /usr/lib/Class0.4/README /usr/doc/classytcl-$RPM_PACKAGE_VERSION/README

%files
/usr/lib/libClass0.4.so
/usr/lib/Class0.4
/usr/doc/classytcl-0.4.1
