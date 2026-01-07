module Doc
  class SubjectsController < BaseController
    before_action :set_subject, only: [:show, :edit, :update, :destroy]

    def index
    end

    private
    def set_subject
      @subject = Subject.find params[:id]
    end
  end
end
