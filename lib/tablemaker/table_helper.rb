module Tablemaker
  class TableHelper
    def initialize(context,table_tag, &block)
      @context = context
      @stack = []
      @table_tag = table_tag

      @root = Tablemaker.column do |r|
        stack(r) do
          yield self
        end
      end
    end

    def row(&block)
      current.row do |r|
        stack(r) do
          yield
        end
      end
    end

    def column(&block)
      current.column do |c|
        stack(c, &block)
      end
    end

    def line(&block)
      current.respond_to?(:row) ? row(&block) : column(&block)
    end

    def td(*args, &blk)
      cell("td", *args, &blk)
    end

    def th(*args, &blk)
      cell("th", *args, &blk)
    end

    def to_html(attrs = {})
      if @table_tag
        context.content_tag("table", attrs) do
          @root.each_row do |r|
            tr_opts = r.first.data[:tr_opts]
            s = context.content_tag("tr", tr_opts) do
              r.each do |c|
                attrs = {}
                attrs[:rowspan] = c.real_rows if c.real_rows > 1
                attrs[:colspan] = c.real_cols if c.real_cols > 1
                s2 = context.content_tag(c.data[:name], c.data[:opts].merge(attrs)) do
                  c.data[:text]
                end

                context.concat(s2)
              end
            end
            context.concat(s)
          end
        end
      else
        @root.each_row do |r|
          tr_opts = attrs.merge(r.first.data[:tr_opts])
          s = context.content_tag("tr", tr_opts) do
            r.each do |c|
              attrs = {}
              attrs[:rowspan] = c.real_rows if c.real_rows > 1
              attrs[:colspan] = c.real_cols if c.real_cols > 1
              s2 = context.content_tag(c.data[:name], c.data[:opts].merge(attrs)) do
                c.data[:text]
              end

              context.concat(s2)
            end
          end
          context.concat(s)
        end
      end
    end


    private

    def cell(name, *args, &block)
      opts = args.extract_options!
      text = if block_given?
               @context.capture(&block)
             else
               args.shift
             end
      current.cell(text: text, name: name, opts: opts)
    end

    def stack(frame)
      @stack.push(frame)
      yield
      @stack.pop
    end

    def context
      @context
    end

    def current
      @stack.last
    end
  end
end
