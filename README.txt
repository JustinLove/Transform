= transform

* https://github.com/JustinLove/Transform

== DESCRIPTION:

Perform simple transformations on row,column type data

== SYNOPSIS:

Operate directly on csv files

  require 'transform/csv'
  Transform.csv2csv('mint.csv', 'ynab.csv') do
    # Date, Description, Original Description, Amount, Transaction Type, Category, Account Name, Labels, Notes
    copy 'Date'
    rename 'Description', 'Payee'
    rename 'Original Description', 'Memo'
    map ['Amount', 'Transaction Type'], 'Inflow' do |amount, type|
      amount if type == 'credit'
    end
    map ['Amount', 'Transaction Type'], 'Outflow' do |amount, type|
      amount if type == 'debit'
    end
    # Date, Payee, Category, Memo, Outflow, Inflow
  end

Directly on Arrays (or other objects that use #shift and #<<)

  require 'transform'
  output = Transform.transform([%w{name digit}, %w{one 1}], []) do
    map 'name', 'NAME' do |name| name.upcase end
    map 'digit', 'digit' do |digit| digit.to_i.succ.to_s end
  end
  p output

== REQUIREMENTS:

Built assuming csv is FasterCSV

== INSTALL:

Not a gem yet.

== LICENSE:

(The MIT License)

Copyright (c) 2010 Justin Love

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
