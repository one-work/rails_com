# frozen_string_literal: true
module RailsCom::TrHelper

  def tr_tag(model, *items, data: {}, icons: ['show', 'edit', 'destroy'], **options, &block)
    data ||= {}
    data.with_defaults!(
      controller: 'show tr-actions',
      tr_actions_data_value: tr_actions(model, *items, icons: icons)
    )
    options.merge! id: "tr_#{model.id}" if model

    tag.tr(data: data, **options, &block)
  end

  def tr_actions(model, *items, icons:)
    defaults = []

    if icons.include?('show')
      defaults << {
        title: t('.show.title'),
        icon: 'eye',
        action: url_for(action: 'show', id: model.id),
        class: 'text-info',
        position: 0
      }
    end

    if icons.include?('edit')
      defaults << {
        title: t('.edit.title'),
        icon: 'pencil',
        action: url_for(action: 'edit', id: model.id),
        class: 'text-link',
        position: 0
      }
    end

    if icons.include?('destroy')
      defaults << {
        title: t('.destroy.title'),
        icon: 'trash',
        method: 'delete',
        action: url_for(action: 'destroy', id: model.id),
        class: 'text-danger',
        confirm: t('.destroy.confirm'),
        position: 0
      }
    end

    items.reject! { |i| i.key?(:enable) && i[:enable] }

    (defaults + items).to_json
  end

end
