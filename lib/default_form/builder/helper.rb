# frozen_string_literal: true

module DefaultForm::Builder
  module Helper
    include Wrap
    include Default

    INPUT_FIELDS = [
      :text_field,
      :password_field,
      :color_field,
      :search_field,
      :telephone_field,
      :phone_field,
      :time_field,
      :datetime_field,
      :datetime_local_field,
      :month_field,
      :week_field,
      :url_field,
      :email_field,
      :range_field,
      :file_field,
      :date_select
    ].freeze

    def fields(scope = nil, model: nil, **options, &block)
      options[:theme] ||= @theme
      super
    end

    def label(method, text = nil, options = {}, &block)
      origin = (options.delete(:origin) || {}).with_defaults!(@css[:origin])
      options[:class] = origin[:label] unless options.key?(:class)
      wrap = options.delete(:wrap_label) || @css.dig(:wrap_label, :normal)

      wrapping(super, wrap: wrap)
    end

    def submit(value = nil, options = {})
      wrap_all_with(nil, options) do |css|
        options[:class] = css.dig(:origin, :submit) unless options.key?(:class)
        options[:data] ||= {}
        options[:data][:disable_with] = 'Searching'
        if self.options[:method] == 'get'
          options[:name] = nil
          if options[:data][:action].present?
            options[:data][:action] += ' form#filter'
          else
            options[:data][:action] = 'form#filter'
          end
        end
        css[:all][:normal] = css.dig(:all, :submit)
        submit_content = wrapping(super, wrap: css.dig(:wrap, :submit))

        offset(css.dig(:before_wrap, :submit)) + submit_content
      end
    end

    def check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
      wrap_all_with(method, options, tag: 'label') do |css|
        default_options(method, options)
        options[:class] = css.dig(:origin, :checkbox) unless options.key?(:class)
        css[:all][:normal] = css.dig(:all, :checkbox)
        options[:label_position] ||= 'after'

        label_content = ''
        if options[:label] && options[:label_position] == 'after'
          content = super + content_tag(:span, options.delete(:label))
        elsif options[:label] && options[:label_position] == 'before'
          content = content_tag(:span, options.delete(:label)) + super
        elsif options[:label]
          content = super
          label_content = content_tag(:span, options.delete(:label), class: css.dig(:origin, :label))
        else
          content = super
        end

        wrap_content = wrapping(content, wrap: css.dig(:wrap, :checkbox))
        if options[:label_position] == 'before_wrap'
          label_content + wrap_content + offset(css.dig(:after_wrap, :checkbox))
        else
          offset(css.dig(:before_wrap, :checkbox)) + wrap_content + offset(css.dig(:after_wrap, :checkbox))
        end
      end
    end

    def collection_check_boxes(method, collection, value_method, text_method, options = {}, html_options = {}, &block)
      wrap_with(method, options, :checkboxes) do |css|
        options[:origin] = css[:origin]
        wrapping(super, wrap: css.dig(:wrap, :checkboxes))
      end
    end

    def radio_button(method, tag_value, options = {})
      wrap_all_with(method, options, tag: 'label') do |css|
        default_options(method, options)
        options[:class] = css.dig(:origin, :radio) unless options.key?(:class)
        css[:all][:normal] = css.dig(:all, :radio)
        options[:label_position] ||= 'after'

        label_content = ''
        if options[:label] && options[:label_position] == 'after'
          content = super + content_tag(:span, options.delete(:label))
        elsif options[:label] && options[:label_position] == 'before'
          content = content_tag(:span, options.delete(:label)) + super
        elsif options[:label]
          content = super
          label_content = content_tag(:span, options.delete(:label), class: css.dig(:origin, :label))
        else
          content = super
        end

        wrap_content = wrapping(content, wrap: css.dig(:wrap, :radio))
        if options[:label_position] == 'before_wrap'
          label_content + wrap_content + offset(css.dig(:after_wrap, :radio))
        else
          offset(css.dig(:before_wrap, :radio)) + wrap_content +  offset(css.dig(:after_wrap, :radio))
        end
      end
    end

    def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {}, &block)
      wrap_with(method, options, :radio) do |css|
        options[:origin] = css[:origin]
        wrapping(super, wrap: css.dig(:wrap, :radios))
      end
    end

    def select(method, choices = nil, options = {}, html_options = {}, &block)
      wrap_with(method, options, :select) do |css|
        options[:selected] ||= default_value(method)
        if html_options[:multiple]
          html_options[:class] = css.dig(:origin, :multi_select)
        else
          html_options[:class] = css.dig(:origin, :select)
        end unless html_options.key?(:class)
        options[:include_blank] = I18n.t('helpers.select.prompt') if options[:include_blank] == true
        css[:all][:normal] = css.dig(:all, :select)

        wrapping(super, wrap: css.dig(:wrap, :select))
      end
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      wrap_with(method, options, :select) do |css|
        if html_options[:multiple]
          html_options[:class] = css.dig(:origin, :multi_select)
        else
          html_options[:class] = css.dig(:origin, :select)
        end unless html_options.key?(:class)
        options[:include_blank] = I18n.t('helpers.select.prompt') if options[:include_blank] == true
        css[:all][:normal] = css.dig(:all, :select)

        wrapping(super, wrap: css.dig(:wrap, :select))
      end
    end

    def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
      wrap_with(method, options, :normal) do |css|
        html_options[:class] = if html_options[:multiple]
          css.dig(:origin, :multi_select)
        else
          css.dig(:origin, :select)
        end unless html_options.key?(:class)

        wrapping(super, wrap: css.dig(:wrap, :select))
      end
    end

    def time_select(method, options = {}, html_options = {})
      wrap_with(method, options, :select) do |css|
        options[:time_separator] = '<span class="select-divider">:</span>'.html_safe unless options.key?(:time_separator)
        html_options[:class] = css.dig(:origin, :select) unless html_options.key?(:class)
        wrapping(super, wrap: css.dig(:wrap, :select))
      end
    end

    def hidden_field(method, options = {})
      options[:autocomplete] = on_options[:autocomplete] unless options.key?(:autocomplete)
      super
    end

    def date_field(method, options = {})
      wrap_with(method, options, :normal) do |css|
        options[:class] = css.dig(:origin, :input) unless options.key?(:class)
        if method.end_with?('(date)')
          real_method = method.to_s.sub('(date)', '')
          options[:data] = {}
          options[:data].merge! controller: 'datetime', action: 'datetime#default' if object.column_for_attribute(real_method).type == :datetime
          options[:value] = object.read_attribute(real_method)&.to_date
        end

        wrapping(super, wrap: css.dig(:wrap, :input))
      end
    end

    def number_field(method, options = {})
      wrap_with(method, options, :normal) do |css|
        options[:class] = css.dig(:origin, :input) unless options.key?(:class)
        options[:step] = default_step(method) unless options.key?(:step)
        wrapping(super, wrap: css.dig(:wrap, :input))
      end
    end

    def text_area(method, options = {})
      wrap_with(method, options, :normal) do |css|
        options[:class] = css.dig(:origin, :textarea) unless options.key?(:class)
        wrapping(super, wrap: css.dig(:wrap, :input))
      end
    end

    # block 应返回 input with wrapper 的内容
    # 注意：此处不要用解构参数 **options, 因为解构的 options object_id 会变。
    def wrap_with(method, options, type)
      wrap_all_with(method, options) do |css|
        default_options(method, options)
        if options[:label]
          label_content = label method, options.delete(:label), wrap_label: css.dig(:wrap_label, type)
        else
          options.delete(:label)
          label_content = ''.html_safe
        end
        input_content = yield css

        label_content + offset(css.dig(:before_wrap, :input)) + input_content + offset(css.dig(:after_wrap, :input))
      end
    end

    # block 应返回  label_content + input_content 的内容
    def wrap_all_with(method, options, tag: 'div')
      css = {}
      @css.each do |key, value|
        css[key] = value.merge options.delete(key) || {}
      end
      inner_content = yield css

      wrapping_all inner_content, method, all: css[:all], tag: tag, required: options[:required]
    end

    INPUT_FIELDS.each do |selector|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{selector}(method, options = {})
          wrap_with(method, options, :normal) do |css|
            unless options.key?(:class)
              if object_has_errors?(method)
                options[:class] = css.dig(:error, :input)
              else
                options[:class] = css.dig(:origin, :input) 
              end
            end
            wrapping(super, wrap: css.dig(:wrap, :input))
          end
        end
      RUBY_EVAL
    end

  end
end
