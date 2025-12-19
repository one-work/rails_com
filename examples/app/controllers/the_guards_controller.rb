class TheGuardsController < ApplicationController
  layout 'rails_com/application'
  skip_before_action :require_recaptcha, raise: false

  def index

  end

  def create
    if verify_rucaptcha?
      clear_ip_count
      redirect_to session[:back_to] || root_url
    else
      redirect_to '/the_guards', alert: 'Invalid captcha code.'
    end
  end

end
