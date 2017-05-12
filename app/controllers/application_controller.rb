class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  module RandomCode
    class << self
      def generate_password len = 8
        seed = (0..9).to_a + ('a'..'z').to_a + ('A'..'Z').to_a + ['!', '@', '#', '$', '%', '.', '*'] * 4
        token = ""
        len.times { |t| token << seed.sample.to_s }
        token
      end

      def generate_cellphone_token len = 6
        a = lambda { (0..9).to_a.sample }
        token = ""
        len.times { |t| token << a.call.to_s }
        token
      end

      def generate_utoken len = 8
        a = lambda { rand(36).to_s(36) }
        token = ""
        len.times { |t| token << a.call.to_s }
        token
      end

      def generate_product_uuid
        Date.today.to_s.split('-')[1..-1].join() << generate_utoken(6).upcase
      end

      def generate_order_uuid
        Date.today.to_s.split('-').join()[2..-1] << generate_utoken(8).upcase
      end
    end
  end

  before_action :set_browser_uuid

  protected
  def auth_user
    unless logged_in?
      flash[:notice] = "请登录"
      redirect_to new_session_path
    end
  end

  def fetch_home_data
    @categories = Category.grouped_data
    @shopping_cart_count = ShoppingCart.by_user_uuid(session[:user_uuid]).count
  end

  def set_browser_uuid
    uuid = cookies[:user_uuid]

    unless uuid
      if logged_in?
        uuid = current_user.uuid
      else
        uuid = RandomCode.generate_utoken
      end
    end

    update_browser_uuid uuid
  end

  def update_browser_uuid uuid
    session[:user_uuid] = cookies.permanent['user_uuid'] = uuid
  end
end
