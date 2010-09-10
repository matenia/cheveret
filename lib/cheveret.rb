#--
# Copyright (c) 2010 RateCity
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

require "active_record"
require "action_view"

require 'active_support/ordered_hash'
require 'active_support/ordered_options'

module Cheveret
  autoload :Column,      'cheveret/column'
  autoload :Helpers,     'cheveret/helpers'
  autoload :Table,       'cheveret/table'
  autoload :Tabulatable, 'cheveret/tabulatable'
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Cheveret::Tabulatable
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, Cheveret::Helpers
end
