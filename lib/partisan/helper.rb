module Partisan
  class Helper
    # Retrieves the parent class name
    def self.parent_class_name(obj)
      # If the object is an ActiveRecord record
      klass = obj.class if obj.class < ActiveRecord::Base

      # If the object respond to `object` and the value is an ActiveRecord record
      klass ||= obj.object.class if obj.respond_to?(:object) && obj.object.class < ActiveRecord::Base

      # In case we’re using STI, loop back until we find the top-level ActiveRecord model
      klass = klass.superclass while klass.superclass != ActiveRecord::Base

      klass.name
    end
  end
end
