#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
catch {destroy .classy__.error}
set object .builder
catch {Classy::Builder destroy}
Classy::Builder .builder
