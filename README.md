# Gan.rb

[![Version](https://img.shields.io/github/v/tag/sashite/gan.rb?label=Version&logo=github)](https://github.com/sashite/gan.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/gan.rb/main)
![Ruby](https://github.com/sashite/gan.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/gan.rb?label=License&logo=github)](https://github.com/sashite/gan.rb/raw/main/LICENSE.md)

> **GAN** (General Actor Notation) support for the Ruby language.

## What is GAN?

GAN (General Actor Notation) defines a consistent and rule-agnostic format for representing game actors in abstract strategy board games. Building upon Piece Name Notation (PNN), GAN eliminates ambiguity by associating each piece with its originating game, allowing for unambiguous gameplay application and cross-game distinctions.

This gem implements the [GAN Specification v1.0.0](https://sashite.dev/documents/gan/1.0.0/), providing a Ruby interface for:

- Serializing game actors to GAN strings
- Parsing GAN strings into their component parts
- Validating GAN strings according to the specification

## Installation

```ruby
# In your Gemfile
gem "sashite-gan"
```

Or install manually:

```sh
gem install sashite-gan
```

## GAN Format

A GAN record consists of a game identifier, followed by a colon, followed by a piece identifier that follows the PNN specification:

```
<game-id>:<piece-id>
```

Where:

- `<game-id>` is a sequence of alphabetic characters identifying the game variant.
- `:` is a literal colon character, serving as a separator.
- `<piece-id>` is a piece representation following the PNN specification: `[<prefix>]<letter>[<suffix>]`.

The casing of the game identifier reflects the player:

- **Uppercase** game identifiers (e.g., `CHESS:`) denote pieces belonging to the first player.
- **Lowercase** game identifiers (e.g., `chess:`) denote pieces belonging to the second player.

## Basic Usage

### Parsing GAN Strings

Convert a GAN string into a structured Ruby hash:

```ruby
require "sashite/gan"

# Basic actor
result = Sashite::Gan.parse("CHESS:K")
# => { game_id: "CHESS", letter: "K" }

# With piece prefix
result = Sashite::Gan.parse("SHOGI:+P")
# => { game_id: "SHOGI", letter: "P", prefix: "+" }

# With piece suffix
result = Sashite::Gan.parse("CHESS:K'")
# => { game_id: "CHESS", letter: "K", suffix: "'" }

# With both piece prefix and suffix
result = Sashite::Gan.parse("SHOGI:+R'")
# => { game_id: "SHOGI", letter: "R", prefix: "+", suffix: "'" }
```

### Safe Parsing

Parse a GAN string without raising exceptions:

```ruby
require "sashite/gan"

# Valid GAN string
result = Sashite::Gan.safe_parse("CHESS:K'")
# => { game_id: "CHESS", letter: "K", suffix: "'" }

# Invalid GAN string
result = Sashite::Gan.safe_parse("invalid gan string")
# => nil
```

### Creating GAN Strings

Convert actor components into a GAN string:

```ruby
require "sashite/gan"

# Basic actor
Sashite::Gan.dump(game_id: "CHESS", letter: "K")
# => "CHESS:K"

# With piece prefix
Sashite::Gan.dump(game_id: "SHOGI", letter: "P", prefix: "+")
# => "SHOGI:+P"

# With piece suffix
Sashite::Gan.dump(game_id: "CHESS", letter: "K", suffix: "'")
# => "CHESS:K'"

# With both piece prefix and suffix
Sashite::Gan.dump(game_id: "SHOGI", letter: "R", prefix: "+", suffix: "'")
# => "SHOGI:+R'"
```

### Validation

Check if a string is valid GAN notation:

```ruby
require "sashite/gan"

Sashite::Gan.valid?("CHESS:K")      # => true
Sashite::Gan.valid?("SHOGI:+P")     # => true
Sashite::Gan.valid?("CHESS:K'")     # => true
Sashite::Gan.valid?("chess:k")      # => true

Sashite::Gan.valid?("")             # => false
Sashite::Gan.valid?("CHESS:k")      # => false (mismatched casing)
Sashite::Gan.valid?("CHESS::K")     # => false
Sashite::Gan.valid?("CHESS-K")      # => false
```

## Casing Rules

The casing of the game identifier must match the piece letter casing:

- **Uppercase** game IDs must have **uppercase** piece letters for the first player
- **Lowercase** game IDs must have **lowercase** piece letters for the second player

This ensures consistency with the FEEN specification's third field.

## Examples

### Chess Pieces

| PNN   | GAN (First Player) | GAN (Second Player) |
|-------|--------------------|--------------------|
| `K'`  | `CHESS:K'`         | `chess:k'`         |
| `Q`   | `CHESS:Q`          | `chess:q`          |
| `R`   | `CHESS:R`          | `chess:r`          |
| `B`   | `CHESS:B`          | `chess:b`          |
| `N`   | `CHESS:N`          | `chess:n`          |
| `P`   | `CHESS:P`          | `chess:p`          |

### Disambiguated Collisions

These examples show how GAN resolves ambiguities between pieces that would have identical PNN representation:

| Description | PNN   | GAN                 |
|-------------|-------|---------------------|
| Chess Rook (white) | `R`   | `CHESS:R`           |
| Makruk Rook (white) | `R`   | `MAKRUK:R`          |
| Shogi Rook (sente) | `R`   | `SHOGI:R`           |
| Promoted Shogi Rook (sente) | `+R`  | `SHOGI:+R`          |

## Documentation

- [Official GAN Specification](https://sashite.dev/documents/gan/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/gan.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-gan) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
