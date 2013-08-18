<p align="center">
  <a href="https://github.com/mirego/partisan">
    <img src="http://i.imgur.com/an3Wj4Q.png" alt="Partisan" />
  </a>
  <br />
  Partisan is a Ruby library that allows ActiveRecord records to follow other records.
  <br /><br />
  <a href="https://rubygems.org/gems/partisan"><img src="https://badge.fury.io/rb/partisan.png" /></a>
  <a href="https://codeclimate.com/github/mirego/partisan"><img src="https://codeclimate.com/github/mirego/partisan.png" /></a>
  <a href="https://travis-ci.org/mirego/partisan"><img src="https://travis-ci.org/mirego/partisan.png?branch=master" /></a>
</p>

---

It’s heavily inspired by `acts_as_follower`. However, it’s not 100% compatible with `acts_as_follower` as I removed some “features”:

* Block a follower
* Methods that returned mixed types of followers/following
* `*_count` methods (see the new features list)

But I also added awesome new ones:

* You can use `following_team_ids` but also `following_team_names` (basically any `following_team_<column>s`). It takes advantage of the `pluck` method, so it doesn’t create an instance of each follower, it just return the relevant column values. (Go check `pluck` documentation, it’s simply awesome).
* The `followers` and `followings` methods now return an `ActiveRecord::Relation` for easy chaining, scoping, counting, pagination, etc.

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'partisan'
```

And then execute

```bash
$ bundle
```

Run the migration to add the `follows` table:

```bash
$ rails generate partisan:install
```

## Usage

Create a couple of models.

```ruby
class Fan < ActiveRecord::Base
  acts_as_follower
end

class Band < ActiveRecord::Base
  acts_as_followable
end
```

And follow/unfollow other records!

```ruby
fan = Fan.find(1)
band = Band.find(2)

fan.follow(band)
fan.following_bands
# => [<Band id=2>]

fan.follows?(band)
# => true

fan.unfollow(band)
fan.follows?(band)
# => false
```

### Cache counters

Most of the times, you would want to get a quick look at about how many fans follow a certain resource. That could be an expensive operation.

However, if the *followed* record has a `followers_count` column, Partisan will populate its value with how many followers the record has.

```ruby
fan.follow(band)

band.followers.count
# SQL query that counts records and returns `1`

band.followers_count
# Quick lookup into the column and returns `1`
```

The same concept applies to `followable` with a `followings_count` column.

### Callbacks

You can define callbacks that will be triggered before or after a following relationship is created.

If a `before_follow` callback returns `false`, it will halt the call and the relationship will be not be saved (much like `ActiveRecords`’s `before_save` callbacks).

```ruby
class Fan < ActiveRecord::Base
  acts_as_follower
  after_follow :send_notification

  def send_notification
    puts "#{self} is now following #{self.just_followed}"
  end
end

class Band < ActiveRecord::Base
  acts_as_followable
  before_follow :ensure_active_fan

  def ensure_active_fan
    self.about_to_be_followed_by.active?
  end
end
```

The available callbacks are:

#### Follower

| Callback          | Reference to the followable |
| ------------------|-----------------------------|
| `before_follow`   | `self.about_to_follow`      |
| `after_follow`    | `self.just_followed`        |
| `before_unfollow` | `self.about_to_unfollow`    |
| `after_unfollow`  | `self.just_unfollowed`      |

#### Followable

| Callback                  | Reference to the follower        |
| --------------------------|----------------------------------|
| `before_being_followed`   | `self.about_to_be_followed_by`   |
| `after_being_followed`    | `self.just_followed_by`          |
| `before_being_unfollowed` | `self.about_to_by_unfollowed_by` |
| `after_being_unfollowed`  | `self.just_unfollowed_by`        |

## License

`Partisan` is © 2013 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/partisan/blob/master/LICENSE.md) file.

## About Mirego

Mirego is a team of passionate people who believe that work is a place where you can innovate and have fun. We proudly build mobile applications for [iPhone](http://mirego.com/en/iphone-app-development/ "iPhone application development"), [iPad](http://mirego.com/en/ipad-app-development/ "iPad application development"), [Android](http://mirego.com/en/android-app-development/ "Android application development"), [Blackberry](http://mirego.com/en/blackberry-app-development/ "Blackberry application development"), [Windows Phone](http://mirego.com/en/windows-phone-app-development/ "Windows Phone application development") and [Windows 8](http://mirego.com/en/windows-8-app-development/ "Windows 8 application development") in beautiful Quebec City.

We also love [open-source software](http://open.mirego.com/) and we try to extract as much code as possible from our projects to give back to the community.
