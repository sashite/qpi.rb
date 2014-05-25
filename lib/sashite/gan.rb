module Sashite
  module GAN
    class Actor
      attr_accessor :dimension, :cgh, :side, :variant, :name

      def initialize dimension, cgh, side, variant, name
        @dimension = dimension
        @cgh = cgh
        @side = side
        @variant = variant
        @name = name
      end

      def to_gan
        [
          @dimension,
          @cgh,
          @side,
          @variant,
          @name
        ].join ':'
      end
    end
  end
end
