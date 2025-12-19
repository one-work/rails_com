module Com
  module Inner::WorkWechatBot
    extend ActiveSupport::Concern

    def send_err_message(title = '队列任务出现错误', err_hash)
      err_hash.each do |key, value|
        add_column key, value
      end
      _body = {
        msgtype: 'markdown',
        markdown: {
          content: ["# #{title}", content].join("\n\n")
        }
      }
      res = HTTPX.post(hook_url, json: _body)
      res.json
    end

    def send_message(err)
      set_content(err)
      HTTPX.post(hook_url, json: body)
    end

    def body(title, content)
      {
        msgtype: 'markdown',
        markdown: {
          content: ["# #{title}", content].join("\n\n")
        }
      }
    end

  end
end
