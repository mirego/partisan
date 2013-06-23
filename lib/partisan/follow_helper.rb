module Partisan
  module FollowHelper

  private

    # Retrieves the parent class name if using STI.
    def parent_class_name(obj)
      klass = obj.class
      klass = klass.superclass while klass.superclass != ActiveRecord::Base

      klass.name
    end

  end
end
