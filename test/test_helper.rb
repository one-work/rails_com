ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/environment'
require 'rails/test_help'
#require 'minitest/mock'
require 'minitest/hooks/test'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

class ActiveSupport::TestCase
  self.fixture_paths = [
    File.expand_path('fixtures', __dir__)
  ]
  self.file_fixture_path = File.expand_path('fixtures', __dir__) + '/files'
  ActionDispatch::IntegrationTest.fixture_paths = self.fixture_paths
  fixtures :all
  #parallelize(workers: :number_of_processors)

  def before_all
    #Meta::Business.sync
    #Com::MetaNamespace.sync
    #Com::MetaController.sync
  end
end

