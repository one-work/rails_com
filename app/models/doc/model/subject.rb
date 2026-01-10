module Doc
  module Model::Subject
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :controller_path, :string
      attribute :action_name, :string
      attribute :path_params, :json
      attribute :request_params, :json
      attribute :request_comments, :json
      attribute :request_headers, :json
      attribute :request_type, :string
      attribute :request_body, :json
      attribute :response_status, :integer, default: 200
      attribute :response_headers, :json
      attribute :response_type, :string
      attribute :response_body, :json
      attribute :note, :string
      attribute :synced_at, :datetime

      belongs_to :meta_action, class_name: 'Meta::Action', foreign_key: [:controller_path, :action_name], primary_key: [:controller_path, :action_name], optional: true
    end

    def xx

    end

    class_methods do

      def sync(now = Time.current)
        DocUtil.docs_hash.each do |controller_path, action_names|
          action_names.each do |action_name|
            subject = self.find_or_initialize_by(controller_path: controller_path, action_name: action_name)
            subject.synced_at = now
            subject.save
          end
        end
        where(synced_at: ...now).delete_all
      end

    end

  end
end
