# frozen_string_literal: true

require "sashite/pin"
require "sashite/sin"

module Sashite
  module Qpi
    # Represents an identifier in QPI (Qualified Piece Identifier) format.
    #
    # QPI is pure composition of SIN and PIN primitives with one constraint:
    # both components must represent the same player (side).
    #
    # ## Minimal API Design
    #
    # The Identifier class provides only 5 core methods:
    # 1. new(sin, pin) — create from components with validation
    # 2. sin — access SIN component
    # 3. pin — access PIN component
    # 4. to_s — serialize to QPI string
    # 5. flip — flip both components (only convenience method)
    #
    # Additionally, component replacement methods:
    # - with_sin(new_sin) — create identifier with different SIN
    # - with_pin(new_pin) — create identifier with different PIN
    #
    # All other operations use the component APIs directly:
    # - qpi.sin.family — access Piece Style
    # - qpi.sin.side — access Piece Side
    # - qpi.pin.type — access Piece Name
    # - qpi.pin.state — access Piece State
    # - qpi.pin.terminal? — access Terminal Status
    #
    # ## Why Only flip as Convenience?
    #
    # flip is the ONLY transformation that naturally operates on both
    # SIN and PIN components simultaneously. All other transformations
    # work through component replacement:
    #
    #   qpi.with_sin(qpi.sin.with_family(:S))      # Transform SIN
    #   qpi.with_pin(qpi.pin.with_type(:Q))        # Transform PIN
    #   qpi.with_pin(qpi.pin.with_terminal(true))  # Transform PIN
    #
    # This avoids arbitrary conveniences and maintains a clear principle.
    #
    # @example Pure composition
    #   sin = Sashite::Sin.parse("C")
    #   pin = Sashite::Pin.parse("K^")
    #   qpi = Sashite::Qpi::Identifier.new(sin, pin)
    #   qpi.to_s              # => "C:K^"
    #   qpi.sin               # => SIN::Identifier
    #   qpi.pin               # => PIN::Identifier
    #
    # @example Access attributes via components
    #   qpi.sin.family        # => :C (Piece Style)
    #   qpi.pin.type          # => :K (Piece Name)
    #   qpi.sin.side          # => :first (Piece Side)
    #   qpi.pin.state         # => :normal (Piece State)
    #   qpi.pin.terminal?     # => true (Terminal Status)
    #
    # @example Transform via components
    #   qpi.with_sin(qpi.sin.with_family(:S))     # => "S:K^"
    #   qpi.with_pin(qpi.pin.with_type(:Q))       # => "C:Q^"
    #   qpi.flip                                   # => "c:k^"
    #
    # @see https://sashite.dev/specs/qpi/1.0.0/ QPI Specification v1.0.0
    class Identifier
      # Component separator for string representation
      SEPARATOR = ":"

      # Error messages
      ERROR_INVALID_QPI = "Invalid QPI string: %s"
      ERROR_SEMANTIC_MISMATCH = "SIN and PIN components must have same side: sin.side=%s, pin.side=%s"
      ERROR_MISSING_SEPARATOR = "QPI string must contain exactly one colon separator: %s"

      # @return [Sin::Identifier] the SIN component
      attr_reader :sin

      # @return [Pin::Identifier] the PIN component
      attr_reader :pin

      # Create a new identifier from SIN and PIN components
      #
      # @param sin [Sin::Identifier] SIN component
      # @param pin [Pin::Identifier] PIN component
      # @raise [ArgumentError] if components have different sides
      #
      # @example
      #   sin = Sashite::Sin.parse("C")
      #   pin = Sashite::Pin.parse("K^")
      #   qpi = Sashite::Qpi::Identifier.new(sin, pin)
      def initialize(sin, pin)
        validate_semantic_consistency(sin, pin)

        @sin = sin
        @pin = pin

        freeze
      end

      # Parse a QPI string into an Identifier object
      #
      # @param qpi_string [String] QPI notation string (format: sin:pin)
      # @return [Identifier] new identifier instance
      # @raise [ArgumentError] if invalid or semantically inconsistent
      #
      # @example
      #   qpi = Sashite::Qpi::Identifier.parse("C:K^")
      #   qpi.sin.family        # => :C
      #   qpi.pin.type          # => :K
      def self.parse(qpi_string)
        string_value = String(qpi_string)
        sin_part, pin_part = split_components(string_value)

        sin_identifier = Sin::Identifier.parse(sin_part)
        pin_identifier = Pin::Identifier.parse(pin_part)

        new(sin_identifier, pin_identifier)
      end

      # Check if a string is a valid QPI notation
      #
      # @param qpi_string [String] the string to validate
      # @return [Boolean] true if valid QPI, false otherwise
      #
      # @example
      #   Sashite::Qpi::Identifier.valid?("C:K^")   # => true
      #   Sashite::Qpi::Identifier.valid?("C:k")    # => false (side mismatch)
      def self.valid?(qpi_string)
        return false unless qpi_string.is_a?(::String)

        sin_part, pin_part = split_components(qpi_string)
        return false unless Sashite::Sin.valid?(sin_part) && Sashite::Pin.valid?(pin_part)

        sin_identifier = Sashite::Sin.parse(sin_part)
        pin_identifier = Sashite::Pin.parse(pin_part)
        sin_identifier.side == pin_identifier.side
      rescue ArgumentError
        false
      end

      # Convert the identifier to its QPI string representation
      #
      # @return [String] QPI notation string (format: sin:pin)
      #
      # @example
      #   qpi.to_s  # => "C:K^"
      def to_s
        "#{@sin}#{SEPARATOR}#{@pin}"
      end

      # Create a new identifier with different SIN component
      #
      # @param new_sin [Sin::Identifier] new SIN component
      # @return [Identifier] new identifier instance
      # @raise [ArgumentError] if new SIN has different side than PIN
      #
      # @example
      #   qpi.with_sin(qpi.sin.with_family(:S))  # => "S:K^"
      def with_sin(new_sin)
        return self if @sin == new_sin

        self.class.new(new_sin, @pin)
      end

      # Create a new identifier with different PIN component
      #
      # @param new_pin [Pin::Identifier] new PIN component
      # @return [Identifier] new identifier instance
      # @raise [ArgumentError] if new PIN has different side than SIN
      #
      # @example
      #   qpi.with_pin(qpi.pin.with_type(:Q))  # => "C:Q^"
      def with_pin(new_pin)
        return self if @pin == new_pin

        self.class.new(@sin, new_pin)
      end

      # Create a new identifier with both components flipped
      #
      # This is the ONLY convenience method because it's the only
      # transformation that naturally operates on both components.
      #
      # @return [Identifier] new identifier with both components flipped
      #
      # @example
      #   qpi = Sashite::Qpi.parse("C:K^")
      #   qpi.flip  # => "c:k^"
      def flip
        self.class.new(@sin.flip, @pin.flip)
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if both SIN and PIN components are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        @sin == other.sin && @pin == other.pin
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value
      def hash
        [self.class, @sin, @pin].hash
      end

      private

      # Split QPI string into SIN and PIN components
      #
      # @param qpi_string [String] QPI string to split
      # @return [Array<String>] array containing [sin_part, pin_part]
      # @raise [ArgumentError] if string doesn't contain exactly one separator
      def self.split_components(qpi_string)
        parts = qpi_string.split(SEPARATOR, 2)
        raise ::ArgumentError, format(ERROR_MISSING_SEPARATOR, qpi_string) unless parts.size == 2

        parts
      end

      private_class_method :split_components

      # Validate that SIN and PIN components have consistent sides
      #
      # @param sin [Sin::Identifier] SIN component to validate
      # @param pin [Pin::Identifier] PIN component to validate
      # @raise [ArgumentError] if sides don't match
      def validate_semantic_consistency(sin, pin)
        return if sin.side == pin.side

        raise ::ArgumentError, format(ERROR_SEMANTIC_MISMATCH, sin.side, pin.side)
      end
    end
  end
end
