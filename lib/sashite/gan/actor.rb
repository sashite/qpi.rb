# frozen_string_literal: true

module Sashite
  module Gan
    # Represents a game actor in GAN format
    #
    # An actor combines a style identifier (SNN format) with a piece identifier (PNN format)
    # to create an unambiguous representation of a game piece within its style context.
    # The casing of both components determines player association and piece ownership:
    # - Style casing determines which player uses that style tradition (fixed per game)
    # - Piece casing determines current piece ownership (may change during gameplay)
    #
    # @example
    #   # Traditional same-style game
    #   white_king = Sashite::Gan::Actor.new("CHESS", "K")  # First player's chess king
    #   black_king = Sashite::Gan::Actor.new("chess", "k")  # Second player's chess king
    #
    #   # Cross-style game
    #   chess_king = Sashite::Gan::Actor.new("CHESS", "K")   # First player uses chess
    #   shogi_king = Sashite::Gan::Actor.new("shogi", "k")   # Second player uses shogi
    #
    #   # Dynamic ownership (piece captured and converted)
    #   captured = Sashite::Gan::Actor.new("CHESS", "k")     # Chess piece owned by second player
    class Actor
      # @return [Sashite::Snn::Style] The style component
      attr_reader :style

      # @return [Pnn::Piece] The piece component
      attr_reader :piece

      # Create a new actor instance
      #
      # @param style [String, Sashite::Snn::Style] The style identifier or style object
      # @param piece [String, Pnn::Piece] The piece identifier or piece object
      # @raise [ArgumentError] if the parameters are invalid
      #
      # @example
      #   # With strings
      #   actor = Sashite::Gan::Actor.new("CHESS", "K")
      #
      #   # With objects
      #   style = Sashite::Snn::Style.new("CHESS")
      #   piece = Pnn::Piece.new("K")
      #   actor = Sashite::Gan::Actor.new(style, piece)
      def initialize(style, piece)
        @style = style.is_a?(Snn::Style) ? style : Snn::Style.new(style.to_s)
        @piece = piece.is_a?(Pnn::Piece) ? piece : Pnn::Piece.parse(piece.to_s)

        freeze
      end

      # Parse a GAN string into an actor object
      #
      # @param gan_string [String] GAN notation string
      # @return [Actor] new actor instance
      # @raise [ArgumentError] if the GAN string is invalid
      #
      # @example
      #   actor = Sashite::Gan::Actor.parse("CHESS:K")
      #   # => #<Sashite::Gan::Actor:0x... style="CHESS" piece="K">
      #
      #   enhanced = Sashite::Gan::Actor.parse("SHOGI:+p'")
      #   # => #<Sashite::Gan::Actor:0x... style="SHOGI" piece="+p'">
      def self.parse(gan_string)
        style_string, piece_string = Gan.parse_components(gan_string)
        new(style_string, piece_string)
      end

      # Convert the actor to its GAN string representation
      #
      # @return [String] GAN notation string
      #
      # @example
      #   actor.to_s  # => "CHESS:K"
      def to_s
        "#{style}:#{piece}"
      end

      # Get the style name as a string
      #
      # @return [String] The style identifier string
      #
      # @example
      #   actor.style_name  # => "CHESS"
      def style_name
        style.to_s
      end

      # Get the piece name as a string
      #
      # @return [String] The piece identifier string
      #
      # @example
      #   actor.piece_name  # => "K"
      def piece_name
        piece.to_s
      end

      # Create a new actor with an enhanced piece
      #
      # @return [Actor] new actor instance with enhanced piece
      #
      # @example
      #   actor.enhance_piece  # SHOGI:P => SHOGI:+P
      def enhance_piece
        self.class.new(style, piece.enhance)
      end

      # Create a new actor with a diminished piece
      #
      # @return [Actor] new actor instance with diminished piece
      #
      # @example
      #   actor.diminish_piece  # CHESS:R => CHESS:-R
      def diminish_piece
        self.class.new(style, piece.diminish)
      end

      # Create a new actor with an intermediate piece state
      #
      # @return [Actor] new actor instance with intermediate piece
      #
      # @example
      #   actor.set_piece_intermediate  # CHESS:R => CHESS:R'
      def set_piece_intermediate
        self.class.new(style, piece.intermediate)
      end

      # Create a new actor with a piece without modifiers
      #
      # @return [Actor] new actor instance with bare piece
      #
      # @example
      #   actor.bare_piece  # SHOGI:+P' => SHOGI:P
      def bare_piece
        self.class.new(style, piece.bare)
      end

      # Create a new actor with piece ownership flipped
      #
      # Changes the piece ownership (case) while keeping the style unchanged.
      # This method is rule-agnostic and preserves all piece modifiers.
      # If modifier removal is needed, it should be done explicitly.
      #
      # @return [Actor] new actor instance with ownership changed
      #
      # @example
      #   actor.change_piece_ownership  # SHOGI:P => SHOGI:p
      #   enhanced.change_piece_ownership  # SHOGI:+P => SHOGI:+p (modifiers preserved)
      #
      #   # To remove modifiers explicitly:
      #   actor.bare_piece.change_piece_ownership  # SHOGI:+P => SHOGI:p
      #   # or
      #   actor.change_piece_ownership.bare_piece  # SHOGI:+P => SHOGI:p
      def change_piece_ownership
        self.class.new(style, piece.flip)
      end

      # Custom equality comparison
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] true if both objects are Actor instances with the same components
      def ==(other)
        other.is_a?(Actor) && style == other.style && piece == other.piece
      end

      # Alias for equality comparison
      alias eql? ==

      # Hash code for use in hashes and sets
      #
      # @return [Integer] The hash code
      def hash
        [self.class, style, piece].hash
      end

      # String representation for debugging
      #
      # @return [String] A detailed string representation
      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} style=#{style_name.inspect} piece=#{piece_name.inspect}>"
      end
    end
  end
end
