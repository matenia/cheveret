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
    def width
      @width || 0
    end

    # set width constraint for the table.
    #
    # if the width value is different to that previously set, cheveret will call the
    # #resize! method to adjust the widths of flexible columns to fit
    #
    # @param [Integer] new_width the maximum width of the table in pixels
    def width=(new_width)
      return @width if new_width == @width

      @width = new_width
      resize!
    end

    def config(new_config={})
      self.width = new_config[:width] if new_config[:width]
      super
    end

    # some meta magic - make sure that the table is resized correctly before any of
    # the render methods start generating output
    [ :render, :header, :body, :rows ].each do |renderer|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{renderer}(*args)
          config = args.extract_options!

          width = config.delete(:width)
          super(*args << config)
        end
      RUBY_EVAL
    end

    def cell(type, column, options={}, &block)
      options[:style] = "width: #{@widths[column.name]}px"
      super
    end

    # resize flexible columns in attempt to reduce the total width, making sure it
    # fits within the constraints of the table
    def resize!
      @widths = {}

      columns_width = 0
      flexibles     = []

      @columns.values.each do |column|
        columns_width += column.width
        flexibles << column if column.flexible?
      end

      # todo: handle too-many/too-wide columns
      raise "uh-oh spaghettio-s" if columns_width > @width

      # todo: fix rounding in with calculation
      # todo: trim last column that fits into table width if necessary
      if columns_width < @width && !flexibles.empty?
        padding = (@width - columns_width) / flexibles.length
        flexibles.each { |column| @widths[column.name] = column.width + padding }
      end
    end

    def weigh!
      raise NotImplementedError
    end

  end
end
