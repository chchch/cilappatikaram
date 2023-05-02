<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

    <xsl:import href="../definitions.xsl"/>

    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>

    <xsl:template name="preface">
    \newpage
    \begin{center}\textsc{TST Diplomatic Editions}\\

    \quotation{This edition has been published as part of the Texts Surrounding Texts project, funded jointly by the Agence nationale de la recherche in France and the Deutsche Forschungsgemeinschaft in Germany. TST Diplomatic Editions publishes unique and important manuscripts from the collection of the Bibliothèque nationale de France.}
    \end{center}
    </xsl:template>

</xsl:stylesheet>
