rem @echo off

if x%1 == x	 goto single
if x%1 == xdvi   goto dvi
if x%1 == xps    goto ps
if x%1 == xpdf   goto pdf
if x%1 == xclean goto clean
if x%1 == xhtml  goto html

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
rem Generate the labels
%latex% forth

rem Generate the alphabetical list of words
perl sort.pl < forth.wrd > forth.wds

rem Get the labels correct
%latex% forth

rem Get the change-bars correct
%latex% forth

if not x%1 == xps goto end

:ps
if not exist forth.dvi goto dvi

dvips -K -t A4 forth
goto end

:html
latex \makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode %2.a.b.c.\input forth
perl sort.pl < forth.wrd > forth.wds
latex \makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode %2.a.b.c.\input forth
latex \makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode %2.a.b.c.\input forth

rem Extract fonts
htcmd -slash c:\MiKTeX\miktex\bin\tex4ht forth -ic:\MiKTeX\tex4ht\texmf\tex4ht\ht-fonts\ -ec:\MiKTeX\tex4ht\texmf\tex4ht\base\win32\tex4ht.env 

rem Make images for missing characters
htcmd -slash c:\MiKTeX\miktex\bin\t4ht forth -ec:\MiKTeX\tex4ht\texmf\tex4ht\base\win32\tex4ht.env  

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
