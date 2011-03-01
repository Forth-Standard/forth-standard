@echo off
set latex=pdflatex

if x%1 == xone   goto single
if x%1 == xdvi   goto dvi
if x%1 == xps    goto ps
if x%1 == xpdf   goto process
if x%1 == xclean goto clean
if x%1 == xhtml  goto dvi
if x%1 == xzip   goto zip

rem Usage
echo "Usage: make [ dvi | ps | pdf | clean ]"
goto end

:single
%latex% forth
goto end

:dvi
set latex=latex --save-size=10000
goto process

:process
title 1/5: Extract support files
%latex% \scrollmode\input forth.tex
perl sort.pl < forth.wrd > forth.wds

if x%1 == xhtml goto html

title 2/5: Create Labels
%latex% forth
title 3/5: Resove Labels
%latex% forth

title 4/5: Create Change Bar
%latex% forth
title 5/5: Set Change Bar
%latex% forth

if not x%1 == xps goto end

:ps
if not exist forth.dvi goto dvi

dvips -K -t A4 forth
goto end

:html
rem Build the html version
htlatex forth
goto end

:zip
cd ..
zip -9 -r basis.zip basis -x \*CVS\* -x \*.pdf -x \*.zip
goto end

:clean
rem Clean LaTeX and PDFLaTeX files
rem forth.log	LaTeX log file
rem forth.out	PDFLaTeX Bookmarks
rem forth.toc	Table of Contents
rem *.wrd	Words (unordered)
rem *.wds	Words (sorted)
rem *.aux	LaTeX auxiliary files
rem *.sub	Auto generated support files
rem *.undo	LEd backup files
rem *.cb*	Change Bars

for %%x in (log out toc) do if exist forth.%%x del forth.%%x
for %%x in (wrd wds aux sub undo) do del *.%%x
del *.cb*

rem Keep the following:
rem forth.pdf	PDF Final output
rem forth.ps	PostScript Final output
rem forth.dvi	LaTeX DVI output

goto end

rem Clean HTML files
rem forth.4ct	ToC postfix
rem forth.4tc	ToC prefix
rem forth.idv	Fonts extract
rem forth.lg	tex4th log file
rem forth.xref	tex4th Cross references
rem forth*.tmp

for %%x in (4ct 4tc idv lg tmp xref) do if exist forth.%%x del forth.%%x

rem Keep the following:
rem forth*.png	Graphics files
rem *.html	HTML files
rem *.css	HTML Style Sheets

:end
title Command prompt
