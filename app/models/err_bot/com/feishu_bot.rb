module Com
  class FeishuBot < ErrBot
    include Model::ErrBot::FeishuBot
    include Inner::FeishuBot
  end
end
