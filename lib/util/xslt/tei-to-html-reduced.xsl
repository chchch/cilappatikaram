<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../../xslt/functions.xsl"/>
<xsl:import href="../../xslt/definitions.xsl"/>
<xsl:import href="../../xslt/common.xsl"/>
<xsl:import href="../../xslt/teiheader.xsl"/>
<xsl:import href="../../xslt/transcription.xsl"/>

<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="x:TEI">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:lb">
    <xsl:choose>
        <xsl:when test="@break = 'no'">
            <xsl:text>%nobreak%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="pretext" select="preceding::text()[1]"/>
            <xsl:if test="normalize-space(substring($pretext,string-length($pretext))) != ''">
                <xsl:text>%nobreak%</xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="span">
        <xsl:attribute name="class">
            <xsl:text>lb</xsl:text>
            <xsl:if test="not(@n)"><xsl:text> unnumbered</xsl:text></xsl:if>
        </xsl:attribute>
        <xsl:attribute name="lang">en</xsl:attribute>
        <xsl:attribute name="data-anno">
            <xsl:text>line </xsl:text>
            <xsl:choose>
                <xsl:when test="@n">
                    <xsl:value-of select="@n"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>beginning</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="data-n">
            <xsl:value-of select="@n"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<xsl:template match="x:pb">
    <xsl:choose>
        <xsl:when test="@break = 'no'">
            <xsl:text>%nobreak%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="pretext" select="preceding::text()[1]"/>
            <xsl:if test="normalize-space(substring($pretext,string-length($pretext))) != ''">
                <xsl:text>%nobreak%</xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="rv" select="substring(@n,string-length(@n))"/>
    <xsl:element name="span">
        <xsl:attribute name="class">
            <xsl:text>pb</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="lang">en</xsl:attribute>
        <xsl:if test="@n">
            <xsl:attribute name="data-n">
                <xsl:choose>
                    <xsl:when test="$rv = 'r' or $rv = 'v'">
                        <xsl:text>f. </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>p. </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="data-anno">
            <xsl:if test="@n">
                <xsl:choose>
                    <xsl:when test="$rv = 'r' or $rv = 'v'">
                        <xsl:text>folio </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>page </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="@n"/>
            </xsl:if>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<xsl:template match="x:cb">
    <xsl:choose>
        <xsl:when test="@break = 'no'">
            <xsl:text>%nobreak%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="pretext" select="preceding::text()[1]"/>
            <xsl:if test="normalize-space(substring($pretext,string-length($pretext))) != ''">
                <xsl:text>%nobreak%</xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="span">
        <xsl:attribute name="class">cb</xsl:attribute>
        <xsl:attribute name="lang">en</xsl:attribute>
        <xsl:if test="@n">
            <xsl:attribute name="data-n">
                <xsl:text>col. </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="data-anno">
            <xsl:if test="@n">
                <xsl:text>column </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:if>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<xsl:template match="x:note">
    <xsl:element name="span">
        <xsl:attribute name="class">invisinote</xsl:attribute>
        <xsl:attribute name="data-anno">note</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:attribute name="data-content"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
</xsl:template>

<xsl:template match="x:milestone"/>

<xsl:template match="x:seg[@function='copy-statement']">
    <xsl:element name="span">
        <xsl:call-template name="lang"/>
        <xsl:attribute name="data-anno">
            <xsl:text>copy statement</xsl:text>
            <xsl:if test="@cert">
                <xsl:text> (</xsl:text><xsl:value-of select="@cert"/><xsl:text> certainty)</xsl:text>
            </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="class">highlit</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<!--
<xsl:template match="node()">
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="text()">
    <xsl:value-of select="."/>
</xsl:template>
-->
</xsl:stylesheet>
