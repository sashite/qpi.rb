# frozen_string_literal: true

require "pnn"

module Sashite
  module Gan
    # Parses GAN strings into their component parts
    class Parser
      # GAN regex pattern for parsing
      PATTERN = /\A(?<game_id>[a-zA-Z]+):(?<pnn_part>[-+]?[a-zA-Z][']?)\z/

      # Parse a GAN string into its components
      #
      # @param gan_string [String] The GAN string to parse
      # @return [Hash] Hash containing the parsed components
      # @raise [ArgumentError] If the GAN string is invalid
      def self.parse(gan_string)
        gan_string = String(gan_string)

        matches = PATTERN.match(gan_string)
        raise ArgumentError, "Invalid GAN string: #{gan_string}" if matches.nil?

        game_id = matches[:game_id]
        pnn_part = matches[:pnn_part]

        # Parse the PNN part using the PNN gem
        pnn_result = Pnn.parse(pnn_part)

        # Verify casing consistency
        unless casing_consistent?(game_id, pnn_result[:letter])
          raise ArgumentError, "Game ID casing (#{game_id}) must match piece letter casing (#{pnn_result[:letter]})"
        end

        # Merge the game_id with the piece parameters for a flatter structure
        { game_id: game_id }.merge(pnn_result)
      end

      # Safely parse a GAN string without raising exceptions
      #
      # @param gan_string [String] The GAN string to parse
      # @return [Hash, nil] Hash containing the parsed components or nil if invalid
      def self.safe_parse(gan_string)
        parse(gan_string)
      rescue ArgumentError
        nil
      end

      # Verifies that the casing of the game_id matches the casing of the piece letter
      #
      # @param game_id [String] The game identifier
      # @param letter [String] The piece letter
      # @return [Boolean] True if casing is consistent
      def self.casing_consistent?(game_id, letter)
        (game_id == game_id.upcase) == (letter == letter.upcase)
      end
    end
  end
end
