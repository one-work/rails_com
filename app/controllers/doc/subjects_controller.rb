module Doc
  class SubjectsController < BaseController
    before_action :set_subject, only: [:show, :edit, :update, :destroy]

    def index
    end

    def code
      @subject = Subject.find_by(controller_path: params[:meta_controller], action_name: params[:meta_action])
    end

    private
    def set_subject
      @subject = Subject.find params[:id]
    end
  end
end
