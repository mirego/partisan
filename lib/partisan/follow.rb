module Partisan
  class Follow < ActiveRecord::Base
    self.table_name = 'follows'

    # Validations
    validates :followable, presence: true
    validates :follower, presence: true

    # Associations
    belongs_to :followable, polymorphic: true
    belongs_to :follower, polymorphic: true

    # Callbacks
    after_create :update_follow_counter
    after_destroy :update_follow_counter

    # Follower's :follow callbacks
    around_create do |follow, blk|
      self.follower.about_to_follow = self.follower.just_followed = self.followable
      self.follower.run_callbacks :follow, &blk
      self.follower.about_to_follow = self.follower.just_followed = nil
    end

    # Followable's :follow callbacks
    around_create do |follow, blk|
      self.followable.about_to_be_followed_by = self.followable.just_followed_by = self.follower
      self.followable.run_callbacks :being_followed, &blk
      self.followable.about_to_be_followed_by = self.followable.just_followed_by = nil
    end

    # Follower's :unfollow callbacks
    around_destroy do |follow, blk|
      self.follower.about_to_unfollow = self.follower.just_unfollowed = self.followable
      self.follower.run_callbacks :unfollow, &blk
      self.follower.about_to_unfollow = self.follower.just_unfollowed = nil
    end

    # Followable's :unfollow callbacks
    around_destroy do |follow, blk|
      self.followable.about_to_be_unfollowed_by = self.followable.just_unfollowed_by = self.follower
      self.followable.run_callbacks :being_unfollowed, &blk
      self.followable.about_to_be_unfollowed_by = self.followable.just_unfollowed_by = nil
    end

  protected

    def update_follow_counter
      self.follower.update_follow_counter
      self.followable.update_follow_counter
    end
  end
end
