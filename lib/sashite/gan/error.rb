# frozen_string_literal: true

module Sashite
  module GAN
    # The error namespace.
    module Error; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'error', '*.rb')].each do |fname|
  require_relative fname
end
