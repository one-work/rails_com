module Com
  module Model::AcmeIdentifier
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :identifier, :string
      attribute :file_name, :string
      attribute :file_content, :string
      attribute :token, :string
      attribute :record_name, :string
      attribute :record_content, :string
      attribute :domain, :string
      attribute :domain_root, :string
      attribute :wildcard, :boolean
      attribute :url, :string

      belongs_to :acme_order

      enum :status, {
        pending: 'pending',
        valid: 'valid',
        invalid: 'invalid',
        deactivated: 'deactivated'
      }, prefix: true

      before_validation :sync_domain_root, if: -> { domain && domain_changed? }
    end

    def sync_domain_root
      self.domain_root = domain.split('.')[-2 .. -1].join('.')
    end

    def reset
      assign_attributes(
        record_name: nil,
        record_content: nil,
        file_name: nil,
        file_content: nil,
        url: nil,
        status: nil
      )
    end

    def authorization
      return @authorization if defined?(@authorization) && url.present?
      @authorization = acme_order.order.authorizations.find { |i| domain == i.domain && wildcard.present? == i.wildcard.present? }
    rescue Acme::Client::Error::BadNonce
      retry
    end

    def deactivate
      acme_order.acme_account.client.deactivate_authorization(url: url)
    rescue Acme::Client::Error::BadNonce
      retry
    end

  end
end
