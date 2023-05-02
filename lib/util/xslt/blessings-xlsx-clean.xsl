<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="tei:TEI">
    <p><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="tei:lb">
    <xsl:if test="@break='no'"><xsl:text>%nobreak%</xsl:text></xsl:if>
</xsl:template>

<xsl:template match="tei:seg[@rend='grantha']">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:g[@xml:lang='sa']">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:g[@ref]">
    <xsl:text>{</xsl:text><xsl:value-of select="translate(@ref,'#','')"/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="tei:unclear">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:choice">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:choice/tei:unclear">
    <xsl:if test="position()=1">
        <ins>(</ins>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">
        <ins>/</ins>
    </xsl:if>
    <xsl:if test="position()=last()">
        <ins>)</ins>
    </xsl:if>
</xsl:template>

<xsl:template match="tei:orig">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:sic">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:corr | tei:reg">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:del">
</xsl:template>

<xsl:template match="tei:surplus">
</xsl:template>

<xsl:template match="tei:supplied">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:note"/>

<xsl:template match="node()">
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="text()">
    <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>
