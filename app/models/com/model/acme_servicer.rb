module Com
  module Model::AcmeServicer
    extend ActiveSupport::Concern

    included do
      attr_accessor :domain

      attribute :type, :string
      attribute :key, :string, comment: '阿里云DNS'
      attribute :secret, :string

      encrypts :key, :secret

      has_many :acme_domains

      accepts_nested_attributes_for :acme_domains
    end

    def client
      'Should implement in subclass'
    end

  end
end
