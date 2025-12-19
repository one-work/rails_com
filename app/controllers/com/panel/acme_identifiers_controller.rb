module Com
  class Panel::AcmeIdentifiersController < Panel::BaseController
    before_action :set_acme_order
    before_action :set_acme_identifier, only: [:show, :edit, :update, :destroy]
    before_action :set_new_acme_identifier, only: [:new, :create]

    def index
      @acme_identifiers = @acme_order.acme_identifiers
    end

    private
    def set_acme_order
      @acme_order = AcmeOrder.find params[:acme_order_id]
    end

    def set_acme_identifier
      @acme_identifier = AcmeIdentifier.find(params[:id])
    end

    def set_new_acme_identifier
      @acme_identifier = @acme_order.acme_identifiers.build(acme_identifier_params)
    end

    def acme_identifier_permit_params
      [
        :identifier
      ]
    end

  end
end
