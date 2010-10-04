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
    def render(collection, options={})
      options[:class] = [ 'table', options[:class] ].flatten.join(' ').strip

      content_tag(:div, options) do
        header + body(collection)
      end
    end

    def header(options={})
      row  = @columns.values.map do |column|
        cell(:th, column) do
          if column.sortable? # todo: abstract out sortable stuff
            content_tag(:a, column.label)
          else
            content_tag(:span, column.label)
          end
        end
      end

      content_tag(:div, :class => 'thead') do
        content_tag(:div, row, :class => 'tr')
      end
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
      alt = cycle('', 'alt', :name => 'cheveret')
      options[:class] = [ 'tr', alt, options[:class]].flatten.join(' ').strip

      content_tag(:div, options) do
        @columns.values.map do |column|
          cell(:td, column) { send(:"data_for_#{column.name}", object) rescue nil }
        end
      end
    end

    def cell(type, column, options={}, &block)
      options[:class] = [ type, column.name, options[:class] ].flatten.join(' ').strip
      content_tag(:div, yield, options)
    end

  end
end
