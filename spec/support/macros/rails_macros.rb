module RailsMacros
  def relation_class(klass)
    if ActiveRecord::VERSION::MAJOR == 3
      ActiveRecord::Relation
    else
      Object.const_get("ActiveRecord::Relation::ActiveRecord_Relation_#{klass}")
    end
  end
end
