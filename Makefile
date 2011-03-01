# Default target simply complains

$PDFTEX = pdflatex
$TEX = latex

usage:
	@echo "Usage: make [ dvi | ps | pdf | clean ]"

# Define a few short-cut targets

dvi: forth.dvi
ps: forth.ps
pdf: forth.pdf
html: forth.html

# Now for the actual detail

one:
	$(PDFTEX) forth.tex

forth.wrd: forth.tex *.tex
	$(PDFTEX) forth.tex

forth.wds: forth.wrd
	perl sort.pl < forth.wrd > forth.wds

forth.dvi: forth.wds
	$(TEX) "\scrollmode\input forth.tex"
	$(TEX) forth.tex

	# Now for the change bars
	$(TEX) forth.tex
	$(TEX) forth.tex

	# Stop make from re-building when the ps target is used
	touch forth.wds		# update .wds as .wrd has been updated
	touch forth.dvi		# now we have to update the .dvi

forth.ps: forth.dvi
	dvips -K -t A4 forth

forth.pdf: forth.wds
	$(PDFTEX) "\scrollmode\input forth.tex"
	$(PDFTEX) forth.tex

	# Now for the change bars
	$(PDFTEX) forth.tex
	$(PDFTEX) forth.tex

zip: *.tex clean
	(cd ..; zip -9 -r basis.zip basis -x \*CVS\* -x \*.pdf -x \*.zip)
	mv ../basis.zip basis-`grep \\revision\} forth.tex | cut -c24-27`-`date +%b-%d`.zip

# This is not currently supported in the latex source,
# but at least we get something usable, one day ...

forth.html: forth.wds
	htlatex forth

clean:
	# First we clean the LaTeX files
	rm -f forth.log		# LaTeX Log file
	rm -f forth.toc		# Table of Contents
	rm -f *.aux		# Auxiliary files

	# The package extension support files
	rm -f forth.cb*		# Changebar
	rm -f forth.out		# Hyperref - PDF Bookmarks

	# Document's own support files
	rm -f *.sub		# Auto generated support files
	rm -f forth.wrd		# Word list (unsorted)
	rm -f forth.wds		# Word list (sorted)

	# htlatex (text4ht) support files
	rm -f forth.4ct		# ToC postfix
	rm -f forth.4tc		# ToC prefix
	rm -f forth.idv		# Fonts extract
	rm -f forth.lg		# log file
	rm -f forth.xref	# Cross references
	rm -f forth*.tmp
