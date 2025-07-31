module Com
  class My::SshKeysController < My::BaseController
    before_action :set_ssh_key, only: [:show, :edit, :update, :destroy, :setup, :deploy, :remote_status]
    before_action :set_new_ssh_key, only: [:new, :create]

    def index
      @ssh_keys = SshKey.where(user_id: current_user.id).order(id: :desc).page(params[:page])
    end

    def setup
      SshKeySetupJob.perform_later(@ssh_key, Current.session.id)
    end

    def deploy
      SshKeyDeployJob.perform_later(@ssh_key, Current.session.id)
    end

    def remote_status
      result = @ssh_key.remote_status
      if result == 'failed'
        @result = '登录失败'
      else
        @result = result
      end
    end

    private
    def set_ssh_key
      @ssh_key = SshKey.where(user_id: current_user.id).find params[:id]
    end

    def set_new_ssh_key
      @ssh_key = SshKey.new(ssh_key_params)
    end

    def ssh_key_params
      p = params.fetch(:ssh_key, {}).permit(
        :host
      )
      p.merge! user_id: current_user.id
    end

  end
end
