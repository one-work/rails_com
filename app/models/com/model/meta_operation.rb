module Com
  module Model::MetaOperation
    extend ActiveSupport::Concern

    included do
      attribute :action_name, :string

      enum :operation, {
        list: 'list',
        read: 'read',
        add: 'add',
        edit: 'edit',
        remove: 'remove'
      }, default: 'read'
    end

  end
end
