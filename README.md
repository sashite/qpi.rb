# Gan.rb

[![Version](https://img.shields.io/github/v/tag/sashite/gan.rb?label=Version&logo=github)](https://github.com/sashite/gan.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/gan.rb/main)
![Ruby](https://github.com/sashite/gan.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/gan.rb?label=License&logo=github)](https://github.com/sashite/gan.rb/raw/main/LICENSE.md)

> **GAN** (General Actor Notation) implementation for the Ruby language.

## What is GAN?

GAN (General Actor Notation) provides a rule-agnostic format for identifying game actors in abstract strategy board games by combining [Style Name Notation (SNN)](https://sashite.dev/specs/snn/1.0.0/) and [Piece Identifier Notation (PIN)](https://sashite.dev/specs/pin/1.0.0/) with a colon separator and consistent case encoding.

GAN represents **all four fundamental piece attributes** from the [Game Protocol](https://sashite.dev/game-protocol/):
- **Type** → PIN component (ASCII letter choice)
- **Side** → Consistent case encoding across both SNN and PIN components
- **State** → PIN component (optional prefix modifier)
- **Style** → SNN component (explicit style identifier)

This gem implements the [GAN Specification v1.0.0](https://sashite.dev/specs/gan/1.0.0/), providing a modern Ruby interface with immutable actor objects and functional programming principles built upon the [sashite-snn](https://rubygems.org/gems/sashite-snn) and [sashite-pin](https://rubygems.org/gems/sashite-pin) gems.

## Installation

```ruby
# In your Gemfile
gem "sashite-gan"
```

Or install manually:

```sh
gem install sashite-gan
```

## Usage

```ruby
require "sashite/gan"

# Parse GAN strings into actor objects
actor = Sashite::Gan.parse("CHESS:K")          # => #<Gan::Actor name=:Chess type=:K side=:first state=:normal>
actor.to_s                                     # => "CHESS:K"
actor.name                                     # => :Chess
actor.type                                     # => :K
actor.side                                     # => :first
actor.state                                    # => :normal

# Extract individual components
actor.to_snn                                   # => "CHESS"
actor.to_pin                                   # => "K"

# Create actors directly
actor = Sashite::Gan.actor(:Chess, :K, :first, :normal) # => #<Gan::Actor name=:Chess type=:K side=:first state=:normal>
actor = Sashite::Gan::Actor.new(:Shogi, :P, :second, :enhanced) # => #<Gan::Actor name=:Shogi type=:P side=:second state=:enhanced>

# Validate GAN strings
Sashite::Gan.valid?("CHESS:K")                 # => true
Sashite::Gan.valid?("shogi:+p")                # => true
Sashite::Gan.valid?("Chess:K")                 # => false (mixed case)
Sashite::Gan.valid?("CHESS")                   # => false (missing piece)

# Class-level validation (same as module method)
Sashite::Gan::Actor.valid?("CHESS:K")          # => true
Sashite::Gan::Actor.valid?("chess:k")          # => true
Sashite::Gan::Actor.valid?("Chess:K")          # => false (mixed case)
Sashite::Gan::Actor.valid?("CHESS:k")          # => false (case mismatch)

# State manipulation (returns new immutable instances)
enhanced = actor.enhance                       # => #<Gan::Actor name=:Chess type=:K side=:first state=:enhanced>
enhanced.to_s                                  # => "CHESS:+K"
enhanced.to_pin                                # => "+K"
diminished = actor.diminish                    # => #<Gan::Actor name=:Chess type=:K side=:first state=:diminished>
diminished.to_s                                # => "CHESS:-K"
diminished.to_pin                              # => "-K"

# Side manipulation
flipped = actor.flip                           # => #<Gan::Actor name=:Chess type=:K side=:second state=:normal>
flipped.to_s                                   # => "chess:k"
flipped.to_snn                                 # => "chess"
flipped.to_pin                                 # => "k"

# Style manipulation
shogi_actor = actor.with_name(:Shogi)          # => #<Gan::Actor name=:Shogi type=:K side=:first state=:normal>
shogi_actor.to_s                               # => "SHOGI:K"
shogi_actor.to_snn                             # => "SHOGI"

# Type manipulation
queen = actor.with_type(:Q)                    # => #<Gan::Actor name=:Chess type=:Q side=:first state=:normal>
queen.to_s                                     # => "CHESS:Q"
queen.to_pin                                   # => "Q"

# State queries
actor.normal?                                  # => true
enhanced.enhanced?                             # => true
diminished.diminished?                         # => true

# Side queries
actor.first_player?                            # => true
flipped.second_player?                         # => true

# Component comparison
chess1 = Sashite::Gan.parse("CHESS:K")
chess2 = Sashite::Gan.parse("chess:k")
shogi = Sashite::Gan.parse("SHOGI:K")

chess1.same_name?(chess2)                      # => true (both chess)
chess1.same_side?(shogi)                       # => true (both first player)
chess1.same_type?(chess2)                      # => true (both kings)
chess1.same_name?(shogi)                       # => false (different styles)

# Functional transformations can be chained
black_promoted = Sashite::Gan.parse("CHESS:P").flip.enhance
black_promoted.to_s                            # => "chess:+p"
black_promoted.to_snn                          # => "chess"
black_promoted.to_pin                          # => "+p"
```

## Format Specification

### Structure
```
<snn>:<pin>
```

### Components

- **SNN Component** (Style Name Notation): Style identifier with case-based side encoding
  - Uppercase: First player styles (`CHESS`, `SHOGI`, `XIANGQI`)
  - Lowercase: Second player styles (`chess`, `shogi`, `xiangqi`)
- **Colon Separator**: Literal `:` character
- **PIN Component** (Piece Identifier Notation): Piece with optional state and case-based ownership
  - Letter case matches SNN case (case consistency requirement)
  - Optional state prefix: `+` (enhanced), `-` (diminished)

### Case Consistency Requirement

**Critical Rule**: The case of the SNN component must match the case of the PIN component:

```ruby
# ✅ Valid combinations
Sashite::Gan.valid?("CHESS:K")     # => true (both uppercase = first player)
Sashite::Gan.valid?("chess:k")     # => true (both lowercase = second player)
Sashite::Gan.valid?("SHOGI:+R")    # => true (both uppercase = first player)
Sashite::Gan.valid?("xiangqi:-g")  # => true (both lowercase = second player)

# ❌ Invalid combinations
Sashite::Gan.valid?("CHESS:k")     # => false (case mismatch)
Sashite::Gan.valid?("chess:K")     # => false (case mismatch)
Sashite::Gan.valid?("SHOGI:+r")    # => false (case mismatch)
```

### Validation Architecture

GAN validation delegates to the underlying components for maximum consistency:
- **SNN validation**: Uses `Sashite::Snn::Style::SNN_PATTERN` for style validation
- **PIN validation**: Uses `Sashite::Pin::Piece::PIN_PATTERN` for piece validation
- **Case consistency**: Ensures matching case between SNN and PIN components

This modular approach avoids code duplication and ensures that GAN validation automatically inherits improvements from the underlying SNN and PIN libraries.

### Examples
- `CHESS:K` - First player chess king
- `chess:k` - Second player chess king
- `SHOGI:+P` - First player enhanced shōgi pawn
- `xiangqi:-g` - Second player diminished xiangqi general

## Game Examples

### Traditional Same-Style Games

In traditional games where both players use the same piece style:

```ruby
# Chess pieces
white_king = Sashite::Gan.parse("CHESS:K")
black_king = Sashite::Gan.parse("chess:k")
white_queen = Sashite::Gan.parse("CHESS:Q")
black_queen = Sashite::Gan.parse("chess:q")

# Shōgi pieces
sente_king = Sashite::Gan.parse("SHOGI:K")
gote_king = Sashite::Gan.parse("shogi:k")
sente_gold = Sashite::Gan.parse("SHOGI:G")
gote_gold = Sashite::Gan.parse("shogi:g")

# Enhanced states for special conditions
castling_rook = Sashite::Gan.parse("CHESS:+R") # Castling-eligible rook
vulnerable_pawn = Sashite::Gan.parse("CHESS:-P")   # En passant vulnerable pawn
promoted_pawn = Sashite::Gan.parse("SHOGI:+P")     # Tokin (promoted pawn)
```

### Cross-Style Games

GAN's explicit style naming enables games where players use different piece traditions:

```ruby
# Chess vs Shōgi
chess_king = Sashite::Gan.parse("CHESS:K")
shogi_king = Sashite::Gan.parse("shogi:k")

# Makruk vs Xiangqi
makruk_queen = Sashite::Gan.parse("MAKRUK:M") # Met (Makruk queen)
xiangqi_general = Sashite::Gan.parse("xiangqi:g") # Xiangqi general

# Multi-tradition setup
def create_cross_style_game
  [
    Sashite::Gan.parse("CHESS:K"),     # First player uses chess
    Sashite::Gan.parse("CHESS:Q"),
    Sashite::Gan.parse("shogi:k"),     # Second player uses shōgi
    Sashite::Gan.parse("shogi:g")
  ]
end
```

### Capture Mechanics Examples

GAN can represent the different capture mechanics described in the specification:

```ruby
# Chess vs Chess (traditional capture)
def chess_capture(captured_piece)
  # In chess, captured pieces retain their identity but become inactive
  captured_piece # GAN remains unchanged: chess:p stays chess:p
end

# Shōgi vs Shōgi (side-changing capture)
def shogi_capture(captured_piece)
  # In shōgi, captured pieces change sides and lose promotions
  captured_piece.flip.normalize # shogi:+p becomes SHOGI:P
end

# Cross-style capture (style transformation)
def cross_style_capture(captured_piece, capturing_style)
  # Captured piece transforms to capturing player's style
  captured_piece.flip.with_name(capturing_style).normalize
  # chess:q captured by Ōgi player becomes OGI:P
end
```

## API Reference

### Main Module Methods

- `Sashite::Gan.valid?(gan_string)` - Check if string is valid GAN notation
- `Sashite::Gan.parse(gan_string)` - Parse GAN string into Actor object
- `Sashite::Gan.actor(name, type, side, state = :normal)` - Create actor instance directly

### Actor Class

#### Creation and Parsing
- `Sashite::Gan::Actor.new(name, type, side, state = :normal)` - Create actor instance
- `Sashite::Gan::Actor.parse(gan_string)` - Parse GAN string (same as module method)
- `Sashite::Gan::Actor.valid?(gan_string)` - Validate GAN string (class method)

#### Attribute Access
- `#name` - Get style name (symbol with proper capitalization)
- `#type` - Get piece type (symbol :A to :Z, always uppercase)
- `#side` - Get player side (:first or :second)
- `#state` - Get piece state (:normal, :enhanced, or :diminished)
- `#to_s` - Convert to GAN string representation
- `#to_pin` - Convert to PIN string representation (piece component only)
- `#to_snn` - Convert to SNN string representation (style component only)

#### Component Extraction

The `to_pin` and `to_snn` methods allow extraction of individual notation components:

```ruby
actor = Sashite::Gan.parse("CHESS:+K")

# Full GAN representation
actor.to_s # => "CHESS:+K"

# Individual components
actor.to_snn      # => "CHESS" (style component)
actor.to_pin      # => "+K"    (piece component)

# Component transformation example
flipped = actor.flip
flipped.to_s      # => "chess:+k"
flipped.to_snn    # => "chess"  (lowercase for second player)
flipped.to_pin    # => "+k"     (lowercase with state preserved)

# State manipulation example
normalized = actor.normalize
normalized.to_s   # => "CHESS:K"
normalized.to_pin # => "K"      (state modifier removed)
normalized.to_snn # => "CHESS"  (style unchanged)
```

#### Component Handling

**Important**: Following PIN and SNN conventions:
- **Style names** are stored with proper capitalization (`:Chess`, `:Shogi`)
- **Piece types** are stored as uppercase symbols (`:K`, `:P`)
- **Display case** is determined by `side` during rendering

```ruby
# Both create the same internal representation
actor1 = Sashite::Gan.parse("CHESS:K")  # name: :Chess, type: :K, side: :first
actor2 = Sashite::Gan.parse("chess:k")  # name: :Chess, type: :K, side: :second

actor1.name        # => :Chess (proper capitalization)
actor2.name        # => :Chess (same style name)
actor1.type        # => :K (uppercase type)
actor2.type        # => :K (same type)

actor1.to_s        # => "CHESS:K" (uppercase display)
actor2.to_s        # => "chess:k" (lowercase display)
actor1.to_snn      # => "CHESS" (uppercase style)
actor2.to_snn      # => "chess" (lowercase style)
actor1.to_pin      # => "K" (uppercase piece)
actor2.to_pin      # => "k" (lowercase piece)
```

#### State Queries
- `#normal?` - Check if normal state (no modifiers)
- `#enhanced?` - Check if enhanced state
- `#diminished?` - Check if diminished state

#### Side Queries
- `#first_player?` - Check if first player actor
- `#second_player?` - Check if second player actor

#### State Transformations (immutable - return new instances)
- `#enhance` - Create enhanced version
- `#diminish` - Create diminished version
- `#normalize` - Remove all state modifiers
- `#flip` - Switch player (change side)

#### Attribute Transformations (immutable - return new instances)
- `#with_name(new_name)` - Create actor with different style name
- `#with_type(new_type)` - Create actor with different piece type
- `#with_side(new_side)` - Create actor with different side
- `#with_state(new_state)` - Create actor with different state

#### Comparison Methods
- `#same_name?(other)` - Check if same style name
- `#same_type?(other)` - Check if same piece type
- `#same_side?(other)` - Check if same side
- `#same_state?(other)` - Check if same state
- `#==(other)` - Full equality comparison

### Constants
- `Sashite::Gan::Actor::SEPARATOR` - Colon separator character

## Advanced Usage

### Component Extraction and Manipulation

The `to_pin` and `to_snn` methods enable powerful component-based operations:

```ruby
# Extract and manipulate components
actor = Sashite::Gan.parse("SHOGI:+P")

# Component extraction
style_str = actor.to_snn    # => "SHOGI"
piece_str = actor.to_pin    # => "+P"

# Reconstruct from components
reconstructed = "#{style_str}:#{piece_str}" # => "SHOGI:+P"

# Cross-component analysis
actors = [
  Sashite::Gan.parse("CHESS:K"),
  Sashite::Gan.parse("SHOGI:K"),
  Sashite::Gan.parse("chess:k")
]

# Group by style component
by_style = actors.group_by(&:to_snn)
# => {"CHESS" => [...], "SHOGI" => [...], "chess" => [...]}

# Group by piece component
by_piece = actors.group_by(&:to_pin)
# => {"K" => [...], "k" => [...]}

# Component-based filtering
uppercase_styles = actors.select { |a| a.to_snn == a.to_snn.upcase }
enhanced_pieces = actors.select { |a| a.to_pin.start_with?("+") }
```

### Component Reconstruction Patterns

```ruby
# Template-based reconstruction
def apply_style_template(actors, new_style)
  actors.map do |actor|
    pin_part = actor.to_pin
    side = actor.side

    # Apply new style while preserving piece and side
    new_style_str = side == :first ? new_style.to_s.upcase : new_style.to_s.downcase
    Sashite::Gan.parse("#{new_style_str}:#{pin_part}")
  end
end

# Convert chess pieces to shōgi style
chess_pieces = [
  Sashite::Gan.parse("CHESS:K"),
  Sashite::Gan.parse("chess:+q")
]

shogi_pieces = apply_style_template(chess_pieces, :Shogi)
# => [SHOGI:K, shogi:+q]

# Component swapping
def swap_components(actor1, actor2)
  [
    Sashite::Gan.parse("#{actor1.to_snn}:#{actor2.to_pin}"),
    Sashite::Gan.parse("#{actor2.to_snn}:#{actor1.to_pin}")
  ]
end

chess_king = Sashite::Gan.parse("CHESS:K")
shogi_pawn = Sashite::Gan.parse("shogi:p")

swapped = swap_components(chess_king, shogi_pawn)
# => [CHESS:p, shogi:K]
```

### Immutable Transformations
```ruby
# All transformations return new instances
original = Sashite::Gan.parse("CHESS:P")
enhanced = original.enhance
cross_style = original.with_name(:Shogi)
enemy = original.flip

# Original actor is never modified
puts original     # => "CHESS:P"
puts enhanced     # => "CHESS:+P"
puts cross_style  # => "SHOGI:P"
puts enemy        # => "chess:p"

# Component extraction shows changes
puts enhanced.to_pin # => "+P" (state changed)
puts cross_style.to_snn # => "SHOGI" (style changed)
puts enemy.to_snn      # => "chess" (case changed)
puts enemy.to_pin      # => "p" (case changed)

# Transformations can be chained
result = original.flip.with_name(:Xiangqi).enhance
puts result # => "xiangqi:+p"
puts result.to_snn     # => "xiangqi"
puts result.to_pin     # => "+p"
```

### Multi-Style Game Management
```ruby
class CrossStyleGame
  def initialize
    @actors = []
    @style_assignments = {}
  end

  def assign_style(player, style)
    side = player == :white ? :first : :second
    @style_assignments[player] = { style: style, side: side }
  end

  def create_actor(player, type, state = :normal)
    assignment = @style_assignments[player]
    Sashite::Gan::Actor.new(assignment[:style], type, assignment[:side], state)
  end

  def valid_combination?
    return true if @style_assignments.size < 2

    sides = @style_assignments.values.map { |a| a[:side] }
    sides.uniq.size == 2 # Must have different sides
  end

  def get_player_style_string(player)
    actor = create_actor(player, :K) # Use king as reference
    actor.to_snn
  end
end

# Usage
game = CrossStyleGame.new
game.assign_style(:white, :Chess)
game.assign_style(:black, :Shogi)

white_king = game.create_actor(:white, :K)
black_king = game.create_actor(:black, :K)

puts white_king # => "CHESS:K"
puts white_king.to_snn # => "CHESS"
puts black_king # => "shogi:k"
puts black_king.to_snn # => "shogi"
puts game.valid_combination? # => true
```

### Validation and Error Handling
```ruby
# Comprehensive validation with both module and class methods
def safe_parse(gan_string)
  # You can use either method for validation
  return nil unless Sashite::Gan.valid?(gan_string)

  # Alternative: return nil unless Sashite::Gan::Actor.valid?(gan_string)

  Sashite::Gan.parse(gan_string)
rescue ArgumentError => e
  puts "Parse error: #{e.message}"
  nil
end

# Batch validation with component extraction
gan_strings = ["CHESS:K", "Chess:K", "SHOGI:+p", "invalid"]
valid_actors = gan_strings.filter_map { |s| safe_parse(s) }

puts "Valid actors with components:"
valid_actors.each do |actor|
  puts "  #{actor} -> style: #{actor.to_snn}, piece: #{actor.to_pin}"
end

# Module-level validation
Sashite::Gan.valid?("CHESS:K")           # => true
Sashite::Gan.valid?("chess:k")           # => true
Sashite::Gan.valid?("Chess:K")           # => false (mixed case)
Sashite::Gan.valid?("CHESS")             # => false (missing piece)

# Class-level validation (equivalent to module method)
Sashite::Gan::Actor.valid?("CHESS:K")    # => true
Sashite::Gan::Actor.valid?("chess:k")    # => true
Sashite::Gan::Actor.valid?("Chess:K")    # => false (mixed case)
Sashite::Gan::Actor.valid?("CHESS:k")    # => false (case mismatch)
```

### Collection Operations
```ruby
# Working with actor collections
actors = [
  Sashite::Gan.parse("CHESS:K"),
  Sashite::Gan.parse("CHESS:Q"),
  Sashite::Gan.parse("shogi:k"),
  Sashite::Gan.parse("shogi:g"),
  Sashite::Gan.parse("XIANGQI:G")
]

# Group by various attributes
by_style = actors.group_by(&:name)
by_side = actors.group_by(&:side)
by_type = actors.group_by(&:type)

# Group by string components
by_style_string = actors.group_by(&:to_snn)
by_piece_string = actors.group_by(&:to_pin)

puts "By style string: #{by_style_string.keys}"  # => ["CHESS", "shogi", "XIANGQI"]
puts "By piece string: #{by_piece_string.keys}"  # => ["K", "Q", "k", "g", "G"]

# Filter operations
first_player_actors = actors.select(&:first_player?)
chess_actors = actors.select { |a| a.name == :Chess }
kings = actors.select { |a| a.type == :K }
uppercase_styles = actors.select { |a| a.to_snn == a.to_snn.upcase }

# Transform collections immutably
enhanced_actors = actors.map(&:enhance)
enemy_actors = actors.map(&:flip)

# Show component changes
puts "Enhanced actors:"
enhanced_actors.each { |a| puts "  #{a} (pin: #{a.to_pin})" }

puts "Enemy actors:"
enemy_actors.each { |a| puts "  #{a} (snn: #{a.to_snn}, pin: #{a.to_pin})" }

# Complex queries
cross_style_pairs = actors.combination(2).select do |a1, a2|
  a1.name != a2.name && a1.side != a2.side
end

puts "Cross-style pairs: #{cross_style_pairs.size}"
```

## Protocol Mapping

GAN encodes piece attributes by combining SNN and PIN information:

| Protocol Attribute | GAN Encoding | Examples | Notes |
|-------------------|--------------|----------|-------|
| **Type** | PIN letter choice | `CHESS:K` = King, `SHOGI:P` = Pawn | Type stored as uppercase symbol (`:K`, `:P`) |
| **Side** | Unified case across components | `CHESS:K` = First player, `chess:k` = Second player | Case consistency enforced |
| **State** | PIN prefix modifier | `SHOGI:+P` = Enhanced, `CHESS:-P` = Diminished | |
| **Style** | SNN identifier | `CHESS:K` = Chess style, `SHOGI:K` = Shōgi style | Style stored with proper capitalization (`:Chess`, `:Shogi`) |

## Properties

* **Rule-Agnostic**: Independent of specific game mechanics
* **Complete Identification**: Explicit representation of all four piece attributes
* **Cross-Style Support**: Enables multi-tradition gaming environments
* **Component Clarity**: Clear separation between style context and piece identity
* **Component Extraction**: Individual SNN and PIN components accessible via `to_snn` and `to_pin`
* **Unified Case Encoding**: Consistent case across both components for side identification
* **Protocol Compliance**: Direct implementation of Sashité piece attributes
* **Immutable Design**: All operations return new instances, ensuring thread safety
* **Compositional Architecture**: Built on independent SNN and PIN specifications
* **Modular Validation**: Delegates validation to underlying components for consistency

## Implementation Notes

### Validation Architecture

GAN follows a modular validation approach that leverages the underlying component libraries:

1. **Component Splitting**: GAN strings are split on the colon separator
2. **Individual Validation**: Each component is validated using its specific regex:
   - SNN component: `Sashite::Snn::Style::SNN_PATTERN`
   - PIN component: `Sashite::Pin::Piece::PIN_PATTERN`
3. **Case Consistency**: Additional validation ensures matching case between components

This approach:
- **Avoids Code Duplication**: No need to maintain a separate GAN regex
- **Maintains Consistency**: Automatically inherits validation improvements from SNN and PIN
- **Provides Clear Error Messages**: Component-specific validation failures are more informative
- **Enables Modularity**: Each library maintains its own validation logic

### Component Handling Convention

GAN follows the same internal representation conventions as its constituent libraries:

1. **Style Names**: Always stored with proper capitalization (`:Chess`, `:Shogi`)
2. **Piece Types**: Always stored as uppercase symbols (`:K`, `:P`)
3. **Display Logic**: Case is computed from `side` during string rendering

This ensures predictable behavior and consistency across the entire Sashité ecosystem.

## System Constraints

- **Case Consistency**: SNN and PIN components must have matching case
- **Exactly 2 players**: Distinguished through consistent case encoding
- **Style Assignment**: Fixed throughout a game (first/second player styles remain constant)
- **Component Validation**: Both SNN and PIN components must be individually valid

## Use Cases

GAN is particularly useful for:

1. **Multi-Style Environments**: Positions involving pieces from multiple style traditions
2. **Cross-Style Games**: Games combining elements from different piece traditions
3. **Component Analysis**: Extracting and analyzing style and piece information separately
4. **Game Engine Development**: Engines needing unambiguous piece identification
5. **Database Systems**: Storing game data without naming conflicts
6. **Hybrid Analysis**: Comparing strategic elements across different traditions
7. **Functional Programming**: Immutable game state representations
8. **Format Conversion**: Converting between GAN and individual SNN/PIN representations

## Dependencies

This gem depends on:

- [sashite-snn](https://github.com/sashite/snn.rb) - Style Name Notation implementation
- [sashite-pin](https://github.com/sashite/pin.rb) - Piece Identifier Notation implementation

## Related Specifications

- [GAN Specification v1.0.0](https://sashite.dev/specs/gan/1.0.0/)
- [GAN Examples](https://sashite.dev/specs/gan/1.0.0/examples/)
- [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/)
- [PIN Specification v1.0.0](https://sashite.dev/specs/pin/1.0.0/)
- [Game Protocol Foundation](https://sashite.dev/game-protocol/)

## Documentation

- [API Documentation](https://rubydoc.info/github/sashite/gan.rb/main)
- [SNN Documentation](https://rubydoc.info/github/sashite/snn.rb/main)
- [PIN Documentation](https://rubydoc.info/github/sashite/pin.rb/main)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/gan.rb.git
cd gan.rb

# Install dependencies
bundle install

# Run tests
ruby test.rb

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`ruby test.rb`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
