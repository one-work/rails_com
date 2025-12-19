# frozen_string_literal: true

module Com
  module Model::ErrNotice
    extend ActiveSupport::Concern

    included do
      attribute :controller_name, :string, index: true

      belongs_to :err_bot
      belongs_to :err, foreign_key: :controller_name, primary_key: :controller_name, optional: true
    end
  end
end
