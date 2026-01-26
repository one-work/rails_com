# frozen_string_literal: true

module RailsCom::Exports
  extend self

  def exports(root = ApplicationExport)
    return @exports if defined? @exports
    Zeitwerk::Loader.eager_load_all
    @exports = root.subclasses
  end

end