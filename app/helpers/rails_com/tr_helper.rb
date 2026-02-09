# frozen_string_literal: true
module RailsCom::TrHelper

  def tr_tag(model, *items, data: {}, icons: ['show', 'edit', 'destroy'], param: { id: model.id }, **options, &block)
    data ||= {}
    data.with_defaults!(
      controller: 'show tr-actions',
      tr_actions_data_value: tr_actions(model, *items, icons: icons, param: param)
    )
    options.with_defaults! id: "tr_#{model.id}" if model

    tag.tr(data: data, **options, &block)
  end

  def tr_actions(model, *items, icons:, param:)
    defaults = []

    if icons.include?('show')
      defaults << {
        action: url_for(action: 'show', **param),
        icon: 'eye',
        label: t('.show.title'),
        class: 'text-info',
        position: 0
      }
    end

    if icons.include?('edit')
      defaults << {
        action: url_for(action: 'edit', **param),
        icon: 'pencil',
        label: t('.edit.title'),
        class: 'text-link',
        position: 0
      }
    end

    if icons.include?('destroy')
      defaults << {
        action: url_for(action: 'destroy', **param),
        label: t('.destroy.title'),
        icon: 'trash',
        method: 'delete',
        class: 'text-danger',
        confirm: t('.destroy.confirm'),
        position: 0
      }
    end

    items.reject! { |i| i.key?(:enable) && i[:enable] }

    (defaults + items).to_json
  end

end
