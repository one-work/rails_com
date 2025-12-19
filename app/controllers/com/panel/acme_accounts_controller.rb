module Com
  class Panel::AcmeAccountsController < Panel::BaseController

    private
    def acme_account_permit_params
      [
        :email
      ]
    end

  end
end
