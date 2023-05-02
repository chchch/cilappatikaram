<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../definitions.xsl"/>
<xsl:import href="common.xsl"/>
<xsl:import href="titlepage.xsl"/>
<xsl:import href="preamble.xsl"/>
<xsl:import href="summary.xsl"/>
<xsl:import href="transcription.xsl"/>

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
<xsl:template match="x:TEI">
    <xsl:text>
%\documentclass[14pt]{extarticle}
\documentclass[12pt,a4paper]{scrbook}
\usepackage[cm-default]{fontspec}
\usepackage{csquotes}
\usepackage{url}
\usepackage[shortcuts]{extdash}
\usepackage{pgffor}
\usepackage[unicode=true]{hyperref}
%\usepackage{breakurl}
\usepackage{array}
%\usepackage{graphicx}
\usepackage[export]{adjustbox}
\usepackage{listings}
\renewcommand{\lstlistingname}{\inputencoding{latin0}Listing}

\usepackage{xcolor}

\usepackage{polyglossia,xunicode}
\setdefaultlanguage{english}
\setotherlanguage{tamil}
\setotherlanguage{portuguese}

\usepackage[normalem]{ulem}
%\usepackage[noend,noeledsec,noledgroup]{reledmac}
\renewcommand{\multfootsep}{\,}
\usepackage[margin=1in]{geometry}

\usepackage{footnote}
\makesavenoteenv{tabular}

\usepackage{setspace}
\onehalfspacing

\graphicspath{ {./assets/} {./img/} }

\usepackage{changepage}

\setlength{\parskip}{\medskipamount}
\setlength{\parindent}{0pt}

\setmainlanguage{english}
\setotherlanguage{tamil}
\setmainfont[
    Path = ./fonts/brill-typeface/,
    UprightFont = brill-roman,
    BoldFont = brill-bold,
    ItalicFont = brill-italic,
    BoldItalicFont = brill-bold-italic,
    Extension = .ttf]{Brill}
\newfontfamily{\defaultfont}[
    Path = ./fonts/brill-typeface/,
    UprightFont = brill-roman,
    BoldFont = brill-bold,
    ItalicFont = brill-italic,
    BoldItalicFont = brill-bold-italic,
    Extension = .ttf]{Brill}
\newfontfamily{\tamilfont}[
    Path = ./fonts/,
    UprightFont = ArimaMadurai-Light,
    BoldFont = ArimaMadurai-Medium,
    Extension = .ttf]{ArimaMadurai}

\usepackage[Tamil,Latin]{ucharclasses}
\setDefaultTransitions{\defaultfont}{}
\setTransitionsForLatin{\defaultfont}{}
\setTransitionTo{Tamil}{\tamilfont}

%\usepackage[style=chicago-authordate,natbib=true,backend=biber,maxcitenames=2]{biblatex}
%\usepackage{cite}

\begin{document}
    </xsl:text>
    <xsl:call-template name="titlepage"/>
    <xsl:call-template name="insidetitlepage"/>
    <xsl:text>\maketitle</xsl:text>
    <xsl:call-template name="preface"/>
    <xsl:text>
\newpage

\tableofcontents

\part{Introduction}
    </xsl:text>
    <xsl:call-template name="summary"/>
    <xsl:call-template name="transcription"/>
    <xsl:text>
\end{document}
    </xsl:text>
</xsl:template>

</xsl:stylesheet>
