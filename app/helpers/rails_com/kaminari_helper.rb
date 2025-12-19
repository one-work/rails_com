module RailsCom
  module KaminariHelper

    def paginate(scope, paginator_class: Kaminari::Helpers::Paginator, template: nil, **options)
      super scope, paginator_class: paginator_class, template: template, theme: 'com', **options
    end

  end
end
