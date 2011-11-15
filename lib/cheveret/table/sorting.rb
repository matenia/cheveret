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
    module Sorting

      def self.included(base)
        base.module_eval do
          extend ClassMethods
        end

        # make sure our column objects can be configured as sortable
        ::Cheveret::Column.send :include, Sortable
      end

      attr_accessor :sort_column, :sort_direction, :sort_param, :sort_url

      module ClassMethods

        ##
        # defines which table columns can be sorted by the user
        #
        def sortable_on(*args)
          args.each do |column_name|
            raise "unrecognised column #{column_name}" unless columns[column_name]
            columns[column_name].sortable = true
          end
        end

        ##
        # TODO: depricate
        #
        def default_sort(column_name, direction)
          raise ArgumentError 'Column not found' unless columns.has_key?(column_name)

          @default_sort_column    = columns[column_name]
          @default_sort_direction = direction
        end

      end # ClassMethods

      module Sortable
        attr_accessor :default_sort_direction, :sortable

        ##
        # whether or not sorting the table by this column is allowed. default +false+
        #
        def sortable?
          sortable == true
        end

        def default_sort_direction
          @default_sort_direction ||= :desc
        end

      end # Sortable

      ##
      #
      #
      def sort_param
        @sort_param ||= '%s'
      end

      ##
      #
      #
      def render_th(column, options={})
        return super unless column.sortable?

        options[:class] = [ 'sortable', *options[:class] ]
        options[:class] << 'sorted' if column.name == sort_column
        options[:class].flatten.join(' ').strip

        super
      end

      ##
      #
      #
      def table_header(column)
        # wrap unsortable columns in a <span> tag
        return template.content_tag(:span, super) unless column.sortable?

        column_key = sort_param % 'sort_column'
        direction_key = sort_param % 'sort_direction'

        attrs = {}
        query = { column_key => column.name,
                  direction_key => column.default_sort_direction }

        if column.name == sort_column
          query[direction_key] = ( sort_direction == :asc ? :desc : :asc )
          attrs[:class] = "#{sort_direction}"
        end
        
        attrs[:rel] = 'nofollow'
        attrs[:href] = template.url_for(sort_url.merge(query))
        template.content_tag(:a, super, attrs)
      end

    end # Sorting
  end # Table
end # Cheveret
