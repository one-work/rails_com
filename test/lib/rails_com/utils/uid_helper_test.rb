require 'test_helper'
class UidHelperTest < ActiveSupport::TestCase


  test 'nsec_uuid' do
    r =  UidHelper.nsec_uuid 'TEST'
    assert_kind_of String, r
    assert_equal 'TEST', r.split('-')[0]
  end



end