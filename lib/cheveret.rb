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

require 'forwardable'

module Cheveret
  class Table
    attr_accessor :columns

    def initialize(&block)
      @columns = ::ActiveSupport::OrderedHash.new
      yield self if block_given?
    end

    def columns(*args, &block)
      return @columns.values unless block_given?
      instance_eval(&block)
      # todo: support populating columns from an array
      # todo: attempt to automatically resolve columns from activerecord etc.
    end

    def add_column(column_name, config={})
      @columns[column_name] = Column.new(column_name, config)
    end

    alias_method :column, :add_column

    def fixed(column_name, config={})
      add_column(column_name, config.merge({ :flexible => false }))
    end

    def flexible(column_name, config={})
      add_column(column_name, config.merge({ :flexible => true }))
    end

    def hidden(column_name, config={})
      add_column(column_name, config.merge({ :visible => false }))
    end

    def remove_column(column_name)
      # todo: allow columns to be removed, not sure why you'd want to do this. maybe
      # just set :visible => false instead?
      raise NotImplementedError
    end

    def resize!(new_width)
      return true if new_width == @width
      @width = new_width

      columns_width = 0
      flexibles     = []

      self.columns.each do |column|
        if column.visible?
          columns_width += column.width
          flexibles << column.name if column.flexible?
        end
      end

      # todo: handle too-many/too-wide columns
      raise "uh-oh spaghettio-s" if columns_width > new_width

      # todo: fix rounding in with calculation
      # todo: trim last column that fits into table width if necessary
      if columns_width < new_width && !flexibles.empty?
        padding = (new_width - columns_width) / flexibles.length
        flexibles.each { |name| @columns[name].width += padding }
      end
    end
  end

  class Column
    extend ::Forwardable

    attr_accessor :name, :data, :width

    [ :visible, :flexible, :label, :sortable ].each do |attr|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def_delegator :@config, :#{attr}, :#{attr}
        def_delegator :@config, :#{attr}=, :#{attr}=
      RUBY_EVAL
    end

    def initialize(column_name, config={})
      @name = column_name

      @config = ::ActiveSupport::OrderedOptions.new
      config.each { |k, v| send("#{k}=", v) if respond_to?(k) }
    end

    # sets the column to be visible. columns are visible by default. use this when
    # you've defined hidden columns that should only be displayed on some condition
    def show
      self.visible = true
    end

    # hides the column, prevents it from being rendered in the table. acts as a
    # helper for setting <tt>:visible => false</tt>
    def hide
      self.visible = false
    end

    # returns +true+ for columns that have <tt>:visible => true</tt> or #show called
    # on them. columns are visible by default
    def visible?
      self.visible != false
    end

    def flexible?
      self.flexible != false
    end

    # returns +true+ unless a column has explicitly set <tt>:sortable => false</tt>
    def sortable?
      self.sortable != false
    end

    def label
      case @config.label
      when nil then @name.to_s.humanize # todo: support i18n for column labels
      when false then nil
      else @config.label
      end
    end
=begin
    def data(object)
      object.send(self.name) if object.respond_to?(self.name)
    end
=end

    def width
      @width || 0
    end
  end

  module Helpers
    # view helper that facilities the rendering of tables for a collection of similar
    # objects
    #
    # behaves much in the same way as Rails +form_for+ helper in that it takes a proc
    # and provides access to a table builder object. the entire block is captured, so
    # additional markup can be output at any point
    #
    #  <% table_for @books, :width => 480 do |t| %>
    #    <% t.columns :title, :author, :publisher, :price %>
    #    <% t.header %>
    #    <% t.body %>
    #  <% end %>
    #
    # === Options
    # * <tt>:width</tt> - the total width of the table in pixels
    # * <tt>:html</tt>  - a hash of html attributes used for the form container
    # * <tt>:url</tt>   - used to generate urls for sortable columns
    # * <tt>:table</tt> - specify a pre-configured table to render
    #
    # === Examples
    def table_for(collection, options={}, &block)
      builder = options.delete(:builder) || ActionView::Base.default_table_builder
      table   = options.delete(:table) || Table.new

      options.merge!({ :collection => collection })
      builder.render(table, self, options, &block)
    end

    def define_table(&block)
      # fixme: rename temporary table builder class
      UberTableBuilder.new(self, &block)
    end

    class UberTableBuilder
      def initialize(template, &block)
        @template = template

        @columns = ::ActiveSupport::OrderedHash.new


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
        end

        @columns[name || name_or_hash] = Column.new(name || name_or_hash, options)
      end

      def columns ; end

      def header ; end

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
              cell(:td, @columns[:#{column.name}]) do
                capture(object, &@columns[:#{column.name}].data)
              end
            end
          RUBY_EVAL
        end
      end

      def render(collection)
        content_tag(:div, body(collection), {
          :class => 'table'
        })
      end

      def header ; end

      def body(collection)
        content_tag(:div, rows(collection), {
          :class => 'tbody'
        })
      end

      def rows(collection)
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
      def row(object, options={})
        # todo: allow :only and :except to not be an array
        cols = @columns.keys.reject { |k| !options[:only].include?(k) } if options[:only]
        cols = @columns.keys.reject { |k| options[:except].include?(k) } if options[:except]

        content_tag(:div, :class => 'tr') do
          cols.map do |column_name|
            column = @columns[column_name]
            cell(:th, column) { send(:"data_for_#{column.name}", object) rescue nil }
          end
        end
      end

      def cell(type, column, &block)
        content_tag(:div, yield, {
          :class => [type, column.name].join(' ')#,
          #:style => "width: #{@resized[column.name]}px;"
        })
      end

      def resize! ; end

    protected

      def method_missing(method_name, *args, &block) #:nodoc:
        if @template.respond_to?(method_name)
          @template.send(method_name, *args, &block)
        else
          super
        end
      end
    end

    # the default #TableBuilder class generates an HTML table using div tags
    class TableBuilder
      extend ::Forwardable
      def_delegators :@table, :columns

      def self.render(table, template, options={}, &block)
        html_attrs = options.delete(:html) || {}
        html_attrs.merge!({ :class => "table",
                            :style => "width: #{options[:width]}px;" })

        template.content_tag(:div, html_attrs) do
          template.capture(self.new(table, template, options), &block)
        end
      end

      def initialize(table, template, options={})
        @table, @template, = table, template

        @width = options.delete(:width)
        @collection = options.delete(:collection)
        @url = options.delete(:url)
      end

      def header(*args, &block)
        @table.resize!(@width)

        row = content_tag(:div, :class => "tr") do
          map_columns(:th) do |column|
            # todo: prevent output of empty <a> tag for header label
            output   = nil_capture(column, &block) if block_given?
            output ||= sort_tag(column) if column.sortable?
            output ||= content_tag(:span, column.label)
          end
        end

        content_tag(:div, row, :class => "thead")
      end

      def body(&block)
        @table.resize!(@width)
        alt = false

        rows = @collection.map do |object|
          object_name = object.class.to_s.split('::').last.underscore || ''
          klass = [ 'tr', object_name, (alt = !alt) ? nil : 'alt' ].compact
          content_tag(:div, :class => klass.join(' ')) do
            map_columns(:td) do |column|
              output   = nil_capture(column, object, &block) if block_given?
              output ||= content_tag(:span, column.data(object))
            end
          end
        end

        content_tag(:div, rows.join, :class => "tbody")
      end

    private

      def map_columns(type, &block) #:nodoc:
        @table.columns.map do |column|
          attrs = { :class => [type, column.name].join(' '),
                    :style => "width: #{column.width}px;" }
          attrs[:class] << ' sortable' if column.sortable?

          content_tag(:div, attrs) do
            yield(column)
          end if column.visible?
        end
      end

      def nil_capture(*args, &block) #:nodoc:
        custom = capture(*args, &block).strip
        output = custom.empty? ? nil : custom
      end

      def sort_tag(column) #:nodoc:
        return nil unless column.sortable? && @url.present?

        sort  = column.name
        order = "desc" if params[:sort].to_s == column.name.to_s && params[:order] == "asc"
        attrs = { :href => url_for(@url.merge({ :sort => sort, :order => order || "desc" })) }

        attrs[:class] = "sorted #{params[:order]}" if params[:sort].to_s == column.name.to_s

        content_tag(:a, column.label, attrs)
      end

      def method_missing(method_name, *args, &block) #:nodoc:
        return @template.send(method_name, *args, &block) if @template.respond_to?(method_name)
        super
      end
    end
  end

  ActionView::Base.class_eval do
    cattr_accessor :default_table_builder
    self.default_table_builder = ::Cheveret::Helpers::TableBuilder
  end
end