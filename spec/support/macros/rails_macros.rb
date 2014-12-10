module RailsMacros
  # NOTE: This method is not fun to maintain but we need it to make sure
  # Partisan methods return *real* not-loaded ActiveRecord relations
  def relation_class(klass)
    if ActiveRecord::VERSION::MAJOR == 3
      ActiveRecord::Relation
    elsif [ActiveRecord::VERSION::MAJOR, ActiveRecord::VERSION::MINOR] == [4, 0]
      "ActiveRecord::Relation::ActiveRecord_Relation_#{klass.name}".constantize
    else
      "#{klass.name}::ActiveRecord_Relation".constantize
    end
  end
end
