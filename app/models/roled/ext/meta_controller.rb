module Roled
  module Ext::MetaController
    extend ActiveSupport::Concern

    included do
      has_many :role_rules, class_name: 'Roled::RoleRule', foreign_key: :controller_path, primary_key: :controller_path
    end

  end
end
