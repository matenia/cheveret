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
    module Columns

      def self.included(base)
        base.module_eval do
          extend ClassMethods
        end
      end

      module ClassMethods

        ##
        # returns an ordered hash of all defined table columns
        #
        def columns
          @columns ||= ::ActiveSupport::OrderedHash.new
        end

        ##
        # define a new (or re-define an existing) table column
        #
        def column(*args)
          options = args.extract_options!
          raise ArgumentError if args.empty?

          column_name = args.first

          # only create new column if one doesn't already exist with specified name
          columns[column_name] ||= Column.new(column_name)
          columns[column_name].tap do |column|
            column.config(options)
          end
        end

        ##
        #
        #
        def remove_column(column_name)
          columns.delete(column_name)
        end

      end # ClassMethods

      ##
      # instance proxy method to get columns defined by the class
      #
      def columns
        self.class.columns
      end

    end # Columns
  end # Table
end # Cheveret
