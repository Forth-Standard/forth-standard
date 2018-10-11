@echo off
set latex=pdflatex
set forth=D:\SwiftForth\SwiftForth\bin\sf
set zip="C:\Program Files\7-Zip\7z" a -tzip -i@include.txt

if x%1 == xone   goto single
if x%1 == xdvi   goto dvi
if x%1 == xps    goto ps
if x%1 == xpdf   goto process
if x%1 == xclean goto clean
if x%1 == xzip   goto zip

rem Usage
echo "Usage: make [ dvi | ps | pdf | clean ]"
goto end

:single
%latex% forth
goto end

:dvi
set latex=latex
goto process

:process
title 1/5: Extract support files
%latex% forth

rem Sort Index of words
if not exist %forth%.exe goto NoSort
%forth% SortIndex.fs

:NoSort
title 2/5: Create Labels
%latex% forth
title 3/5: Resove Labels
%latex% forth

title 4/5: Create Change Bar
%latex% forth
title 5/5: Set Change Bar
%latex% -synctex=1 forth

if not x%1 == xps goto end

:ps
if not exist forth.dvi goto dvi

dvips -K -t A4 forth
goto end

:zip
if exist forth.zip del forth.zip
%zip% forth.zip
goto end

:clean
rem Clean LaTeX and PDFLaTeX files
rem forth.log			LaTeX log file
rem forth.out			PDFLaTeX Bookmarks
rem forth.toc			Table of Contents
rem forth.wrd			Words (definition order)
rem forth.wds			Words (alphabetical order)
rem forth.cb			Change bar data
rem forth.cb2			Change bar data
rem forth.synctex.gz	SyncTex sync data

rem *.aux	LaTeX auxiliary files
rem *.sub	Auto generated support files

for %%x in (log out toc wrd wds cb cb2 synctex.gz) do if exist forth.%%x del forth.%%x
for %%x in (aux sub) do del *.%%x

rem Keep the following:
rem forth.pdf	PDF Final output
rem forth.ps	PostScript Final output
rem forth.dvi	LaTeX DVI output

goto end

:end
title Command prompt
