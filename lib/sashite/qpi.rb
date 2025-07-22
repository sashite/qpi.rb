# frozen_string_literal: true

require_relative "qpi/identifier"

module Sashite
  # QPI (Qualified Piece Identifier) implementation for Ruby
  #
  # Provides a rule-agnostic format for identifying game pieces in abstract strategy
  # board games by combining Style Identifier Notation (SIN) and Piece Identifier
  # Notation (PIN) with a colon separator.
  #
  # QPI represents all four fundamental piece attributes:
  # - Type → PIN component (ASCII letter choice)
  # - Side → PIN component (letter case)
  # - State → PIN component (optional prefix modifier)
  # - Style → SIN component (style identifier)
  #
  # Format: <sin>:<pin>
  # - SIN component: Single ASCII letter (A-Z for first player, a-z for second player)
  # - Colon separator: Literal ':' character
  # - PIN component: Piece identifier with optional state prefix
  #
  # Examples:
  #   "C:K"  - Chess king, first player (normal state)
  #   "c:k"  - Chess king, second player (normal state)
  #   "S:+R" - Shōgi rook, first player (enhanced state)
  #   "s:-p" - Shōgi pawn, second player (diminished state)
  #
  # See: https://sashite.dev/specs/qpi/1.0.0/
  module Qpi
    # Check if a string is a valid QPI notation
    #
    # @param qpi_string [String] The string to validate
    # @return [Boolean] true if valid QPI, false otherwise
    #
    # @example Validate various QPI formats
    #   Sashite::Qpi.valid?("C:K")    # => true
    #   Sashite::Qpi.valid?("s:+r")   # => true
    #   Sashite::Qpi.valid?("C:k")    # => false (semantic mismatch)
    #   Sashite::Qpi.valid?("Chess")  # => false (missing separator)
    #   Sashite::Qpi.valid?("C:")     # => false (missing PIN component)
    def self.valid?(qpi_string)
      Identifier.valid?(qpi_string)
    end

    # Parse a QPI string into an Identifier object
    #
    # @param qpi_string [String] QPI notation string
    # @return [Qpi::Identifier] new identifier instance
    # @raise [ArgumentError] if the QPI string is invalid
    # @example Parse different QPI formats
    #   Sashite::Qpi.parse("C:K")     # => #<Qpi::Identifier sin=:C pin=:K>
    #   Sashite::Qpi.parse("S:+R")    # => #<Qpi::Identifier sin=:S pin=:+R>
    #   Sashite::Qpi.parse("s:-p")    # => #<Qpi::Identifier sin=:s pin=:-p>
    def self.parse(qpi_string)
      Identifier.parse(qpi_string)
    end

    # Create a new identifier instance from components
    #
    # @param sin [String] style identifier (SIN notation)
    # @param pin [String] piece identifier (PIN notation)
    # @return [Qpi::Identifier] new identifier instance
    # @raise [ArgumentError] if parameters are invalid or semantically inconsistent
    # @example Create identifiers from components
    #   Sashite::Qpi.identifier("C", "K")       # => #<Qpi::Identifier sin=:C pin=:K>
    #   Sashite::Qpi.identifier("S", "+R")      # => #<Qpi::Identifier sin=:S pin=:+R>
    #   Sashite::Qpi.identifier("s", "-p")      # => #<Qpi::Identifier sin=:s pin=:-p>
    def self.identifier(sin, pin)
      Identifier.new(sin, pin)
    end
  end
end
