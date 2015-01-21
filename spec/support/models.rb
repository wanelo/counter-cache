require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

class CreateModelsForTest < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.integer :posts_count, :default => 0
      t.integer :posts_ar_count, :default => 0
      t.integer :followers_count, :default => 0
      t.integer :users_i_follow_count, :default => 0
      t.integer :bogus_followed_count, :default => 0
      t.integer :reviews_sum, :default => 0
    end

    create_table :follows do |t|
      t.integer :user_id
      t.integer :followee_id
      t.string :followee_type
    end

    create_table :posts do |t|
      t.string :body
      t.belongs_to :user
    end

    create_table :reviews do |t|
      t.integer :score
      t.belongs_to :user
    end
  end

  def self.down
    drop_table(:users)
    drop_table(:posts)
    drop_table(:follows)
    drop_table(:reviews)
  end
end

class User < ActiveRecord::Base
  has_many :posts
  has_many :reviews

  def calculate_posts_count
    posts.count
  end

  def calculate_bogus_follow_count
    101
  end

end

class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :followee, polymorphic: true

  include Counter::Cache

  counter_cache_on column: :followers_count,
                   relation: :followee,
                   polymorphic: true,
                   recalculation: false

  counter_cache_on column: :bogus_followed_count,
                   relation: :followee,
                   polymorphic: true,
                   method: :calculate_bogus_follow_count,
                   recalculation: true

  counter_cache_on column: :users_i_follow_count,
                   relation: :user,
                   if: ->(follow) { follow.followee_type == "User" },
                   recalculation: false
end

class Post < ActiveRecord::Base
  belongs_to :user

  include Counter::Cache

  counter_cache_on column: :posts_count,
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count,
                   recalculation: false

  counter_cache_on column: :posts_ar_count,
                   relation: :user,
                   relation_class_name: "User",
                   recalculation: false
end

class Review < ActiveRecord::Base
  belongs_to :user

  include Counter::Cache

  counter_cache_on column: :reviews_sum,
    relation: :user,
    increment_by: ->(review) { review.score },
    recalculation: false

end
