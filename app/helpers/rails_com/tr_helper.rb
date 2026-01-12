# frozen_string_literal: true
module RailsCom::TrHelper

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
