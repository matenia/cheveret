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

      attr_accessor :params, :sort_column, :sort_direction, :sort_url

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
        #
        #
        def default_sort(column_name, direction)
          raise ArgumentError 'Column not found' unless columns.has_key?(column_name)

          @default_sort_column    = columns[column_name]
          @default_sort_direction = direction
        end

        def default_sort_column
          @default_sort_column 
        end

        def default_sort_direction
          @default_sort_direction || :asc
        end

      end # ClassMethods

      module Sortable
        attr_accessor :sortable, :sort_key

        ##
        # whether or not sorting the table by this column is allowed. default +false+
        #
        def sortable?
          sortable == true
        end

        def sort_key
          @sort_key || name
        end

      end # Sortable

      def default_sort_column
        self.class.default_sort_column
      end

      def default_sort_direction
        self.class.default_sort_direction
      end

      ##
      #
      #
      def sort_column
        column = if params[:sort_column]
          columns[params[:sort_column].to_sym]
        else
          default_sort_column
        end
      end

      ##
      #
      #
      def sort_key
        sort_column.sort_key # return all keys - multiple sort?
      end

      def sort_direction
        if params[:sort_direction]
          params[:sort_direction].to_sym
        else
          default_sort_direction
        end
      end

      ##
      #
      #
      def render_th(column, options={})
        options[:class] = 'sortable' if column.sortable?
        super
      end

      ##
      #
      #
      def table_header(column)
        # wrap unsortable columns in a <span> tag
        return template.content_tag(:span, super) unless column.sortable?

        query = { :sort_column => column.name, :sort_direction => :desc }
        attrs  = {}

        if column == sort_column
          query[:sort_direction] = ( sort_direction == :asc ? :desc : :asc )
          attrs[:class] = "sorted #{sort_direction}"
        end

        attrs[:href] = template.url_for(sort_url.merge(query))
        template.content_tag(:a, super, attrs)
      end

    end # Sorting
  end # Table
end # Cheveret
