# frozen_string_literal: true

# Sashité namespace for board game notation libraries
module Sashite
  # General Actor Notation (GAN) implementation for Ruby
  #
  # GAN defines a consistent and rule-agnostic format for identifying game actors
  # in abstract strategy board games. GAN provides unambiguous identification of
  # pieces by combining Style Name Notation (SNN) with Piece Name Notation (PNN),
  # eliminating collision problems when multiple piece styles are present in the
  # same context.
  #
  # @see https://sashite.dev/documents/gan/1.0.0/ GAN Specification v1.0.0
  # @author Sashité
  # @since 1.0.0
end

require_relative "sashite/gan"
