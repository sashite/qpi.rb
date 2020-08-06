# GAN.rb

[![Build Status](https://travis-ci.org/sashite/gan.rb.svg?branch=master)](https://travis-ci.org/sashite/gan.rb)

> A Ruby interface for data serialization in [General Actor Notation](https://developer.sashite.com/specs/general-actor-notation) format ♟️

## Installation

1. Add the dependency to your `Gemfile`:

   ```ruby
   gem 'sashite-gan'
   ```

2. Run `bundle install`

## Usage

```ruby
require 'sashite-gan'


# Chess (Western chess)'s Rook, White
piece = Sashite::GAN.parse("C:R")

piece.abbr.to_s # => "R"
piece.style # => "C"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "C:R"
piece.topside.to_s # => "c:r"
piece.bottomside.to_s # => "C:R"
piece.oppositeside.to_s # => "c:r"
piece.promote.to_s # => "C:+R"
piece.unpromote.to_s # => "C:R"


# Chess (Western chess)'s King, Black
piece = Sashite::GAN.parse("c:-k")

piece.abbr.to_s # => "-k"
piece.style # => "c"
piece.topside? # => true
piece.bottomside? # => false
piece.to_s # => "c:-k"
piece.topside.to_s # => "c:-k"
piece.bottomside.to_s # => "C:-K"
piece.oppositeside.to_s # => "C:-K"
piece.promote.to_s # => "c:+-k"
piece.unpromote.to_s # => "c:-k"


# Makruk (Thai chess)'s Bishop, White
piece = Sashite::GAN.parse("M:B")

piece.abbr.to_s # => "B"
piece.style # => "M"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "M:B"
piece.topside.to_s # => "m:b"
piece.bottomside.to_s # => "M:B"
piece.oppositeside.to_s # => "m:b"
piece.promote.to_s # => "M:+B"
piece.unpromote.to_s # => "M:B"


# Shogi (Japanese chess)'s King, Gote
piece = Sashite::GAN.parse("s:-k")

piece.abbr.to_s # => "-k"
piece.style # => "s"
piece.topside? # => true
piece.bottomside? # => false
piece.to_s # => "s:-k"
piece.topside.to_s # => "s:-k"
piece.bottomside.to_s # => "S:-K"
piece.oppositeside.to_s # => "S:-K"
piece.promote.to_s # => "s:+-k"
piece.unpromote.to_s # => "s:-k"


# Shogi (Japanese chess)'s King, Sente
piece = Sashite::GAN.parse("S:-K")

piece.abbr.to_s # => "-K"
piece.style # => "S"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "S:-K"
piece.topside.to_s # => "s:-k"
piece.bottomside.to_s # => "S:-K"
piece.oppositeside.to_s # => "s:-k"
piece.promote.to_s # => "S:+-K"
piece.unpromote.to_s # => "S:-K"


# Shogi (Japanese chess)'s promoted Pawn, Sente
piece = Sashite::GAN.parse("S:+P")

piece.abbr.to_s # => "+P"
piece.style # => "S"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "S:+P"
piece.topside.to_s # => "s:+p"
piece.bottomside.to_s # => "S:+P"
piece.oppositeside.to_s # => "s:+p"
piece.promote.to_s # => "S:+P"
piece.unpromote.to_s # => "S:P"


# Xiangqi (Chinese chess)'s General, Red
piece = Sashite::GAN.parse("X:-G")

piece.abbr.to_s # => "-G"
piece.style # => "X"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "X:-G"
piece.topside.to_s # => "x:-g"
piece.bottomside.to_s # => "X:-G"
piece.oppositeside.to_s # => "x:-g"
piece.promote.to_s # => "X:+-G"
piece.unpromote.to_s # => "X:-G"


# Xiangqi (Chinese chess)'s Flying General, Red
piece = Sashite::GAN.parse("X:+-G")

piece.abbr.to_s # => "+-G"
piece.style # => "X"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "X:+-G"
piece.topside.to_s # => "x:+-g"
piece.bottomside.to_s # => "X:+-G"
piece.oppositeside.to_s # => "x:+-g"
piece.promote.to_s # => "X:+-G"
piece.unpromote.to_s # => "X:-G"


# Dai Dai Shogi (huge Japanese chess)'s Phoenix, Sente
piece = Sashite::GAN.parse("DAI_DAI_SHOGI:PH")

piece.abbr.to_s # => "PH"
piece.style # => "DAI_DAI_SHOGI"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "DAI_DAI_SHOGI:PH"
piece.topside.to_s # => "dai_dai_shogi:ph"
piece.bottomside.to_s # => "DAI_DAI_SHOGI:PH"
piece.oppositeside.to_s # => "dai_dai_shogi:ph"
piece.promote.to_s # => "DAI_DAI_SHOGI:+PH"
piece.unpromote.to_s # => "DAI_DAI_SHOGI:PH"


# A random FOO chess variant's promoted Z piece, Bottom-side
piece = Sashite::GAN.parse("FOO:+Z")

piece.abbr.to_s # => "+Z"
piece.style # => "FOO"
piece.topside? # => false
piece.bottomside? # => true
piece.to_s # => "FOO:+Z"
piece.topside.to_s # => "foo:+z"
piece.bottomside.to_s # => "FOO:+Z"
piece.oppositeside.to_s # => "foo:+z"
piece.promote.to_s # => "FOO:+Z"
piece.unpromote.to_s # => "FOO:Z"
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

This [gem](https://rubygems.org/gems/sashite-gan) is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
