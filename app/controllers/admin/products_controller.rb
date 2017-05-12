class Admin::ProductsController < Admin::BaseController

  before_action :find_product, only: [:edit, :update, :destroy]

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

  def index
    @products = Product.page(params[:page] || 1).per_page(params[:per_page] || 10)
      .order("id desc")
  end

  def new
    @product = Product.new
    @root_categories = Category.roots
  end

  def create
    @product = Product.new(params.require(:product).permit!)
    @root_categories = Category.roots

    if @product.save
      flash[:notice] = "创建成功"
      redirect_to admin_products_path
    else
      render action: :new
    end
  end

  def edit
    @root_categories = Category.roots
    render action: :new
  end

  def update
    @product.attributes = params.require(:product).permit!
    @root_categories = Category.roots
    if @product.save
      flash[:notice] = "修改成功"
      redirect_to admin_products_path
    else
      render action: :new
    end
  end

  def destroy
    if @product.destroy
      flash[:notice] = "删除成功"
      redirect_to admin_products_path
    else
      flash[:notice] = "删除失败"
      redirect_to :back
    end
  end

  private
  def find_product
    @product = Product.find(params[:id])
  end

end
