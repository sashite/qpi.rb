# frozen_string_literal: true

# Sashité namespace for board game notation libraries
module Sashite
  # General Actor Notation (GAN) implementation for Ruby
  #
  # GAN provides a rule-agnostic format for identifying game actors in abstract strategy board games
  # by combining Style Name Notation (SNN) and Piece Identifier Notation (PIN) with a colon separator.
  # GAN represents all four fundamental piece attributes from the Game Protocol:
  # - Type + Side → PIN component (ASCII letter with case encoding)
  # - State → PIN component (optional prefix modifier)
  # - Style → SNN component (explicit style identifier)
  #
  # @see https://sashite.dev/specs/gan/1.0.0/ GAN Specification v1.0.0
  # @author Sashité
end

require_relative "sashite/gan"
