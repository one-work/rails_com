module Statis
  module Model::CounterYear
    extend ActiveSupport::Concern
    include Inner::Compute
    include Ext::Year

    included do
      attribute :begin_on, :date
    end

  end
end
