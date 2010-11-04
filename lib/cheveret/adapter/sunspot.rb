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
  module Adapter
    module Sunspot

      ##
      #
      #
      def table_data_for(column, item)
        item.stored(column.name)
      end

      ##
      #
      #
      [ :current_page,
        :next_page,
        :offset,
        :per_page,
        :total,
        :total_entries,
        :total_pages
      ].each do |proxy|
        # this is really territory of will_paginate
        class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{proxy}(*args)
            return 0 unless collection.respond_to?(:#{proxy})
            collection.#{proxy}(*args)
          end
        RUBY_EVAL
      end

    end # Sunspot
  end # Adapter
end # Cheveret
