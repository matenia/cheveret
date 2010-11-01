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
    module Locale

      ##
      #
      #
      def render_th(column, options={})
        unless options[:title]
          scope = self.class.to_s.sub(/Table\Z/, '').underscore
          hint  = ::I18n.translate("cheveret.hints.#{scope}.#{column.name}",
                                   :default => '')

          options[:title] = hint.strip unless hint.blank?
        end

        super
      end

      ##
      #
      #
      def table_header_for(column)
        scope  = self.class.to_s.sub(/Table\Z/, '').underscore
        header = ::I18n.translate("cheveret.headers.#{scope}.#{column.name}",
                                  :default => column.name.to_s.humanize)
      end

    end # Locale
  end # Table
end # Cheveret