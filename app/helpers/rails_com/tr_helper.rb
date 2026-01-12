# frozen_string_literal: true
module RailsCom::TrHelper

  def tr_actions(model, icons: ['show', 'edit', 'destroy'])
    [
      { title: t('.show.title'), icon: 'eye', action: url_for(action: 'show', id: model.id) },
      { title: t('.edit.title'), icon: 'pencil', action: url_for(action: 'edit', id: model.id) },
      { title: t('.destroy.title'), icon: 'trash', method: 'destroy', action: url_for(action: 'destroy', id: model.id) }
    ].to_json
  end

end
