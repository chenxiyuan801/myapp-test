class Order < ApplicationRecord

  validates :user_id, presence: true
  validates :product_id, presence: true
  validates :address_id, presence: true
  validates :total_money, presence: true
  validates :amount, presence: true
  validates :order_no, uniqueness: true

  belongs_to :user
  belongs_to :product
  belongs_to :address
  belongs_to :payment

  before_create :gen_order_no

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

  module OrderStatus
    Initial = 'initial'
    Paid = 'paid'
  end

  def is_paid?
    self.status == OrderStatus::Paid
  end

  def self.create_order_from_shopping_carts! user, address, *shopping_carts
    shopping_carts.flatten!
    address_attrs = address.attributes.except!("id", "created_at", "updated_at")

    orders = []
    transaction do
      order_address = user.addresses.create!(address_attrs.merge(
        "address_type" => Address::AddressType::Order
      ))

      shopping_carts.each do |shopping_cart|
        orders << user.orders.create!(
          product: shopping_cart.product,
          address: order_address,
          amount: shopping_cart.amount,
          total_money: shopping_cart.amount * shopping_cart.product.price
        )
      end

      shopping_carts.map(&:destroy!)
    end

    orders
  end

  private
  def gen_order_no
    self.order_no = RandomCode.generate_order_uuid
  end

end
