# frozen_string_literal: true

require "sashite/snn"
require "pnn"
require_relative "gan/actor"

module Sashite
  # General Actor Notation (GAN) module
  #
  # GAN provides a consistent and rule-agnostic format for identifying game actors
  # in abstract strategy board games. It combines Style Name Notation (SNN) with
  # Piece Name Notation (PNN) to create unambiguous actor identification that
  # eliminates collision problems when multiple piece styles are present.
  #
  # @see https://sashite.dev/documents/gan/1.0.0/ GAN Specification v1.0.0
  module Gan
    # GAN validation regular expression
    # Matches: <snn>:<pnn> where snn and pnn follow their respective specifications
    VALIDATION_REGEX = /\A([A-Z][A-Z0-9]*|[a-z][a-z0-9]*):[-+]?[a-zA-Z]'?\z/

    # Check if a string is valid GAN notation
    #
    # @param gan_string [String] The string to validate
    # @return [Boolean] true if the string is valid GAN notation, false otherwise
    #
    # @example
    #   Sashite::Gan.valid?("CHESS:K")      # => true
    #   Sashite::Gan.valid?("shogi:+p'")    # => true
    #   Sashite::Gan.valid?("Chess:K")      # => false (mixed case in style)
    #   Sashite::Gan.valid?("CHESS")        # => false (missing piece)
    #   Sashite::Gan.valid?("")             # => false (empty string)
    def self.valid?(gan_string)
      return false unless gan_string.is_a?(String)
      return false if gan_string.empty?

      # Quick regex check first
      return false unless VALIDATION_REGEX.match?(gan_string)

      # Split and validate components individually for more precise validation
      parts = gan_string.split(":", 2)
      return false unless parts.length == 2

      style_part, piece_part = parts

      # Validate SNN and PNN components using their respective libraries
      Snn.valid?(style_part) && Pnn.valid?(piece_part)
    end

    # Convenience method to create an actor object
    #
    # @param style [String, Sashite::Snn::Style] The style identifier or style object
    # @param piece [String, Pnn::Piece] The piece identifier or piece object
    # @return [Sashite::Gan::Actor] A new actor object
    # @raise [ArgumentError] if the parameters are invalid
    #
    # @example
    #   actor = Sashite::Gan.actor("CHESS", "K")
    #   # => #<Sashite::Gan::Actor:0x... style="CHESS" piece="K">
    #
    #   # With objects
    #   style = Sashite::Snn::Style.new("CHESS")
    #   piece = Pnn::Piece.new("K")
    #   actor = Sashite::Gan.actor(style, piece)
    def self.actor(style, piece)
      Actor.new(style, piece)
    end

    # Parse a GAN string into component parts
    #
    # @param gan_string [String] The GAN string to parse
    # @return [Array<String>] An array containing [style_string, piece_string]
    # @raise [ArgumentError] if the string is invalid GAN notation
    #
    # @example
    #   Sashite::Gan.parse_components("CHESS:K")
    #   # => ["CHESS", "K"]
    #
    #   Sashite::Gan.parse_components("shogi:+p'")
    #   # => ["shogi", "+p'"]
    #
    # @api private
    def self.parse_components(gan_string)
      raise ArgumentError, "Invalid GAN format: #{gan_string.inspect}" unless valid?(gan_string)

      gan_string.split(":", 2)
    end
  end
end
