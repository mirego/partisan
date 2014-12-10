require "partisan/version"

require "active_record"

require "partisan/helper"
require "partisan/follow"
require "partisan/follower"
require "partisan/followable"

module Partisan
  def self.inject_into_active_record
    @inject_into_active_record ||= Proc.new do
      def self.acts_as_follower
        self.send :include, Partisan::Follower
      end

      def self.acts_as_followable
        self.send :include, Partisan::Followable
      end

      def self.acts_as_follow
        self.send :include, Partisan::Follow
      end
    end
  end
end

ActiveRecord::Base.class_eval(&Partisan.inject_into_active_record)
