require 'spec_helper'

describe Partisan::Helper do
  describe :ClassMethods do
    describe :parent_class_name do
      let(:parent_class_name) { Partisan::Helper.send(:parent_class_name, object) }

      before do
        run_migration { create_table 'articles' }
      end

      context 'with regular record object' do
        let(:object) { spawn_model('Article', ActiveRecord::Base).new }

        it { expect(parent_class_name).to eql 'Article' }
      end

      context 'with STI-model record object' do
        let(:object) do
          spawn_model('Article', ActiveRecord::Base)
          spawn_model('BlogPost', Article).new
        end

        it { expect(parent_class_name).to eql 'Article' }
      end

      context 'with object that inherits from abstract class' do
        let(:object) do
          spawn_model('ApplicationRecord', ActiveRecord::Base) do
            self.abstract_class = true
          end

          spawn_model('Article', ApplicationRecord).new
        end

        it { expect(parent_class_name).to eql 'Article' }
      end

      context 'with a presented record object' do
        let(:presenter_class) do
          Class.new(::SimpleDelegator) do
            alias_method :object, :__getobj__
          end
        end

        let(:object) do
          spawn_model('Article', ActiveRecord::Base)
          presenter_class.new(Article.new)
        end

        it { expect(parent_class_name).to eql 'Article' }
      end
    end
  end
end
