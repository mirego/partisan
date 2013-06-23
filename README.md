# Partisan

Partisan is a Ruby library that allows ActiveRecord records to be follower and followable

It’s heavily inspired by `acts_as_follower`.

It’s not 100% compatible with `acts_as_follower`, I removed some "features":

* block follower
* Array with all types of followers/following
* `*_count` methods

But I also added awesome new ones:

* model_follower_fields: So you can do `following_team_ids` but also `following_team_names`. It takes advantage of the `pluck` method, so it doesn’t create an instance of each follower. (go check `pluck` documentation, it’s simply awesome).

* followers/followings now returns ActiveRecord::Relation for easy chaining/scoping/paginating...

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'partisan'
```

And then execute:

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

fan.following?(band)
# => true

fan.unfollow(band)
fan.following?(band)
# => false

```

Most of the times, you would want to get a quick look at about how many bands followed a certain resource. That could be an expensive operation.

However, if the *followed* record has an `followers_count` column, Partisan will populate its value with how many bands followed that record.

```ruby
band.follow(band)

band.followers.count
# SQL query that counts records and returns `1`

band.followers_count
# Quick lookup into the column and returns `1`
```

The same concept applies to `followable` with a `following_count` column

## License

`Partisan` is © 2013 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/partisan/blob/master/LICENSE.md) file.

## About Mirego

Mirego is a team of passionate people who believe that work is a place where you can innovate and have fun.
We proudly built mobile applications for
[iPhone](http://mirego.com/en/iphone-app-development/ "iPhone application development"),
[iPad](http://mirego.com/en/ipad-app-development/ "iPad application development"),
[Android](http://mirego.com/en/android-app-development/ "Android application development"),
[Blackberry](http://mirego.com/en/blackberry-app-development/ "Blackberry application development"),
[Windows Phone](http://mirego.com/en/windows-phone-app-development/ "Windows Phone application development") and
[Windows 8](http://mirego.com/en/windows-8-app-development/ "Windows 8 application development").
