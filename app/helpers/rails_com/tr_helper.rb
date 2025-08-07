# frozen_string_literal: true
module RailsCom::TrHelper

  def tr_tag(model, data: {}, &block)
    data ||= {}
    data.with_defaults!(
      controller: 'show',
      action: 'mouseenter->show#show mouseleave->show#hide'
    )
    tag.tr(id: "tr_#{model.id}", data: data, &block)
  end

  def tr_actions(model)
    button_to({ action: 'show', id: model.id }, aria: { label: t('.show.title') }, class: 'button is-small is-borderless') do
      svg_tag 'circle-info', class: 'icon text-info'
    end
  end

end
