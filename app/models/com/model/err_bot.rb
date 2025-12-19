module Com
  module Model::ErrBot
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :base_url, :string
      attribute :hook_key, :string
      attribute :hook_url, :string
      attribute :first_time, :boolean
      attribute :secret, :string

      has_many :err_notices

      accepts_nested_attributes_for :err_notices, allow_destroy: true

      scope :first_time, -> { where(first_time: true) }

      before_validation :set_hook_key, if: -> { hook_url_changed? }
    end

    def set_hook_key
      self.hook_key = hook_url.delete_prefix(self.base_url)
    end

    def set_content(err)
      err.as_json(only: [:path, :controller_name, :action_name, :params, :session, :headers, :ip]).each do |k, v|
        add_column err.class.human_attribute_name(k), v unless v.blank?
      end
      add_column '用户信息', err.user_info.inspect
      add_paragraph(err.exception)
      add_paragraph(err.exception_backtrace[0])
      link_more(
        '详细点击',
        Rails.application.routes.url_for(
          controller: 'com/panel/errs',
          action: 'show',
          err_summary_id: err.err_summary.id,
          id: err.id
        )
      )
    end

  end
end

