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
  module Resizing
    def self.included(base)
      base.module_eval do
        attr_accessor :width
      end
    end

    [ :render, :header, :body, :rows ].each do |renderer|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{renderer}(*)
          # todo: check if we need to resize
          super
        end
      RUBY_EVAL
    end

    def resize!(new_width)
      @widths = {}

      columns_width = 0
      flexibles     = []

      @columns.values.each do |column|
        columns_width += column.width
        flexibles << column if column.flexible?
      end

      # todo: handle too-many/too-wide columns
      raise "uh-oh spaghettio-s" if columns_width > new_width

      # todo: fix rounding in with calculation
      # todo: trim last column that fits into table width if necessary
      if columns_width < new_width && !flexibles.empty?
        padding = (new_width - columns_width) / flexibles.length
        flexibles.each { |column| @widths[column.name] = column.width + padding }
      end
    end
  end
end
