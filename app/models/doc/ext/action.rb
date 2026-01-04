module Doc
  module Ext::Action
    extend ActiveSupport::Concern

    included do
      has_many :subjects, class_name: 'Doc::Subject', dependent: :delete_all
    end

  end
end