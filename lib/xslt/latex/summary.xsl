<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../definitions.xsl"/>
<xsl:import href="common.xsl"/>

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
<xsl:template name="summary">
    <xsl:text>
\part{The manuscript}
\newpage
    </xsl:text>
    <xsl:apply-templates select="//x:summary"/>
</xsl:template>

</xsl:stylesheet>
