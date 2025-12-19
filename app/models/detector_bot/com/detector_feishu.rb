module Com
  class DetectorFeishu < DetectorBot
    include Model::DetectorBot::DetectorFeishu
    include Inner::FeishuBot
  end
end
