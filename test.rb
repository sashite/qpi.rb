# frozen_string_literal: false

require 'simplecov'

::SimpleCov.command_name 'Brutal test suite'
::SimpleCov.start

require './lib/sashite-gan'

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("C:R")
end

raise if actual.inspect.to_s != "C:R"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "R"
raise if actual.abbr.to_s != "R"
raise if actual.style != "C"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "C:R"
raise if actual.topside.to_s != "c:r"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "C:R"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "c:r"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "C:+R"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "C:R"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("c:-k")
end

raise if actual.inspect.to_s != "c:-k"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "-k"
raise if actual.abbr.to_s != "-k"
raise if actual.style != "c"
raise if actual.topside? != true
raise if actual.bottomside? != false
raise if actual.to_s != "c:-k"
raise if actual.topside.to_s != "c:-k"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "C:-K"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "C:-K"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "c:+-k"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "c:-k"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("M:B")
end

raise if actual.inspect.to_s != "M:B"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "B"
raise if actual.abbr.to_s != "B"
raise if actual.style != "M"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "M:B"
raise if actual.topside.to_s != "m:b"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "M:B"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "m:b"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "M:+B"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "M:B"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("s:-k")
end

raise if actual.inspect.to_s != "s:-k"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "-k"
raise if actual.abbr.to_s != "-k"
raise if actual.style != "s"
raise if actual.topside? != true
raise if actual.bottomside? != false
raise if actual.to_s != "s:-k"
raise if actual.topside.to_s != "s:-k"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "S:-K"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "S:-K"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "s:+-k"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "s:-k"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("S:-K")
end

raise if actual.inspect.to_s != "S:-K"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "-K"
raise if actual.abbr.to_s != "-K"
raise if actual.style != "S"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "S:-K"
raise if actual.topside.to_s != "s:-k"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "S:-K"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "s:-k"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "S:+-K"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "S:-K"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("S:+P")
end

raise if actual.inspect.to_s != "S:+P"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "+P"
raise if actual.abbr.to_s != "+P"
raise if actual.style != "S"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "S:+P"
raise if actual.topside.to_s != "s:+p"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "S:+P"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "s:+p"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "S:+P"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "S:P"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("X:-G")
end

raise if actual.inspect.to_s != "X:-G"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "-G"
raise if actual.abbr.to_s != "-G"
raise if actual.style != "X"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "X:-G"
raise if actual.topside.to_s != "x:-g"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "X:-G"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "x:-g"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "X:+-G"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "X:-G"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("X:+-G")
end

raise if actual.inspect.to_s != "X:+-G"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "+-G"
raise if actual.abbr.to_s != "+-G"
raise if actual.style != "X"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "X:+-G"
raise if actual.topside.to_s != "x:+-g"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "X:+-G"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "x:+-g"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "X:+-G"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "X:-G"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("DAI_DAI_SHOGI:PH")
end

raise if actual.inspect.to_s != "DAI_DAI_SHOGI:PH"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "PH"
raise if actual.abbr.to_s != "PH"
raise if actual.style != "DAI_DAI_SHOGI"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "DAI_DAI_SHOGI:PH"
raise if actual.topside.to_s != "dai_dai_shogi:ph"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "DAI_DAI_SHOGI:PH"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "dai_dai_shogi:ph"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "DAI_DAI_SHOGI:+PH"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "DAI_DAI_SHOGI:PH"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"

# ------------------------------------------------------------------------------

actual = begin
  Sashite::GAN.parse("FOO:+Z")
end

raise if actual.inspect.to_s != "FOO:+Z"
raise if actual.class.inspect != "Sashite::GAN::Piece"
raise if actual.abbr.inspect.to_s != "+Z"
raise if actual.abbr.to_s != "+Z"
raise if actual.style != "FOO"
raise if actual.topside? != false
raise if actual.bottomside? != true
raise if actual.to_s != "FOO:+Z"
raise if actual.topside.to_s != "foo:+z"
raise if actual.topside.class.inspect != "Sashite::GAN::Piece"
raise if actual.bottomside.to_s != "FOO:+Z"
raise if actual.bottomside.class.inspect != "Sashite::GAN::Piece"
raise if actual.oppositeside.to_s != "foo:+z"
raise if actual.oppositeside.class.inspect != "Sashite::GAN::Piece"
raise if actual.promote.to_s != "FOO:+Z"
raise if actual.promote.class.inspect != "Sashite::GAN::Piece"
raise if actual.unpromote.to_s != "FOO:Z"
raise if actual.unpromote.class.inspect != "Sashite::GAN::Piece"
