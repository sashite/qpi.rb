# Gan.rb

[![Version](https://img.shields.io/github/v/tag/sashite/gan.rb?label=Version&logo=github)](https://github.com/sashite/gan.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/gan.rb/main)
![Ruby](https://github.com/sashite/gan.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/gan.rb?label=License&logo=github)](https://github.com/sashite/gan.rb/raw/main/LICENSE.md)

> **GAN** (General Actor Notation) support for the Ruby language.

## What is GAN?

GAN (General Actor Notation) defines a consistent and rule-agnostic format for identifying game actors in abstract strategy board games. GAN provides unambiguous identification of pieces by combining Style Name Notation (SNN) with Piece Name Notation (PNN), eliminating collision problems when multiple piece styles are present in the same context.

This gem implements the [GAN Specification v1.0.0](https://sashite.dev/documents/gan/1.0.0/), providing a Ruby interface for working with game actors through a clean and modular API that builds upon the existing [sashite-snn](https://rubygems.org/gems/sashite-snn) and [pnn](https://rubygems.org/gems/pnn) gems.

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

A GAN record consists of a style identifier (SNN format), followed by a colon separator, followed by a piece identifier (PNN format):

```
<style-id>:<piece-id>
```

Where:
- `<style-id>` is a Style Name Notation (SNN) identifier conforming to SNN specification
- `:` is a literal colon character serving as a separator
- `<piece-id>` is a Piece Name Notation (PNN) identifier conforming to PNN specification

## Basic Usage

### Creating Actor Objects

The primary interface is the `Sashite::Gan::Actor` class, which represents a game actor in GAN format:

```ruby
require "sashite/gan"

# Parse a GAN string into an actor object
actor = Sashite::Gan::Actor.parse("CHESS:K")
# => #<Sashite::Gan::Actor:0x... @style="CHESS" @piece="K">

# With piece modifiers
enhanced_actor = Sashite::Gan::Actor.parse("SHOGI:+P")
# => #<Sashite::Gan::Actor:0x... @style="SHOGI" @piece="+P">

# Create directly with constructor
actor = Sashite::Gan::Actor.new("CHESS", "K")
enhanced_actor = Sashite::Gan::Actor.new("SHOGI", "+P")

# Create with style and piece objects
style = Sashite::Snn::Style.new("CHESS")
piece = Pnn::Piece.new("K")
actor = Sashite::Gan::Actor.new(style, piece)

# Convenience method
actor = Sashite::Gan.actor("CHESS", "K")
```

### Converting to GAN String

Convert an actor object back to its GAN string representation:

```ruby
actor = Sashite::Gan::Actor.parse("CHESS:K")
actor.to_s
# => "CHESS:K"

enhanced_actor = Sashite::Gan::Actor.parse("SHOGI:+p'")
enhanced_actor.to_s
# => "SHOGI:+p'"
```

### Accessing Components

Access the style and piece components of an actor:

```ruby
actor = Sashite::Gan::Actor.parse("CHESS:K")

# Access as strings
actor.style_name    # => "CHESS"
actor.piece_name    # => "K"

# Access as objects
actor.style         # => #<Sashite::Snn::Style:0x... @identifier="CHESS">
actor.piece         # => #<Pnn::Piece:0x... @letter="K">

# Check player associations
actor.style.first_player?   # => true
actor.piece.uppercase?      # => true
```

## Casing Combinations and Player Association

GAN allows all four combinations of case between style and piece identifiers to support dynamic ownership changes:

```ruby
# First player's style, first player's piece
actor1 = Sashite::Gan::Actor.parse("CHESS:K")
actor1.style.first_player?   # => true
actor1.piece.uppercase?      # => true

# First player's style, second player's piece (piece was captured and converted)
actor2 = Sashite::Gan::Actor.parse("CHESS:k")
actor2.style.first_player?   # => true
actor2.piece.lowercase?      # => true

# Second player's style, first player's piece (piece was captured and converted)
actor3 = Sashite::Gan::Actor.parse("chess:K")
actor3.style.second_player?  # => true
actor3.piece.uppercase?      # => true

# Second player's style, second player's piece
actor4 = Sashite::Gan::Actor.parse("chess:k")
actor4.style.second_player?  # => true
actor4.piece.lowercase?      # => true
```

## Dynamic Ownership Changes

While style assignment remains fixed throughout a game, piece ownership may change during gameplay:

```ruby
# Original piece owned by first player
original = Sashite::Gan::Actor.parse("SHOGI:P")

# After capture by second player (modifiers preserved by default)
captured = original.change_piece_ownership
captured.to_s # => "SHOGI:p"

# Or create the captured version directly
captured = Sashite::Gan::Actor.new(original.style, "p")

# Example with enhanced piece - modifiers are preserved
enhanced = Sashite::Gan::Actor.parse("SHOGI:+P")
captured_enhanced = enhanced.change_piece_ownership
captured_enhanced.to_s # => "SHOGI:+p" (modifiers preserved)

# To remove modifiers explicitly (if game rules require it):
bare_captured = enhanced.bare_piece.change_piece_ownership
bare_captured.to_s # => "SHOGI:p" (modifiers removed)
```

## Traditional Same-Style Games

In traditional games where both players use the same piece style:

```ruby
# Chess pieces
white_king = Sashite::Gan::Actor.parse("CHESS:K")
black_king = Sashite::Gan::Actor.parse("chess:k")

white_queen = Sashite::Gan::Actor.parse("CHESS:Q")
black_queen = Sashite::Gan::Actor.parse("chess:q")

# Shogi pieces
first_king = Sashite::Gan::Actor.parse("SHOGI:K")
second_king = Sashite::Gan::Actor.parse("shogi:k")

first_gold = Sashite::Gan::Actor.parse("SHOGI:G")
second_gold = Sashite::Gan::Actor.parse("shogi:g")
```

## Cross-Style Games

In games where players use different piece styles:

```ruby
# Chess vs Makruk
chess_king = Sashite::Gan::Actor.parse("CHESS:K")
makruk_king = Sashite::Gan::Actor.parse("makruk:k")

chess_queen = Sashite::Gan::Actor.parse("CHESS:Q")
makruk_queen = Sashite::Gan::Actor.parse("makruk:q")

# Shogi vs Xiangqi
shogi_king = Sashite::Gan::Actor.parse("SHOGI:K")
xiangqi_general = Sashite::Gan::Actor.parse("xiangqi:g")

shogi_gold = Sashite::Gan::Actor.parse("SHOGI:G")
xiangqi_advisor = Sashite::Gan::Actor.parse("xiangqi:a")
```

## Pieces with States and Ownership Changes

```ruby
# Original enhanced piece
original = Sashite::Gan::Actor.parse("CHESS:R'")

# After capture (modifiers preserved by default)
captured = original.change_piece_ownership
captured.to_s # => "chess:R'"

# If game rules require modifier removal during capture:
captured_bare = original.bare_piece.change_piece_ownership
captured_bare.to_s # => "chess:R"

# Promoted shogi piece captured
promoted_pawn = Sashite::Gan::Actor.parse("shogi:+p")
captured_promoted = promoted_pawn.change_piece_ownership
captured_promoted.to_s # => "SHOGI:+p" (modifiers preserved)

# With explicit modifier removal:
captured_demoted = promoted_pawn.bare_piece.change_piece_ownership
captured_demoted.to_s # => "SHOGI:p"
```

## Collision Resolution

GAN resolves naming conflicts between different styles:

```ruby
# All different actors despite similar piece types
chess_rook = Sashite::Gan::Actor.parse("CHESS:R")
shogi_rook = Sashite::Gan::Actor.parse("SHOGI:R")
makruk_rook = Sashite::Gan::Actor.parse("MAKRUK:R")
xiangqi_chariot = Sashite::Gan::Actor.parse("xiangqi:r")

# They can all coexist in the same context
pieces = [chess_rook, shogi_rook, makruk_rook, xiangqi_chariot]
puts pieces.map(&:to_s)
# => ["CHESS:R", "SHOGI:R", "MAKRUK:R", "xiangqi:r"]
```

## Advanced Usage

### Working with Collections

```ruby
# Group actors by style
actors = [
  Sashite::Gan::Actor.parse("CHESS:K"),
  Sashite::Gan::Actor.parse("CHESS:Q"),
  Sashite::Gan::Actor.parse("shogi:k"),
  Sashite::Gan::Actor.parse("shogi:g")
]

grouped = actors.group_by { |actor| actor.style_name.downcase }
# => {"chess" => [...], "shogi" => [...]}

# Filter by player
first_player_actors = actors.select { |actor| actor.style.first_player? }
second_player_actors = actors.select { |actor| actor.style.second_player? }

# Find actors by piece type
kings = actors.select { |actor| actor.piece_name.downcase == "k" }
```

### State Manipulation

```ruby
actor = Sashite::Gan::Actor.parse("SHOGI:P")

# Enhance the piece
enhanced = actor.enhance_piece
enhanced.to_s # => "SHOGI:+P"

# Add intermediate state
intermediate = actor.set_piece_intermediate
intermediate.to_s # => "SHOGI:P'"

# Chain operations
complex = actor.enhance_piece.set_piece_intermediate
complex.to_s # => "SHOGI:+P'"

# Remove all modifiers
bare = complex.bare_piece
bare.to_s # => "SHOGI:P"
```

### Validation

All parsing automatically validates input according to the GAN specification:

```ruby
# Valid GAN strings
Sashite::Gan::Actor.parse("CHESS:K")      # ✓
Sashite::Gan::Actor.parse("shogi:+p")     # ✓
Sashite::Gan::Actor.parse("XIANGQI:r'")   # ✓

# Valid constructor calls
Sashite::Gan::Actor.new("CHESS", "K")     # ✓
Sashite::Gan::Actor.new("shogi", "+p")    # ✓

# Convenience method
Sashite::Gan.actor("MAKRUK", "Q") # ✓

# Check validity
Sashite::Gan.valid?("CHESS:K")            # => true
Sashite::Gan.valid?("Chess:K")            # => false (mixed case in style)
Sashite::Gan.valid?("CHESS")              # => false (missing piece)
Sashite::Gan.valid?("")                   # => false (empty string)

# Invalid GAN strings raise ArgumentError
Sashite::Gan::Actor.parse("")             # ✗ ArgumentError
Sashite::Gan::Actor.parse("Chess:K")      # ✗ ArgumentError (mixed case)
Sashite::Gan::Actor.parse("CHESS")        # ✗ ArgumentError (missing piece)
Sashite::Gan::Actor.parse("CHESS:++K")    # ✗ ArgumentError (invalid piece)
```

### Inspection and Debugging

```ruby
actor = Sashite::Gan::Actor.parse("SHOGI:+p'")

# Get detailed information
actor.inspect
# => "#<Sashite::Gan::Actor:0x... style=\"SHOGI\" piece=\"+p'\">"

# Check components
actor.style_name     # => "SHOGI"
actor.piece_name     # => "+p'"
actor.piece.enhanced?     # => true
actor.piece.intermediate? # => true
```

## API Reference

### Module Methods

- `Sashite::Gan.valid?(gan_string)` - Check if a string is valid GAN notation
- `Sashite::Gan.actor(style, piece)` - Convenience method to create actors

### Sashite::Gan::Actor Class Methods

- `Sashite::Gan::Actor.parse(gan_string)` - Parse a GAN string into an actor object
- `Sashite::Gan::Actor.new(style, piece)` - Create a new actor instance

### Instance Methods

#### Component Access
- `#style` - Get the style object (Sashite::Snn::Style)
- `#piece` - Get the piece object (Pnn::Piece)
- `#style_name` - Get the style name as string
- `#piece_name` - Get the piece name as string

#### Piece State Manipulation
- `#enhance_piece` - Create actor with enhanced piece
- `#diminish_piece` - Create actor with diminished piece
- `#set_piece_intermediate` - Create actor with intermediate piece state
- `#bare_piece` - Create actor with piece without modifiers
- `#change_piece_ownership` - Create actor with piece ownership flipped

#### Conversion
- `#to_s` - Convert to GAN string representation
- `#inspect` - Detailed string representation for debugging

## Properties of GAN

* **Rule-agnostic**: GAN does not encode game states, legality, validity, or game-specific conditions
* **Unambiguous identification**: Different piece styles can coexist without naming conflicts
* **Canonical representation**: Equivalent actors yield identical strings
* **Cross-style support**: Enables games where pieces from multiple traditions may be present
* **Dynamic ownership**: Supports games where piece ownership can change during gameplay
* **Compositional architecture**: Built on independent SNN and PNN specifications

## Constraints

* GAN supports exactly **two players**
* Players are distinguished through the combination of SNN and PNN casing
* Style assignment to players remains **fixed throughout a game**
* Piece ownership may change during gameplay through casing changes
* Both style and piece identifiers must conform to their respective specifications

## Use Cases

GAN is particularly useful in the following scenarios:

1. **Multi-style environments**: When positions or analyses involve pieces from multiple style traditions
2. **Game engine development**: When implementing engines that need to distinguish between similar pieces from different styles while tracking ownership changes
3. **Hybrid games**: When creating or analyzing positions from games that combine elements from different piece traditions
4. **Database systems**: When storing game data that must avoid naming conflicts between similar pieces from different styles
5. **Cross-style analysis**: When comparing or analyzing strategic elements across different piece traditions
6. **Capture-conversion games**: When implementing games like shōgi where pieces change ownership and require clear ownership tracking

## Dependencies

This gem depends on:

- [sashite-snn](https://github.com/sashite/snn.rb) (~> 1.0.0) - Style Name Notation implementation
- [pnn](https://github.com/sashite/pnn.rb) (~> 2.0.0) - Piece Name Notation implementation

## Specification

- [GAN Specification](https://sashite.dev/documents/gan/1.0.0/)
- [SNN Specification](https://sashite.dev/documents/snn/1.0.0/)
- [PNN Specification](https://sashite.dev/documents/pnn/1.0.0/)

## Documentation

- [GAN Documentation](https://rubydoc.info/github/sashite/gan.rb/main)
- [SNN Documentation](https://rubydoc.info/github/sashite/snn.rb/main)
- [PNN Documentation](https://rubydoc.info/github/sashite/pnn.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-gan) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
