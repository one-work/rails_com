module Com
  module Model::ErrBot::FeishuBot
    extend ActiveSupport::Concern

    included do
      attribute :base_url, :string, default: 'https://open.feishu.cn/open-apis/bot/v2/hook/'
    end

    def send_message(err)
      set_content(err)
      _body = body('请求存在错误', content)
      res = HTTPX.post(hook_url, json: body)
      res.json
    end

  end
end
