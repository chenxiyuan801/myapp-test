class VerifyToken < ApplicationRecord

  validates_presence_of :token
  validates_presence_of :cellphone

  scope :available, -> { where("expired_at > :time", time: Time.now) }

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

  def self.upsert cellphone, token
    cond = { cellphone: cellphone }
    record = self.find_by(cond)
    unless record
      record = self.create cond.merge(token: token, expired_at: Time.now + 10.minutes)
    else
      record.update_attributes token: token, expired_at: Time.now + 10.minutes
    end

    record
  end
end
