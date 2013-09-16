module Partisan
  module Follower
    extend ActiveSupport::Concern
    extend ActiveModel::Callbacks
    include Partisan::FollowHelper

    included do
      has_many :follows, as: :follower, class_name: 'Follow', dependent: :destroy
      define_model_callbacks :follow
      define_model_callbacks :unfollow
      attr_accessor :about_to_follow, :just_followed, :about_to_unfollow, :just_unfollowed
    end

    # Add follow record if it doesn’t exist
    #
    # @example
    #
    #   @user.follow(@team)
    #
    # @return (Follow)
    def follow(resource)
      return if self == resource

      follow = fetch_follows(resource).first_or_initialize
      follow.save!
    end
    alias_method :start_following, :follow

    # Delete follow record if it exists
    #
    # @example
    #
    #   @user.unfollow(@team)
    #
    # @return (Follow) || nil
    def unfollow(resource)
      return if self == resource

      record = fetch_follows(resource).first
      record.try(:destroy)
    end
    alias_method :stop_following, :unfollow

    # Return true or false if the resource is following another
    #
    # @example
    #
    #   @user.following?(@team)
    #
    # @return (Boolean)
    def follows?(resource)
      return false if self == resource

      !!fetch_follows(resource).exists?
    end
    alias_method :following?, :follows?

    # Get all follows record related to a resource
    #
    # @example
    #
    #   @user.fetch_follows(@team)
    #
    # @return [Follow, ...]
    def fetch_follows(resource)
      follows.where followable_id: resource.id, followable_type: parent_class_name(resource)
    end

    # Get resource records for a specific type, used by #method_missing
    # It conveniently returns an ActiveRecord::Relation for easy chaining of useful ActiveRecord methods
    #
    # @example
    #
    #   @user.following_by_type('Team')
    #
    # @return (ActiveRecord::Relation)
    def following_by_type(followable_type)
      opts = {
        'follows.follower_id' => self.id,
        'follows.follower_type' => parent_class_name(self)
      }

      followable_type.constantize.joins(:followings).where(opts)
    end

    # Get ids of resources following self
    # Use #pluck for an optimized sql query
    #
    # @example
    #
    #   @user.following_ids_by_type('Team')
    #
    # @return (Array)
    def following_fields_by_type(followable_type, followable_field)
      following_by_type(followable_type).pluck("#{followable_type.tableize}.#{followable_field}")
    end

    # Update cache counter
    # Called in after_create and after_destroy
    def update_follower_counter
      self.update_attribute('followings_count', self.follows.count) if self.respond_to?(:followings_count)
    end

    def method_missing(m, *args)
      if m.to_s[/following_(.+)_(.+)s$/]
        following_fields_by_type($1.singularize.classify, $2)
      elsif m.to_s[/following_(.+)/]
        following_by_type($1.singularize.classify)
      else
        super
      end
    end

    def respond_to?(m, include_private = false)
      super || m.to_s[/following_(.+)_(.+)s$/] || m.to_s[/following_(.+)/]
    end

  end
end
