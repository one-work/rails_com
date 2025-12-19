module RailsCom::LinkToHelper

  def button_to(name = nil, options = nil, html_options = nil, &block)
    button_or_link_to(name, options, html_options, block) do |allowed|
      return super if allowed
    end
  end

  def link_to(name = nil, options = nil, html_options = nil, &block)
    button_or_link_to(name, options, html_options, block) do |allowed|
      return super if allowed
    end
  end

  def button_or_link_to(name, options, html_options, block)
    if block
      _options = name
      _html_options = options || {}
    else
      _options = options
      _html_options = html_options || {}
    end
    text = _html_options.delete(:text)  # text 如果存在须在渲染前删除
    skip = _html_options.delete(:skip)
    allowed = role_permit_options?(_options, _html_options.fetch(:method, nil))

    if skip || (text && !allowed)
      if block
        content_tag(:div, _html_options.slice(:class, :data), &block)
      else
        ERB::Util.html_escape(name)
      end
    else
      yield allowed
    end
  end

end