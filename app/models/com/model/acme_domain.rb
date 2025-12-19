module Com
  module Model::AcmeDomain
    extend ActiveSupport::Concern

    included do
      attribute :domain, :string

      belongs_to :acme_servicer
    end

    def client
      acme_servicer.domain = domain
      acme_servicer
    end

  end
end
