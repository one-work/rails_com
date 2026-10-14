# frozen_string_literal: true
module RailsCom::TrHelper
  DEFAULTS = {
    'show' => {
      icon: 'eye',
      class: 'text-info'
    },
    'edit' => {
      icon: 'pencil',
      class: 'text-link'
    },
    'destroy' => {
      method: 'delete',
      icon: 'trash',
      class: 'text-danger',
      confirm: t(".destroy.confirm")
    }
  }

  def tr_tag(model, *items, data: {}, icons: ['show', 'edit', 'destroy'], param: {}, **options, &block)
    if model.respond_to? :id
      param.with_defaults! id: model.id
      options.with_defaults! id: "tr_#{model.id}"
    end
    data.with_defaults!(
      controller: 'show tr-actions',
      tr_actions_data_value: tr_actions(*items, icons: icons, param: param)
    )

    tag.tr(data: data, **options, &block)
  end

  def tr_actions(*items, icons:, param:)
    defaults = []

    icons.each do |icon|
      if icon.is_a? Hash
        icon.each do |key, value|
          defaults << tr_default_actions(key, action: value)
        end
      elsif DEFAULTS.key?(icon)
        defaults << tr_default_actions(icon)
      end
    end

    items.select! { |i| (i.key?(:enable) && i[:enable]) || !i.key?(:enable) }

    (defaults + items).to_json
  end

  def tr_default_actions(show, action: show, confirm: nil)
    r = {
      action: url_for(action: action, **param),
      label: t(".#{action}.title"),
      position: 0,
      **DEFAULTS[show]
    }
    r.merge! confirm: t(".#{destroy}.confirm")
  end

end
