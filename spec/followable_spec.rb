require 'spec_helper'

describe Partisan::Followable do
  before do
    run_migration do
      create_table(:fans, force: true)
      create_table(:users, force: true)
      create_table(:concerts, force: true)

      create_table(:bands, force: true) do |t|
        t.integer :followers_count, default: 0
      end
    end

    follower 'Fan'
    follower 'User'
    followable 'Band'
    followable 'Concert'
  end

  let(:band) { Band.create }
  let(:user) { User.create }
  let(:concert) { Concert.create }
  let(:fan) { Fan.create }

  describe :InstanceMethods do
    before do
      user.follow band

      band.reload
    end

    describe :followed_by? do
      it { expect(band.followed_by? user).to be_true }
      it { expect(concert.followed_by? user).to be_false }
    end

    describe :followers_by_type do
      it { expect(band.followers_by_type('User').count).to eq 1 }
      it { expect(band.followers_by_type('User')).to be_an_instance_of(ActiveRecord::Relation) }
      it { expect(band.followers_by_type('User').first).to be_an_instance_of(User) }
      it { expect(band.followers_by_type('Fan').count).to eq 0 }
    end

    describe :following_fields_by_type do
      it { expect(band.follower_fields_by_type('User', 'id').count).to eq 1 }
      it { expect(band.follower_fields_by_type('User', 'id').first).to eq user.id }
      it { expect(band.follower_fields_by_type('Fan', 'id').count).to eq 0 }
    end

    describe :followers_by_type_in_method_missing do
      it { expect(band.user_followers.count).to eq 1 }
      it { expect(band.user_followers).to be_an_instance_of(ActiveRecord::Relation) }
      it { expect(band.user_followers.first).to be_an_instance_of(User) }
      it { expect(band.fan_followers.count).to eq 0 }
    end

    describe :following_fields_by_type_in_method_missing do
      it { expect(band.users_follower_ids.count).to eq 1 }
      it { expect(band.users_follower_ids.first).to eq user.id }
      it { expect(band.fans_follower_ids.count).to eq 0 }
    end

    describe :respond_to? do
      it { expect(band.respond_to?(:user_followers)).to be_true }
      it { expect(band.respond_to?(:users_follower_ids)).to be_true }
    end

    describe :update_follow_counter do
      it { expect(band.followers_count).to eq 1 }
    end
  end

  describe :Callbacks do
    before do
      class Buffer
        def self.tmp_value=(tmp_value)
          @tmp_value = tmp_value
        end

        def self.tmp_value
          @tmp_value
        end
      end
    end

    describe :before_followed do
      before do
        followable 'Band' do
          before_followed { Buffer.tmp_value = self.about_to_be_followed_by }
        end
      end

      it { expect{ user.follow(band) }.to change{ Buffer.tmp_value }.to(user) }
    end

    describe :after_followed do
      before do
        followable 'Band' do
          after_followed { Buffer.tmp_value = self.just_followed_by }
        end
      end

      it { expect{ user.follow(band) }.to change{ Buffer.tmp_value }.to(user) }
    end

    describe :before_unfollowed do
      before do
        followable 'Band' do
          before_unfollowed { Buffer.tmp_value = self.about_to_be_unfollowed_by }
        end

        user.follow(band)
      end

      it { expect{ user.unfollow(band) }.to change{ Buffer.tmp_value }.to(user) }
    end

    describe :after_unfollowed do
      before do
        followable 'Band' do
          after_unfollowed { Buffer.tmp_value = self.just_unfollowed_by }
        end

        user.follow(band)
      end

      it { expect{ user.unfollow(band) }.to change{ Buffer.tmp_value }.to(user) }
    end
  end
end
