require "partisan/version"

require "active_record"

require "partisan/follow"
require "partisan/follow_helper"
require "partisan/follower"
require "partisan/followable"

module Partisan
  include Partisan::FollowHelper

  def self.inject_into_active_record
    @inject_into_active_record ||= Proc.new do
      def self.acts_as_follower
        self.send :include, Partisan::Follower
      end

      def self.acts_as_followable
        self.send :include, Partisan::Followable
      end
    end
  end
end

ActiveRecord::Base.class_eval(&Partisan.inject_into_active_record)
