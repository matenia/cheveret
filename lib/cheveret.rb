#--
# Copyright (c) 2010 RateCity
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Cheveret
  module TableHelper
    # renders a table for a collection of objects
    #
    # === Parameters
    # collection<Array,Collection>::
    #
    # options<Hash>::
    #
    #   * +:width+ - total width of the table in pixels. this value is used when
    #                calculating the widths of any flexible columns. required
    #
    #   * +:url+   - todo
    #
    #   * +:scope+ - the i18n localisation scope to use when looking up
    #                translations for column headers
    #
    #   * +:html+  - a hash which is transformed directly into html attributes
    #                for the enclosing table tag
    #
    def table_for(collection, *args, &block)
      raise ArgumentError, "Missing required block" unless block_given?

      options = args.extract_options!

      options[:html] ||= {}
      options[:html][:style] = "width: #{options[:width]}px"

      # todo: wrap this puppy in a div
      content_tag(:div, options[:html]) do
        builder = options[:builder] || Cheveret::Base.default_table_builder
        capture(builder.new(collection, self, options), &block)
      end
    end
  end

  class TableBuilder
    def initialize(collection, template, options)
      @collection, @template, @options = collection, template, options # todo: add other init variables
    end

    # define columns for the table
    def columns(&block)
      @columns = ::ActiveSupport::OrderedHash.new
      yield
    end

    # registers a column
    #
    # === Parameters
    # name<Symbol>::
    #   an identifier for the column. ideally, this should match the method on
    #   your data object so that table data cells can be automagically generated
    #
    # options<Hash>::
    #   a hash of configuration options for the column. available options are:
    #
    #   * +:width+ - the minimum width of the column in pixels. this should
    #                almost always be specified for fixed-width columns. this is
    #                used as the miniumum width when rendering flexible columns
    #
    def column(name, options={})
      @columns ||= ::ActiveSupport::OrderedHash.new

      options.reverse_merge!({ :width => 0 }) # todo: more defaults
      @columns[name] = options
    end

    # registers a fixed with column
    #
    # this is a wrapper method for #column that forces the :flexible option to a
    # +false+ value
    #
    # === Paramters
    # name<Symbol>::
    #
    # options<Hash>::
    #
    def fixed(name, options={})
      options[:flexible] = false
      column(name, options)
    end

    # registers a flexible width column
    #
    # a wrapper around the #column method which forces the :flexible option to
    # +true+
    #
    # === Parameters
    # name<Symbol>::
    #
    # options<Hash>::
    def flexible(name, options={})
      options[:flexible] = true
      column(name, options)
    end

    # shortcut method for showing a column. this is useful if you have some
    # columns that are hidden by default, but need to be displayed on some
    # condition. sets the :visible option to +true+
    #
    # === Parameters
    # name<Symbol>::
    #   the name of the column to show
    #
    def show(name)
      @columns[name][:visible] = true if @columns[name]
    end

    # shortcut method for hiding a column. hidden columns are not rendered in
    # the table or considered when calculating column widths. sets the :visible
    # option to +false+
    #
    # === Parameters
    # name<Symbol>::
    #   the name of the column to hide
    #
    def hide(name)
      @columns[name][:visible] = false if @columns[name]
    end

    # renders markup for the table header
    def header(&block)
      normalize_widths

      row = @template.content_tag(:div, :class => "tr") do
        map_columns(:th) do |name |
          # todo: prevent output of empty <a> tag for header label
          output   = nil_capture(name, &block) if block_given?
          output ||= @template.content_tag(:a, label_for_column(name))
        end
      end

      @template.content_tag(:div, row,
        :class => "thead",
        :style => "width: #{@options[:width]}px;") # todo: missing width?
    end

    # renders the table body, listing the supplied collection of items in table
    # format using the configured columns
    def body(&block)
      rows = @collection.map do |object|
        object_name = object.class.to_s.split('::').last.underscore || ''
        # todo: render alt class for zebra stripes in body
        @template.content_tag(:div, :class => ['tr', object_name].join(' ')) do
          map_columns(:td) do |name|
            output   = nil_capture(name, object, &block) if block_given?
            output ||= @template.content_tag(:span, data_for_column(name, object))
          end
        end
      end

      @template.content_tag(:div, rows.join,
        :class => "tbody",
        :style => "width: #{@options[:width]}px;") # todo: missing width?
    end

  private

    def map_columns(type, &block) #:nodoc:
      @columns.map do |name, options|
        attrs = {
          :class => [type, name].join(' '),
          :style => "width: #{options[:width]}px;" }

        @template.content_tag(:div, attrs) do
          yield(name)
        end unless options[:visible] == false
      end
    end

    def nil_capture(*args, &block) #:nodoc:
      custom = @template.capture(*args, &block).strip
      output = custom.empty? ? nil : custom
    end

    def label_for_column(name) #:nodoc:
      case @columns[name][:label]
      when nil
        "translation" # todo: localisation support
      when false
        nil
      else @columns[name][:label]
      end
    end

    def data_for_column(column_name, object) #:nodoc:
      object.send(column_name) if object.respond_to?(column_name)
    end

    def normalize_widths #:nodoc:
      table_width, columns_width, flexible_columns = @options[:width], 0, []

      @columns.each do |name, options|
        columns_width += options[:width]
        flexible_columns << name unless options[:flexible] == false
      end

      # todo: handle too-many/too-wide columns
      raise "uh-oh spaghettio-s" if columns_width > table_width

      if columns_width < table_width && !flexible_columns.empty?
        # todo: fix rounding in with calculation
        pad_width = (table_width - columns_width) / flexible_columns.length
        flexible_columns.each do |name|
          # todo: trim last column that fits into table width if necessary
          @columns[name][:width] += pad_width
        end
      end
    end
  end

  class Base #:nodoc:
    # todo: move default_table_builder to ActionView::Base
    cattr_accessor :default_table_builder
    self.default_table_builder = ::Cheveret::TableBuilder
  end
end