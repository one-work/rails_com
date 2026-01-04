require 'test_helper'
class TimeHelperTest < ActiveSupport::TestCase

  test 'exact_distance_time' do
    now = Time.now
    r = TimeUtil.exact_distance_time now, now + 1
    assert_equal 1, r[:second]
  end

end
