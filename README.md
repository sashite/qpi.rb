# qpi.rb

[![Version](https://img.shields.io/github/v/tag/sashite/qpi.rb?label=Version&logo=github)](https://github.com/sashite/qpi.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/qpi.rb/main)
[![CI](https://github.com/sashite/qpi.rb/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/sashite/qpi.rb/actions)
[![License](https://img.shields.io/github/license/sashite/qpi.rb?label=License&logo=github)](https://github.com/sashite/qpi.rb/raw/main/LICENSE)

> **QPI** (Qualified Piece Identifier) implementation for Ruby.

## Overview

This library implements the [QPI Specification v1.0.0](https://sashite.dev/specs/qpi/1.0.0/).

QPI provides complete piece identification by combining two primitive notations:
- [SIN](https://sashite.dev/specs/sin/1.0.0/) (Style Identifier Notation) — identifies the piece style
- [PIN](https://sashite.dev/specs/pin/1.0.0/) (Piece Identifier Notation) — identifies the piece attributes

A QPI identifier is a **pair of (SIN, PIN)** that encodes complete **Piece Identity**.

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

## Usage

### Parsing (String → Identifier)

Convert a QPI string into an `Identifier` object.

```ruby
require "sashite/qpi"

# Standard parsing (raises on error)
qpi = Sashite::Qpi.parse("C:K^")
qpi.to_s  # => "C:K^"

# Access the five Piece Identity attributes through components
qpi.sin.style      # => :C (Piece Style)
qpi.pin.type       # => :K (Piece Name)
qpi.pin.side       # => :first (Piece Side)
qpi.pin.state      # => :normal (Piece State)
qpi.pin.terminal?  # => true (Terminal Status)

# Components are full SIN and PIN instances
qpi.sin.first_player?  # => true
qpi.pin.enhanced?      # => false

# Invalid input raises ArgumentError
Sashite::Qpi.parse("invalid")  # => raises ArgumentError
```

### Formatting (Identifier → String)

Convert an `Identifier` back to a QPI string.

```ruby
# From components
sin = Sashite::Sin.parse("C")
pin = Sashite::Pin.parse("K^")
qpi = Sashite::Qpi::Identifier.new(sin, pin)
qpi.to_s  # => "C:K^"

# With attributes
sin = Sashite::Sin.parse("s")
pin = Sashite::Pin.parse("+r")
qpi = Sashite::Qpi::Identifier.new(sin, pin)
qpi.to_s  # => "s:+r"
```

### Validation

```ruby
# Boolean check
Sashite::Qpi.valid?("C:K^")     # => true
Sashite::Qpi.valid?("s:+r")     # => true
Sashite::Qpi.valid?("invalid")  # => false
Sashite::Qpi.valid?("C:")       # => false
Sashite::Qpi.valid?(":K")       # => false
```

### Accessing Components

```ruby
qpi = Sashite::Qpi.parse("S:+R^")

# Get components
qpi.sin  # => #<Sashite::Sin::Identifier style=:S side=:first>
qpi.pin  # => #<Sashite::Pin::Identifier type=:R state=:enhanced terminal=true>

# Serialize components
qpi.sin.to_s  # => "S"
qpi.pin.to_s  # => "+R^"
qpi.to_s      # => "S:+R^"
```

### Five Piece Identity Attributes

All attributes come directly from the components:

```ruby
qpi = Sashite::Qpi.parse("S:+R^")

# From SIN component
qpi.sin.style  # => :S (Piece Style)

# From PIN component
qpi.pin.type       # => :R (Piece Name)
qpi.pin.side       # => :first (Piece Side)
qpi.pin.state      # => :enhanced (Piece State)
qpi.pin.terminal?  # => true (Terminal Status)
```

### Native and Derived Relationship

QPI defines a deterministic relationship based on case comparison between SIN and PIN letters.

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Access the relationship
qpi.sin.side  # => :first (derived from SIN letter case)
qpi.native?   # => true (sin.side == pin.side)
qpi.derived?  # => false

# Native: SIN case matches PIN case
Sashite::Qpi.parse("C:K").native?   # => true (both uppercase/first)
Sashite::Qpi.parse("c:k").native?   # => true (both lowercase/second)

# Derived: SIN case differs from PIN case
Sashite::Qpi.parse("C:k").derived?  # => true (uppercase vs lowercase)
Sashite::Qpi.parse("c:K").derived?  # => true (lowercase vs uppercase)
```

### Transformations

All transformations return new immutable instances.

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Replace SIN component
new_sin = Sashite::Sin.parse("S")
qpi.with_sin(new_sin).to_s  # => "S:K^"

# Replace PIN component
new_pin = Sashite::Pin.parse("+Q^")
qpi.with_pin(new_pin).to_s  # => "C:+Q^"

# Transform both
qpi.with_sin(new_sin).with_pin(new_pin).to_s  # => "S:+Q^"

# Flip both components (change player)
qpi.flip.to_s  # => "c:k^"

# Native/Derived transformations
qpi = Sashite::Qpi.parse("C:r")
qpi.native.to_s  # => "C:R" (PIN case aligned with SIN case)
qpi.derive.to_s  # => "C:r" (already derived, unchanged)

qpi = Sashite::Qpi.parse("C:R")
qpi.native.to_s  # => "C:R" (already native, unchanged)
qpi.derive.to_s  # => "C:r" (PIN case differs from SIN case)
```

### Transform via Components

```ruby
qpi = Sashite::Qpi.parse("C:K^")

# Transform SIN via component
qpi.with_sin(qpi.sin.with_style(:S)).to_s  # => "S:K^"

# Transform PIN via component
qpi.with_pin(qpi.pin.with_type(:Q)).to_s          # => "C:Q^"
qpi.with_pin(qpi.pin.with_state(:enhanced)).to_s  # => "C:+K^"
qpi.with_pin(qpi.pin.with_terminal(false)).to_s   # => "C:K"

# Chain transformations
qpi.flip.with_sin(qpi.sin.with_style(:S)).to_s  # => "s:k^"
```

### Component Queries

Since QPI is a composition, use the component APIs directly:

```ruby
qpi = Sashite::Qpi.parse("S:+P^")

# SIN queries (style and side)
qpi.sin.style          # => :S
qpi.sin.side           # => :first
qpi.sin.first_player?  # => true
qpi.sin.letter         # => "S"

# PIN queries (type, state, terminal)
qpi.pin.type       # => :P
qpi.pin.state      # => :enhanced
qpi.pin.terminal?  # => true
qpi.pin.enhanced?  # => true
qpi.pin.letter     # => "P"
qpi.pin.prefix     # => "+"
qpi.pin.suffix     # => "^"

# Compare QPIs via components
other = Sashite::Qpi.parse("C:+P^")
qpi.sin.same_style?(other.sin)  # => false (S vs C)
qpi.pin.same_type?(other.pin)   # => true (both P)
qpi.sin.same_side?(other.sin)   # => true (both first)
qpi.pin.same_state?(other.pin)  # => true (both enhanced)
```

## API Reference

### Types

```ruby
# Identifier represents a parsed QPI with complete Piece Identity.
class Sashite::Qpi::Identifier
  # Creates an Identifier from SIN and PIN components.
  # Raises ArgumentError if components are invalid.
  #
  # @param sin [Sashite::Sin::Identifier] Style component
  # @param pin [Sashite::Pin::Identifier] Piece component
  # @return [Identifier]
  def initialize(sin, pin)

  # Returns the SIN component.
  #
  # @return [Sashite::Sin::Identifier]
  def sin

  # Returns the PIN component.
  #
  # @return [Sashite::Pin::Identifier]
  def pin

  # Returns true if sin.side equals pin.side (Native relationship).
  #
  # @return [Boolean]
  def native?

  # Returns true if sin.side differs from pin.side (Derived relationship).
  #
  # @return [Boolean]
  def derived?

  # Returns the QPI string representation.
  #
  # @return [String]
  def to_s
end
```

### Parsing

```ruby
# Parses a QPI string into an Identifier.
# Raises ArgumentError if the string is not valid.
#
# @param string [String] QPI string
# @return [Identifier]
# @raise [ArgumentError] if invalid
def Sashite::Qpi.parse(string)
```

### Validation

```ruby
# Reports whether string is a valid QPI.
#
# @param string [String] QPI string
# @return [Boolean]
def Sashite::Qpi.valid?(string)
```

### Transformations

```ruby
# Component replacement (return new Identifier)
def with_sin(new_sin)  # => Identifier with different SIN
def with_pin(new_pin)  # => Identifier with different PIN

# Flip transformation (transforms both components)
def flip  # => Identifier with both SIN and PIN flipped

# Native/Derived transformations
def native  # => Identifier with PIN case aligned to SIN case
def derive  # => Identifier with PIN case opposite to SIN case
```

### Errors

All parsing and validation errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"empty input"` | String length is 0 |
| `"missing colon separator"` | No `:` found in string |
| `"missing SIN component"` | Nothing before `:` |
| `"missing PIN component"` | Nothing after `:` |
| `"invalid SIN component: ..."` | SIN parsing failed |
| `"invalid PIN component: ..."` | PIN parsing failed |

## Piece Identity Mapping

QPI encodes complete **Piece Identity** as defined in the [Glossary](https://sashite.dev/glossary/):

| Piece Attribute     | QPI Access           | Encoding                                               |
|---------------------|----------------------|--------------------------------------------------------|
| **Piece Style**     | `qpi.sin.style`      | SIN letter (case-insensitive identity)                 |
| **Piece Name**      | `qpi.pin.type`       | PIN letter (case-insensitive identity)                 |
| **Piece Side**      | `qpi.pin.side`       | PIN letter case (uppercase = first, lowercase = second)|
| **Piece State**     | `qpi.pin.state`      | PIN modifier (`+` = enhanced, `-` = diminished)        |
| **Terminal Status** | `qpi.pin.terminal?`  | PIN marker (`^` = terminal)                            |

Additionally, QPI provides a **Native/Derived relationship** via `native?`, `derived?`, `native`, and `derive`.

## Design Principles

- **Pure composition**: QPI composes SIN and PIN without reimplementing features
- **Minimal API**: Core methods (`sin`, `pin`, `native?`, `derived?`, `native`, `derive`, `to_s`) plus transformations
- **Component transparency**: Access components directly, no wrapper methods
- **QPI-specific conveniences**: `flip`, `native`, `derive` (operations that span both components)
- **Immutable identifiers**: Frozen instances prevent mutation
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, `ArgumentError` for invalid input
- **No duplication**: Delegates to `sashite-sin` and `sashite-pin`

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [QPI Specification](https://sashite.dev/specs/qpi/1.0.0/) — Official specification
- [QPI Examples](https://sashite.dev/specs/qpi/1.0.0/examples/) — Usage examples
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Style component
- [PIN Specification](https://sashite.dev/specs/pin/1.0.0/) — Piece component

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
