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
  module Rendering
    def render(collection, new_config={})
      content_tag(:div, :class => 'table') do
        header(options) + body(collection, options)
      end
    end

    def header(options={})
      url = options.delete(:url) || {} # todo: current controller action

      row  = @columns.values.map do |column|
        cell(:th, column) do
          if column.sortable?
            content_tag(:a, column.label)
          else
            column.label
          end
        end
      end

      content_tag(:div, row, {
        :class => 'thead'
      })
    end

    def body(collection, options={})
      content_tag(:div, rows(collection), {
        :class => 'tbody'
      })
    end

    def rows(collection, options={})
      collection.map { |object| row(object) }.join
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
        :class => [type, column.name].join(' ')#,
        #:style => "width: #{@widths[column.name] || column.width}px;"
      })
    end

  end
end