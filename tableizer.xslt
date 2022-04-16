<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="utf-8" indent="yes"/>

    <!-- ignoring empty categories with [not(@category='')] -->
    <xsl:key name="key_category" match="grouping/group/product" use="@category"/>

    <xsl:template match="/grouping">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>

        <html>

            <table>
                <xsl:attribute name="class"><xsl:value-of select="name()" /></xsl:attribute>
                <thead>
                    <tr>
                        <xsl:for-each select="group/product[@category and count(. | key('key_category', @category)[1]) = 1]">
                            <xsl:sort select="@category"/>
                            <th>
                                <xsl:attribute name="id">
                                    <xsl:value-of select="@category"/>
                                </xsl:attribute>
                                <xsl:value-of select="@category"/>
                            </th>
                        </xsl:for-each>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="/grouping/group">
                        <tr>
                            <xsl:attribute name="class"><xsl:value-of select="name()" /></xsl:attribute>
                            <xsl:variable name="var_current_group" select="."/>
                            <xsl:for-each select="//product
                                 [generate-id() =  generate-id(key('key_category', @category)[1]) ]">
                                <xsl:sort select="@category"/>
                                <td>
                                    <xsl:attribute name="class"><xsl:value-of select="name()" /></xsl:attribute>
                                    <xsl:variable name="var_category">
                                        <xsl:value-of select="@category"/>
                                    </xsl:variable>
                                    <xsl:attribute name="headers">
                                        <xsl:value-of select="$var_category"/>
                                    </xsl:attribute>
                                    <!--
                                    <xsl:for-each select="$var_current_group/product[@category=$var_category]">
                                        <xsl:if test="position() > 1">,</xsl:if>
                                        <xsl:value-of select="text()" />
                                    </xsl:for-each>
                                    -->
                                    <xsl:for-each select="$var_current_group/product[@category=current()/@category]">
                                        <xsl:if test="position() > 1">,</xsl:if>
                                        <xsl:value-of select="text()" />
                                    </xsl:for-each>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>

        </html>
    </xsl:template>

</xsl:stylesheet>