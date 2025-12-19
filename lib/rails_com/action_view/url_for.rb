module RailsCom::ActionView
  module UrlFor

    def url_for(options = nil)
      if options.is_a?(Hash) && params.key?(:org_id)
        options.merge! org_id: params[:org_id] unless options.key?(:org_id)
      end

      super
    end

  end
end

ActiveSupport.on_load :action_view do
  ActionView::RoutingUrlFor.prepend RailsCom::ActionView::UrlFor
end
