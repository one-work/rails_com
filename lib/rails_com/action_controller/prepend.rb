module RailsCom::ActionController
  module Prepend

    private
    def _prefixes
      # 支持在 views/:controller 目录下以 _:action 开头的子目录进一步分组，会优先查找该目录下文件
      pres = ["#{controller_path}/_#{params[:action]}"]
      controller_paths = [controller_path]
      namespaces = [params[:namespace]]

      super_class = self.class.superclass
      while super_class.action_methods.include?(params[:action])
        pres.append "#{super_class.controller_path}/_#{params[:action]}"

        super_class = super_class.superclass
      end

      route_super_class = self.class.superclass
      super_actions = RailsCom::Routes.controllers[route_super_class.controller_path]
      # 同名 controller, 向上级追溯
      while super_actions.is_a?(Hash) && super_actions.key?(params[:action])
        controller_paths.append route_super_class.controller_path
        namespaces.append super_actions.dig(params[:action], :namespace)

        route_super_class = route_super_class.superclass
        super_actions = RailsCom::Routes.controllers[route_super_class.controller_path]
      end

      # 可以在 controller 中定义 _prefixes 方法
      # super do |pres|
      #   pres + ['xx']
      # end
      if block_given?
        pres = yield pres
      end
      pres += super

      r = controller_paths.map do |i|
        olds = i.split('/')
        olds[-1] = 'base'
        olds.join('/')
      end
      r_index = pres.index(r[-1])
      pres.insert(r_index, *r[0..-2]) if r_index

      # namespaces
      namespaces.uniq!
      namespaces.compact_blank!
      namespace_indexes = namespaces.reverse.map { |n| pres.index(n) }
      namespace_index = namespace_indexes[0] || pres.index('base') || pres.index('application')
      pres.insert(namespace_index, *(namespaces - pres)) if namespace_index

      if defined?(current_organ) && current_organ&.code.present?
        RailsCom.config.override_prefixes.each do |pre|
          index = pres.index(pre)
          pres.insert(index, "#{current_organ.code}/views/#{pre}") if index
        end
        pres.prepend "#{current_organ.code}/views/#{controller_path}"
      end

      pres
    end

  end
end

ActiveSupport.on_load :action_controller_base do
  prepend RailsCom::ActionController::Prepend
end
