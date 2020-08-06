# frozen_string_literal: true

require_relative 'gan/parser'

module Sashite
  # The GAN (General Actor Notation) module.
  #
  # @see https://developer.sashite.com/specs/general-actor-notation
  module GAN
    SEPARATOR_CHAR = ':'

    # Parse the GAN string into a Ruby object structure and return it.
    #
    # @example Chess (Western chess)'s Rook, White
    #   GAN.parse("C:R")
    #
    # @example Chess (Western chess)'s King, Black
    #   GAN.parse("c:-k")
    #
    # @example Makruk (Thai chess)'s Bishop, White
    #   GAN.parse("M:B")
    #
    # @example Shogi (Japanese chess)'s King, Gote
    #   GAN.parse("s:-k")
    #
    # @example Shogi (Japanese chess)'s King, Sente
    #   GAN.parse("S:-K")
    #
    # @example Shogi (Japanese chess)'s promoted Pawn, Sente
    #   GAN.parse("S:+P")
    #
    # @example Xiangqi (Chinese chess)'s General, Red
    #   GAN.parse("X:-G")
    #
    # @example Xiangqi (Chinese chess)'s Flying General, Red
    #   GAN.parse("X:+-G")
    #
    # @example Dai Dai Shogi (huge Japanese chess)'s Phoenix, Sente
    #   GAN.parse("DAI_DAI_SHOGI:PH")
    #
    # @example Another FOO chess variant's promoted Z piece, Bottom-side
    #   GAN.parse("FOO:+Z")
    #
    # @return [Piece] An instance of the piece.
    def self.parse(string)
      Parser.call(string)
    end
  end
end
