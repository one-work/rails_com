# frozen_string_literal: true

require 'rails/generators'
module RailsCom::Generators
  module ScaffoldController

    def assign_controller_names!(name)
      if name.include?('/')
        name = name.split('/')[1..-1].join('/')
        @namespace = name.split('/')[0]
      end

      super
    end

  end
end

Rails::Generators::ScaffoldControllerGenerator.prepend RailsCom::Generators::ScaffoldController
