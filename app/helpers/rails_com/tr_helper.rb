# frozen_string_literal: true
module RailsCom::TrHelper

  def tr_tag(model, *items, data: {}, &block)
    data ||= {}
    data.with_defaults!(
      controller: 'show tr-actions',
      tr_actions_data_value: tr_actions(model, *items)
    )

    tag.tr(id: "tr_#{model.id}", data: data, &block)
  end

  def tr_actions(model, *items, icons: ['show', 'edit', 'destroy'])
    defaults = []

    if icons.include?('show')
      defaults << { title: t('.show.title'), icon: 'eye', action: url_for(action: 'show', id: model.id) }
    end

    if icons.include?('edit')
      defaults << { title: t('.edit.title'), icon: 'pencil', action: url_for(action: 'edit', id: model.id) }
    end

    if icons.include?('destroy')
      defaults << { title: t('.destroy.title'), icon: 'trash', method: 'destroy', action: url_for(action: 'destroy', id: model.id) }
    end

    (defaults + items).to_json
  end

end
