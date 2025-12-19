module Com
  module Model::DetectorBot::DetectorWorkWechat

    def send_message(err)
      set_content(err)
      HTTPX.post(hook_url, json: body)
    end

    def body
      {
        msgtype: 'markdown',
        markdown: {
          content: content
        }
      }
    end

  end
end
