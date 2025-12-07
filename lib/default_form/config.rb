# frozen_string_literal: true

module DefaultForm
  mattr_accessor :config, default: ActiveSupport::OrderedOptions.new

  config.theme = 'default'
  config.help_tag = ->(app, text) {
    app.content_tag(:span, aria: { label: text }) do
      app.content_tag(:i, nil, class: 'fas fa-question-circle')
    end
  }
  config.mapping = ActiveSupport::OrderedOptions.new
  config.mapping.date = {
    input: 'date_field',
    output: 'to_date'
  }
  config.mapping.datetime = {
    input: 'datetime_field',
    output: 'to_datetime'
  }
  config.mapping.integer = {
    input: 'number_field',
    options: { step: 1 },
    output: 'to_i'
  }
  config.mapping.decimal = {
    input: 'number_field',
    options: { step: 0.01 }
  }
  config.mapping.string = {
    input: 'text_field',
    output: 'to_s'
  }
  config.mapping.text = {
    input: 'text_area',
    output: 'to_s'
  }
  config.mapping.array = {
    input: 'text_field',
    options: { multiple: true },
    output: 'to_s'
  }
  config.mapping.taxon = {
    input: 'outer_select',
    output: 'to_s'
  }
  config.mapping.enum = {
    input: 'select_enum',
    output: 'to_s'
  }
  config.mapping.boolean = {
    input: 'check_box',
    output: 'to_s'
  }
end
