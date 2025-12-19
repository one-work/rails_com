module Com
  class AcmeOrderJob < ApplicationJob

    def perform(acme_order)
      acme_order.get_cert
    end

  end
end
