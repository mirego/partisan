require "partisan/version"

require "active_record"

require "partisan/follow"
require "partisan/follow_helper"
require "partisan/follower"
require "partisan/followable"

module Partisan

  include Partisan::FollowHelper
end

require 'partisan/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
