<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../definitions.xsl"/>

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template name="titlepage">
    <xsl:text>\begin{titlepage}

    \title{</xsl:text>
    <xsl:apply-templates select="//x:titleStmt/x:title"/>
    <xsl:text>}</xsl:text>
    
    <xsl:text>\subtitle{A diplomatic edition of </xsl:text>
    <xsl:apply-templates select="//x:idno[@type='shelfmark']"/>
    <xsl:text>, Bibliothèque nationale de France}</xsl:text>

    <xsl:text>\author{</xsl:text>
    <xsl:apply-templates select="//x:editor/x:persName"/>
    <xsl:text>}</xsl:text>

    <xsl:text>
\date{}
\publishers{
\includegraphics[height=2em]{tst}\\
Texts Surrounding Texts\\
Paris · Hamburg
}   
\end{titlepage}
    </xsl:text>
</xsl:template>

<xsl:template name="insidetitlepage">
    <xsl:text>
\lowertitleback{
    \includegraphics[height=1em]{cc.xlarge} \includegraphics[height=1em]{by.xlarge} \includegraphics[height=1em]{nc-eu.xlarge} 2022 </xsl:text>
    <xsl:apply-templates select="//x:editor/x:persName"/>
    <xsl:text>\\
    This text is licensed under a Creative Commons Attribution-NonCommercial license.\\
    Manuscript images are courtesy of Gallica / Bibliothèque nationale de France.\\
    \\
    ISBN XXXX-XXXX-XXXX eBook\\
    \\
    Text Surrounding Texts (FRAL 2018, ANR/DFG)\\
    Centre nationale de la recherche scientifique\\
    Paris, France\\
    \\
    \includegraphics[height=2em]{anr} \hfill \includegraphics[height=2em]{bnf} \hfill \includegraphics[height=1.8em]{dfg} \\
}
    </xsl:text>
</xsl:template>

</xsl:stylesheet>
