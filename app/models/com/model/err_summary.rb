# frozen_string_literal: true

module Com
  module Model::ErrSummary
    extend ActiveSupport::Concern

    included do
      attribute :controller_name, :string
      attribute :action_name, :string
      attribute :exception_object, :string
      attribute :errs_count, :integer

      has_many :errs, ->(o){ where(action_name: o.action_name, exception_object: o.exception_object) }, primary_key: :controller_name, foreign_key: :controller_name
    end

    def clean
      self.class.transaction do
        self.errs.delete_all(:delete_all)
        self.destroy
      end
    end

    class_methods do
      def reset_all_errs_count
        self.find_each do |i|
          self.reset_counters i.id, :errs
        end
      end
    end

  end
end
