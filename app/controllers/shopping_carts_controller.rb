class ShoppingCartsController < ApplicationController

  before_action :find_shopping_cart, only: [:update, :destroy]

  def index
    fetch_home_data
    @shopping_carts = ShoppingCart.by_user_uuid(session[:user_uuid])
      .order("id desc").includes([:product => [:main_product_image]])
  end

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

  def create
    amount = params[:amount].to_i
    amount = amount <= 0 ? 1 : amount

    @product = Product.find(params[:product_id])
    @shopping_cart = ShoppingCart.create_or_update!({
      user_uuid: session[:user_uuid],
      product_id: params[:product_id],
      amount: amount
    })

    render layout: false
  end

  def update
    if @shopping_cart
      amount = params[:amount].to_i
      amount = amount <= 0 ? 1 : amount

      @shopping_cart.update_attribute :amount, amount
    end

    redirect_to shopping_carts_path
  end

  def destroy
    @shopping_cart.destroy if @shopping_cart

    redirect_to shopping_carts_path
  end

  private
  def find_shopping_cart
    @shopping_cart = ShoppingCart.by_user_uuid(session[:user_uuid])
      .where(id: params[:id]).first
  end

end
