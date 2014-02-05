require 'action_view'
require 'tablemaker/table_helper'

module Tablemaker
  module ViewHelpers
    module ActionView
      def make_table(opts = {}, &block)
        table = TableHelper.new(self,true, &block).to_html(opts)
      end
      def make_table_without_tag(opts = {}, &block)
        table = TableHelper.new(self,false, &block).to_html(opts)
      end
    end
  end
end
