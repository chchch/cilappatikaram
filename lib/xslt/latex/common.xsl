<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../definitions.xsl"/>

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template name="dup">
<!-- from https://www.oreilly.com/library/view/xslt-cookbook/0596003722/ch01s05.html -->
    <xsl:param name="input"/>
     <xsl:param name="count" select="1"/>
     <xsl:choose>
          <xsl:when test="not($count) or not($input)"/>
          <xsl:when test="$count = 1">
               <xsl:value-of select="$input"/>
          </xsl:when>
          <xsl:otherwise>
               <!-- If $count is odd append an extra copy of input -->
               <xsl:if test="$count mod 2">
                    <xsl:value-of select="$input"/>
               </xsl:if>
               <!-- Recursively apply template after doubling input and 
               halving count -->
               <xsl:call-template name="dup">
                    <xsl:with-param name="input" 
                         select="concat($input,$input)"/>
                    <xsl:with-param name="count" 
                         select="floor($count div 2)"/>
               </xsl:call-template>     
          </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template match="x:p">
    <xsl:text>

</xsl:text>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:table">
    <xsl:variable name="cols" select="count(./x:row[1]/x:cell)"/>
    <xsl:text>
\begin{tabular}{</xsl:text>
    <xsl:call-template name="dup">
        <xsl:with-param name="input">l</xsl:with-param>
        <xsl:with-param name="count" select="$cols"/>
    </xsl:call-template>
    <xsl:text>}
    </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
\end{tabular}
    </xsl:text>
</xsl:template>

<xsl:template match="x:row">
    <xsl:apply-templates/>
    <xsl:text>
    </xsl:text>
</xsl:template>

<xsl:template match="x:cell">
    <xsl:apply-templates/>
    <xsl:text> &amp;</xsl:text>
</xsl:template>
<xsl:template match="x:cell[last()]">
    <xsl:apply-templates/>
    <xsl:text> \\
    </xsl:text>
</xsl:template>

<xsl:template match="x:locus">
    <xsl:text>\hyperlink{img-</xsl:text>
    <xsl:value-of select="@facs"/>
    <xsl:text>}{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="x:list">
    <xsl:text>
\begin{itemize}
    </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
\end{itemize}
    </xsl:text>
</xsl:template>
<xsl:template match="x:item">
    <xsl:text>
\item </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
    </xsl:text>
</xsl:template>
<xsl:template match="x:title">
    <xsl:text>\emph{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>
<xsl:template match="x:quote">
    <xsl:text>“</xsl:text><xsl:apply-templates/><xsl:text>”</xsl:text>
</xsl:template>

<xsl:template match="x:ex">
    <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="x:note[@place='foot']">
    <xsl:text>\footnote{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="x:head">
    <xsl:text>\chapter*{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}
    \addcontentsline{toc}{chapter}{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}
    </xsl:text>
</xsl:template>
<xsl:template match="x:del">
    <xsl:text>\sout{\textcolor{gray}{</xsl:text><xsl:apply-templates/><xsl:text>}}</xsl:text>
</xsl:template>
<xsl:template match="x:add">
    <xsl:text>\textbf{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>
<xsl:template match="x:sic">
    <xsl:text>\textcolor{purple}{¿}</xsl:text><xsl:apply-templates/><xsl:text>\textcolor{purple}{?}</xsl:text>
</xsl:template>
<xsl:template match="x:hi[@rend='subscript']">
    <xsl:text>\textsubscript{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>
<xsl:template match="x:hi[@rend='superscript']">
    <xsl:text>\textsuperscript{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>
</xsl:stylesheet>

