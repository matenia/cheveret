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
  module Util

    ##
    # borrowed from sunspot/lib/sunspot/util.rb
    #
    class ContextBoundDelegate
      class << self
        def instance_eval_with_context(receiver, &block)
          calling_context = eval('self', block.binding)
          if parent_calling_context = calling_context.instance_eval{@__calling_context__}
            calling_context = parent_calling_context
          end
          new(receiver, calling_context).instance_eval(&block)
        end
        private :new
      end

      BASIC_METHODS = Set[:==, :equal?, :"!", :"!=", :instance_eval,
                          :object_id, :__send__, :__id__]

      instance_methods.each do |method|
        unless BASIC_METHODS.include?(method.to_sym)
          undef_method(method)
        end
      end

      def initialize(receiver, calling_context)
        @__receiver__, @__calling_context__ = receiver, calling_context
      end

      def method_missing(method, *args, &block)
        begin
          @__receiver__.send(method.to_sym, *args, &block)
        rescue ::NoMethodError => e
          begin
            @__calling_context__.send(method.to_sym, *args, &block)
          rescue ::NoMethodError
            raise(e)
          end
        end
      end
    end

  end # Util
end #Cheveret