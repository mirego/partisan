require 'partisan'
require 'rails'

module Partisan
  class Railtie < Rails::Railtie
    initializer "follows.active_record" do |app|
      ActiveSupport.on_load :active_record, {}, &Partisan.inject_into_active_record
    end
  end
end
