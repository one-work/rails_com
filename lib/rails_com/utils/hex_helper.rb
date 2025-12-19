module HexHelper
  extend self

  def sample
    [rand(0..255), rand(0..255), rand(0..255)].map { |i| i.to_s(16).rjust(2, '0') }.join
  end

  def rgb_sample
    "##{sample}"
  end

end
