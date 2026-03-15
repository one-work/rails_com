module Statis
  module Model::CounterWeek
    extend ActiveSupport::Concern
    include Inner::Compute
    include Ext::Week

  end
end
