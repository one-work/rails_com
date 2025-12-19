module Com
  class DiskController < ActiveStorage::DiskController

    def update
      token = decode_verified_token
      if token
        if acceptable_content?(token)
          named_disk_service(token[:service_name]).upload token[:key], request.body, checksum: token[:checksum].presence
          head :no_content
        else
          head :unprocessable_entity
        end
      else
        head :not_found
      end
    rescue ActiveStorage::IntegrityError
      head :unprocessable_entity
    end

  end
end
