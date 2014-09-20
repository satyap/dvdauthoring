The files in this tarball are for experts only!
Edit vid2dvd.pl and menubuttons.pl to set the location of these files, and to
set the font you want to use. Edit the Makefile in the menu-example directory
to point at the real location of menumakefile


Files:

make-dvd-xml.sh: Script that drives the whole thing.

menubuttons.pl: Library script to make menu button XML. Don't run this
directly.

menumakefile: Makefile library. Call from your makefile.

menuMask.pl: Creates the menu's highlight and select images. Called from
vid2dvd and menubuttons.

menu-example/: Sample menu directory for manually creating menus. See the
Makefile.

README.txt: This file

subslib.sh: Subroutine library in shell.

vid2dvd.pl: The main script to take a desc.txt file and produce menus and XML.


desc.txt is a file containing 2 lines per video. You should convert the videos
to DVD format  before running vid2dvd.pl, which does most of the work. You may
have to change some of the paths in some of the scripts.

desc.txt 2-line format example:
2006.08.04_10-13-36 This is a title
2006.08.04_10-13-36.dv

"20060804 This is a title" will be a menu item and the video will have a
subtitle added to it consisting of the date, time, and title.

2006.08.04_10-13-36.dv is a sample file name, of course. Convert that to a DVD
format with:
tovid -in 2006.08.04_10-13-36.dv -out 2006.08.04_10-13-36.dv -ntsc -dvd

(or -pal instead of -ntsc. Yes, this produces a file called
2006.08.04_10-13-36.dv.mpg)

The vid2dvd.pl script produces a shell script which you can run to do all the
conversions. The shell script will produce your menu as well as chunks of XML
suitable for use in makedvd's XML file (see dvdstruct.xml).

