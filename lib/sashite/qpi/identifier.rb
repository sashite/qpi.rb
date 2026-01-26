# frozen_string_literal: true

require_relative "constants"
require_relative "errors"

module Sashite
  module Qpi
    # Represents a parsed QPI (Qualified Piece Identifier) identifier.
    #
    # A QPI identifier encodes complete Piece Identity by combining:
    # - A SIN (Style Identifier Notation) component for Piece Style
    # - A PIN (Piece Identifier Notation) component for Piece Name, Side, State, and Terminal Status
    #
    # Additionally, QPI defines a Native/Derived relationship based on case comparison
    # between the SIN and PIN letters.
    #
    # Instances are immutable (frozen after creation).
    #
    # @example Creating identifiers
    #   sin = Sashite::Sin.parse("C")
    #   pin = Sashite::Pin.parse("K^")
    #   qpi = Identifier.new(sin, pin)
    #
    # @example Accessing components
    #   qpi.sin.abbr       # => :C
    #   qpi.pin.abbr       # => :K
    #   qpi.pin.side       # => :first
    #   qpi.pin.state      # => :normal
    #   qpi.pin.terminal?  # => true
    #
    # @example Native/Derived relationship
    #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("K"))
    #   qpi.native?   # => true (both uppercase/first)
    #
    #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("k"))
    #   qpi.derived?  # => true (SIN uppercase, PIN lowercase)
    #
    # @see https://sashite.dev/specs/qpi/1.0.0/
    class Identifier
      # @return [Sashite::Sin::Identifier] The SIN component
      attr_reader :sin

      # @return [Sashite::Pin::Identifier] The PIN component
      attr_reader :pin

      # Creates a new Identifier instance.
      #
      # @param sin [Sashite::Sin::Identifier] The SIN component
      # @param pin [Sashite::Pin::Identifier] The PIN component
      # @return [Identifier] A new frozen Identifier instance
      # @raise [Errors::Argument] If components are invalid
      #
      # @example
      #   sin = Sashite::Sin.parse("C")
      #   pin = Sashite::Pin.parse("K^")
      #   Identifier.new(sin, pin)
      def initialize(sin, pin)
        validate_sin!(sin)
        validate_pin!(pin)

        @sin = sin
        @pin = pin

        freeze
      end

      # ========================================================================
      # String Conversion
      # ========================================================================

      # Returns the QPI string representation.
      #
      # @return [String] The QPI string in format "SIN:PIN"
      #
      # @example
      #   qpi.to_s  # => "C:K^"
      def to_s
        "#{sin}#{Constants::SEPARATOR}#{pin}"
      end

      # ========================================================================
      # Native/Derived Relationship
      # ========================================================================

      # Checks if the identifier is native.
      #
      # A QPI is native when sin.side equals pin.side (same case).
      #
      # @return [Boolean] true if native
      #
      # @example
      #   Identifier.new(Sin.parse("C"), Pin.parse("K")).native?  # => true
      #   Identifier.new(Sin.parse("c"), Pin.parse("k")).native?  # => true
      #   Identifier.new(Sin.parse("C"), Pin.parse("k")).native?  # => false
      def native?
        sin.side.equal?(pin.side)
      end

      # Checks if the identifier is derived.
      #
      # A QPI is derived when sin.side differs from pin.side (different case).
      #
      # @return [Boolean] true if derived
      #
      # @example
      #   Identifier.new(Sin.parse("C"), Pin.parse("k")).derived?  # => true
      #   Identifier.new(Sin.parse("c"), Pin.parse("K")).derived?  # => true
      #   Identifier.new(Sin.parse("C"), Pin.parse("K")).derived?  # => false
      def derived?
        !native?
      end

      # ========================================================================
      # Native/Derived Transformations
      # ========================================================================

      # Returns a new Identifier with PIN case aligned to SIN case.
      #
      # If already native, returns self.
      #
      # @return [Identifier] A native Identifier
      #
      # @example
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("r"))
      #   qpi.native.to_s  # => "C:R"
      #
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("R"))
      #   qpi.native.to_s  # => "C:R" (unchanged)
      def native
        return self if native?

        self.class.new(sin, pin.with_side(sin.side))
      end

      # Returns a new Identifier with PIN case opposite to SIN case.
      #
      # If already derived, returns self.
      #
      # @return [Identifier] A derived Identifier
      #
      # @example
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("R"))
      #   qpi.derive.to_s  # => "C:r"
      #
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("r"))
      #   qpi.derive.to_s  # => "C:r" (unchanged)
      def derive
        return self if derived?

        opposite_side = sin.side.equal?(:first) ? :second : :first
        self.class.new(sin, pin.with_side(opposite_side))
      end

      # ========================================================================
      # Component Transformations
      # ========================================================================

      # Returns a new Identifier with a different SIN component.
      #
      # @param new_sin [Sashite::Sin::Identifier] The new SIN component
      # @return [Identifier] A new Identifier with the specified SIN
      # @raise [Errors::Argument] If the SIN is invalid
      #
      # @example
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("K"))
      #   qpi.with_sin(Sin.parse("S")).to_s  # => "S:K"
      def with_sin(new_sin)
        self.class.new(new_sin, pin)
      end

      # Returns a new Identifier with a different PIN component.
      #
      # @param new_pin [Sashite::Pin::Identifier] The new PIN component
      # @return [Identifier] A new Identifier with the specified PIN
      # @raise [Errors::Argument] If the PIN is invalid
      #
      # @example
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("K"))
      #   qpi.with_pin(Pin.parse("+Q^")).to_s  # => "C:+Q^"
      def with_pin(new_pin)
        self.class.new(sin, new_pin)
      end

      # Returns a new Identifier with PIN side flipped.
      #
      # The SIN component remains unchanged. This reflects the QPI specification
      # constraint that SIN (Player Style + Player Side) is stable within a Match,
      # while PIN side (Piece Side) may change via Mutation.
      #
      # @return [Identifier] A new Identifier with PIN side flipped
      #
      # @example
      #   qpi = Identifier.new(Sin.parse("C"), Pin.parse("K^"))
      #   qpi.flip.to_s  # => "C:k^"
      #
      #   qpi = Identifier.new(Sin.parse("c"), Pin.parse("r"))
      #   qpi.flip.to_s  # => "c:R"
      def flip
        self.class.new(sin, pin.flip)
      end

      # ========================================================================
      # Equality
      # ========================================================================

      # Checks equality with another Identifier.
      #
      # @param other [Object] The object to compare
      # @return [Boolean] true if equal
      def ==(other)
        return false unless self.class === other

        sin == other.sin && pin == other.pin
      end

      alias eql? ==

      # Returns a hash code for the Identifier.
      #
      # @return [Integer] Hash code
      def hash
        [sin, pin].hash
      end

      # Returns an inspect string for the Identifier.
      #
      # @return [String] Inspect representation
      def inspect
        "#<#{self.class} #{self}>"
      end

      private

      # ========================================================================
      # Private Validation
      # ========================================================================

      def validate_sin!(sin)
        return if sin.is_a?(Sashite::Sin::Identifier)

        raise Errors::Argument, Errors::Argument::Messages::INVALID_SIN
      end

      def validate_pin!(pin)
        return if pin.is_a?(Sashite::Pin::Identifier)

        raise Errors::Argument, Errors::Argument::Messages::INVALID_PIN
      end
    end
  end
end
