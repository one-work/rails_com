# frozen_string_literal: true
module RailsCom::TrHelper

  def tr_tag(model, data: {})
    data ||= {}
    data.with_defaults!(
      controller: 'show',
      action: 'mouseenter->show#show mouseleave->show#hide'
    )
    tag.tr(id: "tr_#{model.id}", data: data)
  end

end
