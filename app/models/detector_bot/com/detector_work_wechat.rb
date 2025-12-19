module Com
  class DetectorWorkWechat < DetectorBot
    include Model::DetectorBot::DetectorWorkWechat
    include Inner::WorkWechatBot
  end
end
