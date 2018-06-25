class QbwcController < ApplicationController  
  # before_action :authenticate_user!, except:[:_generate_wsdl, :action]
  # before_action :admin_only, except:[:_generate_wsdl]
  include QBWC::Controller

end