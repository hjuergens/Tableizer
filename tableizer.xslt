<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl" >
    <xsl:output method="html" encoding="utf-8" indent="yes" />

    <xsl:key name="kProd1" match="product" use="@category"/>

<xsl:template match="/root">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>

    <html>

    <xsl:variable name="column_names">
        <xsl:for-each select="//product[count(. | key('kProd1', @category)[1]) = 1]">
        <!-- xsl:for-each select="//product
             [generate-id() =  generate-id(key('kProd1', @category)[1]) ]" -->
            <xsl:sort select="@category" />
            <xsl:element name="column_name">
                <xsl:value-of select="@category"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>

    <table>
        <thead>
        <tr>
            <!-- <xsl:for-each select="$column_names"> does not work -->
            <!-- https://www.xml.com/pub/a/2003/07/16/nodeset.html -->
            <xsl:for-each select="exsl:node-set($column_names)/column_name">
                <th>
                <xsl:value-of select="current()"/>
                </th>
            </xsl:for-each>
        </tr>
        </thead>
        <tbody>
        <xsl:for-each select="/root/group">
            <tr>
                <xsl:variable name="current_group" select="." />
                <xsl:for-each select="exsl:node-set($column_names)/column_name">
                    <td>
                        <xsl:variable name="var_category"><xsl:value-of select="./text()"/></xsl:variable>
                        <xsl:attribute name="name"><xsl:value-of select="$var_category"/></xsl:attribute>
                        <xsl:value-of select="$current_group/product[@category=$var_category]/text()" />
                    </td>
                </xsl:for-each>
            </tr>
        </xsl:for-each>
        </tbody>
    </table>

    </html>
</xsl:template>

</xsl:stylesheet>