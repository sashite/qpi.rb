# frozen_string_literal: true

require "pnn"

module Sashite
  module Gan
    # Serializes actor components into GAN (General Actor Notation) strings.
    #
    # The dumper transforms piece data and game identifiers into properly
    # formatted GAN strings, ensuring consistency between game ID casing
    # and piece letter casing according to the GAN specification.
    #
    # According to the specification, game IDs must be either all uppercase
    # or all lowercase, and their casing must match the casing of the piece letter.
    class Dumper
      # Pattern for validating game identifiers - must be all uppercase OR all lowercase
      GAME_ID_PATTERN = /\A([A-Z]+|[a-z]+)\z/

      # Error message templates
      INVALID_GAME_ID_ERROR = "Game ID must be a non-empty string containing only ASCII letters and must be either all uppercase or all lowercase: %s"
      CASING_MISMATCH_ERROR = "Game ID casing (%s) must match piece letter casing (%s)"

      # Serializes actor components into a GAN string
      #
      # @param game_id [String] The game identifier (e.g., "CHESS", "shogi")
      # @param piece_params [Hash] Piece parameters as accepted by Pnn.dump:
      #   @option piece_params [String] :letter The single ASCII letter identifier (required)
      #   @option piece_params [String, nil] :prefix Optional prefix modifier for the piece ("+", "-")
      #   @option piece_params [String, nil] :suffix Optional suffix modifier for the piece ("'")
      # @return [String] A properly formatted GAN notation string (e.g., "CHESS:K'")
      # @raise [ArgumentError] If game_id is invalid or casing is inconsistent with piece letter
      # @example Create a GAN string for a white chess king with castling rights
      #   Dumper.dump(game_id: "CHESS", letter: "K", suffix: "'")
      #   # => "CHESS:K'"
      # @example Create a GAN string for a promoted shogi pawn
      #   Dumper.dump(game_id: "SHOGI", letter: "P", prefix: "+")
      #   # => "SHOGI:+P"
      def self.dump(game_id:, **piece_params)
        game_id = String(game_id)
        validate_game_id!(game_id)

        # Build the piece string using the PNN gem
        pnn_string = ::Pnn.dump(**piece_params)

        # Verify casing consistency
        validate_casing_consistency!(game_id, pnn_string)

        "#{game_id}:#{pnn_string}"
      end

      # @api private
      # Validates that the game_id contains only ASCII letters
      #
      # @param game_id [String] The game identifier to validate
      # @return [void]
      # @raise [ArgumentError] If game_id contains non-letter characters
      def self.validate_game_id!(game_id)
        return if game_id.match?(GAME_ID_PATTERN)

        raise ::ArgumentError, format(INVALID_GAME_ID_ERROR, game_id)
      end
      private_class_method :validate_game_id!

      # @api private
      # Validates that the casing of the game_id is consistent with the piece letter
      #
      # According to GAN specification, if game_id is uppercase, piece letter must be uppercase,
      # and if game_id is lowercase, piece letter must be lowercase.
      #
      # @param game_id [String] The game identifier
      # @param pnn_string [String] The PNN string
      # @return [void]
      # @raise [ArgumentError] If casing is inconsistent
      def self.validate_casing_consistency!(game_id, pnn_string)
        return if casing_consistent?(game_id, pnn_string)

        raise ::ArgumentError, format(CASING_MISMATCH_ERROR, game_id, pnn_string)
      end
      private_class_method :validate_casing_consistency!

      # @api private
      # Verifies that the casing of the game_id matches the casing of the piece letter
      #
      # @param game_id [String] The game identifier
      # @param pnn_string [String] The PNN string
      # @return [Boolean] True if casing is consistent
      def self.casing_consistent?(game_id, pnn_string)
        # Both must be uppercase or both must be lowercase
        (game_id == game_id.upcase) == (pnn_string == pnn_string.upcase)
      end
      private_class_method :casing_consistent?
    end
  end
end
