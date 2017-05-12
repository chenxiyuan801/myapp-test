class ShoppingCart < ApplicationRecord

  validates :user_uuid, presence: true
  validates :product_id, presence: true
  validates :amount, presence: true

  belongs_to :product

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

  scope :by_user_uuid, -> (user_uuid) { where(user_uuid: user_uuid) }

  def self.create_or_update! options = {}
    cond = {
      user_uuid: options[:user_uuid],
      product_id: options[:product_id]
    }

    record = where(cond).first
    if record
      record.update_attributes!(options.merge(amount: record.amount + options[:amount]))
    else
      record = create!(options)
    end

    record
  end

end
