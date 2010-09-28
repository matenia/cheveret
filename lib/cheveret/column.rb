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
  class Column
    attr_accessor :name, :data, :label, :weight, :width
    attr_accessor :flexible, :sortable

    def initialize(name, config={})
      config.merge(:name => name).each do |k, v|
        instance_variable_set(:"@#{k}", v) if respond_to?(:"#{k}=")
      end
    end

    def flexible?
      @flexible == true
    end

    def label
      case @label
      when nil then @name.to_s.humanize # todo: support i18n for column labels
      when false then nil
      else @label
      end
    end

    # returns +true+ unless a column has explicitly set <tt>:sortable => false</tt>
    def sortable?
      @sortable == true
    end

    def width
      @width || 0
    end

  end
end