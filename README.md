# Sashite::GAN ♟️

> An implementation of [General Actor Notation](https://developer.sashite.com/specs/general-actor-notation) for storing actors from abstract strategy games.

## Installation

Add this line to your application's Gemfile:

    gem 'sashite-gan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sashite-gan

## Usage

    require 'sashite-gan'

    # Chess (Western) Rook, White
    Sashite::GAN.string(is_checkmateable: false, is_promoted: false, is_topside: false, piece_abbr: 'r', style_abbr: 'c') # => 'C:R'

    # Chess (Western) King, Black
    Sashite::GAN.string(is_checkmateable: true, is_promoted: false, is_topside: true, piece_abbr: 'k', style_abbr: 'c') # => 'c:-k'

    # Shogi King, Gote
    Sashite::GAN.string(is_checkmateable: true, is_promoted: false, is_topside: true, piece_abbr: 'k', style_abbr: 's') # => 's:-k'

    # Shogi promoted Pawn, Sente
    Sashite::GAN.string(is_checkmateable: false, is_promoted: true, is_topside: false, piece_abbr: 'p', style_abbr: 's') # => 'S:+P'

    # Xiangqi General, Red
    Sashite::GAN.string(is_checkmateable: true, is_promoted: false, is_topside: false, piece_abbr: 'g', style_abbr: 'x') # => 'X:-G'

    # Xiangqi Flying General, Red
    Sashite::GAN.string(is_checkmateable: true, is_promoted: true, is_topside: false, piece_abbr: 'g', style_abbr: 'x') # => 'X:+-G'

    # Go Stone, Black
    Sashite::GAN.string(is_checkmateable: false, is_promoted: false, is_topside: false, piece_abbr: 's', style_abbr: 'go') # => 'GO:S'

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

The `sashite-gan` gem is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
