module Com
  class MemoryJob < ApplicationJob

    def perform
      raise
      #Open3.popen2e('')
    end

  end
end
