# Sashite::GAN

Implementation of [General Actor Notation](//sashite-wiki.herokuapp.com/General_Actor_Notation) for storing actors from abstract strategy games.

## Status

[![Gem Version](https://badge.fury.io/rb/sashite-gan.svg)](//badge.fury.io/rb/sashite-gan)
[![Build Status](https://secure.travis-ci.org/sashite/gan.rb.svg?branch=master)](//travis-ci.org/sashite/gan.rb?branch=master)

## Installation

Add this line to your application's Gemfile:

    gem 'sashite-gan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sashite-gan

## Usage

    require 'sashite-gan'

    actor = Sashite::GAN::Actor.new 2,
      'bc096c4c7f48fc5c4c162555e4df98169e204aea', 'top', 'xianqi', 'rook'
    actor.to_gan # => '2:bc096c4c7f48fc5c4c162555e4df98169e204aea:top:xianqi:rook'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
