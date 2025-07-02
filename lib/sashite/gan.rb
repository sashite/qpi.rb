# frozen_string_literal: true

require_relative "gan/actor"

module Sashite
  # GAN (General Actor Notation) implementation for Ruby
  #
  # Provides a rule-agnostic format for identifying game actors in abstract strategy board games
  # by combining Style Name Notation (SNN) and Piece Identifier Notation (PIN) with a colon separator.
  #
  # GAN represents all four fundamental piece attributes from the Game Protocol:
  # - Type → PIN component (ASCII letter choice)
  # - Side → Consistent case encoding across both SNN and PIN components
  # - State → PIN component (optional prefix modifier)
  # - Style → SNN component (explicit style identifier)
  #
  # Format: <snn>:<pin>
  # - SNN component: Style identifier with case-based side encoding
  # - Colon separator: Literal ":"
  # - PIN component: Piece with optional state and case-based ownership
  # - Case consistency: SNN and PIN components must have matching case
  #
  # Examples:
  #   "CHESS:K"    - First player chess king
  #   "chess:k"    - Second player chess king
  #   "SHOGI:+P"   - First player enhanced shōgi pawn
  #   "xiangqi:-g" - Second player diminished xiangqi general
  #
  # See: https://sashite.dev/specs/gan/1.0.0/
  module Gan
    # Regular expression for GAN validation
    # Matches: <snn>:<pin> where snn and pin follow their respective specifications
    # with consistent case encoding
    GAN_REGEX = /\A([A-Z][A-Z0-9]*|[a-z][a-z0-9]*):[-+]?[A-Za-z]\z/

    # Check if a string is valid GAN notation
    #
    # @param gan [String] The string to validate
    # @return [Boolean] true if valid GAN, false otherwise
    #
    # @example
    #   Sashite::Gan.valid?("CHESS:K")      # => true
    #   Sashite::Gan.valid?("shogi:+p")     # => true
    #   Sashite::Gan.valid?("Chess:K")      # => false (mixed case in style)
    #   Sashite::Gan.valid?("CHESS:k")      # => false (case mismatch)
    #   Sashite::Gan.valid?("CHESS")        # => false (missing piece)
    #   Sashite::Gan.valid?("")             # => false (empty string)
    def self.valid?(gan)
      return false unless gan.is_a?(::String)
      return false if gan.empty?

      # Quick regex check first
      return false unless GAN_REGEX.match?(gan)

      # Split and validate components individually for precise validation
      parts = gan.split(":", 2)
      return false unless parts.length == 2

      snn_part, pin_part = parts

      # Check case consistency between components
      return false unless case_consistent?(snn_part, pin_part)

      # Validate individual components using their respective libraries
      Snn.valid?(snn_part) && Pin.valid?(pin_part)
    end

    # Parse a GAN string into an Actor object
    #
    # @param gan_string [String] GAN notation string
    # @return [Gan::Actor] new actor instance
    # @raise [ArgumentError] if the GAN string is invalid
    # @example
    #   Sashite::Gan.parse("CHESS:K")     # => #<Gan::Actor name=:Chess type=:K side=:first state=:normal>
    #   Sashite::Gan.parse("shogi:+p")    # => #<Gan::Actor name=:Shogi type=:P side=:second state=:enhanced>
    #   Sashite::Gan.parse("XIANGQI:-G")  # => #<Gan::Actor name=:Xiangqi type=:G side=:first state=:diminished>
    def self.parse(gan_string)
      Actor.parse(gan_string)
    end

    # Create a new actor instance
    #
    # @param name [Symbol] style name (with proper capitalization)
    # @param type [Symbol] piece type (:A to :Z)
    # @param side [Symbol] player side (:first or :second)
    # @param state [Symbol] piece state (:normal, :enhanced, or :diminished)
    # @return [Gan::Actor] new actor instance
    # @raise [ArgumentError] if parameters are invalid
    # @example
    #   Sashite::Gan.actor(:Chess, :K, :first, :normal)     # => #<Gan::Actor name=:Chess type=:K side=:first state=:normal>
    #   Sashite::Gan.actor(:Shogi, :P, :second, :enhanced)  # => #<Gan::Actor name=:Shogi type=:P side=:second state=:enhanced>
    def self.actor(name, type, side, state = :normal)
      Actor.new(name, type, side, state)
    end

    private

    # Check case consistency between SNN and PIN components
    #
    # @param snn_part [String] the SNN component
    # @param pin_part [String] the PIN component (with optional prefix)
    # @return [Boolean] true if case is consistent, false otherwise
    def self.case_consistent?(snn_part, pin_part)
      # Extract letter from PIN part (remove optional +/- prefix)
      pin_letter_match = pin_part.match(/[-+]?([A-Za-z])$/)
      return false unless pin_letter_match

      pin_letter = pin_letter_match[1]

      snn_uppercase = snn_part == snn_part.upcase
      pin_uppercase = pin_letter == pin_letter.upcase

      snn_uppercase == pin_uppercase
    end
  end
end
