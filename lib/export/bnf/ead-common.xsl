<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:output method="xml" encoding="UTF-8"/>

<xsl:template match="x:div1|x:div2|x:div3">
    <xsl:element name="p">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:head">
    <xsl:element name="head">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:p">
    <xsl:element name="p">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:list">
    <xsl:element name="list">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>
<xsl:template match="x:item">
    <xsl:element name="item">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:span">
    <xsl:element name="span">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:emph">
    <xsl:element name="emph">
        <xsl:attribute name="render">
            <xsl:value-of select="@rend"/>
        </xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:lg">
    <xsl:if test="@met">
        <xsl:element name="p"><xsl:value-of select="@met"/></xsl:element>
    </xsl:if>
    <xsl:element name="list">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:l">
    <xsl:element name="item">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:num">
    <xsl:element name="num">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

</xsl:stylesheet>
