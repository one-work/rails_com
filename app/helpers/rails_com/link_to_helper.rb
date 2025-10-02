module RailsCom::LinkToHelper

  def button_to(name = {}, options = {}, html_options = nil, &block)
    if block_given?
      _options = name
      _html_options = options || {}
    else
      _options = options
      _html_options = html_options || {}
    end
    text = _html_options.delete(:text)
    skip_role = _html_options.delete(:skip_role)

    return super if skip_role || role_permit_options?(_options, _html_options.fetch(:method, nil))

    if text
      if block_given?
        content_tag(:div, _html_options.slice(:class, :data), &block)
      else
        ERB::Util.html_escape(name)
      end
    end
  end

  def link_to(name = {}, options = {}, html_options = nil, &block)
    if block_given?
      _options = name
      _html_options = options || {}
    else
      _options = options
      _html_options = html_options || {}
    end

    if request.variant.include?(:mini_program)
      _html_options['data-turbo-action'] = 'replace'
    end

    text = _html_options.delete(:text)
    skip_role = _html_options.delete(:skip_role)
    return super if skip_role || role_permit_options?(_options, _html_options.fetch(:method, nil))

    if text
      if block_given?
        content_tag(:div, _html_options.slice(:class, :data), &block)
      else
        ERB::Util.html_escape(name)
      end
    end
  end

end