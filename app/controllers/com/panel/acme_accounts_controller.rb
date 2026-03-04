module Com
  class Panel::AcmeAccountsController < Panel::BaseController

    private
    def acme_account_params
      params.fetch(:acme_account, {}).permit(
        :email
      )
    end

  end
end
