# frozen_string_literal: true

class Object
  def to_format_yaml
    to_yaml.gsub(/^---(\s|\n)?/, '')
  end
end