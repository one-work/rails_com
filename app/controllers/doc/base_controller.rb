module Doc
  class BaseController < BaseController
    before_action :set_subjects

    private
    def set_subjects
      @subjects = Subject.page(params[:page])
    end

  end
end
