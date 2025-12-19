# frozen_string_literal: true

# 亚洲最新ip地址
# http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
module IpHelper
  extend self

  def read(name)
    IO.foreach(name) do |x|
      if x.match? /apnic\|CN\|ipv4/
        r = x.split('|').values_at(3, 4)
        int_min = IPAddr.new(r[0]).to_i
        int_max = min + r[1].to_i - 1
        ip_max = IPAddr.new(max, Socket::AF_INET).to_s

        [r[0], ip_max, int_min, int_max]
      end
    end
  end

end