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

module Cheveret
  module Helpers
    def cheveret_header(*args, &block)
      # :width, :scope, :class
      options = args.extract_options!
      table   = resolve_table(args, options)

      # todo: setup table with options, resolve widths etc.
      # table.width = options[:width]

      content_tag(:div, :class => 'thead') do
        content_tag(:div, :class => 'tr') do
          table.columns.map do |k, v|
            content_tag(:div, :class => [ 'th', k.to_s].join(' ')) do
              html = capture(k, v, &block).strip if block_given?
              unless html.is_a?(String) && html.strip.length > 0
                # todo: add href, title attributes to header link
                content_tag(:a, v.label)
              else
                html
              end
            end if v.display?
          end.join
        end
      end
    end

    def cheveret_body(*args, &block)
      # :width, :scope, :collection
      options = args.extract_options!
      table   = resolve_table(args, options)

      content_tag(:div, :class => 'tbody') do
        options[:collection].map do |object|
          cheveret_row(table, object) do |k, v|
            html = capture(k, v, object, &block) if block_given?
            unless html.is_a?(String) && html.strip.length > 0
              object.send(k) if object.respond_to?(k)
            else
              html
            end
          end
        end.join
      end
    end

    def cheveret_row(table, object, &block)
      klass = object.class.to_s.split('::').last.underscore || ''
      content_tag(:div, :class => ['tr', klass].join(' ')) do
        table.columns.map do |k, v|
          content_tag(:div, :class => [ 'td', k.to_s ].join(' ')) do
            content_tag(:span, block.call(k, v)) # todo: could this be yield?
          end if v.display?
        end.join
      end
    end

    def cheveret_table
    end

  private

    def resolve_table(args, options)
      args.first.cheveret
    end

  end
end
