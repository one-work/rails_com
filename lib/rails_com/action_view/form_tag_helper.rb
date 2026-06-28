# frozen_string_literal: true

module RailsCom::ActionView
  module FormTagHelper

    def set_default_disable_with(value, tag_options)
      data = tag_options.fetch('data', {})

      if tag_options['data-turbo-submits-with'] == false || data['turbo_submits_with'] == false
        data.delete('turbo_submits_with')
      elsif ActionView::Base.automatically_disable_submit_tag
        disable_with_text = tag_options['data-turbo-submits-with']
        disable_with_text ||= data['turbo_submits_with']
        disable_with_text ||= value.to_s.clone
        tag_options.deep_merge!('data' => { 'turbo_submits_with' => disable_with_text })
      end

      tag_options.delete('data-turbo-submits-with')
    end

  end
end

ActiveSupport.on_load :action_view do
  ActionView::Helpers::FormTagHelper.prepend RailsCom::ActionView::FormTagHelper
end
