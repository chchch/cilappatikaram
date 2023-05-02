<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../definitions.xsl"/>
<xsl:import href="common.xsl"/>

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
<xsl:template name="transcription">
    <xsl:text>
\cleardoublepage
\makeatletter\@openrightfalse
\part{Diplomatic edition}
    </xsl:text>
    <xsl:apply-templates select="//x:text"/>
    <xsl:text>
\@openrighttrue\makeatother
    </xsl:text>
</xsl:template>

<xsl:template match="x:milestone">
    <xsl:text>
\newpage
\hypertarget{img-</xsl:text>
    <xsl:value-of select="@facs"/>
    <xsl:text>}{
    \includegraphics[width=\textwidth]{img-</xsl:text>
    <xsl:value-of select="@facs"/>
    <xsl:text>}}
\newpage</xsl:text>
</xsl:template>
</xsl:stylesheet>
