<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst exsl">

<xsl:param name="personnames" select="document('../../../authority-files/authority/authority/persons_base.xml')"/>

<xsl:import href="../../xslt/functions.xsl"/>
<xsl:import href="ead-functions.xsl"/>
<xsl:import href="../../xslt/definitions.xsl"/>
<xsl:import href="ead-common.xsl"/>
<xsl:import href="bnf.xsl"/>

<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

<xsl:template name="gallica">
    <xsl:variable name="url" select="ancestor::x:TEI/x:facsimile/x:graphic/@url"/>
    <xsl:variable name="pre" select="substring-after($url,'https://gallica.bnf.fr/iiif')"/>
    <xsl:variable name="mid" select="substring-before($pre,'manifest.json')"/>
    <xsl:text>https://gallica.bnf.fr</xsl:text>
    <xsl:value-of select="$mid"/>
    <xsl:text>f</xsl:text>
</xsl:template>

<xsl:template name="shelfmark">
    <xsl:value-of select="ancestor-or-self::x:TEI[1]/x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msIdentifier/x:idno[@type='shelfmark']"/>
</xsl:template>

<xsl:template name="tsturl">
    <xsl:variable name="shelfmark"><xsl:call-template name="shelfmark"/></xsl:variable>

    <xsl:variable name="shelf1" select="substring-before($shelfmark,' ')"/>
    <xsl:variable name="shelf2" select="substring-after($shelfmark,' ')"/>
    <xsl:variable name="shelf2letters" select="translate($shelf2,'0123456789','')"/>
    <xsl:variable name="shelf2numbers" select="format-number(translate($shelf2,$shelf2letters,''),'0000')"/>
    <xsl:text>https://tst-project.github.io/mss/</xsl:text>
    <xsl:value-of select="$shelf1"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$shelf2numbers"/>
    <xsl:value-of select="$shelf2letters"/>
    <xsl:text>.xml</xsl:text>
</xsl:template>

<xsl:template name="facslink">
    <xsl:variable name="url" select="ancestor::x:TEI/x:facsimile/x:graphic/@url"/>
    <xsl:choose>
        <xsl:when test="starts-with($url,'https://gallica.bnf.fr/')">
            <xsl:call-template name="gallica"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="tsturl"/>
            <xsl:text>?facs=</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="x:title">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:p//x:title | x:desc//x:title | x:bibl//x:title | x:summary//x:title">
    <emph render="italic"><xsl:apply-templates/></emph>
</xsl:template>

<xsl:template match="x:idno[@type='alternate']/x:idno">
    <unitid type="ancienne cote"><xsl:value-of select="."/></unitid>
</xsl:template>

<xsl:template match="processing-instruction('xml-stylesheet')"/>

<xsl:template match="x:TEI">
    <ead>
        <eadheader>
            <eadid/>
            <filedesc>
                <titlestmt>
                    <xsl:element name="titleproper">
                        <xsl:variable name="shelfmark">
                            <xsl:call-template name="shelfmark"/>
                        </xsl:variable>
                        <xsl:value-of select="substring-before($shelfmark,' ')"/>
                        <xsl:text> </xsl:text>
                        <num>
                            <xsl:value-of select="substring-after($shelfmark,' ')"/>
                        </num>
                        <xsl:text>. </xsl:text>
                        <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:titleStmt/x:title"/>
                    </xsl:element>
                    <subtitle>Notice descriptive</subtitle>
                </titlestmt>
                <publicationstmt>
                    <publisher>Bibliothèque nationale de France</publisher>
                    <date calendar="gregorian" era="ce">2022</date>
                </publicationstmt>
            </filedesc>
            <profiledesc>
              <creation audience="internal">Cette notice a été encodée en XML conformément à la DTD EAD (version 2002).</creation>
              <langusage>Notice rédigée en <language langcode="eng">anglais</language>.</langusage>
            </profiledesc>
        </eadheader>
        <archdesc>
            <xsl:call-template name="archdesc"/>
        </archdesc>
    </ead>
</xsl:template>

<xsl:template name="archdesc">
    <xsl:choose>
        <xsl:when test="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem/@source">
            <xsl:attribute name="level">otherlevel</xsl:attribute>
            <xsl:attribute name="otherlevel">recueil</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="level">item</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="didetc"/>
</xsl:template>

<xsl:template name="didetc">
    <xsl:param name="repo">true</xsl:param>
    <xsl:param name="type">cote</xsl:param>
    <did>
        <unitid>
            <xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
            <xsl:call-template name="shelfmark"/>
        </unitid>
        <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msIdentifier/x:idno[@type='alternate']/x:idno"/>
        <unittitle><xsl:apply-templates select="x:teiHeader/x:fileDesc/x:titleStmt/x:title"/></unittitle>
        <unittitle type="non-latin originel"><xsl:copy-of select="x:teiHeader/x:fileDesc/x:titleStmt/x:title"/></unittitle>
        <langmaterial>
            <xsl:variable name="tech" select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc/rend"/>
            <xsl:choose>
                <xsl:when test="$tech">
                    <xsl:call-template name="capitalize">
                        <xsl:with-param name="str"><xsl:value-of select="$tech"/></xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Manuscript</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text> in </xsl:text>
            <!--xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem[1]/x:textLang"/-->
            <xsl:call-template name="textLang"/>
            <xsl:text>.</xsl:text>
        </langmaterial>
        <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:history/x:origin/x:origDate[1]"/>
        <physdesc>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:history/x:origin/x:origPlace"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:handDesc"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:typeDesc"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:decoDesc"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc/x:supportDesc/x:collation"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc/x:supportDesc/x:support"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc/x:supportDesc/x:extent"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc/x:layoutDesc/x:layout"/>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc/x:bindingDesc/x:binding"/>
            <xsl:call-template name="stamps"/>
        </physdesc>
        <xsl:if test="$repo = 'true'">
            <repository>
                <corpname authfilenumber="751041006" normal="Bibliothèque nationale de France. Département des Manuscrits" source="Repertoire_des_Centres_de_Ressources">Bibliothèque nationale de France. Département des Manuscrits</corpname>
            </repository>
        </xsl:if>
    </did>
    <scopecontent>
        <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:summary"/>                
        <p>
            <emph render="bold">Contents</emph>
            <xsl:variable name="class" select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/@class"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$TST/tst:mstypes/tst:entry[@key=$class]"/>
            <xsl:text>)</xsl:text>
        </p>
        <xsl:for-each select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem">
            <xsl:choose>
                <xsl:when test="not(@source)">
                    <xsl:apply-templates select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <p> 
                        <xsl:call-template name="msItemHeader"/>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!--xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem[not(@source)]"/-->
        <p>
            <emph render="bold">Paratexts</emph>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:additions"/>
        </p>
        <xsl:call-template name="conventions"/>
    </scopecontent>
    <xsl:if test="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem/@source">
        <dsc>
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem[@source]"/>
        </dsc>
    </xsl:if>
    <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:additional/x:listBibl"/>
    <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:history/x:provenance"/>
    <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:history/x:acquisition"/>
    <xsl:call-template name="citation"/>
</xsl:template>

<xsl:template match="x:additions">
    <list>
        <xsl:apply-templates select="x:desc[not(@type='stamp')]"/>
        <xsl:call-template name="more-additions"/>
    </list>
</xsl:template>
<xsl:template match="x:additions/x:desc[not(@type='stamp')]">
    <xsl:variable name="type" select="@type"/>
    <item>
        <xsl:if test="@corresp or @synch">
            <xsl:call-template name="synch-format"/>
        </xsl:if>
        <xsl:if test="$type">
            <emph render="bold">
                <xsl:call-template name="splitlist">
                        <xsl:with-param name="list" select="$type"/>
                        <xsl:with-param name="nocapitalize">true</xsl:with-param>
                        <xsl:with-param name="map">tst:additiontype</xsl:with-param>
                </xsl:call-template>
            </emph>
        </xsl:if>
        <xsl:if test="@subtype">
            <xsl:text>, </xsl:text>
            <xsl:variable name="subtype" select="@subtype"/>
            <xsl:call-template name="splitlist">
                <xsl:with-param name="list" select="@subtype"/>
                <xsl:with-param name="nocapitalize">true</xsl:with-param>
                <xsl:with-param name="map">tst:subtype</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="./node()">
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </item>
</xsl:template>
<xsl:template name="more-additions">
  <xsl:variable name="ps" select="ancestor::x:TEI/x:text//*[
                                @function != '' and
                                @function != 'rubric' and 
                                @function != 'incipit' and
                                @function != 'explicit' and
                                @function != 'completion-statement' and
                                @function != 'colophon' and 
                                not(ancestor::x:seg or ancestor::x:fw)] |
                                ancestor::x:TEI/x:text//*[@function = 'rubric']/*[@function != ''] |
                                ancestor::x:TEI/x:text//*[@function = 'incipit']/*[@function != ''] |
                                ancestor::x:TEI/x:text//*[@function = 'explicit']/*[@function != ''] |
                                ancestor::x:TEI/x:text//*[@function = 'completion-statement']/*[@function != ''] |
                                ancestor::x:TEI/x:text//*[@function = 'colophon']/*[@function != ''] |
                                ancestor::x:TEI/x:text//x:fw"/>
    <xsl:if test="node()[not(self::text())] or $ps">
        <xsl:for-each select="$ps">
            <item>
                <xsl:variable name="type">
                    <xsl:choose>
                    <xsl:when test="self::x:fw"><xsl:text>header</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:value-of select="@function"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="cu" select="substring-after(ancestor::x:text/@synch,'#')"/>
                <xsl:variable name="tu" select="substring-after(ancestor::x:text/@corresp,'#')"/>
                <xsl:if test="$cu or $tu">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="$cu"/>
                    <xsl:if test="$cu and $tu">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="$tu">
                        <xsl:value-of select="$tu"/>
                    </xsl:if>
                    <xsl:text>) </xsl:text>
                </xsl:if>
                <xsl:if test="$type">
                    <emph render="bold">
                        <xsl:call-template name="splitlist">
                                <xsl:with-param name="list" select="$type"/>
                                <xsl:with-param name="nocapitalize">true</xsl:with-param>
                                <xsl:with-param name="map">tst:additiontype</xsl:with-param>
                        </xsl:call-template>

                        <xsl:variable name="placement" select="@place | ancestor::x:fw/@place"/>
                        <xsl:if test="$placement">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="translate($placement,'-',' ')"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>

                        <xsl:variable name="moretypes" select=".//x:seg"/>
                        <xsl:if test="$moretypes/@function">
                            <xsl:text>, </xsl:text>
                            <xsl:variable name="uniquetypes">
                                <xsl:for-each select="$moretypes">
                                    <xsl:sort select="@function"/>
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:for-each select="exsl:node-set($uniquetypes)/x:seg">
                                <xsl:variable name="pos" select="position()"/>
                                <xsl:if test="$pos = last() or not(@function=following-sibling::x:seg/@function)">
                                    <xsl:variable name="func" select="@function"/>
                                    <xsl:variable name="addname" select="$TST/tst:additiontype//tst:entry[@key=$func]"/>
                                    <xsl:choose>
                                        <xsl:when test="$addname"><xsl:value-of select="$addname"/></xsl:when>
                                        <xsl:otherwise><xsl:value-of select="$func"/></xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="not($pos = last())">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </emph>
                </xsl:if>
                <xsl:if test="./node()">
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:call-template name="import-milestone"/>
                <xsl:call-template name="import-lb"/>
                <!--xsl:if test="not(./*[1]/@facs)">
                    <xsl:variable name="milestone" select="preceding::*[@facs][1]"/>
                    <xsl:if test="$milestone">
                        <xsl:apply-templates select="$milestone"/>
                    </xsl:if>
                </xsl:if-->
                <xsl:apply-templates/>
            </item>
      </xsl:for-each>
    </xsl:if>
</xsl:template>
<xsl:template name="conventions">
    <p><emph render="bold">Transcription conventions</emph><lb/>
        <xsl:if test="//x:unclear">
            <emph render="bold"><xsl:text>()</xsl:text></emph><xsl:text> indicates unclear text. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:del">
            <emph render="bold"><xsl:text>〚〛</xsl:text></emph><xsl:text> indicates deletions. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:add">
            <emph render="bold"><xsl:text>\/</xsl:text></emph><xsl:text> indicates additions. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:sic">
            <emph render="bold">¿?</emph><xsl:text> indicates </xsl:text><emph render="italic"><xsl:text>sic erat scriptum</xsl:text></emph><xsl:text> or surplus text. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:supplied | //x:reg | //x:corr | //x:ex">
            <emph render="bold"><xsl:text>[]</xsl:text></emph><xsl:text> indicates text supplied or corrected by the cataloguer. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:note">
            <emph render="bold"><xsl:text>{}</xsl:text></emph><xsl:text> indicates a note. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:space[not(@type='vacat')]">
            <emph render="bold">[</emph>_<emph render="bold">]</emph><xsl:text> indicates spaces. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:space[@type='vacat']">
            <emph render="bold">[</emph>vacat<emph render="bold">]</emph><xsl:text> indicates the scribe deliberately left a space. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:gap[@reason='ellipsis']">
            <xsl:text>[…] indicates an ellipsis. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:gap[@reason='lost']">
            <xsl:text>[‡] indicates characters lost due to damage. </xsl:text>
        </xsl:if>
        <xsl:if test="//x:gap[@reason != 'lost' and @reason !='ellipsis']">
            <xsl:text>[?] indicates a gap in the reading. </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="x:teiHeader/x:encodingDesc/x:p"/>
    </p>
</xsl:template>
<xsl:template match="x:encodingDesc/x:p">
    <xsl:apply-templates/><xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="x:listBibl">
    <bibliography>
        <xsl:apply-templates/>
    </bibliography>
</xsl:template>
<xsl:template match="x:bibl">
    <bibref><xsl:apply-templates/></bibref>
</xsl:template>

<xsl:template match="x:provenance">
    <custodhist>
        <xsl:apply-templates/>
    </custodhist>
</xsl:template>
<xsl:template match="x:acquisition">
    <acqinfo>
        <xsl:apply-templates/>
    </acqinfo>
</xsl:template>

<xsl:template name="citation">
    <processinfo>
        <p><xsl:text>This catalogue entry has been adapted from:</xsl:text></p>
        <p>
            <bibref>
                <xsl:for-each select="x:teiHeader/x:fileDesc/x:titleStmt/x:editor/x:persName">
                    <xsl:choose>
                        <xsl:when test="position() = last() and not(position() = 1)">
                            <xsl:text> &amp; </xsl:text>
                        </xsl:when>
                        <!-- TODO more than two authors -->
                        <xsl:otherwise/>
                    </xsl:choose>
                    <xsl:variable name="name" select="."/>
                    <xsl:variable name="surname" select="$name/x:surname"/>
                    <xsl:variable name="forename" select="$name/x:forename"/>
                    <xsl:choose>
                        <xsl:when test="$surname">
                            <xsl:value-of select="$surname"/>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="$forename"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="first" select="substring-before($name,' ')"/>
                            <xsl:variable name="last" select="substring-after($name,' ')"/>
                            <xsl:value-of select="$last"/>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="$first"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text>. </xsl:text>
                <xsl:value-of select="x:teiHeader/x:fileDesc/x:publicationStmt/x:date"/>
                <xsl:text>. </xsl:text>
                <xsl:text>“</xsl:text>
                <xsl:element name="extref">
                    <xsl:attribute name="actuate">onrequest</xsl:attribute>
                    <xsl:attribute name="show">new</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:call-template name="tsturl"/>
                    </xsl:attribute>
                    <xsl:call-template name="shelfmark"/><xsl:text>. </xsl:text>
                    <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:titleStmt/x:title"/>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:text>” </xsl:text>
                <emph render="italic">
                    <xsl:text>Descriptive Catalogue of the Texts Surrounding Texts Project.</xsl:text>
                </emph>
                <xsl:text> Paris: TST Project. </xsl:text>
                <extref actuate="onrequest" show="new" href="https://doi.org/10.5281/zenodo.6475589">
                    <xsl:text>doi:10.5281/zenodo.6475589</xsl:text>
                </extref>
            </bibref>
        </p>
    </processinfo>
</xsl:template>

<xsl:template name="stamps">
    <xsl:if test="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:additions/x:desc[@type='stamp']">
        <physfacet type="estampille">
            <xsl:apply-templates select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:additions/x:desc[@type='stamp']"/>
        </physfacet>
    </xsl:if>
</xsl:template>

<xsl:template match="x:additions/x:desc[@type='stamp']">
    <xsl:if test="@subtype">
        <xsl:text> (</xsl:text>
        <xsl:variable name="subtype" select="@subtype"/>
        <xsl:call-template name="splitlist">
            <xsl:with-param name="list" select="@subtype"/>
            <xsl:with-param name="nocapitalize">true</xsl:with-param>
            <xsl:with-param name="map">tst:subtype</xsl:with-param>
        </xsl:call-template>
        <xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="x:p">
    <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="x:msContents/x:summary">
    <xsl:choose>
        <xsl:when test="x:p">
            <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="p">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="msItemHeader">
    <xsl:if test="@corresp or @synch">
        <xsl:call-template name="synch-format"/>
    </xsl:if>
    <xsl:if test="./x:author">
        <xsl:apply-templates select="x:author"/><xsl:text>, </xsl:text>
    </xsl:if>
    <title>
        <xsl:choose>
            <xsl:when test="x:title"><xsl:apply-templates select="x:title"/></xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="x:TEI/x:teiHeader/x:fileDesc/x:titleStmt/x:title"/>
            </xsl:otherwise>
        </xsl:choose>
    </title>
    <xsl:if test="@defective = 'true'">
        <xsl:text> (incomplete)</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="x:msItem">
    <xsl:variable name="thisid" select="concat('#',@xml:id)"/>
    <p> 
        <xsl:call-template name="msItemHeader"/>
        <xsl:variable name="items" select="x:rubric or x:incipit or x:explicit or x:finalRubric or x:colophon or ancestor::x:TEI/x:text[@corresp=$thisid]//x:seg[@function='rubric' or @function='incipit' or @function='explicit' or @function='finalRubric' or @function='colophon']"/>
        <xsl:if test="$items">
            <list>
                <xsl:for-each select="x:rubric | ancestor::x:TEI/x:text[@corresp=$thisid]//x:seg[@function='rubric' and not(@corresp)] | ancestor::x:TEI/x:text//x:seg[@function='rubric' and @corresp=$thisid]">
                     <xsl:call-template name="excerpt">
                        <xsl:with-param name="header">Rubric</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="x:incipit | ancestor::x:TEI/x:text[@corresp=$thisid]//x:seg[@function='incipit' and not(@corresp)] | ancestor::x:TEI/x:text//x:seg[@function='incipit' and @corresp=$thisid]">
                     <xsl:call-template name="excerpt">
                        <xsl:with-param name="header">Incipit</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="x:explicit | ancestor::x:TEI/x:text[@corresp=$thisid]//x:seg[@function='explicit' and not(@corresp)] | ancestor::x:TEI/x:text//x:seg[@function='explicit' and @corresp=$thisid]">
                     <xsl:call-template name="excerpt">
                        <xsl:with-param name="header">Explicit</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="x:finalRubric | ancestor::x:TEI/x:text[@corresp=$thisid]//x:seg[@function='completion-statement' and not(@corresp)] | ancestor::x:TEI/x:text//x:seg[@function='completion-statement' and @corresp=$thisid]">
                     <xsl:call-template name="excerpt">
                        <xsl:with-param name="header">Completion statement</xsl:with-param>
                     </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="x:colophon | ancestor::x:TEI/x:text[@corresp=$thisid]//x:seg[@function='colophon' and not(@corresp)] | ancestor::x:TEI/x:text//x:seg[@function='colophon' and @corresp=$thisid]">
                     <xsl:call-template name="excerpt">
                        <xsl:with-param name="header">Colophon</xsl:with-param>
                     </xsl:call-template>
                </xsl:for-each>
            </list>
        </xsl:if>
    </p>
</xsl:template>

<xsl:template match="x:msItem[@source]">
    <c level="otherlevel" otherlevel="partie_composante">
        <xsl:apply-templates/>
    </c>
</xsl:template>
<xsl:template match="x:msItem[@source]/x:TEI">
    <xsl:call-template name="didetc">
        <xsl:with-param name="repo">false</xsl:with-param>
        <xsl:with-param name="type">division</xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template name="excerpt">
     <xsl:param name="header"/>    
     <item>
         <emph render="bold"><xsl:value-of select="$header"/></emph>
         <xsl:choose>
            <xsl:when test="@type='root-text'"> (root text)</xsl:when>
            <xsl:when test="@type='commentary'"> (commentary)</xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
         <xsl:text> </xsl:text>
         <blockquote><p>
            <xsl:call-template name="import-milestone"/>
            <xsl:call-template name="import-lb"/>
            <!--xsl:if test="local-name() = 'seg' and not(./*[1]/@facs)">
                <xsl:variable name="milestone" select="preceding::*[@facs][1]"/>
                <xsl:if test="$milestone">
                    <xsl:apply-templates select="$milestone"/>
                </xsl:if>
            </xsl:if-->
            <xsl:apply-templates/>
         </p></blockquote>
     </item>
</xsl:template>

<xsl:template match="x:seg//x:lg | x:seg//x:l">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:milestone">
    <xsl:if test="position() != 1"><lb/></xsl:if>
    <xsl:choose>
        <xsl:when test="@facs">
            <xsl:element name="extref">
                <xsl:attribute name="show">new</xsl:attribute>
                <xsl:attribute name="actuate">onrequest</xsl:attribute>
                <xsl:attribute name="href"><xsl:call-template name="facslink"/><xsl:value-of select="@facs"/></xsl:attribute>
                <xsl:call-template name="milestone"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="milestone"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template name="milestone">
    <xsl:variable name="unit" select="@unit"/>
    <xsl:text>[</xsl:text>
    <xsl:choose>
        <xsl:when test="$unit">
            <xsl:variable name="unitname" select="$TST//tst:milestones/tst:entry[@key=$unit]"/>
            <xsl:choose>
                <xsl:when test="$unitname"><xsl:value-of select="$unitname"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$unit"/></xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@n"><xsl:text> </xsl:text></xsl:if>
        </xsl:when>
        <xsl:when test="ancestor::x:TEI/x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc[@form = 'pothi']">
            <xsl:text>folio </xsl:text>
        </xsl:when>
    <xsl:when test="ancestor::x:TEI/x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:physDesc/x:objectDesc[@form = 'book']">
            <xsl:text>page </xsl:text>
        </xsl:when>
    </xsl:choose>
    <xsl:value-of select="@n"/>
    <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="x:lb | x:pb | x:cb">
    <xsl:if test="position() != 1"><lb/></xsl:if>
    <xsl:choose>
        <xsl:when test="@facs and @n">
            <xsl:element name="extref">
                <xsl:attribute name="show">new</xsl:attribute>
                <xsl:attribute name="actuate">onrequest</xsl:attribute>
                <xsl:attribute name="href"><xsl:call-template name="facslink"/><xsl:value-of select="@facs"/></xsl:attribute>
                <xsl:text>[</xsl:text>
                <xsl:if test="local-name() = 'cb'">
                    <xsl:text>column </xsl:text>
                </xsl:if>
                <xsl:value-of select="@n"/>
                <xsl:text>]</xsl:text>
            </xsl:element>
            <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="@n">
                <xsl:text>[</xsl:text>
                <xsl:if test="local-name() = 'cb'">
                    <xsl:text>column </xsl:text>
                </xsl:if>
                <xsl:value-of select="@n"/>
                <xsl:text>] </xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="x:unclear">
    <emph render="bold">(</emph><xsl:apply-templates/><emph render="bold">)</emph>
</xsl:template>
<xsl:template match="x:add">
    <emph render="bold"><xsl:text>\</xsl:text></emph><xsl:apply-templates/><emph render="bold"><xsl:text>/</xsl:text></emph>
</xsl:template>

<xsl:template match="x:gap">
        <xsl:variable name="spacechar">
            <xsl:choose>
                <xsl:when test="@reason='ellipsis'">…</xsl:when>
                <xsl:when test="@reason='lost'">‡</xsl:when>
                <xsl:otherwise>?</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="extentnum" select="translate(@extent,translate(@extent,'0123456789',''),'')"/>
        <xsl:text>[</xsl:text>
        <xsl:choose>
            <xsl:when test="count(./*) &gt; 0"><xsl:apply-templates/></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@quantity &gt; 0">
                        <xsl:call-template name="repeat">
                            <xsl:with-param name="output"><xsl:value-of select="$spacechar"/></xsl:with-param>
                            <xsl:with-param name="count" select="@quantity"/>
                        </xsl:call-template>

                    </xsl:when>
                    <xsl:when test="number($extentnum) &gt; 0">
                        <xsl:call-template name="repeat">
                            <xsl:with-param name="output"><xsl:value-of select="$spacechar"/></xsl:with-param>
                            <xsl:with-param name="count" select="$extentnum"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise><xsl:text>…</xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
</xsl:template>
<xsl:template match="x:space">
    <emph render="bold">[</emph>
    <xsl:choose>
        <xsl:when test="count(./*) &gt; 0">
            <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="@type='vacat'"><xsl:text>vacat</xsl:text></xsl:when>
        <xsl:otherwise>
            <xsl:text>_</xsl:text>
            <xsl:choose>
                <xsl:when test="@quantity &gt; 1">
                    <xsl:call-template name="repeat">
                        <xsl:with-param name="output"><xsl:text>_&#x200B;</xsl:text></xsl:with-param>
                        <xsl:with-param name="count" select="@quantity"/>
                    </xsl:call-template>

                </xsl:when>
                <xsl:when test="@extent">
                    <xsl:variable name="extentnum" select="translate(@extent,translate(@extent,'0123456789',''),'')"/>
                    <xsl:if test="number($extentnum) &gt; 1">
                        <xsl:call-template name="repeat">
                            <xsl:with-param name="output"><xsl:text>_&#x200B;</xsl:text></xsl:with-param>
                            <xsl:with-param name="count" select="$extentnum"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
    <emph render="bold">]</emph>
</xsl:template>

<xsl:template match="x:sic | x:surplus">
    <emph render="bold"><xsl:text>¿</xsl:text></emph>
    <xsl:apply-templates/>
    <emph render="bold"><xsl:text>?</xsl:text></emph>
</xsl:template>
<xsl:template match="x:supplied | x:corr | x:reg">
    <emph render="bold"><xsl:text>[</xsl:text></emph>
    <xsl:apply-templates/>
    <emph render="bold"><xsl:text>]</xsl:text></emph>
</xsl:template>

<xsl:template match="x:orig">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:note">
    <xsl:text>{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="x:author">
    <xsl:element name="persname">
        <xsl:attribute name="role">0070</xsl:attribute>
        <xsl:variable name="txt" select="text()"/>
        <xsl:variable name="found" select="$personnames//x:person/x:persName[text() = $txt]"/>
        <xsl:if test="$found">
            <xsl:variable name="parent" select="$found/parent::*"/>
            <xsl:variable name="key" select="$parent/x:idno[@type='BnF']"/>
            <xsl:choose>
                <xsl:when test="$key">
                    <xsl:attribute name="source">BnF</xsl:attribute>
                    <xsl:attribute name="authfilenumber">
                        <xsl:value-of select="$key"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="normal">
                        <xsl:value-of select="$parent/x:persName[@type='standard']"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:binding/x:p |x:binding//x:material">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="x:binding/x:decoNote">
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="x:binding">
    <physfacet type="reliure">
        <xsl:apply-templates select="./node()[not(self::text())]"/>
    </physfacet>
    <lb/>
</xsl:template>

<xsl:template match="x:layout">
    <physfacet type="réglure">
        <xsl:if test="@columns and not(@columns = '') and not(@columns = '0')">
            <xsl:variable name="q" select="translate(@columns,' ','-')"/>
            <xsl:call-template name="units">
                <xsl:with-param name="u">column</xsl:with-param>
                <xsl:with-param name="q" select="$q"/>
            </xsl:call-template>
            <xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:if test="@writtenLines and not(@writtenLines = '') and not(@writtenLines = '0')">
            <xsl:value-of select="translate(@writtenLines,' ','-')"/>
            <xsl:text> written lines per page. </xsl:text>
        </xsl:if>
        <xsl:if test="@ruledLines and not(@ruledLines='') and not(@ruledLines = '0')">
            <xsl:value-of select="translate(@ruledLines,' ','-')"/>
            <xsl:text> ruled lines per page. </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </physfacet>
    <lb/>
    <lb/>
</xsl:template>

<xsl:template match="x:dimensions">
    <xsl:if test="node()[not(self::text())]">
            <xsl:if test="@type">
                <emph render="bold"><xsl:value-of select="@type"/></emph><xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="x:height and x:width and x:depth">
                    <xsl:apply-templates select="x:height"/><xsl:text> × </xsl:text>
                    <xsl:apply-templates select="x:width"/><xsl:text> × </xsl:text>
                    <xsl:apply-templates select="x:depth"/>
                </xsl:when>
                <xsl:when test="x:height and x:width">
                    <xsl:apply-templates select="x:height"/><xsl:text> × </xsl:text>
                    <xsl:apply-templates select="x:width"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="x:height">
                        <xsl:text>(height) </xsl:text>
                        <xsl:apply-templates select="x:height"/>
                    </xsl:if>
                    <xsl:if test="x:width">
                        <xsl:text>(width) </xsl:text>
                        <xsl:apply-templates select="x:width"/>
                    </xsl:if>
                    <xsl:if test="x:depth">
                        <xsl:text>(depth) </xsl:text>
                        <xsl:apply-templates select="x:depth"/>
                    </xsl:if>
                </xsl:otherwise>
        </xsl:choose>
        <xsl:text>mm. </xsl:text>
        <xsl:apply-templates select="x:note"/>
    </xsl:if>
</xsl:template>

<xsl:template match="x:width | x:height | x:depth">
    <xsl:call-template name="measure"/>
</xsl:template>

<xsl:template match="x:dimensions/x:note">
    <xsl:element name="p">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="@quantity">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template name="min-max">
    <xsl:choose>
        <xsl:when test="@min and not(@min='') and @max and not(@max='')">
            <xsl:value-of select="@min"/><xsl:text>-</xsl:text><xsl:value-of select="@max"/>
            <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="@min and not(@min='')"><xsl:apply-templates select="@min"/></xsl:if>
            <xsl:if test="@max and not(@max='')"><xsl:apply-templates select="@max"/></xsl:if>
            <xsl:text> </xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@min">
    <xsl:text>min. </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
</xsl:template>
<xsl:template match="@max">
    <xsl:text>max. </xsl:text>
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template name="measure">
    <xsl:param name="q" select="@quantity"/>
    <xsl:if test="$q or @min or @max">
        <xsl:apply-templates select="$q"/>
        <xsl:call-template name="min-max"/>
    </xsl:if>
</xsl:template>

<xsl:template match="x:support">
    <physfacet type="support">
        <xsl:variable name="mat" select="//x:objectDesc/x:supportDesc/@material"/>
        <xsl:value-of select="$TST/tst:materials/tst:entry[@key=$mat]"/>
        <xsl:text> (</xsl:text>
        <xsl:call-template name="capitalize"><xsl:with-param name="str" select="//x:objectDesc/@form"/></xsl:call-template><xsl:text>.</xsl:text>
        <xsl:apply-templates select="./x:measure[@unit='stringhole']"/>
        <xsl:text>) </xsl:text>
    </physfacet>
    <extent>
        <xsl:apply-templates select="./x:measure[@unit='folio']"/><xsl:text> </xsl:text>
    </extent>
</xsl:template>
<xsl:template match="x:extent">
    <dimensions>
        <xsl:apply-templates select="./x:dimensions"/>
        <xsl:text> </xsl:text>
    </dimensions>
</xsl:template>

<xsl:template match="x:measure">
    <xsl:value-of select="@quantity"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@unit"/>
    <xsl:text>.</xsl:text>
    <xsl:if test="./node()"><xsl:text> </xsl:text></xsl:if>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="x:measure[@unit='stringhole' or @unit='folio' or @unit='page']">
    <xsl:if test="@quantity and not(@quantity = '') and not(@quantity = '0')">
        <xsl:text> </xsl:text>
        <xsl:call-template name="units"/>
        <xsl:text>.</xsl:text>
        <xsl:if test="./node()"><xsl:text> </xsl:text></xsl:if>
        <xsl:apply-templates />
   </xsl:if>
</xsl:template>
<xsl:template match="x:collation">
    <physfacet type="codicologie">
        <xsl:apply-templates select="./node()[not(self::text())]"/>
    </physfacet>
    <lb/>
    <lb/>
</xsl:template>
<xsl:template match="x:objectDesc/x:supportDesc/x:collation/x:desc">
    <xsl:if test="@xml:id">
        <emph render="bold"><xsl:value-of select="@xml:id"/></emph>
        <xsl:text>: </xsl:text>
    </xsl:if>
    <xsl:apply-templates />
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="x:collation/x:desc/x:list">
    <xsl:for-each select="x:item">
        <xsl:apply-templates/>
        <xsl:choose>
            <xsl:when test="position() = last()"><xsl:text>.</xsl:text></xsl:when>
            <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- EAD doesn't allow list in physfacet -->

<!-- EAD doesn't allow persname in emph -->
<xsl:template match="x:persName">
    <xsl:variable name="txt" select="text()"/>
    <xsl:variable name="norm" select="@key"/>
    <xsl:choose>
        <xsl:when test="@role">
            <xsl:variable name="tstrole" select="@role"/>
            <xsl:variable name="role" select="$BnF/tst:roles/tst:entry[@key=$tstrole]"/>
            <xsl:variable name="found" select="$personnames//x:person/x:persName[text() = $norm] | $personnames//x:person/x:persName[text() = $txt]"/>
            <xsl:element name="persname">
                <xsl:if test="$role">
                    <xsl:attribute name="role"><xsl:value-of select="$role"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$found">
                    <xsl:variable name="parent" select="$found/parent::*"/>
                    <xsl:variable name="key" select="$parent/x:idno[@type='BnF']"/>
                    <xsl:choose>
                        <xsl:when test="$key">
                            <xsl:attribute name="source">BnF</xsl:attribute>
                            <xsl:attribute name="authfilenumber">
                                <xsl:value-of select="$key"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="normal">
                                <xsl:value-of select="$parent/x:persName[@type='standard']"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="x:foreign">
    <emph render="italic"><xsl:apply-templates/></emph>
</xsl:template>

<xsl:template match="x:locus">
    <xsl:choose>
        <xsl:when test="@facs">
            <xsl:element name="extref">
                <xsl:attribute name="show">new</xsl:attribute>
                <xsl:attribute name="actuate">onrequest</xsl:attribute>
                <xsl:attribute name="href"><xsl:call-template name="facslink"/><xsl:value-of select="@facs"/></xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="x:ref">
    <xsl:element name="extref">
        <xsl:attribute name="show">new</xsl:attribute>
        <xsl:attribute name="actuate">onrequest</xsl:attribute>
        <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:q | x:quote | x:title[@type='article']">
    <xsl:choose>
        <xsl:when test="@rend='block'">
            <blockquote><p><xsl:apply-templates/></p></blockquote>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>“</xsl:text><xsl:apply-templates/><xsl:text>”</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="x:term">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template name="synch-format">
    <xsl:text>(</xsl:text>
    <xsl:choose>
        <xsl:when test="@synch or @corresp">
            <xsl:if test="@synch">
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="translate(@synch,'#','')"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="@corresp">
                <xsl:if test="@synch"><xsl:text>; </xsl:text></xsl:if>
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="translate(@corresp,'#','')"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:when>
        <xsl:when test="@scope">
            <xsl:value-of select="@scope"/>
        </xsl:when>
        <xsl:otherwise/>
    </xsl:choose>
    <xsl:text>) </xsl:text>
</xsl:template>

<xsl:template match="x:handDesc">
    <physfacet type="écriture">
        Scribal hands: <xsl:apply-templates select="./node()[not(self::text())]"/>
    </physfacet>
    <lb/>
</xsl:template>
<xsl:template match="x:typeDesc">
    <physfacet type="écriture">
        Typography: <xsl:apply-templates select="./node()[not(self::text())]"/>
    </physfacet>
    <lb/>
</xsl:template>
<xsl:template match="x:decoDesc">
    <xsl:if test="x:decoNote[@type='decorative' or @type='monogram' or @type='coat-of-arms' or @type='paraph' or @type='royal-cypher']">
        <physfacet type="décoration">
            <xsl:apply-templates select="x:decoNote[@type='decorative' or @type='monogram' or @type='coat-of-arms' or @type='paraph' or @type='royal-cypher']"/>
        </physfacet>
        <lb/>
    </xsl:if>
    <xsl:if test="x:decoNote[@type='diagram' or @type='doodle' or @type='drawing' or @type='painting' or @type='table']">
        <physfacet type="illustration">
            <xsl:apply-templates select="x:decoNote[@type='diagram' or @type='doodle' or @type='drawing' or @type='painting' or @type='table']"/>
        </physfacet>
        <lb/>
    </xsl:if>
</xsl:template>
<xsl:template match="x:decoNote">
    <xsl:if test="@corresp or @synch">
        <xsl:call-template name="synch-format"/>
    </xsl:if>
    <xsl:variable name="type" select="@type"/>
    <xsl:call-template name="capitalize">
        <xsl:with-param name="str" select="$TST/tst:decotype/tst:entry[@key=$type]"/>
    </xsl:call-template>
    <xsl:if test="@subtype">
        <xsl:text> (</xsl:text>
        <xsl:variable name="subtype" select="@subtype"/>
        <xsl:call-template name="splitlist">
            <xsl:with-param name="list" select="@subtype"/>
            <xsl:with-param name="nocapitalize">true</xsl:with-param>
            <xsl:with-param name="map">tst:subtype</xsl:with-param>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
        </xsl:if>
    <xsl:if test="normalize-space(.) != ''">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates/>
    </xsl:if>
</xsl:template>
<xsl:template match="x:decoNote/x:desc">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:handNote | x:typeNote">
    <xsl:call-template name="synch-format"/>
    <xsl:apply-templates select="@scribeRef"/>

    <xsl:call-template name="splitlist">    
        <xsl:with-param name="list" select="@script"/>
    </xsl:call-template>
    <xsl:text> script</xsl:text>
    <xsl:if test="@scriptRef and not(@scriptRef='')">
        <xsl:text>: </xsl:text>
        <xsl:call-template name="splitlist">
            <xsl:with-param name="list" select="@scriptRef"/>
            <xsl:with-param name="nocapitalize">true</xsl:with-param>
            <xsl:with-param name="map">tst:scriptRef</xsl:with-param>
        </xsl:call-template>
    </xsl:if>
    <xsl:text>. </xsl:text>

    <xsl:if test="@medium and not(@medium='')">
        <xsl:variable name="donelist">
            <xsl:call-template name="splitlist">
                <xsl:with-param name="list" select="@medium"/>
                <xsl:with-param name="nocapitalize">true</xsl:with-param>
                <xsl:with-param name="map">tst:media</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="capitalize">
            <xsl:with-param name="str" select="$donelist"/>
        </xsl:call-template>
        <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:handNote/@scribeRef | x:typeNote/@scribeRef">
    <xsl:if test="not(. = '')">
        <xsl:variable name="scribe" select="."/>
        <xsl:value-of select="$TST/tst:scribes/tst:entry[@key=$scribe]"/>
        <xsl:text>. </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="x:handNote/x:desc | x:typeNote/x:desc">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:origPlace">
    <geogname role="5020"><xsl:apply-templates/></geogname>
    <lb/>
</xsl:template>

<xsl:template match="x:origDate">
    <xsl:variable name="date">
        <xsl:choose>
            <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
            <xsl:when test="@notBefore and @notAfter">
                <xsl:value-of select="@notBefore"/><xsl:text>/</xsl:text><xsl:value-of select="@notAfter"/>
            </xsl:when>
            <xsl:when test="@notAfter">
                <xsl:value-of select="@notAfter"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:variable>
    <unitdate calendar="gregorian" era="ce">
        <xsl:if test="$date">
            <xsl:attribute name="normal"><xsl:value-of select="$date"/></xsl:attribute>
            <xsl:value-of select="$date"/><xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </unitdate>
</xsl:template>

<xsl:template match="x:origDate//x:persName">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template name="textLang">
    <xsl:variable name="mainlang" select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem[1]/x:textLang/@mainLang"/>
    <xsl:variable name="mainlangs" select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem[position() > 1]/x:textLang/@mainLang"/>
    <xsl:variable name="otherlanglists" select="x:teiHeader/x:fileDesc/x:sourceDesc/x:msDesc/x:msContents/x:msItem/x:textLang/@otherLangs"/>

    <language>
        <xsl:attribute name="langcode"><xsl:value-of select="$TST/tst:iso6392b/tst:entry[@key=$mainlang]"/></xsl:attribute>
        <xsl:value-of select="$TST/tst:langs/tst:entry[@key=$mainlang]"/>
    </language>

    <xsl:if test="$mainlangs or $otherlanglists">
        <xsl:variable name="alllangs">
            <xsl:for-each select="$otherlanglists">
                <xsl:call-template name="genericsplit">
                    <xsl:with-param name="list" select="."/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="$mainlangs">
                <tst:node><xsl:value-of select="."/></tst:node>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="uniquelangs">
            <xsl:for-each select="exsl:node-set($alllangs)/node()">
                <xsl:sort select="text()"/>
                <xsl:if test="text() != $mainlang">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="exsl:node-set($uniquelangs)/node()">
            <xsl:variable name="code" select="text()"/>
            <xsl:variable name="pos" select="position()"/>
            <xsl:if test="not($code = $mainlang) and
                         ( $pos = last() or not($code=following-sibling::*/text()) )">
                <xsl:if test="$pos = 1">
                    <xsl:text> (+ </xsl:text>
                </xsl:if>
                <language>
                    <xsl:attribute name="langcode"><xsl:value-of select="$TST/tst:iso6392b/tst:entry[@key=$code]"/></xsl:attribute>
                    <xsl:value-of select="$TST/tst:langs/tst:entry[@key=$code]"/>
                </language>
                <xsl:choose>
                    <xsl:when test="not($pos = last())">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:if>
</xsl:template>

<!--xsl:template match="x:textLang">
        <xsl:variable name="mainLang" select="@mainLang"/>
        <language>
            <xsl:attribute name="langcode"><xsl:value-of select="$TST/tst:iso6392b/tst:entry[@key=$mainLang]"/></xsl:attribute>
            <xsl:value-of select="$TST/tst:langs/tst:entry[@key=$mainLang]"/>
        </language>
        <xsl:if test="@otherLangs and not(@otherLangs='')">
            <xsl:variable name="otherlangs">
                <xsl:call-template name="genericsplit">
                    <xsl:with-param name="list" select="@otherLangs"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:text> (+ </xsl:text>
            <xsl:for-each select="exsl:node-set($otherlangs)/node()">
                <xsl:variable name="code" select="./text()"/>
                <xsl:element name="language">
                    <xsl:attribute name="langcode">
                        <xsl:value-of select="$TST/tst:iso6392b/tst:entry[@key=$code]"/>
                    </xsl:attribute>
                    <xsl:value-of select="$TST/tst:langs/tst:entry[@key=$code]"/>
                </xsl:element>
                <xsl:if test="not(position() = last())">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
        </xsl:if>
</xsl:template-->

<xsl:template match="x:pc">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:seg">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="x:list">
    <list>
        <xsl:apply-templates/>
    </list>
</xsl:template>

<xsl:template match="x:g">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="ename" select="$TST//tst:entitynames/tst:entry[@key=$ref]"/>
        <xsl:variable name="txt" select="$TST//tst:entities/tst:entry[@key=$ref]"/>
    <xsl:if test="$ename">
        <xsl:text>{</xsl:text><xsl:value-of select="$ename"/><xsl:text>}</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="x:emph">
    <xsl:element name="emph">
        <xsl:if test="@rend='bold' or @rend='boldface'">
            <xsl:attribute name="render">bold</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/> 
    </xsl:element>
</xsl:template>

<xsl:template match="x:hi">
    <xsl:element name="emph">
        <xsl:choose>
            <xsl:when test="@rend='bold' or @rend='boldface'">
                <xsl:attribute name="render">bold</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='subscript'">
                <xsl:attribute name="render">sub</xsl:attribute>
            </xsl:when>
            <xsl:when test="@rend='superscript'">
                <xsl:attribute name="render">super</xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <xsl:apply-templates/> 
    </xsl:element>
</xsl:template>

<xsl:template match="x:subst | x:choice">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:del">
    <emph render="bold"><xsl:text>〚</xsl:text></emph>
    <xsl:apply-templates/>
    <emph render="bold"><xsl:text>〛</xsl:text></emph>
</xsl:template>

<xsl:template match="x:ex">
    <emph render="bold"><xsl:text>[</xsl:text></emph>
    <xsl:apply-templates/>
    <emph render="bold"><xsl:text>]</xsl:text></emph>
</xsl:template>

<xsl:template match="x:placeName | x:geogName | x:orgName">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template name="import-milestone">
    <xsl:if test="self::x:fw or @function">
        <xsl:variable name="testnode">
            <xsl:call-template name="firstmilestone">
                <xsl:with-param name="start" select="./node()[1]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="innermilestone" select="exsl:node-set($testnode)/node()[1]"/>
        <xsl:if test="not($innermilestone) or not($innermilestone[local-name() = 'milestone' or local-name = 'pb']) or not($innermilestone/@n)">
            <xsl:variable name="milestone" select="preceding::*[(self::x:milestone and (@unit = 'folio' or @unit = 'page') ) or self::x:pb][1]"/>
            <xsl:if test="$milestone">
                <xsl:apply-templates select="$milestone">
                    <xsl:with-param name="excerpt">yes</xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:if>
    </xsl:if>
</xsl:template>

<xsl:template name="import-lb">
    <xsl:if test="self::x:fw or @function">
        <xsl:variable name="testnode">
            <xsl:call-template name="firstmilestone">
                <xsl:with-param name="start" select="./node()[1]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="milestone" select="exsl:node-set($testnode)/node()[1]"/>
        <xsl:if test="not($milestone)">

            <xsl:variable name="lb" select="preceding::*[self::x:lb][1]"/>
            <xsl:if test="$lb">
                <xsl:apply-templates select="$lb">
                    <xsl:with-param name="hyphen">no</xsl:with-param>
                </xsl:apply-templates>
                <xsl:text>>[…]</xsl:text>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:if>
</xsl:template>
</xsl:stylesheet>
