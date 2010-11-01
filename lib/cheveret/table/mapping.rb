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
    module Mapping

      def self.included(base)
        base.module_eval do
          extend ClassMethods
        end

        ::Cheveret::Column.send :include, Mappable
      end

      module ClassMethods
      end # ClassMethods

      module Mappable
        attr_accessor :data, :header
      end # Mappable

      ##
      #
      #
      def table_data(column, item)
        args = [ item ]

        case column.data
        when Symbol
          args.unshift(column) if method(column.data).arity > 1
          send(column.data, *args)
        when Proc
          args.unshift(column) if column.data.arity > 1
          template.capture(*args, &column.data)
        else
          if respond_to?(column.name)
            send(column.name, item)
          else
             table_data_for(column, item)
          end
        end
      end

      ##
      #
      #
      def table_data_for(column, item)
        raise NotImplementedError
      end

      ##
      #
      #
      def table_header(column)
        case column.header
        when Symbol then send(column.header)
        when Proc then template.capture(&column.header)
        when String then column.header
        else
          table_header_for(column) unless column.header == false
        end
      end

      ##
      #
      #
      def table_header_for(column)
        raise NotImplementedError
      end

    end # Mapping
  end # Table
end # Cheveret