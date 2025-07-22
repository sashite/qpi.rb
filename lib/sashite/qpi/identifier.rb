# frozen_string_literal: true

require "sashite/sin"
require "sashite/pin"

module Sashite
  module Qpi
    # Represents an identifier in QPI (Qualified Piece Identifier) format.
    #
    # A QPI identifier consists of a SIN component and PIN component separated by a colon:
    # - SIN component: Style identifier with case-based player assignment
    # - PIN component: Piece identifier with type, state, and case-based ownership
    # - Semantic constraint: Both components must represent the same player side
    #
    # All instances are immutable - transformation methods return new instances.
    # This follows the QPI Specification v1.0.0 combining SIN and PIN with semantic validation.
    class Identifier
      # Component separator
      SEPARATOR = ":"

      # Error messages
      ERROR_INVALID_QPI = "Invalid QPI string: %s"
      ERROR_INVALID_SIN_COMPONENT = "Invalid SIN component: %s"
      ERROR_INVALID_PIN_COMPONENT = "Invalid PIN component: %s"
      ERROR_SEMANTIC_MISMATCH = "SIN and PIN components must represent the same player side: SIN side=%s, PIN side=%s"
      ERROR_MISSING_SEPARATOR = "QPI string must contain exactly one colon separator: %s"

      # @return [Symbol] the SIN component (style identifier)
      def sin
        @sin_identifier.letter
      end

      # @return [Symbol] the PIN component (piece identifier)
      def pin
        @pin_identifier.to_s.to_sym
      end

      # Create a new identifier instance
      #
      # @param sin [String] style identifier (SIN notation)
      # @param pin [String] piece identifier (PIN notation)
      # @raise [ArgumentError] if parameters are invalid or semantically inconsistent
      def initialize(sin, pin)
        @sin_string = String(sin)
        @pin_string = String(pin)

        validate_components
        validate_semantic_consistency

        # Store parsed instances instead of just strings
        @sin_identifier = Sin::Identifier.parse(@sin_string)
        @pin_identifier = Pin::Identifier.parse(@pin_string)

        freeze
      end

      # Parse a QPI string into an Identifier object
      #
      # @param qpi_string [String] QPI notation string (format: sin:pin)
      # @return [Identifier] new identifier instance
      # @raise [ArgumentError] if the QPI string is invalid
      # @example Parse QPI strings with automatic component separation
      #   Sashite::Qpi::Identifier.parse("C:K")   # => #<Qpi::Identifier sin=:C pin=:K>
      #   Sashite::Qpi::Identifier.parse("s:+r")  # => #<Qpi::Identifier sin=:s pin=:+r>
      #   Sashite::Qpi::Identifier.parse("S:-P")  # => #<Qpi::Identifier sin=:S pin=:-P>
      def self.parse(qpi_string)
        string_value = String(qpi_string)
        sin_part, pin_part = split_components(string_value)
        new(sin_part, pin_part)
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
        "#{@sin_identifier.to_s}#{SEPARATOR}#{@pin_identifier.to_s}"
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

      # Get the style (alias for sin)
      #
      # @return [Symbol] style identifier
      def style
        sin
      end

      # Get the piece type from PIN component
      #
      # @return [Symbol] piece type (:A to :Z)
      def type
        @pin_identifier.type
      end

      # Get the player side from PIN component
      #
      # @return [Symbol] player side (:first or :second)
      def side
        @pin_identifier.side
      end

      # Get the piece state from PIN component
      #
      # @return [Symbol] piece state (:normal, :enhanced, or :diminished)
      def state
        @pin_identifier.state
      end

      # Check if identifier has semantic consistency
      #
      # @return [Boolean] true if SIN and PIN components represent the same side
      def valid?
        @sin_identifier.side == @pin_identifier.side
      end

      # Create a new identifier with enhanced state
      #
      # @return [Identifier] new identifier with enhanced PIN component
      def enhance
        new_pin_identifier = @pin_identifier.enhance
        return self if new_pin_identifier.equal?(@pin_identifier)

        self.class.new(@sin_identifier.to_s, new_pin_identifier.to_s)
      end

      # Create a new identifier with diminished state
      #
      # @return [Identifier] new identifier with diminished PIN component
      def diminish
        new_pin_identifier = @pin_identifier.diminish
        return self if new_pin_identifier.equal?(@pin_identifier)

        self.class.new(@sin_identifier.to_s, new_pin_identifier.to_s)
      end

      # Create a new identifier with normal state (no modifiers)
      #
      # @return [Identifier] new identifier with normalized PIN component
      def normalize
        new_pin_identifier = @pin_identifier.normalize
        return self if new_pin_identifier.equal?(@pin_identifier)

        self.class.new(@sin_identifier.to_s, new_pin_identifier.to_s)
      end

      # Create a new identifier with different piece type
      #
      # @param new_type [Symbol] new piece type (:A to :Z)
      # @return [Identifier] new identifier with different type
      def with_type(new_type)
        new_pin_identifier = @pin_identifier.with_type(new_type)
        return self if new_pin_identifier.equal?(@pin_identifier)

        self.class.new(@sin_identifier.to_s, new_pin_identifier.to_s)
      end

      # Create a new identifier with different style
      #
      # @param new_style [String, Symbol] new style identifier
      # @return [Identifier] new identifier with different SIN component
      def with_style(new_style)
        # Convert style to appropriate case based on current side
        new_style_str = case side
                        when :first then new_style.to_s.upcase
                        when :second then new_style.to_s.downcase
                        end

        return self if new_style_str == @sin_identifier.to_s

        self.class.new(new_style_str, @pin_identifier.to_s)
      end

      # Create a new identifier with flipped player side
      #
      # @return [Identifier] new identifier with both SIN and PIN components flipped
      def flip_side
        new_sin_identifier = @sin_identifier.flip
        new_pin_identifier = @pin_identifier.flip
        self.class.new(new_sin_identifier.to_s, new_pin_identifier.to_s)
      end

      # Create a new identifier with flipped style assignment
      #
      # @return [Identifier] new identifier with flipped SIN component only
      def flip_style
        new_sin_identifier = @sin_identifier.flip
        self.class.new(new_sin_identifier.to_s, @pin_identifier.to_s)
      end

      # Create a new identifier with both style and side flipped
      #
      # @return [Identifier] new identifier with both components flipped
      def flip
        flip_side
      end

      # Create a new identifier with different components
      #
      # @param new_sin [String] new SIN component
      # @param new_pin [String] new PIN component
      # @return [Identifier] new identifier with different components
      def with_components(new_sin, new_pin)
        self.class.new(new_sin, new_pin)
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

      # Check if this identifier has the same style as another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if same style (case-insensitive)
      def same_style?(other)
        return false unless other.is_a?(self.class)

        @sin_identifier.same_letter?(other.sin_component)
      end

      # Check if this identifier has different style from another
      #
      # @param other [Identifier] identifier to compare with
      # @return [Boolean] true if different styles
      def cross_style?(other)
        return false unless other.is_a?(self.class)

        !same_style?(other)
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

      # Validate individual SIN and PIN components
      #
      # @raise [ArgumentError] if components are invalid
      def validate_components
        unless Sashite::Sin.valid?(@sin_string)
          raise ::ArgumentError, format(ERROR_INVALID_SIN_COMPONENT, @sin_string)
        end

        unless Sashite::Pin.valid?(@pin_string)
          raise ::ArgumentError, format(ERROR_INVALID_PIN_COMPONENT, @pin_string)
        end
      end

      # Validate semantic consistency between SIN and PIN components
      #
      # @raise [ArgumentError] if sides don't match
      def validate_semantic_consistency
        sin_side = Sashite::Sin.parse(@sin_string).side
        pin_side = Sashite::Pin.parse(@pin_string).side

        return if sin_side == pin_side

        raise ::ArgumentError, format(ERROR_SEMANTIC_MISMATCH, sin_side, pin_side)
      end
    end
  end
end
