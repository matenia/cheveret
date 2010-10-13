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
  module DSL
    def header_default(&block)
      raise NotImplementedError
    end

    def data_default(&block)
      raise NotImplementedError
    end

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
        name = name_or_hash.except(:label, :hint, :width).keys.first
        name_or_hash.delete(name).each { |k| options[k] = true }
        options.merge!(name_or_hash)
      else
        name = name_or_hash
      end

      if @columns[name].present?
        options.each { |k, v| @columns[name].send(:"#{k}=", v) }
      else
        @columns[name] = Column.new(name, options)
      end
    end

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
        column = @columns[ column_name ]
        column.data = block

        block_args = [ 'object ']
        block_args.unshift("@columns[:#{column.name}]") if args.first

        instance_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def data_for_#{column.name}(object)
            capture(#{block_args.join(', ')}, &@columns[:#{column.name}].data)
          end
        RUBY_EVAL
      end
    end

    def header(*args, &block)
      raise NotImplementedError
    end

  end
end
