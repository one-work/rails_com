module Doc
  class SubjectsController < BaseController

    def index
      @subjects = Subject.page(params[:page])
    end

  end
end
