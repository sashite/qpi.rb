# Qpi.rb

[![Version](https://img.shields.io/github/v/tag/sashite/qpi.rb?label=Version&logo=github)](https://github.com/sashite/qpi.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/qpi.rb/main)
![Ruby](https://github.com/sashite/qpi.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/qpi.rb?label=License&logo=github)](https://github.com/sashite/qpi.rb/raw/main/LICENSE.md)

> **QPI** (Qualified Piece Identifier) implementation for the Ruby language.

## What is QPI?

QPI (Qualified Piece Identifier) provides complete piece identification by combining two primitive notations:
- [SIN](https://sashite.dev/specs/sin/1.0.0/) (Style Identifier Notation) — identifies the piece style
- [PIN](https://sashite.dev/specs/pin/1.0.0/) (Piece Identifier Notation) — identifies the piece attributes

A QPI identifier is simply a **pair of (SIN, PIN)** with one constraint: both components must represent the same player.

This gem implements the [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) with a minimal compositional API.

## Core Concept

```ruby
# QPI is just composition
qpi = Sashite::Qpi.new(sin_component, pin_component)

# Serializes as "sin:pin"
qpi.to_s # => "C:K^"

# Access components directly
qpi.sin   # => SIN::Identifier instance
qpi.pin   # => PIN::Identifier instance
```

**That's it.** All piece attributes come from the components.

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

```ruby
gem "sashite-sin"  # Style Identifier Notation
gem "sashite-pin"  # Piece Identifier Notation
```

## Quick Start

```ruby
require "sashite/qpi"

# Parse a QPI string
qpi = Sashite::Qpi.parse("C:K^")
qpi.to_s # => "C:K^"

# Access the five fundamental attributes through components
qpi.sin.family        # => :C (Piece Style)
qpi.pin.type          # => :K (Piece Name)
qpi.sin.side          # => :first (Piece Side)
qpi.pin.state         # => :normal (Piece State)
qpi.pin.terminal?     # => true (Terminal Status)

# Components are full SIN and PIN instances
qpi.sin.first_player? # => true
qpi.pin.enhanced?     # => false
```

## Basic Usage

### Creating Identifiers

```ruby
# Parse from string
qpi = Sashite::Qpi.parse("C:K^")

# Create from components
sin = Sashite::Sin.parse("C")
pin = Sashite::Pin.parse("K^")
qpi = Sashite::Qpi.new(sin, pin)

# Validate
Sashite::Qpi.valid?("C:K^")   # => true
Sashite::Qpi.valid?("C:k")    # => false (side mismatch)
```

### Accessing Components

```ruby
qpi = Sashite::Qpi.parse("S:+R^")

# Get components
qpi.sin                       # => #<Sin::Identifier family=:S side=:first>
qpi.pin                       # => #<Pin::Identifier type=:R state=:enhanced terminal=true>

# Serialize components
qpi.sin.to_s                  # => "S"
qpi.pin.to_s                  # => "+R^"
qpi.to_s                      # => "S:+R^"
```

### Five Fundamental Attributes

All attributes come directly from the components:

```ruby
qpi = Sashite::Qpi.parse("S:+R^")

# From SIN component
qpi.sin.family                # => :S (Piece Style)
qpi.sin.side                  # => :first (Piece Side)

# From PIN component
qpi.pin.type                  # => :R (Piece Name)
qpi.pin.state                 # => :enhanced (Piece State)
qpi.pin.terminal?             # => true (Terminal Status)
```

## Transformations

All transformations return new immutable QPI instances:

### Replace Components

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Replace SIN component
new_sin = Sashite::Sin.parse("S")
qpi.with_sin(new_sin) # => "S:K^"

# Replace PIN component
new_pin = Sashite::Pin.parse("Q^")
qpi.with_pin(new_pin) # => "C:Q^"

# Transform both
qpi.with_sin(new_sin).with_pin(new_pin) # => "S:Q^"
```

### Flip (Only Convenience Method)

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Flip both components (change player)
qpi.flip # => "c:k^"
```

**Why only `flip`?** It's the only transformation that affects **both** SIN and PIN components simultaneously. All other transformations work through component replacement.

### Transform via Components

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Transform SIN via component
qpi.with_sin(qpi.sin.with_family(:S)) # => "S:K^"

# Transform PIN via component
qpi.with_pin(qpi.pin.with_type(:Q)) # => "C:Q^"
qpi.with_pin(qpi.pin.with_state(:enhanced)) # => "C:+K^"
qpi.with_pin(qpi.pin.with_terminal(false)) # => "C:K"

# Chain transformations
qpi
  .flip
  .with_sin(qpi.sin.with_family(:S))
  .with_pin(qpi.pin.with_type(:Q)) # => "s:q^"
```

## Component Queries

Since QPI is just a composition, use the component APIs directly:

```ruby
qpi = Sashite::Qpi.parse("S:+P^")

# SIN queries (style and side)
qpi.sin.family                # => :S
qpi.sin.side                  # => :first
qpi.sin.first_player?         # => true
qpi.sin.letter                # => "S"

# PIN queries (type, state, terminal)
qpi.pin.type                  # => :P
qpi.pin.state                 # => :enhanced
qpi.pin.terminal?             # => true
qpi.pin.enhanced?             # => true
qpi.pin.letter                # => "P"
qpi.pin.prefix                # => "+"
qpi.pin.suffix                # => "^"

# Compare QPIs
other = Sashite::Qpi.parse("C:+P^")
qpi.sin.same_family?(other.sin)  # => false (S vs C)
qpi.pin.same_type?(other.pin)    # => true (both P)
qpi.sin.same_side?(other.sin)    # => true (both first)
qpi.pin.same_state?(other.pin)   # => true (both enhanced)
```

## API Reference

### Main Module

```ruby
# Parse QPI string
Sashite::Qpi.parse(qpi_string) # => Qpi::Identifier

# Create from components
Sashite::Qpi.new(sin, pin) # => Qpi::Identifier

# Validate string
Sashite::Qpi.valid?(qpi_string) # => Boolean
```

### Identifier Class

#### Core Methods (5 total)

```ruby
# Creation
Sashite::Qpi.new(sin, pin) # Create from components

# Component access
qpi.sin                        # => SIN::Identifier
qpi.pin                        # => PIN::Identifier

# Serialization
qpi.to_s # => "C:K^"

# Component replacement
qpi.with_sin(new_sin)          # New QPI with different SIN
qpi.with_pin(new_pin)          # New QPI with different PIN

# Convenience (transforms both components)
qpi.flip # Flip both SIN and PIN sides
```

#### Equality

```ruby
qpi1 == qpi2 # True if both SIN and PIN equal
```

**That's the entire API.** Everything else uses the component APIs directly.

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

<uppercase-pin> ::= ["+" | "-"] <uppercase-letter> ["^"]
<lowercase-pin> ::= ["+" | "-"] <lowercase-letter> ["^"]
```

### Semantic Constraint

**Critical**: The SIN and PIN components must represent the **same player**:

```ruby
# Valid - both first player
Sashite::Qpi.valid?("C:K")     # => true
Sashite::Qpi.valid?("C:+K^")   # => true

# Valid - both second player
Sashite::Qpi.valid?("c:k")     # => true
Sashite::Qpi.valid?("c:-p^")   # => true

# Invalid - side mismatch
Sashite::Qpi.valid?("C:k")     # => false (first vs second)
Sashite::Qpi.valid?("c:K")     # => false (second vs first)
```

### Regular Expression
```ruby
/\A([A-Z]:[-+]?[A-Z]\^?|[a-z]:[-+]?[a-z]\^?)\z/
```

## Examples

### Basic Identifiers

```ruby
# Chess pieces
chess_king = Sashite::Qpi.parse("C:K^")
chess_king.sin.family         # => :C (Chess style)
chess_king.pin.type           # => :K (King)
chess_king.pin.terminal?      # => true

# Shogi pieces
shogi_rook = Sashite::Qpi.parse("S:+R")
shogi_rook.sin.family         # => :S (Shogi style)
shogi_rook.pin.type           # => :R (Rook)
shogi_rook.pin.enhanced?      # => true (promoted)

# Xiangqi pieces
xiangqi_general = Sashite::Qpi.parse("X:G^")
xiangqi_general.sin.family    # => :X (Xiangqi style)
xiangqi_general.pin.type      # => :G (General)
xiangqi_general.pin.terminal? # => true
```

### Cross-Style Scenarios

```ruby
# Chess vs Shogi match
chess_player = Sashite::Qpi.parse("C:K^")   # First player uses Chess
shogi_player = Sashite::Qpi.parse("s:k^")   # Second player uses Shogi

# Different styles
chess_player.sin.same_family?(shogi_player.sin) # => false

# Same piece type
chess_player.pin.same_type?(shogi_player.pin) # => true (both kings)

# Different players
chess_player.sin.same_side?(shogi_player.sin) # => false
```

### Component Manipulation

```ruby
# Start with Chess king
qpi = Sashite::Qpi.parse("C:K^")

# Change to Shogi style (keep same piece)
shogi_king = qpi.with_sin(qpi.sin.with_family(:S))
shogi_king.to_s # => "S:K^"

# Change to queen (keep same style)
chess_queen = qpi.with_pin(qpi.pin.with_type(:Q))
chess_queen.to_s # => "C:Q^"

# Enhance piece (keep everything else)
enhanced = qpi.with_pin(qpi.pin.with_state(:enhanced))
enhanced.to_s # => "C:+K^"

# Remove terminal marker
non_terminal = qpi.with_pin(qpi.pin.with_terminal(false))
non_terminal.to_s # => "C:K"

# Switch player (flip both components)
opponent = qpi.flip
opponent.to_s # => "c:k^"
```

### Working with Components

```ruby
qpi = Sashite::Qpi.parse("S:+R^")

# Extract and transform SIN
sin = qpi.sin                           # => "S"
new_sin = sin.with_family(:C)           # => "C"
qpi.with_sin(new_sin).to_s              # => "C:+R^"

# Extract and transform PIN
pin = qpi.pin                           # => "+R^"
new_pin = pin.with_type(:B)             # => "+B^"
qpi.with_pin(new_pin).to_s              # => "S:+B^"

# Multiple PIN transformations
new_pin = pin
          .with_type(:Q)
          .with_state(:normal)
          .with_terminal(false)
qpi.with_pin(new_pin).to_s # => "S:Q"

# Create completely new QPI
new_sin = Sashite::Sin.parse("X")
new_pin = Sashite::Pin.parse("G^")
Sashite::Qpi.new(new_sin, new_pin).to_s # => "X:G^"
```

### Immutability

```ruby
original = Sashite::Qpi.parse("C:K^")

# All transformations return new instances
flipped = original.flip
enhanced = original.with_pin(original.pin.with_state(:enhanced))
different = original.with_sin(original.sin.with_family(:S))

# Original unchanged
original.to_s                 # => "C:K^"
flipped.to_s                  # => "c:k^"
enhanced.to_s                 # => "C:+K^"
different.to_s                # => "S:K^"

# Components are also immutable
sin = original.sin
pin = original.pin
sin.frozen?                   # => true
pin.frozen?                   # => true
```

## Attribute Mapping

QPI exposes all five fundamental attributes from the Sashité Game Protocol through component delegation:

| Protocol Attribute | QPI Access | Example |
|-------------------|------------|---------|
| **Piece Style** | `qpi.sin.family` | `:C` (Chess), `:S` (Shogi) |
| **Piece Name** | `qpi.pin.type` | `:K` (King), `:R` (Rook) |
| **Piece Side** | `qpi.sin.side` or `qpi.pin.side` | `:first`, `:second` |
| **Piece State** | `qpi.pin.state` | `:normal`, `:enhanced`, `:diminished` |
| **Terminal Status** | `qpi.pin.terminal?` | `true`, `false` |

**Note**: `qpi.sin.side` and `qpi.pin.side` are always equal (semantic constraint).

## Design Principles

### 1. Pure Composition

QPI doesn't reimplement features — it composes existing primitives:

```ruby
# QPI is just a validated pair
class Identifier
  def initialize(sin, pin)
    raise unless sin.side == pin.side # Only validation

    @sin = sin
    @pin = pin
  end
end
```

### 2. Absolute Minimal API

**5 core methods only:**
1. `new(sin, pin)` — create from components
2. `sin` — get SIN component
3. `pin` — get PIN component
4. `to_s` — serialize
5. `flip` — flip both components (only convenience method)

Everything else uses component APIs directly.

### 3. Component Transparency

Access components directly — no wrappers:

```ruby
# Use component APIs directly
qpi.sin.family
qpi.sin.with_family(:S)
qpi.pin.type
qpi.pin.with_type(:Q)
qpi.pin.with_terminal(true)

# No need for wrapper methods like:
# qpi.family
# qpi.with_family
# qpi.type
# qpi.with_type
# qpi.with_terminal
```

### 4. Single Convenience Method

Only `flip` is provided as a convenience because it's the **only** transformation that naturally operates on both components:

```ruby
# Makes sense as convenience
qpi.flip # Flips both SIN and PIN

# Would be arbitrary conveniences
# qpi.with_family(:S)  # Just use qpi.with_sin(qpi.sin.with_family(:S))
# qpi.with_type(:Q)    # Just use qpi.with_pin(qpi.pin.with_type(:Q))
```

### 5. Immutability

All instances frozen. Transformations return new instances:

```ruby
qpi1 = Sashite::Qpi.parse("C:K^")
qpi2 = qpi1.flip
qpi1.frozen?                  # => true
qpi2.frozen?                  # => true
qpi1.equal?(qpi2)             # => false
```

## Error Handling

```ruby
# Invalid QPI string
begin
  Sashite::Qpi.parse("invalid")
rescue ArgumentError => e
  e.message # => "Invalid QPI string: invalid"
end

# Side mismatch between components
sin = Sashite::Sin.parse("C")   # first player
pin = Sashite::Pin.parse("k")   # second player
begin
  Sashite::Qpi.new(sin, pin)
rescue ArgumentError => e
  e.message # => Semantic consistency error
end

# Component validation errors delegate
begin
  Sashite::Qpi.parse("CC:K")
rescue ArgumentError => e
  # SIN validation error
end
```

## Performance Considerations

### Efficient Composition

```ruby
# Components are created once
sin = Sashite::Sin.parse("C")
pin = Sashite::Pin.parse("K^")
qpi = Sashite::Qpi.new(sin, pin)

# Accessing components is O(1)
qpi.sin         # => direct reference
qpi.pin         # => direct reference

# No overhead from method delegation
qpi.sin.family # => direct method call on component
```

### Transformation Patterns

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Pattern 1: Single component transformation
qpi.with_pin(qpi.pin.with_type(:Q))

# Pattern 2: Multiple transformations on same component
new_pin = qpi.pin
             .with_type(:Q)
             .with_state(:enhanced)
             .with_terminal(false)
qpi.with_pin(new_pin)

# Pattern 3: Transform both components
new_sin = qpi.sin.with_family(:S)
new_pin = qpi.pin.with_type(:R)
Sashite::Qpi.new(new_sin, new_pin)

# Pattern 4: Flip (convenience)
qpi.flip # Most efficient for switching sides
```

## Comparison with Other Approaches

### Why Not More Convenience Methods?

```ruby
# ✗ Arbitrary conveniences
qpi.with_family(:S)    # Why this...
qpi.with_type(:Q)      # ...but not this?
qpi.with_state(:enhanced)  # Where do we stop?
qpi.with_terminal(true)    # All PIN methods?

# ✓ Consistent principle: use components
qpi.with_sin(qpi.sin.with_family(:S))
qpi.with_pin(qpi.pin.with_type(:Q))
qpi.with_pin(qpi.pin.with_state(:enhanced))
qpi.with_pin(qpi.pin.with_terminal(true))

# ✓ Only exception: flip (transforms both)
qpi.flip
```

### Why Composition Over Inheritance?

```ruby
# ✗ Bad: QPI inheriting from PIN
class Qpi < Pin
  # Problem: QPI is not a specialized PIN
end

# ✓ Good: QPI composes SIN and PIN
class Qpi
  def initialize(sin, pin)
    @sin = sin
    @pin = pin
  end
end
```

## Design Properties

- **Rule-agnostic**: Independent of game mechanics
- **Complete identification**: All five protocol attributes
- **Cross-style support**: Multi-tradition games
- **Absolute minimal API**: Only 5 core methods
- **Pure composition**: Zero feature duplication
- **Component transparency**: Direct primitive access
- **Immutable**: Frozen instances
- **Semantic validation**: Automatic side consistency
- **Type-safe**: Full component type preservation
- **Single convenience**: Only `flip` (multi-component operation)

## Related Specifications

- [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/) - Technical specification
- [QPI Examples](https://sashite.dev/specs/qpi/1.0.0/examples/) - Usage examples
- [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/) - Style component
- [PIN Specification v1.0.0](https://sashite.dev/specs/pin/1.0.0/) - Piece component
- [Sashité Game Protocol](https://sashite.dev/game-protocol/) - Foundation

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
