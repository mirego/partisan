module Partisan
  module Followable
    extend ActiveSupport::Concern
    extend ActiveModel::Callbacks

    include Partisan::FollowHelper

    included do
      has_many :followings, as: :followable, class_name: 'Partisan::Follow', dependent: :destroy
      define_model_callbacks :being_followed
      define_model_callbacks :being_unfollowed
      attr_accessor :about_to_be_followed_by, :just_followed_by, :about_to_be_unfollowed_by, :just_unfollowed_by
    end

    # Return true or false if the resource is following another
    #
    # @example
    #
    #   @team.followed_by?(@user)
    #
    # @return (Boolean)
    def followed_by?(resource)
      resource.following?(self)
    end

    # Get resource records for a specific type, used by #method_missing
    # It conveniently returns an ActiveRecord::Relation for easy chaining of useful ActiveRecord methods
    #
    # @example
    #
    #   @team.followers_by_type('User')
    #
    # @return (ActiveRecord::Relation)
    def followers_by_type(follower_type)
      opts = {
        'follows.followable_id' => self.id,
        'follows.followable_type' => parent_class_name(self)
      }

      follower_type.constantize.joins(:follows).where(opts)
    end

    # Get ids of resources following self
    # Use #pluck for an optimized sql query
    #
    # @example
    #
    #   @team.following_ids_by_type('User')
    #
    # @return (Array)
    def follower_fields_by_type(follower_type, follower_field)
      followers_by_type(follower_type).pluck("#{follower_type.tableize}.#{follower_field}")
    end

    # Update cache counter
    # Called in after_create and after_destroy
    def update_follow_counter
      self.update_attribute('followers_count', self.followings.count) if self.respond_to?(:followers_count)
    end

    def method_missing(m, *args)
      if m.to_s[/(.+)_follower_(.+)s$/]
        follower_fields_by_type($1.singularize.classify, $2)
      elsif m.to_s[/(.+)_followers$/]
        followers_by_type($1.singularize.classify)
      else
        super
      end
    end

    def respond_to?(m, include_private = false)
      super || m.to_s[/(.+)_follower_(.+)s$/] || m.to_s[/(.+)_follower/]
    end
  end
end
