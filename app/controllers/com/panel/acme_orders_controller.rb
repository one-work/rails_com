module Com
  class Panel::AcmeOrdersController < Panel::BaseController
    before_action :set_acme_account
    before_action :set_acme_order, only: [:show, :edit, :order, :verify, :cert, :update, :destroy]
    before_action :set_new_acme_order, only: [:new, :create]

    def index
      q_params = {
        acme_account_id: @acme_account.id
      }
      q_params.merge! params.permit(:acme_account_id)

      @acme_orders = AcmeOrder.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def order
      r = @acme_order.order(true)
      render 'update'
    end

    def cert
      @acme_order.get_cert

      render 'update'
    end

    private
    def set_acme_account
      @acme_account = AcmeAccount.find params[:acme_account_id]
    end

    def set_acme_order
      @acme_order = @acme_account.acme_orders.find(params[:id])
    end

    def set_new_acme_order
      @acme_order = @acme_account.acme_orders.build(acme_order_params)
    end

    def acme_order_params
      params.fetch(:acme_order, {}).permit(
        :sync_host,
        :sync_path,
        identifiers: []
      )
    end

  end
end
