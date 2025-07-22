# Qpi.rb

[![Version](https://img.shields.io/github/v/tag/sashite/qpi.rb?label=Version&logo=github)](https://github.com/sashite/qpi.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/qpi.rb/main)
![Ruby](https://github.com/sashite/qpi.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/qpi.rb?label=License&logo=github)](https://github.com/sashite/qpi.rb/raw/main/LICENSE.md)

> **QPI** (Qualified Piece Identifier) implementation for the Ruby language.

## What is QPI?

QPI (Qualified Piece Identifier) provides a rule-agnostic format for identifying game pieces in abstract strategy board games by combining [Style Identifier Notation (SIN)](https://sashite.dev/specs/sin/1.0.0/) and [Piece Identifier Notation (PIN)](https://sashite.dev/specs/pin/1.0.0/) with a colon separator.

QPI represents **all four fundamental piece attributes** from the [Sashité Protocol](https://sashite.dev/protocol/):

- **Type** → PIN component (ASCII letter choice)
- **Side** → PIN component (letter case)
- **State** → PIN component (optional prefix modifier)
- **Style** → SIN component (style identifier)

Unlike [Extended Piece Identifier Notation (EPIN)](https://sashite.dev/specs/epin/1.0.0/) which uses derivation markers, QPI explicitly names the style for unambiguous identification.

This gem implements the [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/), providing a modern Ruby interface with immutable identifier objects and functional programming principles.

## Installation

```ruby
# In your Gemfile
gem "sashite-qpi"
```

Or install manually:

```sh
gem install sashite-qpi
```

## Usage

### Basic Operations

```ruby
require "sashite/qpi"

# Parse QPI strings into identifier objects
identifier = Sashite::Qpi.parse("C:K")         # => #<Qpi::Identifier sin=:C pin=:K>
identifier.to_s                                # => "C:K"
identifier.sin                                 # => :C
identifier.pin                                 # => :K
identifier.style                               # => :C
identifier.type                                # => :K
identifier.side                                # => :first
identifier.state                               # => :normal

# Create identifiers directly
identifier = Sashite::Qpi.identifier("C", "K")              # => #<Qpi::Identifier sin=:C pin=:K>
identifier = Sashite::Qpi::Identifier.new("S", "+R")        # => #<Qpi::Identifier sin=:S pin=:+R>

# Validate QPI strings
Sashite::Qpi.valid?("C:K")                    # => true
Sashite::Qpi.valid?("s:+p")                   # => true
Sashite::Qpi.valid?("invalid")                # => false
Sashite::Qpi.valid?("C:k")                    # => false (semantic mismatch)

# Access all four piece attributes
chess_king = Sashite::Qpi.parse("C:K")
chess_king.type                                # => :K
chess_king.side                                # => :first
chess_king.state                               # => :normal
chess_king.style                               # => :C

shogi_promoted = Sashite::Qpi.parse("s:+r")
shogi_promoted.type                            # => :R
shogi_promoted.side                            # => :second
shogi_promoted.state                           # => :enhanced
shogi_promoted.style                           # => :s

# Extract individual components
chess_king.to_sin                              # => "C"
chess_king.to_pin                              # => "K"
shogi_promoted.to_sin                          # => "s"
shogi_promoted.to_pin                          # => "+r"
```

### Single-Style Games

```ruby
# Western Chess
white_king = Sashite::Qpi.parse("C:K")        # Chess king, first player
black_queen = Sashite::Qpi.parse("c:q")       # Chess queen, second player
castling_rook = Sashite::Qpi.parse("C:+R")    # Chess rook, castling eligible

# Japanese Shōgi
sente_king = Sashite::Qpi.parse("S:K")        # Shōgi king, sente
gote_promoted_rook = Sashite::Qpi.parse("s:+r") # Shōgi dragon king, gote
promoted_pawn = Sashite::Qpi.parse("S:+P")    # Shōgi tokin, sente

# Chinese Xiangqi
red_general = Sashite::Qpi.parse("X:G")       # Xiangqi general, red
black_cannon = Sashite::Qpi.parse("x:c")      # Xiangqi cannon, black
```

### Cross-Style Scenarios

```ruby
# Chess vs. Shōgi match
chess_player = Sashite::Qpi.parse("C:K")      # First player uses Chess
shogi_player = Sashite::Qpi.parse("s:k")      # Second player uses Shōgi

# Ōgi vs. Makruk match
ogi_king = Sashite::Qpi.parse("O:K")          # First player uses Ōgi
makruk_queen = Sashite::Qpi.parse("m:m")      # Second player uses Makruk

# Verify cross-style combinations
chess_player.cross_style?(shogi_player)       # => true
chess_player.same_style?(shogi_player)        # => false
```

### Identifier Transformations

```ruby
# All transformations return new immutable instances
identifier = Sashite::Qpi.parse("C:K")

# Transform PIN component (piece attributes)
enhanced = identifier.enhance                  # => "C:+K"
different_type = identifier.with_type(:Q)     # => "C:Q"
flipped_side = identifier.flip_side           # => "c:k"

# Transform SIN component (style)
different_style = identifier.with_style(:S)   # => "S:K"
flipped_style = identifier.flip_style         # => "c:K"

# Chain transformations
result = identifier.flip_style.enhance.with_type(:Q)  # => "c:+Q"

# Original identifier remains unchanged
identifier.to_s                               # => "C:K"
```

### Component Extraction

QPI provides methods to extract individual notation components:

```ruby
# Extract and manipulate components
identifier = Sashite::Qpi.parse("S:+P")

# Component extraction
style_str = identifier.to_sin               # => "S"
piece_str = identifier.to_pin               # => "+P"

# Reconstruct from components
reconstructed = "#{style_str}:#{piece_str}" # => "S:+P"

# Cross-component analysis
identifiers = [
  Sashite::Qpi.parse("C:K"),
  Sashite::Qpi.parse("S:K"),
  Sashite::Qpi.parse("c:k")
]

# Group by style component
by_style = identifiers.group_by(&:to_sin)
# => {"C" => [...], "S" => [...], "c" => [...]}

# Group by piece component
by_piece = identifiers.group_by(&:to_pin)
# => {"K" => [...], "k" => [...]}

# Component-based filtering
uppercase_styles = identifiers.select { |i| i.to_sin == i.to_sin.upcase }
enhanced_pieces = identifiers.select { |i| i.to_pin.start_with?("+") }
```

### Validation and Constraints

```ruby
# Semantic validation - style and side must match
Sashite::Qpi.valid?("C:K")                    # => true (first player Chess with first player piece)
Sashite::Qpi.valid?("c:k")                    # => true (second player Chess with second player piece)
Sashite::Qpi.valid?("C:k")                    # => false (first player Chess with second player piece)
Sashite::Qpi.valid?("c:K")                    # => false (second player Chess with first player piece)

# Syntactic validation
Sashite::Qpi.valid?("C:")                     # => false (missing PIN)
Sashite::Qpi.valid?(":K")                     # => false (missing SIN)
Sashite::Qpi.valid?("CC:K")                   # => false (invalid SIN)
Sashite::Qpi.valid?("C:KK")                   # => false (invalid PIN)
```

#### Modular Validation Architecture

QPI validation delegates to the underlying components for maximum consistency:

```ruby
# QPI validation follows a three-step process:
# 1. Component Splitting: QPI strings are split on the colon separator
# 2. Individual Validation: Each component validated using its specific pattern:
#    - SIN component: Uses Sashite::Sin::Identifier::SIN_PATTERN
#    - PIN component: Uses Sashite::Pin::Identifier::PIN_PATTERN
# 3. Cross-Reference Constraint: Ensures matching player assignment

# This modular approach:
# - Avoids Code Duplication: No separate QPI regex needed
# - Maintains Consistency: Inherits validation improvements from SIN and PIN
# - Provides Clear Error Messages: Component-specific failures are informative
# - Enables Modularity: Each library maintains its own validation logic

def demonstrate_validation_delegation
  qpi_string = "C:+K"

  # QPI splits and delegates validation
  sin_part, pin_part = qpi_string.split(':')

  sin_valid = Sashite::Sin.valid?(sin_part)    # => true
  pin_valid = Sashite::Pin.valid?(pin_part)    # => true

  # Plus semantic consistency check
  sin_side = sin_part == sin_part.upcase ? :first : :second
  pin_side = pin_part.match(/[A-Z]/) ? :first : :second
  sides_match = sin_side == pin_side           # => true

  overall_valid = sin_valid && pin_valid && sides_match

  puts "SIN valid: #{sin_valid}, PIN valid: #{pin_valid}, Sides match: #{sides_match}"
  puts "Overall valid: #{overall_valid}"
end
```

## Format Specification

### Structure
```
<sin>:<pin>
```

### Grammar (BNF)
```bnf
<qpi> ::= <uppercase-qpi> | <lowercase-qpi>

<uppercase-qpi> ::= <uppercase-letter> <colon> <uppercase-pin>
<lowercase-qpi> ::= <lowercase-letter> <colon> <lowercase-pin>

<colon> ::= ":"

<uppercase-pin> ::= <uppercase-letter> | <state-modifier> <uppercase-letter>
<lowercase-pin> ::= <lowercase-letter> | <state-modifier> <lowercase-letter>

<state-modifier> ::= "+" | "-"
<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
```

### Regular Expression
```ruby
/\A([A-Z]:[-+]?[A-Z]|[a-z]:[-+]?[a-z])\z/
```

### Component Mapping

| Piece Attribute | QPI Encoding | Examples |
|-------------------|--------------|----------|
| **Type** | PIN letter choice | `C:K` = King, `C:P` = Pawn |
| **Side** | PIN case | `C:K` = First player, `c:k` = Second player |
| **State** | PIN prefix modifier | `S:+P` = Enhanced, `C:-P` = Diminished |
| **Style** | SIN identifier | `C:K` = Chess style, `S:K` = Shōgi style |

## API Reference

### Main Module Methods

- `Sashite::Qpi.valid?(qpi_string)` - Check if string is valid QPI notation
- `Sashite::Qpi.parse(qpi_string)` - Parse QPI string into Identifier object
- `Sashite::Qpi.identifier(sin, pin)` - Create identifier instance from components

### Identifier Class

#### Creation and Parsing
- `Sashite::Qpi::Identifier.new(sin, pin)` - Create identifier from SIN and PIN strings
- `Sashite::Qpi::Identifier.parse(qpi_string)` - Parse QPI string

#### Attribute Access
- `#sin` - Get SIN component (style identifier as symbol)
- `#pin` - Get PIN component (piece identifier as symbol)
- `#style` - Get style (alias for #sin)
- `#type` - Get piece type (from PIN component)
- `#side` - Get player side (from PIN component)
- `#state` - Get piece state (from PIN component)
- `#to_s` - Convert to QPI string representation
- `#to_sin` - Convert to SIN string representation (style component only)
- `#to_pin` - Convert to PIN string representation (piece component only)

#### Component Access
- `#sin_component` - Get parsed SIN identifier object
- `#pin_component` - Get parsed PIN identifier object

#### Component Extraction

The `to_sin` and `to_pin` methods allow extraction of individual notation components:

```ruby
identifier = Sashite::Qpi.parse("C:+K")

# Full QPI representation
identifier.to_s # => "C:+K"

# Individual components
identifier.to_sin    # => "C"  (style component)
identifier.to_pin    # => "+K" (piece component)

# Component transformation example
flipped = identifier.flip
flipped.to_s         # => "c:+k"
flipped.to_sin       # => "c"  (lowercase for second player)
flipped.to_pin       # => "+k" (lowercase with state preserved)

# State manipulation example
normalized = identifier.normalize
normalized.to_s      # => "C:K"
normalized.to_sin    # => "C"  (style unchanged)
normalized.to_pin    # => "K"  (state modifier removed)
```

#### Validation Queries
- `#valid?` - Check if identifier has semantic consistency
- `#same_style?(other)` - Check if same style
- `#cross_style?(other)` - Check if different styles
- `#same_side?(other)` - Check if same side
- `#same_type?(other)` - Check if same type
- `#same_state?(other)` - Check if same state

#### Transformations (immutable - return new instances)

**PIN Component Transformations:**
- `#enhance` - Create enhanced version
- `#diminish` - Create diminished version
- `#normalize` - Remove all state modifiers
- `#with_type(new_type)` - Change piece type
- `#flip_side` - Switch player side

**SIN Component Transformations:**
- `#with_style(new_style)` - Change style
- `#flip_style` - Switch style player assignment

**Combined Transformations:**
- `#flip` - Flip both style and side assignments
- `#with_components(sin, pin)` - Create with different components

#### State Queries
- `#normal?` - Check if normal state
- `#enhanced?` - Check if enhanced state
- `#diminished?` - Check if diminished state
- `#first_player?` - Check if first player piece
- `#second_player?` - Check if second player piece

## Advanced Usage

### Component Extraction and Manipulation

The `to_sin` and `to_pin` methods enable powerful component-based operations:

```ruby
# Extract and manipulate components
identifier = Sashite::Qpi.parse("S:+P")

# Component extraction
style_str = identifier.to_sin    # => "S"
piece_str = identifier.to_pin    # => "+P"

# Reconstruct from components
reconstructed = "#{style_str}:#{piece_str}" # => "S:+P"

# Cross-component analysis
identifiers = [
  Sashite::Qpi.parse("C:K"),
  Sashite::Qpi.parse("S:K"),
  Sashite::Qpi.parse("c:k")
]

# Group by style component
by_style = identifiers.group_by(&:to_sin)
# => {"C" => [...], "S" => [...], "c" => [...]}

# Group by piece component
by_piece = identifiers.group_by(&:to_pin)
# => {"K" => [...], "k" => [...]}

# Component-based filtering
uppercase_styles = identifiers.select { |i| i.to_sin == i.to_sin.upcase }
enhanced_pieces = identifiers.select { |i| i.to_pin.start_with?("+") }
```

### Component Reconstruction Patterns

```ruby
# Template-based reconstruction
def apply_style_template(identifiers, new_style)
  identifiers.map do |identifier|
    pin_part = identifier.to_pin
    side = identifier.side

    # Apply new style while preserving piece and side
    new_style_str = side == :first ? new_style.to_s.upcase : new_style.to_s.downcase
    Sashite::Qpi.parse("#{new_style_str}:#{pin_part}")
  end
end

# Convert chess pieces to shōgi style
chess_pieces = [
  Sashite::Qpi.parse("C:K"),
  Sashite::Qpi.parse("c:+q")
]

shogi_pieces = apply_style_template(chess_pieces, :S)
# => [S:K, s:+q]

# Component swapping
def swap_components(identifier1, identifier2)
  [
    Sashite::Qpi.parse("#{identifier1.to_sin}:#{identifier2.to_pin}"),
    Sashite::Qpi.parse("#{identifier2.to_sin}:#{identifier1.to_pin}")
  ]
end

chess_king = Sashite::Qpi.parse("C:K")
shogi_pawn = Sashite::Qpi.parse("s:p")

swapped = swap_components(chess_king, shogi_pawn)
# => [C:p, s:K]
```

### Cross-Style Game Management

```ruby
class CrossStyleMatch
  def initialize
    @pieces = {}
  end

  def place(square, qpi_string)
    identifier = Sashite::Qpi.parse(qpi_string)
    @pieces[square] = identifier
  end

  def pieces_by_style(style)
    @pieces.select { |_, piece| piece.style.to_s.upcase == style.to_s.upcase }
  end

  def cross_style_pieces
    styles = @pieces.values.map { |p| p.style.to_s.upcase }.uniq
    styles.size > 1
  end

  def promote(square, new_type = :Q)
    piece = @pieces[square]
    return nil unless piece&.normal?

    @pieces[square] = piece.with_type(new_type).enhance
  end
end

# Usage
match = CrossStyleMatch.new
match.place("e1", "C:K")    # Chess king
match.place("e8", "s:k")    # Shōgi king
match.place("a1", "C:R")    # Chess rook
match.place("a9", "s:l")    # Shōgi lance

chess_pieces = match.pieces_by_style(:C)
shogi_pieces = match.pieces_by_style(:S)

puts "Cross-style match: #{match.cross_style_pieces}" # => true
puts "Chess pieces: #{chess_pieces.size}"             # => 2
puts "Shōgi pieces: #{shogi_pieces.size}"             # => 2
```

### Capture Mechanics Simulation

```ruby
def simulate_capture(attacker_qpi, defender_qpi, game_rules)
  attacker = Sashite::Qpi.parse(attacker_qpi)
  defender = Sashite::Qpi.parse(defender_qpi)

  case game_rules
  when :chess
    # Chess: captured piece becomes inactive
    captured = defender  # Piece retains identity but becomes inactive

  when :shogi
    # Shōgi: captured piece changes side and loses promotion
    captured = defender.flip_side.normalize

  when :ogi_transformation
    # Ōgi: captured piece transforms completely
    captured = attacker.with_type(:P).normalize  # Becomes pawn of capturing side

  else
    captured = defender
  end

  {
    original: defender.to_s,
    captured: captured.to_s,
    attacker_style: attacker.style,
    transformation: defender.to_s != captured.to_s
  }
end

# Chess capture
chess_result = simulate_capture("C:Q", "c:p", :chess)
puts chess_result  # => { original: "c:p", captured: "c:p", ... }

# Shōgi capture
shogi_result = simulate_capture("S:R", "s:+p", :shogi)
puts shogi_result  # => { original: "s:+p", captured: "S:P", ... }

# Ōgi transformation
ogi_result = simulate_capture("O:K", "c:q", :ogi_transformation)
puts ogi_result    # => { original: "c:q", captured: "O:P", ... }
```

### Piece Analysis

```ruby
def analyze_position(qpi_strings)
  pieces = qpi_strings.map { |qpi| Sashite::Qpi.parse(qpi) }

  {
    total: pieces.size,
    by_style: pieces.group_by(&:style),
    by_side: pieces.group_by(&:side),
    by_type: pieces.group_by(&:type),
    by_state: pieces.group_by(&:state),
    cross_style: pieces.map(&:style).uniq.size > 1,
    promoted: pieces.count(&:enhanced?),
    weakened: pieces.count(&:diminished?)
  }
end

position = %w[C:K C:Q C:+R c:k c:q s:+r S:G s:+p]
analysis = analyze_position(position)

puts "Cross-style position: #{analysis[:cross_style]}"  # => true
puts "Styles present: #{analysis[:by_style].keys}"     # => [:C, :c, :s, :S]
puts "Promoted pieces: #{analysis[:promoted]}"         # => 3
```

### Validation Patterns

```ruby
class QpiValidator
  def self.validate_match_consistency(qpi_strings)
    pieces = qpi_strings.map { |qpi| Sashite::Qpi.parse(qpi) }
    errors = []

    # Check for semantic consistency
    pieces.each do |piece|
      unless piece.valid?
        errors << "Invalid piece: #{piece}"
      end
    end

    # Check for duplicate pieces at same location (if positions provided)
    # Check for impossible combinations, etc.

    errors.empty? ? :valid : errors
  end

  def self.cross_style_rules_check(qpi1, qpi2)
    piece1 = Sashite::Qpi.parse(qpi1)
    piece2 = Sashite::Qpi.parse(qpi2)

    {
      same_style: piece1.same_style?(piece2),
      cross_style: piece1.cross_style?(piece2),
      compatible_interaction: compatible_styles?(piece1.style, piece2.style)
    }
  end

  private

  def self.compatible_styles?(style1, style2)
    # Implementation depends on game rules
    # This is a placeholder for actual compatibility logic
    true
  end
end
```

## System Constraints

- **Semantic Consistency**: SIN and PIN components must have matching player assignments
- **Component Independence**: Each component validated according to its own specification
- **Cross-Style Support**: Enables multi-tradition gaming environments
- **Complete Attribute Coverage**: All four fundamental piece attributes represented

## Use Cases

QPI is particularly useful for:

1. **Multi-Style Environments**: Positions involving pieces from multiple style traditions
2. **Cross-Style Games**: Games combining elements from different piece traditions
3. **Component Analysis**: Extracting and analyzing style and piece information separately using `to_sin` and `to_pin`
4. **Game Engine Development**: Engines needing unambiguous piece identification
5. **Database Systems**: Storing game data without naming conflicts
6. **Hybrid Analysis**: Comparing strategic elements across different traditions
7. **Functional Programming**: Immutable game state representations
8. **Format Conversion**: Converting between QPI and individual SIN/PIN representations
9. **Validation Systems**: Leveraging modular validation for robust error checking

## Component Dependencies

QPI builds upon two foundational specifications:

- [SIN (Style Identifier Notation)](https://sashite.dev/specs/sin/1.0.0/): Style identification with player assignment
- [PIN (Piece Identifier Notation)](https://sashite.dev/specs/pin/1.0.0/): Piece type, side, and state representation

Both dependencies are automatically managed:

```ruby
# Dependencies are resolved automatically
qpi = Sashite::Qpi.parse("C:+K")

# Access underlying components
sin_component = qpi.sin_component  # => Sashite::Sin::Identifier instance
pin_component = qpi.pin_component  # => Sashite::Pin::Identifier instance

# Component methods are available
sin_component.first_player?        # => true
pin_component.enhanced?            # => true
```

## Design Properties

- **Rule-Agnostic**: Independent of specific game mechanics
- **Complete Identification**: Explicit representation of all four piece attributes
- **Cross-Style Support**: Enables multi-tradition gaming environments
- **Component Clarity**: Clear separation between style context and piece identity
- **Component Extraction**: Individual SIN and PIN components accessible via `to_sin` and `to_pin`
- **Semantic Validation**: Ensures consistency between style and piece ownership
- **Modular Validation**: Delegates validation to underlying components for consistency
- **Immutable**: All instances are frozen and transformations return new objects
- **Functional**: Pure functions with no side effects

## Implementation Notes

### Validation Architecture

QPI follows a modular validation approach that leverages the underlying component libraries:

1. **Component Splitting**: QPI strings are split on the colon separator
2. **Individual Validation**: Each component is validated using its specific pattern:
   - SIN component: `Sashite::Sin::Identifier::SIN_PATTERN`
   - PIN component: `Sashite::Pin::Identifier::PIN_PATTERN`
3. **Cross-Reference Constraint**: Additional validation ensures matching player assignment between components

This approach:
- **Avoids Code Duplication**: No need to maintain a separate QPI regex
- **Maintains Consistency**: Automatically inherits validation improvements from SIN and PIN
- **Provides Clear Error Messages**: Component-specific validation failures are more informative
- **Enables Modularity**: Each library maintains its own validation logic

```ruby
# Example of validation delegation in practice
qpi_string = "C:+K"

# QPI internally splits and validates each component
sin_part, pin_part = qpi_string.split(':')

# Delegates to component validation
sin_valid = Sashite::Sin.valid?(sin_part)    # => true
pin_valid = Sashite::Pin.valid?(pin_part)    # => true

# Plus semantic consistency check
sin_identifier = Sashite::Sin.parse(sin_part)
pin_identifier = Sashite::Pin.parse(pin_part)
sides_match = sin_identifier.side == pin_identifier.side  # => true

overall_valid = sin_valid && pin_valid && sides_match
```

### Component Handling Convention

QPI follows the same internal representation conventions as its constituent libraries:

1. **Style Letters**: Stored as symbols with case preserved (`:C`, `:c`, `:S`, `:s`)
2. **Piece Types**: Always stored as uppercase symbols (`:K`, `:P`)
3. **Display Logic**: Case is computed from `side` during string rendering

This ensures predictable behavior and consistency across the entire Sashité ecosystem.

## Related Specifications

- [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) - Complete technical specification
- [QPI Examples](https://sashite.dev/specs/qpi/1.0.0/examples/) - Practical implementation examples
- [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/) - Style identification component
- [PIN Specification v1.0.0](https://sashite.dev/specs/pin/1.0.0/) - Piece identification component
- [EPIN Specification v1.0.0](https://sashite.dev/specs/epin/1.0.0/) - Alternative with derivation markers
- [Sashité Protocol](https://sashite.dev/protocol/) - Conceptual foundation for abstract strategy board games

## Documentation

- [Official QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/)
- [QPI Examples Documentation](https://sashite.dev/specs/qpi/1.0.0/examples/)
- [Sashité Protocol Foundation](https://sashite.dev/protocol/)
- [API Documentation](https://rubydoc.info/github/sashite/qpi.rb/main)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/qpi.rb.git
cd qpi.rb

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
