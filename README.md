# Tablemaker

HTML table generator that allows arbitrary nested cell subdivisions
and applies colspan/rowspan as needed.

[![Build Status](https://travis-ci.org/levinalex/tablemaker.svg?branch=master)](https://travis-ci.org/levinalex/tablemaker)

Including the gem in your Rails project will give you a new view helper `make_table`

## Usage

```slim
- items = ['E', 'F']

= make_table(class: 'foo') do |t|
  - t.row do
    - t.th("A", tr_opts: {class: 'th'})
    - t.th("B")
    - t.th("C")
  - t.row do
    - t.column do
      - items.each_with_index do |item, idx|
        - t.td(item, tr_opts: {'data-id': idx})
  - t.td(style: 'background: green', tr_opts: {class: 't-footer'}) do
    p cell content
    
  
    
```

this will generate this output:

<table class="foo">
    <tr class="th">
        <th>A</th>
        <th>B</th>
        <th>C</th>
    </tr>
    <tr data-id="0">
        <td colspan="3">E</td>
    </tr>
    <tr data-id="1">
        <td colspan="3">F</td>
    </tr>
    <tr class="t-footer">
        <td style="background: green" colspan="3">
            <p>cell content</p>
        </td>
    </tr>
</table>


source:

```html
<table class="foo">
    <tr class="th">
        <th>A</th>
        <th>B</th>
        <th>C</th>
    </tr>
    <tr data-id="0">
        <td colspan="3">E</td>
    </tr>
    <tr data-id="1">
        <td colspan="3">F</td>
    </tr>
    <tr>
        <td style="background: green" colspan="3">
            <p>cell content</p>
        </td>
    </tr>
</table>
```

You can use `make_table_without_tag` to render part of a table.
You can pass attributes to `<tr>` tag from first cell in row/column using `tr_opts` 

```slim
table
  thead
    tr
      th A
      th B
      th C
  tbody
    = make_table_without_tag(id: 'first-row') do |t|
      - t.row do
        - t.column do
          - items.each_with_index do |item, idx|
            - t.td(item, tr_opts: { 'data-id': idx })    
```

source: 
```html
<tr id="first-row" data-id="0">
    <td>E</td>
</tr>
<tr data-id="1">
    <td>F</td><
/tr>
```

## Examples outside Rails

A very basic table:

```ruby
# +---+---+
# | A | B |
# +---+---+
# | C | D |
# +---+---+
#
@table2 = Tablemaker.column do |c|
  c.row do |r|
    r.cell("A")
    r.cell("B")
  end
  c.row do |r|
    @c2 = r.cell("C")
    @d2 = r.cell("D")
  end
end

# but you can also start with columns and construct the table left-to-right. this produces the exact same result:
#
Tablemaker.row do |r|
  r.column do |c|
    c.cell("A")
    c.cell("C")
  end
  r.column do |c|
    c.cell("B")
    c.cell("D")
  end
end
```

A more advanced example:

```ruby
# +---+---+---+
# |   | B |   |
# |   +---+ C |
# |   | D |   |
# | A +---+---+
# |   |   | F |
# |   | E +---+
# |   |   | G |
# +---+---+---+
#
@table = Tablemaker.row do |t|
  t.cell("A")
  t.column do |r|
    r.row do |c|
      c.column do |rr|
        rr.cell("B")
        rr.cell("D")
      end
      c.cell("C")
    end
    r.row do |c|
      c.cell("E")
      c.column do |rr|
        rr.cell("F")
        rr.cell("G")
      end
    end
  end
end
```

this will generate the following output:

<table>
  <tr>
    <td rowspan=4>A</td>
    <td rowspan=2>B</td>
    <td>D</td>
  </tr>
  <tr>
    <td>E</td>
  </tr>
  <tr>
    <td rowspan=2>C</td>
    <td>F</td>
  </tr>
  <tr>
    <td>G</td>
  </tr>
</table>


Tablemaker keeps track of all the rowspan/colspan attributes required to generate a valid HTML table
