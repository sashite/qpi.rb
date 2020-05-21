# frozen_string_literal: true

module Sashite
  # General Actor Notation
  class GAN
    # @return [String] The representation of an actor.
    def self.string(is_checkmateable:, is_promoted:, is_topside:, piece_abbr:, style_abbr:)
      unless [false, true].include?(is_topside)
        raise TypeError, is_topside.class.inspect
      end

      piece_code = piece_code_builder(
        piece_abbr: piece_abbr,
        is_checkmateable: is_checkmateable,
        is_promoted: is_promoted
      )

      piece_code_with_prefix = "#{style_abbr}:#{piece_code}"

      if is_topside
        piece_code_with_prefix.downcase
      else
        piece_code_with_prefix.upcase
      end
    end

    def self.piece_code_builder(piece_abbr:, is_checkmateable:, is_promoted:)
      unless [false, true].include?(is_checkmateable)
        raise TypeError, is_checkmateable.class.inspect
      end

      unless [false, true].include?(is_promoted)
        raise TypeError, is_promoted.class.inspect
      end

      str = piece_abbr
      str = "-#{str}" if is_checkmateable
      str = "+#{str}" if is_promoted
      str
    end
    private_class_method :piece_code_builder
  end
end
