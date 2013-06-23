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

  protected

    def update_follow_counter
      self.follower.update_follow_counter
      self.followable.update_follow_counter
    end
  end
end
