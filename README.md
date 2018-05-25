# Counter::Cache

[![Gem Version](https://badge.fury.io/rb/counter-cache.png)](http://badge.fury.io/rb/ventable)
[![Build Status](https://travis-ci.org/wanelo/counter-cache.svg?branch=master&fl)](https://travis-ci.org/wanelo/counter-cache)
[![Code Climate](https://codeclimate.com/github/wanelo/counter-cache.png)](https://codeclimate.com/github/wanelo/counter-cache)

Counting things is hard, counting them at scale is even harder, so control when things are counted.

Any time your application performs pagination, the underlying library probably issues a `select count(*) from ...`
request to the database, because all paginators need to know how many pages there are. This works on a small-to-medium
dataset, and in an application with relatively low web traffic. But at high traffic volume, live counts saturate CPU on the
database server. This is because sorting typically happens on CPU of the database server, using a small amount of heap
RAM or even worse &mdash; using temp files, which grinds the disk IO to a hault.  Web requests become slower and
slower, start to pile up in various queues, and eventually saturate all of the app servers.
There you are, the site is down.

This gem provides a solution that works at scale, and will help you keep your site up.

This library is battle-tested at Wanelo, where it has been running for several years.

### Overview

[Rails Counter Caches](http://railscasts.com/episodes/23-counter-cache-column) are a convenient way to keep counters on
models that have many children. Without them, you always do live counts, which do not scale. But at high scale, Rails
counter caches create update contention on single models, especially for social sites where any single model might become
extremely popular. Many web requests trying to update the same row creates database deadlocks and kills performance due
to locking and an uncontrollable increase in iops.

This library provides all the benefits of rails counter cache, without the penalty of the contention on updates,
by serializing, buffering, and delaying updates via a queue. Counts becoming slightly less realtime, but with a guarantee that
single models will never be updated more than once in certain time periods.

![Counter Cache Flow](doc/counter-cache-flow.png)

By default, a Buffer Counter is used which implements two modes of counting. The two modes are deferred and recalculation.

IMPORTANT: If Sidekiq is to be used as the delayed job framework, using `sidekiq-unique-jobs` is essential: https://github.com/mhenrixon/sidekiq-unique-jobs

### Mode: Deferred

Initial mode that is used to provide roughly realtime counters.

This mode is meant to provide very reasonably up to date counters using values buffered into Redis, without asking the database
for the count at all. An example of how this works is described:

Scenario: User has many posts. We want to keep track of the number of posts on the user model (posts_count column).

When a post is created:

1. Increment a key in Redis that corresponds to the field and user that relates to the post.
2. Enqueue a delayed job that will later reconcile the counter column based on the key in redis.
3. When the job runs, it picks up the value from redis (which can be zero or more) and adds the value to user.posts_count
   column on the associated model.

```ruby
  user = User.find_by_id(100)
  user.posts_count # 10
  user.posts.create(...) # => Job is enqueued
  user.posts.create(...) # => Job is already enqueued

  # come back later (after a delay)
  user = User.find_by_id(100)
  user.posts_count # 12
```

### Mode: Recalculation

Runs later and ensures values are completely up to date.

This mode is used to compensate for transient errors that may cause the deferred counters to drift from the actual
values. The exact reasons this happens are undefined, redis could hang, go away, the universe could skip ahead in time,
who knows.

Using the same scenario as above:

Scenario: User has many posts. We want to keep track of the number of posts on the user model (posts_count column).

1. Enqueue a job that is delayed by many hours (customizable)
2. When the job runs, run a full count query to find the true count from the database and save the value to the database.

```ruby
  user = User.find_by_id(100)
  user.posts_count # 10
  user.posts.create(...)
  user.posts.create(...)

  # redis crashes, world explodes, etc.. we miss on deferred update.

  user = User.find_by_id(100)
  user.posts_count # 11, due to only one deferred update having run.

  # come back later in a couple hours
  user = User.find_by_id(100)
  user.posts_count # 12
```

## Installation

Add this line to your application's Gemfile:

    gem 'counter-cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install counter-cache

## Usage

Counter caches are configured on the models from the perspective of the child model to the parent that contains the counter.

#### Basic Counter with recalculation:

```ruby
class Post
  include Counter::Cache

  counter_cache_on column: :posts_count, # users.posts_count
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count # This is a method on the user.
end
```

#### To allow a timestamp to be updated:

```ruby
class Post
  include Counter::Cache

  counter_cache_on column: :posts_count, # users.posts_count
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count, # This is a method on the user.
                   touch_column: :posts_updated_at
end
```

#### To increment dynamically:

```ruby
class Review
  include Counter::Cache

  counter_cache_on column: :reviews_sum,
                   relation: :product,
                   relation_class_name: "Product",
                   increment_by: ->(review) { review.score },
                   method: :recalculate_reviews_sum, # This is a method on the product.
end
```

#### To control when recalculation happens:

```ruby
class Post
  include Counter::Cache

  counter_cache_on column: :posts_count, # users.posts_count
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count, # This is a method on the user.
                   recalculation: true|false, # whether to ever recalculate this counter.
                   recalculation_delay: 10.seconds # Only a hard value that defines when to perform a full recalculation.
end
```

#### To control when the deferred job runs:

```ruby
class Post
  include Counter::Cache

  counter_cache_on column: :posts_count, # users.posts_count
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count, # This is a method on the user.
                   wait: 10.seconds # This can be a hard value

  counter_cache_on column: :posts_count, # users.posts_count
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count, # This is a method on the user.
                   wait: ->(user) { user.posts_count * 10 } # .. or a proc, in this case, the more posts a user has, the less frequently it will be updated.
end
```

#### To control if an update should even happen:

```ruby
class Post
  include Counter::Cache

  counter_cache_on column: :posts_count, # users.posts_count
                   relation: :user,
                   relation_class_name: "User",
                   method: :calculate_posts_count, # This is a method on the user.
                   if: ->(post) { post.public? ? false : true }
end
```

#### Polymorphism (because YAY)

Setting `polymorphic: true`, will ask ActiveRecord what the class is (User, Store), based on followee_type, and update
the appropriate model. So if a user is followed, then that users followers_count will increment.

```ruby
class User
  attr_accessible :followers_count
end

class Store
  attr_accessible :followers_count
end

class Follow
  attr_accessible :user_id, :followee_id, :followee_type

  belongs_to :followee, polymorphic: true

  include Counter::Cache

  counter_cache_on column: :followers_count,
                   relation: :followee,
                   polymorphic: true
end
```

## Configuration

In an initializer such as `config/initializers/counter_cache.rb`, write the configuration as:

```ruby
Counter::Cache.configure do |c|
  c.default_worker_adapter = MyCustomWorkAdapter
  c.recalculation_delay    = 6.hours # Default delay for recalculations
  c.redis_url              = 'redis://localhost:6379/1' #Default redis url
  c.redis_pool             = Redis.new # Default redis pool
  c.counting_data_store    = MyCustomDataStore # Default is Counter::Cache::Redis
end
```

### default_worker_adapter

The worker adapter allows you to control how jobs are delayed/enqueued for later execution. Three options are passed:

 - delay: This is the delay in seconds that the execution should be delayed. Can be ignored or adjusted. We pass this to
   sidekiq.
 - base_class: This is the class name of the source object.
 - options: This will be a hash of options that should be passed to the instance of the counter.

An example of a dummy adapter is like so:

```ruby
class TestWorkerAdapter
  def enqueue(delay, base_class, options)
    options[:source_object_class_name] = base_class.constantize
    counter_class = options[:counter].constantize # options[:counter] is the class name of the counter that called the adapter.
    counter = counter_class.new(nil, options)
    counter.save!
  end
end
```

An example of a dummy adapter that uses Sidekiq is like so:

```ruby
class CounterWorker
  include Sidekiq::Worker

  def perform(base_class, options)
    options.symbolize_keys! # From ActiveSupport, Sidekiq looses symbol information from hashes.
    options[:source_object_class_name] = base_class.constantize
    counter_class = options[:counter].constantize # options[:counter] is the class name of the counter that called the adapter.
    counter = counter_class.new(nil, options)
    counter.save!
  end

  def self.enqueue(delay, base_class, options)
    perform_in(delay, base_class, options)
  end
end
```

### recalculation_delay

This should be set to the default delay for recalculations, in seconds.

### redis_pool

This can either be a single redis connection or a ConnectionPool instance (https://github.com/mperham/connection_pool).

### counting_data_store

This defaults to Counter::Cache::Redis but can be set to anything. The Redis store describes what the API would be.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/counter-cache/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Running specs:

Appraisal is used to test against multiple versions of activerecord. 3.2, 4.0, and 4.1 are currently supported.

To install dependencies:

    $ bundle exec appraisal install

To run specs across versions:

    $ bundle exec appraisal rspec
