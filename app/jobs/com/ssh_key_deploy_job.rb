module Com
  class SshKeyDeployJob < ApplicationJob

    def perform(ssh_key, auth_token)
      ssh_key.deploy_with_log(auth_token)
    end

  end
end
