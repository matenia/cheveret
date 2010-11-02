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
  module Table
    module Sizing

      def self.included(base)
        base.module_eval do
          extend ClassMethods
        end

        # allow columns to be flexible and/or have their width set
        ::Cheveret::Column.send :include, Sizable
      end

      attr_accessor :width

      module ClassMethods

        # todo: set width?

      end # ClassMethods

      module Sizable
        attr_accessor :flexible, :size, :width

        ##
        #
        #
        def flexible?
          @flexible == true
        end

        ##
        #
        #
        def size
          @size || width
        end

        ##
        #
        #
        def width
          @width || 0
        end

      end # Sizable

      ##
      #
      #
      def width
        @width ||= 0
      end

      [ :table, :thead, :tbody, :rows].each do |elem|
        class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def render_#{elem}(*args)
            resize! if needs_resize?

            options = args.extract_options!
            options[:style] = "width:\#{width}px;" if width > 0
            super(*(args << options))
          end
        RUBY_EVAL
      end

      ##
      #
      #
      def render_th(column, options={})
        options[:style] = "width:#{column.size}px;" if column.size > 0
        super
      end

      ##
      #
      #
      def render_td(column, options={})
        options[:style] = "width:#{column.size}px;" if column.size > 0
        super
      end

      ##
      #
      #
      def resize!
        columns_width, flexibles = 0, []

        columns.values.each do |column|
          columns_width += column.width
          flexibles << column if column.flexible?
        end

        # todo: handle too-many/too-wide columns
        raise "uh-oh spaghettio-s" if columns_width > width

        # todo: fix rounding in with calculation
        if columns_width < width && !flexibles.empty?
          padding = (width - columns_width) / flexibles.length
          flexibles.each { |column| column.size = column.width + padding }
        end
      end

      ##
      #
      #
      def needs_resize?
        columns.map(&:size).sum != width
      end


    end # Sizing
  end # Table
end # Cheveret