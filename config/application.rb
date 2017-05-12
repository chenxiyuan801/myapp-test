require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV['ALIPAY_PID'] = '10469'
ENV['ALIPAY_MD5_SECRET'] = '34NrkS8OWTNGiQize4Ng9Ag5nqQoqKxJ'
ENV['ALIPAY_URL'] = 'https://codepay.fateqq.com:51888/creat_order/'
ENV['ALIPAY_RETURN_URL'] = 'https://polar-sierra-61329.herokuapp.com/payments/pay_return'
ENV['ALIPAY_NOTIFY_URL'] = 'https://polar-sierra-61329.herokuapp.com/payments/pay_notify'


module MasterRailsByActions
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W[#{Rails.root}/lib]

    config.generators do |generator|
      generator.assets false
      generator.test_framework false
      generator.skip_routes true
    end

  end
end
