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

      attr_accessor :sort_column, :sort_url

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
        def default_sort(*args)
          raise NotImplementedError
        end

      end # ClassMethods

      module Sortable
        attr_accessor :sortable

        ##
        # whether or not sorting the table by this column is allowed. default +false+
        #
        def sortable?
          sortable == true
        end

      end # Sortable

      ##
      #
      #
      def sort_column
        template.request.params[:sort_column] || @sort_column
      end

      def sort_direction
        template.request.params[:sort_direction] || @sort_direction
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
        return super unless column.sortable?

        params = { :sort_column => column.name, :sort_direction => :desc }
        attrs  = {}

        if column.name.to_s == sort_column
          params[:sort_direction] = sort_direction == 'asc' ? 'desc' : 'asc'
          attrs[:class] = "sorted #{sort_direction}"
        end

        attrs[:href] = template.url_for(sort_url.merge(params))
        template.content_tag(:a, super, attrs)
      end

    end # Sorting
  end # Table
end # Cheveret
