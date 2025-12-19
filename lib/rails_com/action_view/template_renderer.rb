# frozen_string_literal: true

module RailsCom::ActionView
  module TemplateRenderer

    def render(context, options)
      return super if defined?(WebConsole) && context.is_a?(WebConsole::View)

      # 默认Rails行为是： 在查找模板的时候，路径的优先级优于 format 的优先级；
      # 我们需要 formats 的优先级优于路径；
      request = context.request
      if request && request.format.symbol
        _formats = [request.format.symbol]
      else
        _formats = @lookup_context.formats[0..0].presence || [:html]
      end

      # todo better implement
      @lookup_context.send :_set_detail, :formats, _formats

      # 当前 template 名称
      context.instance_variable_set(:@_rendered_template, options[:template])

      begin
        super
      rescue ActionView::MissingTemplate
        if @lookup_context.formats.include?(:html)
          raise
        else
          @lookup_context.send :_set_detail, :formats, [:html]
          retry
        end
      end
    end

  end
end

ActiveSupport.on_load :action_view do
  ActionView::TemplateRenderer.prepend RailsCom::ActionView::TemplateRenderer
end
