# Tableizer
Displays irregular row contents in a common table. Considers each row variation and fill in necessary empty cells.

# Introduction

Let us look onto the following XML fragment:
```
<root>
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
</root>
```
We observe three groups with two products each which are assigned to a exactly
one category out of three. Our aim ist to create a table with the columns
showing the assignment to a category and the groups building the rows.


# Collect all Columns

First we collect all distinct categories.

The following fragement was found here
[/how-to-select-distinct-values-from-xml-document-using-xpath](https://stackoverflow.com/questions/2871707/how-to-select-distinct-values-from-xml-document-using-xpath)
```
    <xsl:variable name="column_names">
        <!-- <xsl:for-each select="//product[count(. | key('products-by-category', @category)[1]) = 1]"> -->
        <xsl:for-each select="//product
             [generate-id() =  generate-id(key('kProd1', @category)[1]) ]">
            <xsl:sort select="@category" />
            <xsl:element name="column_name">
                <xsl:value-of select="@category"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
```
Explained:
* The expression `key('kProd1', @category)[1]` returns only the first Product
with the same Category
* The expression `generate-id() =  generate-id(key('kProd1', @category)[1])`
will be true only for the first Product with the current Category
* `<xsl:element name="column_name">` will assign the Category 
to a new node `column_name`

You may also consider the expression:
```
<xsl:for-each select="//product[count(. | key('kProd1', @category)[1]) = 1]">
```
see 
[XSLT/Muenchian grouping - Wikipedia](https://en.wikipedia.org/wiki/XSLT/Muenchian_grouping)
for a detailed description.

# Iterate over frayed data

## Column headers

-[ ] Explain the nedd for `exsl:node-set`
```
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
```

## Rows

```
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
```
Explained
-[ ] Explain


# Result

| A   | B   | C   |
|-----|-----|-----|
| A1  |     | C1  |
 | A2  | B2  |     |
 |     | B3  | C3  |

