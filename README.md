Cheveret
========

A Rails library for generating flexible width HTML tables.

_**Cheveret**: (noun) a small English table of the 18th century, having an oblong top, one or two rows of drawers, and slender legs joined near the bottom by a shelf._

Install
-------

Cheveret was developed for Rails 2.3.8 and might work with more recent versions. There are no other dependencies aside from Rails itself.

To install using Bundler simply add the following to your `Gemfile` and run a `bundle install`:

    gem 'cheveret', :git => 'git@github.com:ratecity/cheveret.git'

Usage
-----

Generating HTML tables of data in the views of your Rails application is not very **DRY** even for the simpler of cases. Cheveret allows you to more clearly separate logic and templating and reduce the amount of code in your views.

There are several ways to define the structure of a table using Cheveret, the simplest being via the `tabulatable` method in your `ActiveRecord` models:

    class Book < ActiveRecord::Base
      tabulatable do |t|
        t.flexible :title
        t.column   :author       :width => 200, :flexible => true
        t.column   :release_date :width => 100, :label=> false
        t.sortable :amount,
        t.fixed    :add_to_cart, :width => 120, :display => false
      end

      ...

    end

An instance of `Cheveret::Table` will then be configured on your model, accessible via `.cheveret`.

### Rendering

You can now render a table in your view by using the `cheveret_table` helper:

    = cheveret_table_for @books

If your view should only display a subset of the defined columns in the table (e.g. not display the _add to cart_ button for non-authenticated users), supply either `:only` or `:exclude`:

    = cheveret_table_for @books, :exclude => :add_to_cart

### Header

By default, Cheveret will attempt to use i18n to look up a sensible label for your column headers using the `cheveret.#{object.human_name}.#{column_name}.label` scope, where `object` is the object in which your columns are defined. If a translation is found at `.desc` in the same scope, it will be used as the HTML `title` attribute of the label element.

The default behaviour can be overridden by way of the `:label` option when defining your columns. Prevent the label from being rendered altogether by specifying `:label => false`.

Lastly, you can completely override the markup for each header cell by using the `cheveret_headers_for` helper and supplying a block:

    = cheveret_headers_for @books do |name, column|
      - case name
      - when :add_to_cart
        = image_tag("add_to_cart.png")

In the above example, the block will be called once for each column in the table and render the results. There are two exceptions to this behaviour:

1. if the return value is `nil`, Cheveret will render standard markup using the columns `:label` setting

2. otherwise, if the return value is `false`, no markup will be rendered

### Body

When rendering the table body, Cheveret assumes it's dealing with `ActiveRecord` model objects (or similar) and that you have _named your columns to match your data_. To get a value for each table cell it will call `object.send(column_name)` to each of your objects.

This is sufficient for a list of simple `ActiveRecord` instances, but what if you need to format values, or you want to list something else? Enter the `cheveret_body_for` helper:

    = cheveret_body_for @books do |name, column, book|
      - case name
      - when :amount
        = number_to_currency(book.amount)

This behaves in the same way as `cheveret_header`, except for the additional 3rd argument passed to the block, which gives access to the data object being rendered.

You could, for example, create a column that is an aggregate of more than one attribute:

    = cheveret_body_for @books do |name, column, book|
       - case name
       - when :title
         = "#{book.title} (#{book.edition})"

Or, if you're using _Sunspot_, list stored search results without hitting the database to get model objects:

    = cheveret_body_for @books do |name, column, book|
      = book.stored(name)

Todo
----

* Make the documentation tell fewer lies
* Support i18n translations for table headers
* Handle exceeding table width, drop columns

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Maintainers & Contributors
--------------------------

* Ben Caldwell - http://github.com/lankz

Copyright
---------

Copyright (c) 2010 RateCity. See LICENSE for details.