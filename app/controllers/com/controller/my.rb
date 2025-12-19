module Com
  module Controller::My
    extend ActiveSupport::Concern
    include Controller::Curd

    private
    def tab_item_items
      @roled_tabs.pluck(:path)
    end

  end
end
