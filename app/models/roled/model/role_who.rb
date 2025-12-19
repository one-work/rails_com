module Roled
  module Model::RoleWho
    extend ActiveSupport::Concern

    included do
      belongs_to :role
      belongs_to :who, polymorphic: true

      has_many :role_rules, primary_key: :role_id, foreign_key: :role_id
      has_many :tabs, primary_key: :role_id, foreign_key: :role_id

      after_create :compute_role_cache!
      after_destroy :compute_role_cache!
    end

    def compute_role_cache!
      who.compute_role_cache!
    end

  end
end
