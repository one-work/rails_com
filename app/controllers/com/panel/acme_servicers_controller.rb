module Com
  class Panel::AcmeServicersController < Panel::BaseController
    before_action :set_new_acme_servicer, only: [:new, :create]

    def new
      @acme_servicer.acme_domains.build
    end

    private
    def set_new_acme_servicer
      @acme_servicer = AcmeServicer.new(acme_servicer_params)
    end

    def acme_servicer_params
      params.fetch(:acme_servicer, {}).permit(
        :type,
        :key,
        :secret,
        acme_domains_attributes: [:domain]
      )
    end

  end
end
