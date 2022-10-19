# Tableizer
Displays irregular row contents in a common table. Considers each row variation and fill in necessary empty cells.

# Introduction

Let us look onto the following XML fragment:
```
<grouping>
    <group>
        <product category="A">A1</product>
        <product category="C">C1</product>
    </group>
    <group>
        <product category="A">A2</product>
        <product category="B">B2</product>
    </group>
    <group>
        <product category="B">B3</product>
        <product category="C">C3</product>
    </group>
</grouping>
```
We observe three groups with two products each which are assigned to a exactly
one category out of three. Our aim ist to create a table with the columns
showing the assignment to a category and the groups building the rows.


# Collect all Columns

First we collect all distinct categories.

The following fragement was found here
[/how-to-select-distinct-values-from-xml-document-using-xpath](https://stackoverflow.com/questions/2871707/how-to-select-distinct-values-from-xml-document-using-xpath)
```xml
    <xsl:variable name="column_names">
        <!--
            for description see below: <xsl:for-each select="//product[@category and count(. | key('products-by-category', @category)[1]) = 1]">
         -->
        <xsl:for-each select="//product
             [generate-id() =  generate-id(key('key_category', @category)[1]) ]">
            <xsl:sort select="@category" />
            <xsl:element name="column_name">
                <xsl:value-of select="@category"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
```
Explained:
* The expression `key('key_category', @category)[1]` returns only the first Product
with the same Category
* The expression `generate-id() =  generate-id(key('key_category', @category)[1])`
will be true only for the first Product with the current Category
* `<xsl:element name="column_name">` will assign the Category 
to a new node `column_name`

You may also consider the expression:
```xml
<xsl:for-each select="//product[count(. | key('key_category', @category)[1]) = 1]">...</xsl:for-each>
``` 

see 
[XSLT/Muenchian grouping - Wikipedia](https://en.wikipedia.org/wiki/XSLT/Muenchian_grouping)
for a detailed description.

# Iterate over frayed data

## Column headers

With the help of the `exsl:node-set` variable defined above
```xml
 <thead>
    <tr>
       <!-- https://www.xml.com/pub/a/2003/07/16/nodeset.html -->
       <xsl:for-each select="exsl:node-set($column_names)/column_name">
          <th>
             <xsl:value-of select="current()"/>
          </th>
       </xsl:for-each>
    </tr>
 </thead>
```

or the plain vanilla version without any extensions
```xml
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
```
Explained:
* Take the first element of all products with same
category as the current on:`key('key_category', @category)[1]`
* Count number of nodes in the union of the current one (.) 
and the first from node set (see above). Take it if it's one:
`count(. | key('key_category', @category)[1]) = 1]`

## Rows

To build the rows of the table we iterate over the groups.
With the help of the `exsl:node-set` variable defined above the iteration
may look like this:
```xml
<xsl:for-each select="/grouping/group">
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
```
Or the plain vanilla version without any extensions
```xml
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
                <xsl:for-each select="$var_current_group/product[@category=$var_category]">
                    <xsl:if test="position() > 1">,</xsl:if>
                    <xsl:value-of select="text()" />
                </xsl:for-each>
            </td>
        </xsl:for-each>
    </tr>
</xsl:for-each>
```
Explained:
* Here are two loops:
  * outer loop over the row data `select="/grouping/group"` and
  * inner loop over the columns `select="//product[generate-id() =  generate-id(key('key_category', @category)[1]) ]"` 
* The current position of the outer loop has to be stored with
`<xsl:variable name="var_current_group" select="."/>` to be 
accessible in the inner loop.
* The expression `select="$var_current_group/product[@category=current()/@category]"`
selects the data for the current column.

# Result

| A   | B   | C   |
|-----|-----|-----|
| A1  |     | C1  |
 | A2  | B2  |     |
 |     | B3  | C3  |

