require 'acme-client'
module Com
  module Model::AcmeAccount
    extend ActiveSupport::Concern

    included do
      attribute :email, :string
      attribute :kid, :string

      has_many :acme_orders, dependent: :destroy_async

      if ActiveStorage::Blob.services.instance_values.dig('configurations', :acme)
        has_one_attached :private_pem, service: :acme
      else
        has_one_attached :private_pem
      end

      after_create_commit :generate_account

      validates :email, uniqueness: true
    end

    def private_key
      return @private_key if defined? @private_key
      if private_pem_blob
        @private_key = OpenSSL::PKey::RSA.new(private_pem_blob.download)
      else
        @private_key = OpenSSL::PKey::RSA.new(4096)
      end
    end

    def generate_account
      store_private_pem unless private_pem_blob
      self.update(kid: account.kid)
    end

    def store_private_pem
      Tempfile.open do |file|
        file.binmode
        file.write private_key.to_pem
        file.rewind
        self.private_pem.attach io: file, filename: "#{email}.pem"
      end
    end

    def client
      return @client if defined? @client

      if self.kid
        @client = Acme::Client.new(private_key: private_key, directory: directory, kid: kid)
      else
        @client = Acme::Client.new(private_key: private_key, directory: directory)
      end
    end

    def directory
      RailsCom.config.acme_url
    end

    def contact
      "mailto:#{email}"
    end

    def account
      return @account if defined? @account
      @account = client.new_account(contact: contact, terms_of_service_agreed: true)
    end

  end
end
