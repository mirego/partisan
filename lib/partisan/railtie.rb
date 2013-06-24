require 'partisan'
require 'rails'

module Partisan
  class Railtie < Rails::Railtie
    initializer "follows.active_record" do |app|
      ActiveSupport.on_load :active_record do
        def self.acts_as_follower
          self.send :include, Partisan::Follower
        end

        def self.acts_as_followable
          self.send :include, Partisan::Followable
        end
      end
    end
  end
end
