How to Structure a LaTeX Document -- from https://en.wikibooks.org/wiki/LaTeX/simple.tex
===========
     In this article, I shall discuss some of the fundamental topics inproducing a structured document.  This document itself does not go intomuch depth, but is instead the output of an example of how to implementstructure. Its {} source, when in used with [http://www.comp.leeds.ac.uk/andyr/misc/latex/latextutorial2.html](my tutorial)provides all the relevant information.  Introduction
-----------
This small document is designed to illustrate how easy it is to create awell structured document within .  You should quickly be able tosee how the article looks very professional, despite the content beingfar from academic.  Titles, section headings, justified text, textformatting etc., is all there, and you would be surprised when you seejust how little markup was required to get this output.Structure
-----------
One of the great advantages of {} is that all it needs to know isthe structure of a document, and then it will take care of the layoutand presentation itself.  So, here we shall begin looking at how exactlyyou tell {} what it needs to know about your document.\subsection{Top Matter}The first thing you normally have is a title of the document, as well asinformation about the author and date of publication.  In {} terms,this is all generally referred to as _top matter_.\subsubsection{Article Information}
	- `title` _title_ - The title of the article.
	- `date` - The date. Use:
	
		- `date today` - to get the
		date that the document is typeset.
		- `date date` - for a  
		specific date.
		
		
	\subsubsection{Author Information}The basic article class only provides the one command:
	- `author` - The author of the document.
	It is common to not only include the author name, but to insert newlines after and add things suchas address and email details.  For a slightly more logical approach, usethe AMS article class (`amsart`) and you have the following extracommands:
	- `address` - The author's address.  Use
	the new line command for
	line breaks.
	- `thanks` - Where you put any acknowledgments.
	- `email` - The author's email address.
	- `urladdr` - The URL for the author's web page.
	\subsection{Sectioning Commands}The commands for inserting sections are fairly intuitive.  Of course,certain commands are appropriate to different document classes.For example, a book has chapters but a article doesn't.\begin{center}\begin{tabular}{| l | l |} \hline  Command & Level \\ \hline                                     `part` _part_ & -1 \\`chapter` _chapter_ & 0 \\`section` _section_ & 1 \\`subsection` _subsection_ & 2 \\\hline\end{tabular}\end{center}Numbering of the sections is performed automatically by {}, so don'tbother adding them explicitly, just insert the heading you want betweenthe curly braces.  If you don't want sections number, then add an asterisk (*) after thesection command, but before the first curly brace, e.g., _A Title Without Numbers_.
> Leslie LamportLaTeX: A Document Preparation System.  Addison Wesley, Massachusetts,  2nd Edition,  1994.
   