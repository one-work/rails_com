# frozen_string_literal: true
module RailsCom::FormatHelper

  def simple_format_hash(hash_text, html_options = {}, options = {})
    wrapper_tag = options.fetch(:wrapper_tag, :p)

    hash_text.map do |k, v|
      if k.to_s.rstrip.end_with?(':')
        split_text = content_tag('span', '')
      else
        split_text = content_tag('span', ':')
      end
      text = content_tag('span', k.to_s) + split_text + content_tag('span', v.to_s)

      content_tag(wrapper_tag, text, html_options)
    end.join("\n\n").html_safe
  end

  def ex_simple_format(text, html_options = {}, options = {})
    text = '' if text.nil?
    text = text.dup
    start_tag = tag('p', html_options, true)
    text = sanitize(text) unless options[:sanitize] == false
    text = text.to_str
    text.gsub!(/\n?/, "</p>\n#{start_tag}")
    text.insert 0, start_tag
    text.html_safe.safe_concat("</p>")
  end

  def simple_format(text, html_options = {}, options = {})
    if text.is_a?(Hash)
      return simple_format_hash(text, html_options, options)
    end

    if text.is_a?(Array)
      return text.map { |t| content_tag(:p, t, html_options) }.join("\n").html_safe
    end

    text = text.to_s

    super
  end

end
