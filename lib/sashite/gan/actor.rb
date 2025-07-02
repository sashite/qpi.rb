# frozen_string_literal: true

require "sashite/pin"
require "sashite/snn"

module Sashite
  module Gan
    # Represents a game actor in GAN (General Actor Notation) format.
    #
    # An actor combines a style identifier (SNN format) with a piece identifier (PIN format)
    # using a colon separator and consistent case encoding to create an unambiguous
    # representation of a game piece within its style context.
    #
    # GAN represents all four fundamental piece attributes from the Game Protocol:
    # - Type → PIN component (ASCII letter choice)
    # - Side → Consistent case encoding across both SNN and PIN components
    # - State → PIN component (optional prefix modifier)
    # - Style → SNN component (explicit style identifier)
    #
    # All instances are immutable - transformation methods return new instances.
    # This follows the Game Protocol's actor model with complete attribute representation.
    class Actor
      # Colon separator character
      SEPARATOR = ":"

      # Player side constants
      FIRST_PLAYER = :first
      SECOND_PLAYER = :second

      # State constants
      NORMAL_STATE = :normal
      ENHANCED_STATE = :enhanced
      DIMINISHED_STATE = :diminished

      # Valid sides
      VALID_SIDES = [FIRST_PLAYER, SECOND_PLAYER].freeze

      # Valid states
      VALID_STATES = [NORMAL_STATE, ENHANCED_STATE, DIMINISHED_STATE].freeze

      # Valid types (A-Z)
      VALID_TYPES = (:A..:Z).to_a.freeze

      # Error messages
      ERROR_INVALID_GAN = "Invalid GAN format: %s"
      ERROR_CASE_MISMATCH = "Case mismatch between SNN and PIN components in GAN string: %s"
      ERROR_INVALID_NAME = "Name must be a symbol with proper capitalization, got: %s"
      ERROR_INVALID_TYPE = "Type must be a symbol from :A to :Z, got: %s"
      ERROR_INVALID_SIDE = "Side must be :first or :second, got: %s"
      ERROR_INVALID_STATE = "State must be :normal, :enhanced, or :diminished, got: %s"

      # Create a new actor instance
      #
      # @param name [Symbol] style name (with proper capitalization)
      # @param type [Symbol] piece type (:A to :Z)
      # @param side [Symbol] player side (:first or :second)
      # @param state [Symbol] piece state (:normal, :enhanced, or :diminished)
      # @raise [ArgumentError] if parameters are invalid
      # @example
      #   Actor.new(:Chess, :K, :first, :normal)
      #   Actor.new(:Shogi, :P, :second, :enhanced)
      def initialize(name, type, side, state = NORMAL_STATE)
        self.class.validate_name(name)
        self.class.validate_type(type)
        self.class.validate_side(side)
        self.class.validate_state(state)

        @style = Snn::Style.new(name, side)
        @piece = Pin::Piece.new(type, side, state)

        freeze
      end

      # Parse a GAN string into an Actor object
      #
      # @param gan_string [String] GAN notation string
      # @return [Actor] new actor instance
      # @raise [ArgumentError] if the GAN string is invalid or has case mismatch
      # @example
      #   Actor.parse("CHESS:K")     # => #<Actor name=:Chess type=:K side=:first state=:normal>
      #   Actor.parse("shogi:+p")    # => #<Actor name=:Shogi type=:P side=:second state=:enhanced>
      #   Actor.parse("XIANGQI:-G")  # => #<Actor name=:Xiangqi type=:G side=:first state=:diminished>
      def self.parse(gan_string)
        string_value = String(gan_string)

        # Split into SNN and PIN components
        snn_part, pin_part = string_value.split(SEPARATOR, 2)

        # Validate basic format
        unless snn_part && pin_part && string_value.count(SEPARATOR) == 1
          raise ::ArgumentError, format(ERROR_INVALID_GAN, string_value)
        end

        # Validate case consistency
        validate_case_consistency(snn_part, pin_part, string_value)

        # Parse components - let SNN and PIN handle their own validation
        parsed_style = Snn::Style.parse(snn_part)
        parsed_piece = Pin::Piece.parse(pin_part)

        # Create actor with parsed components
        new(parsed_style.name, parsed_piece.type, parsed_style.side, parsed_piece.state)
      end

      # Convert the actor to its GAN string representation
      #
      # @return [String] GAN notation string
      # @example
      #   actor.to_s  # => "CHESS:K"
      #   actor.to_s  # => "shogi:+p"
      #   actor.to_s  # => "XIANGQI:-G"
      def to_s
        "#{style}#{SEPARATOR}#{piece}"
      end

      # Convert the actor to its PIN representation (piece component only)
      #
      # @return [String] PIN notation string for the piece component
      # @example
      #   actor.to_pin  # => "K"
      #   promoted_actor.to_pin  # => "+p"
      #   diminished_actor.to_pin  # => "-G"
      def to_pin
        piece.to_s
      end

      # Convert the actor to its SNN representation (style component only)
      #
      # @return [String] SNN notation string for the style component
      # @example
      #   actor.to_snn  # => "CHESS"
      #   black_actor.to_snn  # => "chess"
      #   xiangqi_actor.to_snn  # => "XIANGQI"
      def to_snn
        style.to_s
      end

      # Get the style name
      #
      # @return [Symbol] style name (with proper capitalization)
      # @example
      #   actor.name  # => :Chess
      def name
        style.name
      end

      # Get the piece type
      #
      # @return [Symbol] piece type (:A to :Z, always uppercase)
      # @example
      #   actor.type  # => :K
      def type
        piece.type
      end

      # Get the player side
      #
      # @return [Symbol] player side (:first or :second)
      # @example
      #   actor.side  # => :first
      def side
        style.side
      end

      # Get the piece state
      #
      # @return [Symbol] piece state (:normal, :enhanced, or :diminished)
      # @example
      #   actor.state  # => :normal
      def state
        piece.state
      end

      # Create a new actor with enhanced piece state
      #
      # @return [Actor] new actor instance with enhanced piece
      # @example
      #   actor.enhance  # CHESS:K => CHESS:+K
      def enhance
        self.class.new(name, type, side, ENHANCED_STATE)
      end

      # Create a new actor with diminished piece state
      #
      # @return [Actor] new actor instance with diminished piece
      # @example
      #   actor.diminish  # CHESS:K => CHESS:-K
      def diminish
        self.class.new(name, type, side, DIMINISHED_STATE)
      end

      # Create a new actor with normal piece state (no modifiers)
      #
      # @return [Actor] new actor instance with normalized piece
      # @example
      #   actor.normalize  # CHESS:+K => CHESS:K
      def normalize
        self.class.new(name, type, side, NORMAL_STATE)
      end

      # Create a new actor with opposite ownership (side)
      #
      # Changes both the style and piece sides consistently.
      # This method is rule-agnostic and preserves all piece modifiers.
      #
      # @return [Actor] new actor instance with flipped side
      # @example
      #   actor.flip  # CHESS:K => chess:k
      #   enhanced.flip  # CHESS:+K => chess:+k (modifiers preserved)
      def flip
        opposite_side = first_player? ? SECOND_PLAYER : FIRST_PLAYER
        self.class.new(name, type, opposite_side, state)
      end

      # Create a new actor with a different style name (keeping same type, side, and state)
      #
      # @param new_name [Symbol] new style name (with proper capitalization)
      # @return [Actor] new actor instance with different style name
      # @example
      #   actor.with_name(:Shogi)  # CHESS:K => SHOGI:K
      def with_name(new_name)
        self.class.new(new_name, type, side, state)
      end

      # Create a new actor with a different piece type (keeping same name, side, and state)
      #
      # @param new_type [Symbol] new piece type (:A to :Z)
      # @return [Actor] new actor instance with different piece type
      # @example
      #   actor.with_type(:Q)  # CHESS:K => CHESS:Q
      def with_type(new_type)
        self.class.new(name, new_type, side, state)
      end

      # Create a new actor with a different side (keeping same name, type, and state)
      #
      # @param new_side [Symbol] :first or :second
      # @return [Actor] new actor instance with different side
      # @example
      #   actor.with_side(:second)  # CHESS:K => chess:k
      def with_side(new_side)
        self.class.new(name, type, new_side, state)
      end

      # Create a new actor with a different piece state (keeping same name, type, and side)
      #
      # @param new_state [Symbol] :normal, :enhanced, or :diminished
      # @return [Actor] new actor instance with different piece state
      # @example
      #   actor.with_state(:enhanced)  # CHESS:K => CHESS:+K
      def with_state(new_state)
        self.class.new(name, type, side, new_state)
      end

      # Check if the actor has enhanced state
      #
      # @return [Boolean] true if enhanced
      def enhanced?
        piece.enhanced?
      end

      # Check if the actor has diminished state
      #
      # @return [Boolean] true if diminished
      def diminished?
        piece.diminished?
      end

      # Check if the actor has normal state (no modifiers)
      #
      # @return [Boolean] true if no modifiers are present
      def normal?
        piece.normal?
      end

      # Check if the actor belongs to the first player
      #
      # @return [Boolean] true if first player
      def first_player?
        style.first_player?
      end

      # Check if the actor belongs to the second player
      #
      # @return [Boolean] true if second player
      def second_player?
        style.second_player?
      end

      # Check if this actor has the same style name as another
      #
      # @param other [Actor] actor to compare with
      # @return [Boolean] true if same style name
      # @example
      #   chess1.same_name?(chess2)  # (CHESS:K) and (chess:Q) => true
      def same_name?(other)
        return false unless other.is_a?(self.class)

        name == other.name
      end

      # Check if this actor is the same type as another (ignoring name, side, and state)
      #
      # @param other [Actor] actor to compare with
      # @return [Boolean] true if same piece type
      # @example
      #   king1.same_type?(king2)  # (CHESS:K) and (SHOGI:k) => true
      def same_type?(other)
        return false unless other.is_a?(self.class)

        type == other.type
      end

      # Check if this actor belongs to the same side as another
      #
      # @param other [Actor] actor to compare with
      # @return [Boolean] true if same side
      def same_side?(other)
        return false unless other.is_a?(self.class)

        side == other.side
      end

      # Check if this actor has the same state as another
      #
      # @param other [Actor] actor to compare with
      # @return [Boolean] true if same piece state
      def same_state?(other)
        return false unless other.is_a?(self.class)

        state == other.state
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if actors are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        name == other.name && type == other.type && side == other.side && state == other.state
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value
      def hash
        [self.class, name, type, side, state].hash
      end

      # Validate that the name is a valid symbol with proper capitalization
      #
      # @param name [Symbol] the name to validate
      # @raise [ArgumentError] if invalid
      def self.validate_name(name)
        return if valid_name?(name)

        raise ::ArgumentError, format(ERROR_INVALID_NAME, name.inspect)
      end

      # Validate that the type is a valid symbol
      #
      # @param type [Symbol] the type to validate
      # @raise [ArgumentError] if invalid
      def self.validate_type(type)
        return if VALID_TYPES.include?(type)

        raise ::ArgumentError, format(ERROR_INVALID_TYPE, type.inspect)
      end

      # Validate that the side is a valid symbol
      #
      # @param side [Symbol] the side to validate
      # @raise [ArgumentError] if invalid
      def self.validate_side(side)
        return if VALID_SIDES.include?(side)

        raise ::ArgumentError, format(ERROR_INVALID_SIDE, side.inspect)
      end

      # Validate that the state is a valid symbol
      #
      # @param state [Symbol] the state to validate
      # @raise [ArgumentError] if invalid
      def self.validate_state(state)
        return if VALID_STATES.include?(state)

        raise ::ArgumentError, format(ERROR_INVALID_STATE, state.inspect)
      end

      # Check if a name is valid (symbol with proper capitalization)
      #
      # @param name [Object] the name to check
      # @return [Boolean] true if valid
      def self.valid_name?(name)
        return false unless name.is_a?(::Symbol)

        name_string = name.to_s
        return false if name_string.empty?

        # Must match proper capitalization pattern: first letter uppercase, rest lowercase/digits
        name_string.match?(/\A[A-Z][a-z0-9]*\z/)
      end

      # Validate case consistency between SNN and PIN components
      #
      # @param snn_part [String] the SNN component
      # @param pin_part [String] the PIN component (with optional prefix)
      # @param full_string [String] the full GAN string for error reporting
      # @raise [ArgumentError] if case mismatch detected
      def self.validate_case_consistency(snn_part, pin_part, full_string)
        # Extract letter from PIN part (remove optional +/- prefix)
        pin_letter = pin_part.match(/[-+]?([A-Za-z])$/)[1]

        snn_uppercase = snn_part == snn_part.upcase
        pin_uppercase = pin_letter == pin_letter.upcase

        return if snn_uppercase == pin_uppercase

        raise ::ArgumentError, format(ERROR_CASE_MISMATCH, full_string)
      end

      # Match GAN pattern against string
      #
      # @param string [String] string to match
      # @return [MatchData] match data
      # @raise [ArgumentError] if string doesn't match
      def self.match_pattern(string)
        matches = GAN_PATTERN.match(string)
        return matches if matches

        raise ::ArgumentError, format(ERROR_INVALID_GAN, string)
      end

      private_class_method :valid_name?, :validate_case_consistency

      private

      # Get the style component
      #
      # @return [Sashite::Snn::Style] the style component
      attr_reader :style

      # Get the piece component
      #
      # @return [Sashite::Pin::Piece] the piece component
      attr_reader :piece
    end
  end
end
