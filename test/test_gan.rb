require_relative '_test_helper'

describe Sashite::GAN::Actor do
  describe '#to_s' do
    before do
      @actor = Sashite::GAN::Actor.new 2,
        'bc096c4c7f48fc5c4c162555e4df98169e204aea',
        'top', 'xianqi', 'rook'
    end

    it 'returns the GAN of the actor' do
      @actor.to_gan.must_equal '2:bc096c4c7f48fc5c4c162555e4df98169e204aea:top:xianqi:rook'
    end
  end
end
