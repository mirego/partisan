module Partisan
  module Follow
    extend ActiveSupport::Concern

    # Constants
    FOLLOWER_FOLLOW_ACCESSORS = [:about_to_follow, :just_followed]
    FOLLOWER_UNFOLLOW_ACCESSORS = [:about_to_unfollow, :just_unfollowed]
    FOLLOWABLE_BEING_FOLLOWED_ACCESSORS = [:about_to_be_followed_by, :just_followed_by]
    FOLLOWABLE_BEING_UNFOLLOWED_ACCESSORS = [:about_to_be_unfollowed_by, :just_unfollowed_by]

    included do
      # Validations
      validates :followable, presence: true
      validates :follower, presence: true

      # Associations
      belongs_to :followable, polymorphic: true
      belongs_to :follower, polymorphic: true

      # Callbacks
      after_create :update_follow_counter
      after_destroy :update_follow_counter

      around_create :around_create_follower
      around_create :around_create_followable
      around_destroy :around_destroy_follower
      around_destroy :around_destroy_followable
    end

  protected

    def update_follow_counter
      follower.update_followings_counter
      followable.update_followers_counter
    end

    def around_create_follower(&blk)
      execute_callback :follower, :follow, &blk
    end

    def around_create_followable(&blk)
      execute_callback :followable, :being_followed, &blk
    end

    def around_destroy_follower(&blk)
      execute_callback :follower, :unfollow, &blk
    end

    def around_destroy_followable(&blk)
      execute_callback :followable, :being_unfollowed, &blk
    end

  private

    def execute_callback(association, callback, &blk)
      # Fetch our associated objects
      object = send(association)
      reverse_object = association == :follower ? send(:followable) : send(:follower)

      # Associate each given accessor to the reverse object
      accessors = self.class.accessors_for_follow_callback(association, callback)
      accessors.map { |accessor| object.send "#{accessor}=", reverse_object }

      # Run the callbacks
      object.run_callbacks(callback, &blk)

      # Reset each accessor value
      accessors.map { |accessor| object.send "#{accessor}=", nil }

      true
    end

    module ClassMethods
      def accessors_for_follow_callback(association, callback)
        const_get "#{association}_#{callback}_accessors".upcase
      end
    end
  end
end
