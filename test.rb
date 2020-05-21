# frozen_string_literal: true

require_relative 'lib/sashite/gan'

# Chess (Western) Rook, White
raise if Sashite::GAN.string(
  is_checkmateable: false,
  is_promoted: false,
  is_topside: false,
  piece_abbr: 'r',
  style_abbr: 'c'
) != 'C:R'

# Chess (Western) King, Black
raise if Sashite::GAN.string(
  is_checkmateable: true,
  is_promoted: false,
  is_topside: true,
  piece_abbr: 'k',
  style_abbr: 'c'
) != 'c:-k'

# Shogi King, Gote
raise if Sashite::GAN.string(
  is_checkmateable: true,
  is_promoted: false,
  is_topside: true,
  piece_abbr: 'k',
  style_abbr: 's'
) != 's:-k'

# Shogi promoted Pawn, Sente
raise if Sashite::GAN.string(
  is_checkmateable: false,
  is_promoted: true,
  is_topside: false,
  piece_abbr: 'p',
  style_abbr: 's'
) != 'S:+P'

# Xiangqi General, Red
raise if Sashite::GAN.string(
  is_checkmateable: true,
  is_promoted: false,
  is_topside: false,
  piece_abbr: 'g',
  style_abbr: 'x'
) != 'X:-G'

# Xiangqi Flying General, Red
raise if Sashite::GAN.string(
  is_checkmateable: true,
  is_promoted: true,
  is_topside: false,
  piece_abbr: 'g',
  style_abbr: 'x'
) != 'X:+-G'

# Go Stone, Black
raise if Sashite::GAN.string(
  is_checkmateable: false,
  is_promoted: false,
  is_topside: false,
  piece_abbr: 's',
  style_abbr: 'go'
) != 'GO:S'
