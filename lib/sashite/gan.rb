# frozen_string_literal: true

require_relative File.join("gan", "dumper")
require_relative File.join("gan", "parser")
require_relative File.join("gan", "validator")

module Sashite
  # This module provides a Ruby interface for serialization and
  # deserialization of game actors in GAN format.
  #
  # GAN (General Actor Notation) defines a consistent and rule-agnostic
  # format for representing game actors in abstract strategy board games,
  # building upon Piece Name Notation (PNN).
  #
  # @see https://sashite.dev/documents/gan/1.0.0/
  module Gan
    # Serializes an actor into a GAN string.
    #
    # @param game_id [String] The game identifier
    # @param piece_params [Hash] Piece parameters as accepted by Pnn.dump
    # @option piece_params [String] :letter The single ASCII letter identifier (required)
    # @option piece_params [String, nil] :prefix Optional prefix modifier for the piece ("+", "-")
    # @option piece_params [String, nil] :suffix Optional suffix modifier for the piece ("'")
    # @return [String] GAN notation string
    # @raise [ArgumentError] If any parameter is invalid
    # @example
    #   Sashite::Gan.dump(game_id: "CHESS", letter: "K", suffix: "'")
    #   # => "CHESS:K'"
    def self.dump(game_id:, **piece_params)
      Dumper.dump(game_id:, **piece_params)
    end

    # Parses a GAN string into its component parts.
    #
    # @param gan_string [String] GAN notation string
    # @return [Hash] Hash containing the parsed actor data with the following keys:
    #   - :game_id [String] - The game identifier
    #   - :letter [String] - The base letter identifier
    #   - :prefix [String, nil] - The prefix modifier if present
    #   - :suffix [String, nil] - The suffix modifier if present
    # @raise [ArgumentError] If the GAN string is invalid
    # @example
    #   Sashite::Gan.parse("CHESS:K'")
    #   # => { game_id: "CHESS", letter: "K", suffix: "'" }
    def self.parse(gan_string)
      Parser.parse(gan_string)
    end

    # Safely parses a GAN string into its component parts without raising exceptions.
    #
    # @param gan_string [String] GAN notation string
    # @return [Hash, nil] Hash containing the parsed actor data or nil if parsing fails
    # @example
    #   # Valid GAN string
    #   Sashite::Gan.safe_parse("CHESS:K'")
    #   # => { game_id: "CHESS", letter: "K", suffix: "'" }
    #
    #   # Invalid GAN string
    #   Sashite::Gan.safe_parse("invalid")
    #   # => nil
    def self.safe_parse(gan_string)
      Parser.safe_parse(gan_string)
    end

    # Validates if the given string is a valid GAN string
    #
    # @param gan_string [String] GAN string to validate
    # @return [Boolean] True if the string is a valid GAN string
    # @example
    #   Sashite::Gan.valid?("CHESS:K'") # => true
    #   Sashite::Gan.valid?("invalid") # => false
    def self.valid?(gan_string)
      Validator.valid?(gan_string)
    end
  end
end
