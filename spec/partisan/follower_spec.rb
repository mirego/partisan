require 'spec_helper'

describe Partisan::Follower do
  before do
    run_migration do
      create_table(:users, force: true) do |t|
        t.integer :followings_count, default: 0
        t.integer :followers_count, default: 0
      end
      create_table(:concerts, force: true)
      create_table(:bands, force: true)
    end

    followable_and_follower 'User'
    followable 'Band'
    followable 'Concert'
  end

  let(:band) { Band.create }
  let(:user) { User.create }
  let(:user2) { User.create }
  let(:concert) { Concert.create }

  describe :UserToUser do
    before do
      user.follow user2

      user.reload
      user2.reload
    end

    it { expect(user.followings_count).to eq 1 }
    it { expect(user2.followers_count).to eq 1 }
  end

  describe :InstanceMethods do
    before do
      user.follow band

      user.reload
    end

    describe :follow do
      it { expect(Follow.last.follower_id).to eq user.id }
      it { expect(Follow.last.followable_id).to eq band.id }
    end

    describe :unfollow do
      it { expect{user.unfollow band}.to change{Follow.last}.to(nil) }
    end

    describe :follows? do
      let(:band2) { Band.create }

      it { expect(user.follows? band).to be_truthy }
      it { expect(user.follows? band2).to be_falsey }
    end

    describe :following_by_type do
      it { expect(user.following_by_type('Band').count).to eq 1 }
      it { expect(user.following_by_type('Band')).to be_an_instance_of(relation_class(Band)) }
      it { expect(user.following_by_type('Band').first).to be_an_instance_of(Band) }
      it { expect(user.following_by_type('Concert').count).to eq 0 }
    end

    describe :following_fields_by_type do
      it { expect(user.following_fields_by_type('Band', 'id').count).to eq 1 }
      it { expect(user.following_fields_by_type('Band', 'id').first).to eq band.id }
      it { expect(user.following_fields_by_type('Concert', 'id').count).to eq 0 }
    end

    describe :following_by_type_in_method_missing do
      it { expect(user.following_bands.count).to eq 1 }
      it { expect(user.following_bands).to be_an_instance_of(relation_class(Band)) }
      it { expect(user.following_bands.first).to be_an_instance_of(Band) }

      it { expect(user.following_concerts.count).to eq 0 }
      it { expect(user.following_concerts).to be_an_instance_of(relation_class(Concert)) }
    end

    describe :following_fields_by_type_in_method_missing do
      it { expect(user.following_band_ids.count).to eq 1 }
      it { expect(user.following_band_ids.first).to eq band.id }
      it { expect(user.following_concert_ids.count).to eq 0 }
    end

    describe :update_follow_counter do
      it { expect(user.followings_count).to eq 1 }
    end

    describe :respond_to? do
      it { expect(user.respond_to?(:following_bands)).to be_truthy }
      it { expect(user.respond_to?(:following_band_ids)).to be_truthy }
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

    describe :before_follow do
      before do
        follower 'User' do
          before_follow { Buffer.tmp_value = self.about_to_follow }
        end
      end

      it { expect{ user.follow(band) }.to change{ Buffer.tmp_value }.to(band) }
    end

    describe :after_follow do
      before do
        follower 'User' do
          after_follow { Buffer.tmp_value = self.just_followed }
        end
      end

      it { expect{ user.follow(band) }.to change{ Buffer.tmp_value }.to(band) }
    end

    describe :before_unfollow do
      before do
        follower 'User' do
          before_unfollow { Buffer.tmp_value = self.about_to_unfollow }
        end

        user.follow(band)
      end

      it { expect{ user.unfollow(band) }.to change{ Buffer.tmp_value }.to(band) }
    end

    describe :after_unfollow do
      before do
        follower 'User' do
          after_unfollow { Buffer.tmp_value = self.about_to_unfollow }
        end

        user.follow(band)
      end

      it { expect{ user.unfollow(band) }.to change{ Buffer.tmp_value }.to(band) }
    end
  end

  describe :AliasMethods do
    subject { User.new }

    it { should respond_to :start_following }
    it { should respond_to :stop_following }
    it { should respond_to :following? }
  end
end
