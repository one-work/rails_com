# frozen_string_literal: true

module Com
  class ApplicationController < ApplicationController

    def up
      render plain: 'ok'
    end

  end
end