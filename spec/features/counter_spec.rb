require 'spec_helper'
require 'support/models'
require 'support/worker_adapter'
require 'fakeredis'

RSpec.describe "Counting" do

  before do
    ActiveRecord::Base.silence { CreateModelsForTest.migrate(:up) }
    Counter::Cache.configure do |c|
      c.redis_pool = Redis.new
      c.default_worker_adapter = TestWorkerAdapter.new
    end
  end

  after do
    ActiveRecord::Base.silence { CreateModelsForTest.migrate(:down) }
  end

  let(:user) { User.create }

  describe '#posts_count' do
    it 'increments' do
      expect {
        user.posts.create
      }.to change { user.reload.posts_count }.by(1)
    end

    it 'decrements' do
      post = user.posts.create
      expect {
        post.destroy
      }.to change { user.reload.posts_count }.by(-1)
    end
  end

  describe '#posts_ar_count' do
    it 'increments' do
      expect {
        user.posts.create
      }.to change { user.reload.posts_ar_count }.by(1)
    end

    it 'decrements' do
      post = user.posts.create
      expect {
        post.destroy
      }.to change { user.reload.posts_ar_count }.by(-1)
    end
  end

  describe '#polymorphic followers_count' do
    let(:follower_user) { User.create }
    it 'increments' do
      expect {
        Follow.create(user: follower_user, followee: user)
      }.to change { user.reload.followers_count }.by(1)
    end

    it 'decrements' do
      follow = Follow.create(user: follower_user, followee: user)
      expect {
        follow.destroy
      }.to change { user.reload.followers_count }.by(-1)
    end
  end

  describe '#users_i_follow_count' do
    let(:follower_user) { User.create }

    it 'increments' do
      expect {
        Follow.create(user: follower_user, followee: user)
      }.to change { follower_user.reload.users_i_follow_count }.by(1)
    end

    it 'decrements' do
      follow = Follow.create(user: follower_user, followee: user)
      expect {
        follow.destroy
      }.to change { follower_user.reload.users_i_follow_count }.by(-1)
    end
  end

  describe '#bogus_followed_count' do
    let(:follower_user) { User.create }

    it 'eventually recalculates' do
      expect(user.reload.bogus_followed_count).to_not eq(101)
      Follow.create(user: follower_user, followee: user)
      expect(user.reload.bogus_followed_count).to eq(101)
    end
  end
end

