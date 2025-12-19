module RailsCom::ActionController
  module Extend

    def whether_filter_role(action_name)
      callback = self.get_callbacks(:process_action).find { |i| i.filter == :require_role }
      return false unless callback

      _if = callback.instance_variable_get(:@if).map do |c|
        c.instance_variable_get(:@actions).include? action_name
      end

      _unless = callback.instance_variable_get(:@unless).map do |c|
        c.instance_variable_get(:@actions).exclude? action_name
      end

      (_if + _unless).exclude?(false)
    end

    # if whether_filter(:require_user)
    #   skip_before_action :require_user
    # end
    def whether_filter(filter)
      self.get_callbacks(:process_action).map(&:filter).include?(filter.to_sym)
    end

    def raw_view_paths
      view_paths.paths.map { |i| i.path }
    end

    def super_controllers(root = ApplicationController)
      r = ancestors.select(&->(i){ i.is_a?(Class) })
      r[1..r.index(root)]
    end

  end
end

ActiveSupport.on_load :action_controller do
  extend RailsCom::ActionController::Extend
end
