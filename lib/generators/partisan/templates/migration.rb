class AddFollowsMigration < ActiveRecord::Migration
  def up
    create_table :follows do |t|
      t.references :followable, polymorphic: true
      t.references :follower, polymorphic: true

      t.timestamps null: false
    end

    add_index :follows, ['follower_id', 'follower_type'], name: 'index_partisan_followers'
    add_index :follows, ['followable_id', 'followable_type'], name: 'index_partisan_followables'
    add_index :follows, ['follower_id', 'follower_type', 'followable_id', 'followable_type'], name: 'index_partisan_unique_follow', unique: true
  end

  def down
    drop_table :follows
  end
end
