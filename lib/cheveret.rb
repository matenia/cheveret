#--
# Copyright (c) 2010 RateCity Pty. Ltd.
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
  class Column
    attr_accessor :name, :data, :flexible, :label, :sortable, :width

    def initialize(column_name, config={})
      config.merge(:name => column_name).each do |k, v|
        send("#{k}=", v) if respond_to?(k)
      end
    end

    def flexible?
      @flexible != false
    end

    def label
      case @label
      when nil then @name.to_s.humanize # todo: support i18n for column labels
      when false then nil
      else @label
      end
    end

    # returns +true+ unless a column has explicitly set <tt>:sortable => false</tt>
    def sortable?
      @sortable != false
    end

    def width
      @width || 0
    end
  end

  module Helpers
    def define_table(&block)
      # fixme: rename temporary table builder class
      TableBuilder.new(self, &block)
    end

    class TableBuilder
      def initialize(template, &block)
        @template = template
        @columns  = ::ActiveSupport::OrderedHash.new

        # dsl block gets eval'd in the instance, method_missing forwards calls to the
        # template so that blocks get output correctly
        instance_eval(&block) if block_given?
      end

      def header_default(&block) ; end

      def data_default(&block) ; end

      # registers a new column with the specified options
      #
      # @example minimum required to define a column
      #   column :author
      #
      # @example flexible width, sortable column
      #   column :description => [ :flexible, :sortable ]
      #
      # @example fixed with column with no header label
      #   column :check_box, :label => false, :width => 30
      #
      # @example sortable column with custom header label
      #   column :published => [ :sortable ], :label => "Publish Date"
      #
      # @param [Symbol,Array] name_or_hash
      #   the name of the column, optionally combined with any flags that should be
      #   set to +true+
      #
      # @param [Hash] options a hash of options for the column
      #
      # @option options [Proc] :data
      #
      # @option options [Boolean] :flexible (false)
      #   if +true+ the column will resize automatically depending on the size of the
      #   table
      #
      # @option options [Proc] :header
      #
      # @option options [String,Boolean] :label
      #   used to determine what gets used as a label in the column header. if set to
      #   +false+ no lable will be rendered
      #
      # @option options [Boolean] :sortable (false)
      #
      # @option options [Integer] :width
      def column(name_or_hash, options={})
        if name_or_hash.is_a?(Hash)
          name = name_or_hash.except(:label, :width).keys.first
          name_or_hash.delete(name).each { |k| options[k] = true }
          options.merge!(name_or_hash)
        else
          name = name_or_hash
        end

        if @columns[name].present?
          options.each { |k, v| @column[name].send(:"#{k}=", v) }
        else
          @columns[name] = Column.new(name, options)
        end
      end

      def columns ; end

      # define how to extract and render data value for a particular column
      #
      # chevert will call the block you define here to render the inner part of the
      # table data cell for each object in the collection
      #
      # if you don't specify one or more column names when calling this method,
      # cheveret will assume that you're defining the data block for the last column
      # you registered
      #
      # @example format money values in the view
      #   - column :price
      #   - data do |book|
      #     %span= number_to_currency book.price
      #
      # @example define data block for multiple columns
      #   - column :title
      #   - column :author
      #   - data [ :title, :author ] do |column, object|
      #     %p{ :class => column.name }= object.send(column.name)
      def data(*args, &block)
        options = args.extract_options!

        [ *args.first || @columns.keys.last ].each do |column_name|
          column = @columns[column_name ]
          column.data = block

          instance_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def data_for_#{column.name}(object)
              capture(object, &@columns[:#{column.name}].data)
            end
          RUBY_EVAL
        end
      end

      def render(collection, options={})
        resize!(options.delete(:width)) if options[:width].present?

        content_tag(:div, :class => 'table') do
          header(options) + body(collection, options)
        end
      end

      def header(options={})
        url = options.delete(:url) || {} # todo: current controller action

        content_tag(:div, :class => 'thead') do
          @columns.values.map do |column|
            cell(:th, column) do
              if column.sortable?
                content_tag(:a, column.label)
              else
                column.label
              end
            end
          end
        end
      end

      def body(collection, options={})
        content_tag(:div, rows(collection), {
          :class => 'tbody'
        })
      end

      def rows(collection, options={})
        collection.map { |object| row(object) }
      end

      # render a single table row for the specified data object
      #
      # @param [Object] object
      # @param [Hash]   options
      #
      # @option options [Array] :only
      # @option options [Array] :except
      # @option options [Array,String] :class
      # @option options [Integer] :width
      def row(object, options={})
        # todo: allow :only and :except to not be an array
        cols = @columns.keys.reject { |k| !options[:only].include?(k) } if options[:only]
        cols = @columns.keys.reject { |k| options[:except].include?(k) } if options[:except]
        cols ||= @columns.keys

        content_tag(:div, :class => 'tr') do
          cols.map do |column_name|
            column = @columns[column_name]
            cell(:td, column) { send(:"data_for_#{column.name}", object) rescue nil }
          end
        end
      end

      def cell(type, column, &block)
        content_tag(:div, yield, {
          :class => [type, column.name].join(' '),
          :style => "width: #{@widths[column.name] || column.width}px;"
        })
      end

      def resize!(new_width)
        @widths = {}

        columns_width = 0
        flexibles     = []

        @columns.values.each do |column|
          columns_width += column.width
          flexibles << column if column.flexible?
        end

        # todo: handle too-many/too-wide columns
        raise "uh-oh spaghettio-s" if columns_width > new_width

        # todo: fix rounding in with calculation
        # todo: trim last column that fits into table width if necessary
        if columns_width < new_width && !flexibles.empty?
          padding = (new_width - columns_width) / flexibles.length
          flexibles.each { |column| @widths[column.name] = column.width + padding }
        end
      end

    protected

      def method_missing(method_name, *args, &block) #:nodoc:
        if @template.respond_to?(method_name)
          @template.send(method_name, *args, &block)
        else
          super
        end
      end
    end
  end

  ActionView::Base.class_eval do
    cattr_accessor :default_table_builder
    self.default_table_builder = ::Cheveret::Helpers::TableBuilder
  end
end