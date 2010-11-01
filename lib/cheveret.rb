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
  autoload :Column, 'cheveret/column'
  autoload :Helper, 'cheveret/helper'
  autoload :Util,   'cheveret/util'

  module Adapter
    autoload :ActiveRecord, 'adapter/active_record'
    autoload :Sunspot,      'adapter/sunspot'
  end

  module Builder
    autoload :Divider,        'cheveret/builder/divider'
    # autoload :DefinitionList, 'cheveret/builder/definition_list'
    # autoload :Table,          'cheveret/builder/table'
  end

  module Table
    autoload :Base,      'cheveret/table'
    autoload :Columns,   'cheveret/table/columns'
    autoload :Locale,    'cheveret/table/locale'
    autoload :Mapping,   'cheveret/table/mapping'
    autoload :Rendering, 'cheveret/table/rendering'
    autoload :Sizing,    'cheveret/table/sizing'
    autoload :Sorting,   'cheveret/table/sorting'
  end

end