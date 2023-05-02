<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

<xsl:output method="html" encoding="UTF-8" />

<xsl:template match="tei:TEI">
    <p><xsl:apply-templates /></p>
</xsl:template>

<xsl:template match="tei:lb">
    <xsl:if test="@break='no'"><xsl:text>%nobreak%</xsl:text></xsl:if>
</xsl:template>

<xsl:template match="tei:seg[@rend='grantha']">
    <b><xsl:apply-templates /></b>
</xsl:template>

<xsl:template match="tei:g[@xml:lang='sa']">
    <b><xsl:apply-templates /></b>
</xsl:template>

<xsl:template match="tei:g[@ref]">
    <xsl:text>{</xsl:text><xsl:value-of select="translate(@ref,'#','')"/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="tei:unclear">
    <ins>(</ins><xsl:apply-templates/><ins>)</ins>
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
    <ins>¡</ins><xsl:apply-templates/><ins>!</ins>
</xsl:template>

<xsl:template match="tei:sic">
    <ins>¿</ins><xsl:apply-templates/><ins>?</ins>
</xsl:template>

<xsl:template match="tei:corr | tei:reg">
    <ins><xsl:apply-templates/></ins>
</xsl:template>

<xsl:template match="tei:del">
    <del><xsl:apply-templates/></del>
</xsl:template>

<xsl:template match="tei:surplus">
    <ins>{</ins><xsl:apply-templates/><ins>}</ins>
</xsl:template>

<xsl:template match="tei:supplied[@reason = 'lost'] | tei:supplied[@reason = 'illegible']">
    <ins>[</ins><xsl:apply-templates/><ins>]</ins>
</xsl:template>

<xsl:template match="tei:supplied[@reason = 'omitted']">
    <ins>⟨</ins><xsl:apply-templates/><ins>⟩</ins>
</xsl:template>

<xsl:template match="tei:gap[@reason = 'lost'] | tei:gap[@reason = 'illegible']">
    <ins>[</ins>
    <xsl:text>...</xsl:text>
    <ins>]</ins>

</xsl:template>

<xsl:template match="tei:gap[@reason = 'ellipsis']">
    <xsl:text>[...]</xsl:text>
</xsl:template>
<xsl:template match="node()">
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="text()">
    <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>
