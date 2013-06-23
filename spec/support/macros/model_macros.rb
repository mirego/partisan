module ModelMacros
  # Create a new emotional model
  def followable(klass_name, &block)
    spawn_model klass_name, ActiveRecord::Base do
      acts_as_followable
      instance_exec(&block) if block
    end
  end

  # Create a new emotive model
  def follower(klass_name, &block)
    spawn_model klass_name, ActiveRecord::Base do
      acts_as_follower
      class_eval(&block) if block
    end
  end

  protected

  # Create a new model class
  def spawn_model(klass_name, parent_klass, &block)
    Object.instance_eval { remove_const klass_name } if Object.const_defined?(klass_name)
    Object.const_set(klass_name, Class.new(parent_klass))
    Object.const_get(klass_name).class_eval(&block) if block_given?
  end
end
