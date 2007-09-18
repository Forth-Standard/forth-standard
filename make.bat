rem @echo off

if x%1 == xone	 goto single
if x%1 == xdvi   goto dvi
if x%1 == xps    goto ps
if x%1 == xpdf   goto pdf
if x%1 == xclean goto clean
if x%1 == xhtml  goto dvi

rem Usage
echo "Usage: make [ dvi | ps | pdf | clean ]"

:single
latex forth
goto end

:dvi
set latex=latex
goto process

:pdf
set latex=pdflatex
goto process

:process
rem Get the word list (index)
%latex% forth
perl sort.pl < forth.wrd > forth.wds

if x%1 == xhtml goto html

rem Get the labels
%latex% forth
%latex% forth

rem Get the change bars
%latex% forth
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

:clean
rem Clean LaTeX and PDFLaTeX files
rem forth.log	LaTeX log file
rem forth.out	PDFLaTeX Bookmarks
rem forth.toc	Table of Contents
rem *.wrd	Words (unordered)
rem *.wds	Words (sorted)
rem *.aux	LaTeX auxiliary files
rem *.rat	Rationale text
rem *.undo	LEd backup files
rem *.cb*	Change Bars

for %%x in (log out toc) do if exist forth.%%x del forth.%%x
for %%x in (wrd wds aux rat undo) do del *.%%x
del *.cb*

rem Keep the following:
rem forth.pdf	PDF Final output
rem forth.ps	PostScript Final output
rem forth.dvi	LaTeX DVI output

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
