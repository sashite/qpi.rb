# frozen_string_literal: true

require "sashite/pin"
require "sashite/sin"

module Sashite
  module Qpi
    # Represents an identifier in QPI (Qualified Piece Identifier) format.
    #
    # A QPI identifier combines style and piece attributes into a unified representation:
    # - Family: Style family from SIN component (:A to :Z only)
    # - Type: Piece type (:A to :Z) from PIN component
    # - Side: Player assignment (:first or :second) from both components
    # - State: Piece state (:normal, :enhanced, :diminished) from PIN component
    # - Semantic constraint: SIN and PIN components must represent the same player
    #
    # All instances are immutable - transformation methods return new instances.
    # This follows the QPI Specification v1.0.0 with strict parameter validation
    # consistent with the underlying SIN and PIN primitive specifications.
    #
    # ## Strict Parameter Validation
    #
    # QPI enforces the same strict validation as its underlying primitives:
    # - Family parameter must be a symbol from :A to :Z (not :a to :z)
    # - Type parameter must be a symbol from :A to :Z (delegated to PIN)
    # - Side parameter determines the display case, not the input parameters
    #
    # This ensures consistency with SIN and PIN behavior where lowercase symbols
    # are rejected with ArgumentError.
    #
    # @example Strict parameter validation
    #   # Valid - uppercase symbols only
    #   Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)   # => "C:K"
    #   Sashite::Qpi::Identifier.new(:C, :K, :second, :normal)  # => "c:k"
    #
    #   # Invalid - lowercase symbols rejected
    #   Sashite::Qpi::Identifier.new(:c, :K, :second, :normal)  # => ArgumentError
    #   Sashite::Qpi::Identifier.new(:C, :k, :second, :normal)  # => ArgumentError
    #
    # @see https://sashite.dev/specs/qpi/1.0.0/ QPI Specification v1.0.0
    class Identifier
      # Component separator for string representation
      SEPARATOR = ":"

      # Error messages
      ERROR_INVALID_QPI = "Invalid QPI string: %s"
      ERROR_SEMANTIC_MISMATCH = "Family and side must represent the same player: family=%s (side=%s), side=%s"
      ERROR_MISSING_SEPARATOR = "QPI string must contain exactly one colon separator: %s"

      # @return [Symbol] the style family (:A to :Z based on SIN component)
      def family
        @sin_identifier.family
      end

      # @return [Symbol] the piece type (:A to :Z)
      def type
        @pin_identifier.type
      end

      # @return [Symbol] the player side (:first or :second)
      def side
        @pin_identifier.side
      end

      # @return [Symbol] the piece state (:normal, :enhanced, or :diminished)
      def state
        @pin_identifier.state
      end

      # Create a new identifier instance
      #
      # @param family [Symbol] style family identifier (:A to :Z only)
      # @param type [Symbol] piece type (:A to :Z only)
      # @param side [Symbol] player side (:first or :second)
      # @param state [Symbol] piece state (:normal, :enhanced, or :diminished)
      # @raise [ArgumentError] if parameters are invalid or semantically inconsistent
      #
      # @example Create identifiers with strict parameter validation
      #   # Valid - uppercase symbols only
      #   chess_king = Sashite::Qpi::Identifier.new(:C, :K, :first, :normal)   # => "C:K"
      #   chess_pawn = Sashite::Qpi::Identifier.new(:C, :P, :second, :normal)  # => "c:p"
      #
      #   # Invalid - lowercase symbols rejected
      #   # Sashite::Qpi::Identifier.new(:c, :K, :first, :normal)   # => ArgumentError
      #   # Sashite::Qpi::Identifier.new(:C, :k, :first, :normal)   # => ArgumentError
      def initialize(family, type, side, state = Pin::Identifier::NORMAL_STATE)
        # Strict validation - delegate to underlying primitives for consistency
        Sin::Identifier.validate_family(family)
        Pin::Identifier.validate_type(type)
        Pin::Identifier.validate_side(side)
        Pin::Identifier.validate_state(state)

        # Create PIN component
        @pin_identifier = Pin::Identifier.new(type, side, state)

        # Create SIN component - pass family directly without normalization
        @sin_identifier = Sin::Identifier.new(family, side)

        # Validate semantic consistency
        validate_semantic_consistency

        freeze
      end

      # Parse a QPI string into an Identifier object
      #
      # @param qpi_string [String] QPI notation string (format: sin:pin)
      # @return [Identifier] new identifier instance
      # @raise [ArgumentError] if the QPI string is invalid
      #
      # @example Parse QPI strings with automatic component separation
      #   Sashite::Qpi::Identifier.parse("C:K")   # => #<Qpi::Identifier family=:C type=:K side=:first state=:normal>
      #   Sashite::Qpi::Identifier.parse("s:+r")  # => #<Qpi::Identifier family=:S type=:R side=:second state=:enhanced>
      #   Sashite::Qpi::Identifier.parse("X:-S")  # => #<Qpi::Identifier family=:X type=:S side=:first state=:diminished>
      def self.parse(qpi_string)
        string_value = String(qpi_string)
        sin_part, pin_part = split_components(string_value)

        # Parse components
        sin_identifier = Sin::Identifier.parse(sin_part)
        pin_identifier = Pin::Identifier.parse(pin_part)

        # Validate semantic consistency BEFORE creating new instance
        unless sin_identifier.side == pin_identifier.side
          raise ::ArgumentError, format(ERROR_SEMANTIC_MISMATCH,
                                        sin_part, sin_identifier.side, pin_identifier.side)
        end

        # Extract parameters and create new instance
        new(sin_identifier.family, pin_identifier.type, pin_identifier.side, pin_identifier.state)
      end

      # Check if a string is a valid QPI notation
      #
      # @param qpi_string [String] the string to validate
      # @return [Boolean] true if valid QPI, false otherwise
      #
      # @example Validate QPI strings with semantic checking
      #   Sashite::Qpi::Identifier.valid?("C:K")     # => true
      #   Sashite::Qpi::Identifier.valid?("s:+r")    # => true
      #   Sashite::Qpi::Identifier.valid?("C:k")     # => false (semantic mismatch)
      #   Sashite::Qpi::Identifier.valid?("Chess")   # => false (no separator)
      def self.valid?(qpi_string)
        return false unless qpi_string.is_a?(::String)

        # Split components and validate each part
        sin_part, pin_part = split_components(qpi_string)
        return false unless Sashite::Sin.valid?(sin_part) && Sashite::Pin.valid?(pin_part)

        # Semantic consistency check
        sin_identifier = Sashite::Sin.parse(sin_part)
        pin_identifier = Sashite::Pin.parse(pin_part)
        sin_identifier.side == pin_identifier.side
      rescue ArgumentError
        false
      end

      # Convert the identifier to its QPI string representation
      #
      # @return [String] QPI notation string (format: sin:pin)
      # @example Display QPI identifiers
      #   identifier.to_s  # => "C:K"
      def to_s
        "#{@sin_identifier}#{SEPARATOR}#{@pin_identifier}"
      end

      # Convert to SIN string representation (style component only)
      #
      # @return [String] SIN notation string
      # @example Extract style component
      #   identifier.to_sin  # => "C"
      def to_sin
        @sin_identifier.to_s
      end

      # Convert to PIN string representation (piece component only)
      #
      # @return [String] PIN notation string
      # @example Extract piece component
      #   identifier.to_pin  # => "+K"
      def to_pin
        @pin_identifier.to_s
      end

      # Get the parsed SIN identifier object
      #
      # @return [Sashite::Sin::Identifier] SIN component as identifier object
      def sin_component
        @sin_identifier
      end

      # Get the parsed PIN identifier object
      #
      # @return [Sashite::Pin::Identifier] PIN component as identifier object
      def pin_component
        @pin_identifier
      end

      # Create a new identifier with enhanced state
      #
      # @return [Identifier] new identifier with enhanced PIN component
      def enhance
        return self if enhanced?

        self.class.new(family, type, side, Pin::Identifier::ENHANCED_STATE)
      end

      # Create a new identifier with diminished state
      #
      # @return [Identifier] new identifier with diminished PIN component
      def diminish
        return self if diminished?

        self.class.new(family, type, side, Pin::Identifier::DIMINISHED_STATE)
      end

      # Create a new identifier with normal state (no modifiers)
      #
      # @return [Identifier] new identifier with normalized PIN component
      def normalize
        return self if normal?

        self.class.new(family, type, side, Pin::Identifier::NORMAL_STATE)
      end

      # Create a new identifier with different piece type
      #
      # @param new_type [Symbol] new piece type (:A to :Z)
      # @return [Identifier] new identifier with different type
      def with_type(new_type)
        return self if type == new_type

        self.class.new(family, new_type, side, state)
      end

      # Create a new identifier with different side
      #
      # @param new_side [Symbol] new player side (:first or :second)
      # @return [Identifier] new identifier with different side
      def with_side(new_side)
        return self if side == new_side

        self.class.new(family, type, new_side, state)
      end

      # Create a new identifier with different state
      #
      # @param new_state [Symbol] new piece state (:normal, :enhanced, or :diminished)
      # @return [Identifier] new identifier with different state
      def with_state(new_state)
        return self if state == new_state

        self.class.new(family, type, side, new_state)
      end

      # Create a new identifier with different family
      #
      # @param new_family [Symbol] new style family identifier (:A to :Z)
      # @return [Identifier] new identifier with different family
      def with_family(new_family)
        return self if family == new_family

        self.class.new(new_family, type, side, state)
      end

      # Create a new identifier with opposite player assignment
      #
      # Changes the player assignment (side) while preserving the family and piece attributes.
      # This maintains semantic consistency between the components.
      #
      # @return [Identifier] new identifier with opposite side but same family
      #
      # @example Flip player assignment while preserving family and attributes
      #   chess_first = Sashite::Qpi::Identifier.parse("C:K")   # Chess king, first player
      #   chess_second = chess_first.flip                       # => "c:k" (Chess king, second player)
      #
      #   shogi_first = Sashite::Qpi::Identifier.parse("S:+R")  # Shogi enhanced rook, first player
      #   shogi_second = shogi_first.flip                       # => "s:+r" (Shogi enhanced rook, second player)
      def flip
        self.class.new(family, type, opposite_side, state)
      end

      # Check if the identifier has normal state
      #
      # @return [Boolean] true if normal state
      def normal?
        @pin_identifier.normal?
      end

      # Check if the identifier has enhanced state
      #
      # @return [Boolean] true if enhanced state
      def enhanced?
        @pin_identifier.enhanced?
      end

      # Check if the identifier has diminished state
      #
      # @return [Boolean] true if diminished state
      def diminished?
        @pin_identifier.diminished?
      end

      # Check if the identifier belongs to the first player
      #
      # @return [Boolean] true if first player
      def first_player?
        @pin_identifier.first_player?
      end

      # Check if the identifier belongs to the second player
      #
      # @return [Boolean] true if second player
      def second_player?
        @pin_identifier.second_player?
      end

      # Check if this identifier has the same family as another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if same family (case-insensitive)
      def same_family?(other)
        return false unless other.is_a?(self.class)

        @sin_identifier.same_family?(other.sin_component)
      end

      # Check if this identifier has different family from another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if different families
      def cross_family?(other)
        return false unless other.is_a?(self.class)

        !same_family?(other)
      end

      # Check if this identifier has the same side as another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if same side
      def same_side?(other)
        return false unless other.is_a?(self.class)

        @pin_identifier.same_side?(other.pin_component)
      end

      # Check if this identifier has the same type as another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if same type
      def same_type?(other)
        return false unless other.is_a?(self.class)

        @pin_identifier.same_type?(other.pin_component)
      end

      # Check if this identifier has the same state as another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if same state
      def same_state?(other)
        return false unless other.is_a?(self.class)

        @pin_identifier.same_state?(other.pin_component)
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if identifiers are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        @sin_identifier == other.sin_component && @pin_identifier == other.pin_component
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value
      def hash
        [self.class, @sin_identifier, @pin_identifier].hash
      end

      private

      # Split QPI string into SIN and PIN components
      #
      # @param qpi_string [String] QPI string to split
      # @return [Array<String>] array containing [sin_part, pin_part]
      def self.split_components(qpi_string)
        parts = qpi_string.split(SEPARATOR, 2)
        raise ::ArgumentError, format(ERROR_MISSING_SEPARATOR, qpi_string) unless parts.size == 2

        parts
      end

      private_class_method :split_components

      # Validate semantic consistency between SIN and PIN components
      #
      # @raise [ArgumentError] if family case doesn't match side
      def validate_semantic_consistency
        expected_side = @sin_identifier.side
        actual_side = @pin_identifier.side

        return if expected_side == actual_side

        raise ::ArgumentError, format(ERROR_SEMANTIC_MISMATCH,
                                      @sin_identifier.letter, expected_side, actual_side)
      end

      # Get the opposite player side
      #
      # @return [Symbol] the opposite side
      def opposite_side
        first_player? ? Pin::Identifier::SECOND_PLAYER : Pin::Identifier::FIRST_PLAYER
      end
    end
  end
end
