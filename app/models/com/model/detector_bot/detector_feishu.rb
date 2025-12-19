module Com
  module Model::DetectorBot::DetectorFeishu

    def send_message(err)
      add_at
      set_content(err)
      _body = body('请求存在故障', content)
      res = HTTPX.post(hook_url, json: _body)
      res.json
    end

  end
end
