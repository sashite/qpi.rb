# frozen_string_literal: true

require_relative "qpi/identifier"

module Sashite
  # QPI (Qualified Piece Identifier) implementation for Ruby
  #
  # Provides complete piece identification by combining two primitive notations:
  # - SIN (Style Identifier Notation) — identifies the piece style
  # - PIN (Piece Identifier Notation) — identifies the piece attributes
  #
  # A QPI identifier is simply a pair of (SIN, PIN) with one constraint:
  # both components must represent the same player.
  #
  # ## Core Concept
  #
  # QPI is pure composition:
  #
  #   sin = Sashite::Sin.parse("C")
  #   pin = Sashite::Pin.parse("K^")
  #   qpi = Sashite::Qpi.new(sin, pin)
  #   qpi.to_s  # => "C:K^"
  #   qpi.sin   # => SIN::Identifier instance
  #   qpi.pin   # => PIN::Identifier instance
  #
  # All piece attributes come from the components.
  #
  # ## Five Fundamental Attributes
  #
  # QPI exposes all five attributes from the Sashité Game Protocol:
  # - **Piece Style** — via qpi.sin.family
  # - **Piece Name** — via qpi.pin.type
  # - **Piece Side** — via qpi.sin.side or qpi.pin.side
  # - **Piece State** — via qpi.pin.state
  # - **Terminal Status** — via qpi.pin.terminal?
  #
  # ## Format Specification
  #
  # Structure: `<sin>:<pin>`
  #
  # Grammar (BNF):
  #   <qpi> ::= <uppercase-qpi> | <lowercase-qpi>
  #   <uppercase-qpi> ::= <uppercase-letter> ":" <uppercase-pin>
  #   <lowercase-qpi> ::= <lowercase-letter> ":" <lowercase-pin>
  #   <uppercase-pin> ::= ["+" | "-"] <uppercase-letter> ["^"]
  #   <lowercase-pin> ::= ["+" | "-"] <lowercase-letter> ["^"]
  #
  # Regular Expression: `/\A([A-Z]:[-+]?[A-Z]\^?|[a-z]:[-+]?[a-z]\^?)\z/`
  #
  # ## Semantic Constraint
  #
  # The SIN and PIN components must represent the same player:
  # - Valid: "C:K" (both first player), "c:k" (both second player)
  # - Invalid: "C:k" (side mismatch), "c:K" (side mismatch)
  #
  # ## Examples
  #
  #   # Parse QPI string
  #   qpi = Sashite::Qpi.parse("C:K^")
  #   qpi.sin.family        # => :C (Piece Style)
  #   qpi.pin.type          # => :K (Piece Name)
  #   qpi.sin.side          # => :first (Piece Side)
  #   qpi.pin.state         # => :normal (Piece State)
  #   qpi.pin.terminal?     # => true (Terminal Status)
  #
  #   # Create from components
  #   sin = Sashite::Sin.parse("S")
  #   pin = Sashite::Pin.parse("+R^")
  #   qpi = Sashite::Qpi.new(sin, pin)
  #   qpi.to_s              # => "S:+R^"
  #
  #   # Transform via components
  #   qpi.with_sin(qpi.sin.with_family(:C))     # => "C:+R^"
  #   qpi.with_pin(qpi.pin.with_type(:B))       # => "S:+B^"
  #
  #   # Flip both components (only convenience method)
  #   qpi.flip              # => "s:+r^"
  #
  # ## Design Properties
  #
  # - **Rule-agnostic**: Independent of game mechanics
  # - **Pure composition**: Zero feature duplication
  # - **Minimal API**: Only 5 core methods
  # - **Component transparency**: Direct primitive access
  # - **Immutable**: Frozen instances
  # - **Semantic validation**: Automatic side consistency
  #
  # @see https://sashite.dev/specs/qpi/1.0.0/ QPI Specification v1.0.0
  # @see https://sashite.dev/specs/sin/1.0.0/ Style Identifier Notation (SIN)
  # @see https://sashite.dev/specs/pin/1.0.0/ Piece Identifier Notation (PIN)
  module Qpi
    # Check if a string is a valid QPI notation
    #
    # @param qpi_string [String] the string to validate
    # @return [Boolean] true if valid QPI, false otherwise
    #
    # @example
    #   Sashite::Qpi.valid?("C:K^")   # => true
    #   Sashite::Qpi.valid?("C:k")    # => false (side mismatch)
    def self.valid?(qpi_string)
      Identifier.valid?(qpi_string)
    end

    # Parse a QPI string into an Identifier object
    #
    # @param qpi_string [String] QPI notation string (format: sin:pin)
    # @return [Qpi::Identifier] identifier with sin and pin components
    # @raise [ArgumentError] if invalid or semantically inconsistent
    #
    # @example
    #   qpi = Sashite::Qpi.parse("C:K^")
    #   qpi.sin.family        # => :C
    #   qpi.pin.type          # => :K
    #   qpi.pin.terminal?     # => true
    def self.parse(qpi_string)
      Identifier.parse(qpi_string)
    end

    # Create a new identifier from SIN and PIN components
    #
    # @param sin [Sin::Identifier] SIN component
    # @param pin [Pin::Identifier] PIN component
    # @return [Qpi::Identifier] new identifier instance
    # @raise [ArgumentError] if components have different sides
    #
    # @example
    #   sin = Sashite::Sin.parse("C")
    #   pin = Sashite::Pin.parse("K^")
    #   qpi = Sashite::Qpi.new(sin, pin)
    #   qpi.to_s              # => "C:K^"
    def self.new(sin, pin)
      Identifier.new(sin, pin)
    end
  end
end
