<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst exsl">

<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

<xsl:variable name="bnfDefs">

<tst:roles>
    <tst:entry key="addressee">0290</tst:entry>
    <tst:entry key="author">0070</tst:entry>
    <tst:entry key="binder">4140</tst:entry>
    <tst:entry key="collector">4010</tst:entry>
    <tst:entry key="commissioner">3120</tst:entry>
    <tst:entry key="owner">4010</tst:entry>
    <tst:entry key="scribe">0270</tst:entry>
    <tst:entry key="signer">0650</tst:entry>
    <tst:entry key="translator">0680</tst:entry>
</tst:roles>

</xsl:variable>

<xsl:variable name="BnF" select="exsl:node-set($bnfDefs)"/>

</xsl:stylesheet>
