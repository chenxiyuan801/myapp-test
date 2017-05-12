class Payment < ApplicationRecord

  module PaymentStatus
    Initial = 'initial'
    Success = 'success'
    Failed = 'failed'
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

  belongs_to :user
  has_many :orders

  before_create :gen_payment_no

  def self.create_from_orders! user, *orders
    orders.flatten!

    payment = nil
    transaction do
      payment = user.payments.create!(
        total_money: orders.sum(&:total_money)
      )

      orders.each do |order|
        if order.is_paid?
          raise "order #{order.order_no} has already paid"
        end

        order.payment = payment
        order.save!
      end
    end

    payment
  end

  def is_success?
    self.status == PaymentStatus::Success
  end

  def do_success_payment! options
    self.transaction do
      self.transaction_no = options[:pay_no]
      self.status = Payment::PaymentStatus::Success
      self.raw_response = options.to_json
      self.payment_at = Time.now
      self.save!

      # 更新订单状态
      self.orders.each do |order|
        if order.is_paid?
          raise "order #{order.order_no} has alreay been paid"
        end

        order.status = Order::OrderStatus::Paid
        order.payment_at = Time.now
        order.save!
      end
    end
  end

  def do_failed_payment! options
    self.transaction_no = options[:pay_no]
    self.status = Payment::PaymentStatus::Failed
    self.raw_response = options.to_json
    self.payment_at = Time.now
    self.save!
  end

  private
  def gen_payment_no
    self.payment_no = RandomCode.generate_utoken(32)
  end

end
