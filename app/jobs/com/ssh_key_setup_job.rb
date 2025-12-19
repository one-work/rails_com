module Com
  class SshKeySetupJob < ApplicationJob

    def perform(ssh_key, auth_token)
      ssh_key.setup_with_log(auth_token)
    end

  end
end
