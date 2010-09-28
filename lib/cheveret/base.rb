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
  class Base
    def initialize(template, config={}, &block)
      @config, @template = config, template

      @width, @widths = 0, {}
      @columns        = ::ActiveSupport::OrderedHash.new

      # dsl block gets eval'd in the instance, method_missing forwards calls to the
      # template so that blocks get output correctly
      instance_eval(&block) if block_given?
    end

    include DSL
    include Rendering
    include Resizing

  protected

    # since the define_table block gets instance_eval'd in the context of this object
    # we need to proxy view methods (e.g. check_box_tag) back to the template
    def method_missing(method_name, *args, &block) #:nodoc:
      if @template.respond_to?(method_name)
        @template.send(method_name, *args, &block)
      else
        super
      end
    end

  end
end
