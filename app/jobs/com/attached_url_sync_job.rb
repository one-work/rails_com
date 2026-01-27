module Com
  class AttachedUrlSyncJob < ApplicationJob

    def perform(model, attach, *urls)
      attached = model.public_send(attach)
      attached.url_sync(*urls) unless attached.attached?
    end

  end
end
