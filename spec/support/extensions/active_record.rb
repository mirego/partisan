class ActiveRecord::Base
  def self.acts_as_follower
    self.send :include, Partisan::Follower
  end

  def self.acts_as_followable
    self.send :include, Partisan::Followable
  end
end
