# Qpi.rb

[![Version](https://img.shields.io/github/v/tag/sashite/qpi.rb?label=Version&logo=github)](https://github.com/sashite/qpi.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/qpi.rb/main)
![Ruby](https://github.com/sashite/qpi.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/qpi.rb?label=License&logo=github)](https://github.com/sashite/qpi.rb/raw/main/LICENSE.md)

> **QPI** (Qualified Piece Identifier) implementation for the Ruby language.

## What is QPI?

QPI (Qualified Piece Identifier) provides a rule-agnostic format for identifying game pieces in abstract strategy board games by combining [Style Identifier Notation (SIN)](https://sashite.dev/specs/sin/1.0.0/) and [Piece Identifier Notation (PIN)](https://sashite.dev/specs/pin/1.0.0/) primitives with a colon separator.

This gem implements the [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) exactly, providing complete piece identification with all four fundamental attributes: **Family**, **Type**, **Side**, and **State**.

## Installation

```ruby
# In your Gemfile
gem "sashite-qpi"
```

Or install manually:

```sh
gem install sashite-qpi
```

## Dependencies

QPI builds upon two foundational primitive specifications:

```ruby
gem "sashite-sin"  # Style Identifier Notation
gem "sashite-pin"  # Piece Identifier Notation
```

## Usage

### Basic Operations

```ruby
require "sashite/qpi"

# Parse QPI strings
identifier = Sashite::Qpi.parse("C:K")         # Chess king, first player
identifier.to_s                                # => "C:K"

# Create identifiers from parameters (strict validation)
identifier = Sashite::Qpi.identifier(:C, :K, :first, :normal)
identifier = Sashite::Qpi::Identifier.new(:S, :R, :first, :enhanced)

# Validate QPI strings
Sashite::Qpi.valid?("C:K")                    # => true
Sashite::Qpi.valid?("s:+p")                   # => true
Sashite::Qpi.valid?("C:k")                    # => false (semantic mismatch)
```

### Strict Parameter Validation

**Important**: QPI enforces the same strict validation as its underlying SIN and PIN primitives:

```ruby
# ✓ Valid - uppercase symbols only for family and type parameters
Sashite::Qpi.identifier(:C, :K, :first, :normal)   # => "C:K"
Sashite::Qpi.identifier(:C, :K, :second, :normal)  # => "c:k"

# ✗ Invalid - lowercase symbols rejected with ArgumentError
Sashite::Qpi.identifier(:c, :K, :first, :normal)   # => ArgumentError
Sashite::Qpi.identifier(:C, :k, :first, :normal)   # => ArgumentError
```

**Key principle**: Input parameters must use uppercase symbols (`:A` to `:Z`). The `side` parameter determines the display case, not the input case.

### Attribute Access

```ruby
identifier = Sashite::Qpi.parse("S:+R")

# Four fundamental piece attributes
identifier.family                             # => :S
identifier.type                               # => :R
identifier.side                               # => :first
identifier.state                              # => :enhanced

# Component extraction
identifier.to_sin                             # => "S"
identifier.to_pin                             # => "+R"
identifier.sin_component                      # => #<Sashite::Sin::Identifier>
identifier.pin_component                      # => #<Sashite::Pin::Identifier>
```

### Transformations

```ruby
# All transformations return new immutable instances
identifier = Sashite::Qpi.parse("C:K")

# State transformations
enhanced = identifier.enhance                       # => "C:+K"
diminished = identifier.diminish                    # => "C:-K"
normalized = identifier.normalize                   # => "C:K"

# Attribute transformations
different_type = identifier.with_type(:Q)           # => "C:Q"
different_side = identifier.with_side(:second)      # => "c:k"
different_state = identifier.with_state(:enhanced)  # => "C:+K"
different_family = identifier.with_family(:S)       # => "S:K"

# Player assignment flip
flipped = identifier.flip # => "c:k"

# Chain transformations
result = identifier.flip.enhance.with_type(:Q) # => "c:+q"
```

### State and Comparison Queries

```ruby
identifier = Sashite::Qpi.parse("S:+P")

# State queries
identifier.normal?                             # => false
identifier.enhanced?                           # => true
identifier.diminished?                         # => false
identifier.first_player?                       # => true
identifier.second_player?                      # => false

# Comparison methods
other = Sashite::Qpi.parse("C:+P")
identifier.same_family?(other)                # => false (S vs C)
identifier.same_type?(other)                  # => true (both P)
identifier.same_side?(other)                  # => true (both first player)
identifier.same_state?(other)                 # => true (both enhanced)
identifier.cross_family?(other)               # => true (different families)
```

## API Reference

### Main Module Methods

- `Sashite::Qpi.parse(qpi_string)` - Parse QPI string into Identifier object
- `Sashite::Qpi.identifier(family, type, side, state = :normal)` - Create identifier from parameters (strict validation)
- `Sashite::Qpi.valid?(qpi_string)` - Check if string is valid QPI notation

### Identifier Class

#### Creation and Parsing
- `Sashite::Qpi::Identifier.new(family, type, side, state = :normal)` - Create from parameters (strict validation)
- `Sashite::Qpi::Identifier.parse(qpi_string)` - Parse QPI string

#### Parameter Validation
**Strict validation enforced**:
- `family` parameter: Must be symbol `:A` to `:Z` (uppercase only)
- `type` parameter: Must be symbol `:A` to `:Z` (uppercase only)
- `side` parameter: Must be `:first` or `:second`
- `state` parameter: Must be `:normal`, `:enhanced`, or `:diminished`

#### Attribute Access
- `#family` - Get style family (symbol `:A` to `:Z`)
- `#type` - Get piece type (symbol `:A` to `:Z`)
- `#side` - Get player side (`:first` or `:second`)
- `#state` - Get piece state (`:normal`, `:enhanced`, or `:diminished`)
- `#to_s` - Convert to QPI string representation

#### Component Access
- `#to_sin` - Get SIN string representation
- `#to_pin` - Get PIN string representation
- `#sin_component` - Get SIN identifier object
- `#pin_component` - Get PIN identifier object

#### State Queries
- `#normal?` - Check if normal state
- `#enhanced?` - Check if enhanced state
- `#diminished?` - Check if diminished state
- `#first_player?` - Check if first player
- `#second_player?` - Check if second player

#### Transformations (immutable - return new instances)
- `#enhance` - Create enhanced version
- `#diminish` - Create diminished version
- `#normalize` - Remove state modifiers
- `#with_type(new_type)` - Change piece type
- `#with_side(new_side)` - Change player side
- `#with_state(new_state)` - Change piece state
- `#with_family(new_family)` - Change style family
- `#flip` - Switch player assignment for both components

#### Comparison Methods
- `#same_family?(other)` - Check if same style family
- `#same_type?(other)` - Check if same piece type
- `#same_side?(other)` - Check if same player side
- `#same_state?(other)` - Check if same piece state
- `#cross_family?(other)` - Check if different style families
- `#==(other)` - Full equality comparison

## Format Specification

### Structure
```
<sin>:<pin>
```

### Grammar (BNF)
```bnf
<qpi> ::= <uppercase-qpi> | <lowercase-qpi>
<uppercase-qpi> ::= <uppercase-letter> ":" <uppercase-pin>
<lowercase-qpi> ::= <lowercase-letter> ":" <lowercase-pin>
<uppercase-pin> ::= ["+" | "-"] <uppercase-letter>
<lowercase-pin> ::= ["+" | "-"] <lowercase-letter>
```

### Regular Expression
```ruby
/\A([A-Z]:[-+]?[A-Z]|[a-z]:[-+]?[a-z])\z/
```

### Examples

- `C:K` - Chess-style king, first player
- `c:k` - Chess-style king, second player
- `S:+R` - Shogi-style enhanced rook, first player
- `x:-s` - Xiangqi-style diminished soldier, second player

## Semantic Consistency

QPI enforces semantic consistency: the style and piece components must represent the same player. Both components use case to indicate player assignment, and these must align.

**Valid combinations:**
```ruby
Sashite::Qpi.valid?("C:K")    # => true (both first player)
Sashite::Qpi.valid?("c:k")    # => true (both second player)
```

**Invalid combinations:**
```ruby
Sashite::Qpi.valid?("C:k")    # => false (family=first, piece=second)
Sashite::Qpi.valid?("c:K")    # => false (family=second, piece=first)
```

## Parameter Validation

### Strict Validation Rules

QPI enforces strict parameter validation consistent with its underlying SIN and PIN primitives:

```ruby
# ✓ Valid parameter examples
Sashite::Qpi.identifier(:C, :K, :first, :normal)     # All uppercase symbols
Sashite::Qpi.identifier(:S, :R, :second, :enhanced)  # Display case determined by side

# ✗ Invalid parameter examples (raise ArgumentError)
Sashite::Qpi.identifier(:c, :K, :first, :normal)     # Lowercase family rejected
Sashite::Qpi.identifier(:C, :k, :first, :normal)     # Lowercase type rejected
Sashite::Qpi.identifier("C", :K, :first, :normal)    # String family rejected
Sashite::Qpi.identifier(:C, "K", :first, :normal)    # String type rejected
```

### Error Handling

QPI delegates validation to its underlying primitives, ensuring consistent error messages:

```ruby
begin
  Sashite::Qpi.identifier(:c, :K, :first, :normal)
rescue ArgumentError => e
  # Same error message as Sashite::Sin::Identifier.new(:c, :first)
  puts e.message # => "Family must be a symbol from :A to :Z representing Style Family, got: :c"
end

begin
  Sashite::Qpi.identifier(:C, :k, :first, :normal)
rescue ArgumentError => e
  # Same error message as Sashite::Pin::Identifier.new(:k, :first, :normal)
  puts e.message # => "Type must be a symbol from :A to :Z, got: :k"
end
```

## Design Properties

- **Rule-agnostic**: Independent of specific game mechanics
- **Complete identification**: All four piece attributes represented
- **Cross-style support**: Enables multi-tradition gaming
- **Semantic validation**: Ensures component consistency
- **Primitive foundation**: Built from SIN and PIN specifications
- **Strict validation**: Consistent parameter validation with underlying primitives
- **Immutable**: All instances frozen, transformations return new objects
- **Functional**: Pure functions with no side effects

## Related Specifications

- [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) - Complete technical specification
- [QPI Examples](https://sashite.dev/specs/qpi/1.0.0/examples/) - Practical implementation examples
- [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/) - Style identification component
- [PIN Specification v1.0.0](https://sashite.dev/specs/pin/1.0.0/) - Piece identification component
- [Sashité Protocol](https://sashite.dev/protocol/) - Conceptual foundation

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
