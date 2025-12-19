module Com
  module Model::ErrBot::WorkWechatBot
    extend ActiveSupport::Concern

    included do
      attribute :base_url, :string, default: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key='
    end

  end
end
