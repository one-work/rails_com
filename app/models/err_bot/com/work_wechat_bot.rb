module Com
  class WorkWechatBot < ErrBot
    include Model::ErrBot::WorkWechatBot
    include Inner::WorkWechatBot
  end
end
