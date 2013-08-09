module RailsMacros
  def relation_class(klass)
    if ActiveRecord::VERSION::MAJOR == 3
      ActiveRecord::Relation
    else
      "ActiveRecord::Relation::ActiveRecord_Relation_#{klass.name}".constantize
    end
  end
end
