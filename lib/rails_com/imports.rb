# frozen_string_literal: true

module RailsCom::Imports
  extend self

  def imports(root = ApplicationExport)
    return @imports if defined? @imports
    Zeitwerk::Loader.eager_load_all
    @imports = root.subclasses
  end

end