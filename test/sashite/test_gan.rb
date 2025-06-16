# frozen_string_literal: true

require "simplecov"
SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Gan (General Actor Notation)
#
# Tests the GAN implementation for Ruby, covering validation,
# actor creation, style-piece composition, and format compliance
# according to the GAN specification v1.0.0.
#
# This test assumes the existence of:
# - lib/sashite-gan.rb

require_relative "../../lib/sashite-gan"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Gan (General Actor Notation)"
puts

# Test module-level validation method
run_test("Module validation accepts valid GAN strings") do
  valid_gans = [
    "CHESS:K", "chess:k", "SHOGI:P", "shogi:p",
    "XIANGQI:r", "xiangqi:R", "MAKRUK:Q", "makruk:q",
    "CHESS960:K", "chess960:k", "JANGGI:g", "janggi:G",
    "A:A", "Z:Z", "a:a", "z:z", "A1:B", "z9:x",
    "CHESS:+P", "shogi:+p", "XIANGQI:-r", "makruk:-q",
    "CHESS:K'", "shogi:p'", "XIANGQI:R'", "makruk:Q'",
    "CHESS:+K'", "shogi:-p'", "XIANGQI:+r'", "makruk:-q'"
  ]

  valid_gans.each do |gan|
    raise "#{gan.inspect} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Module validation rejects invalid GAN strings") do
  invalid_gans = [
    "", "CHESS", ":K", "CHESS:", "Chess:K", "CHESS:Chess",
    "CHESS-960:K", "9CHESS:K", "CHESS:++K", "CHESS:KK",
    "CHESS: K", "CHESS :K", " CHESS:K", "CHESS:K ",
    "chess_variant:k", "CHESS:k''", "CHESS:k+", "CHESS:'k",
    "CHESS K", "CHESS::K", "CHESS:K:extra", "123:K",
    "CHESS:123", "a-b:c", "CHESS:k-", "CHESS:+", "CHESS:-"
  ]

  invalid_gans.each do |gan|
    raise "#{gan.inspect} should be invalid" if Sashite::Gan.valid?(gan)
  end
end

run_test("Module validation handles non-string input") do
  non_strings = [nil, 123, :CHESS, [], {}, %w[CHESS K]]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Gan.valid?(input)
  end
end

run_test("Module validation validates SNN and PNN components separately") do
  # Valid regex but invalid components
  invalid_component_gans = [
    "Chess:K",     # Mixed case style (invalid SNN)
    "CHESS:Kk",    # Multiple letters (invalid PNN)
    "CHESS-960:K", # Invalid SNN with hyphen
    "CHESS:++K"    # Invalid PNN with double prefix
  ]

  invalid_component_gans.each do |gan|
    raise "#{gan.inspect} should be invalid due to component validation" if Sashite::Gan.valid?(gan)
  end
end

run_test("Module convenience method creates actor objects") do
  actor = Sashite::Gan.actor("CHESS", "K")

  raise "Should return Actor instance" unless actor.is_a?(Sashite::Gan::Actor)
  raise "Should have correct style" unless actor.style_name == "CHESS"
  raise "Should have correct piece" unless actor.piece_name == "K"
end

run_test("Module convenience method accepts objects") do
  style = Sashite::Snn::Style.new("CHESS")
  piece = Pnn::Piece.new("K")
  actor = Sashite::Gan.actor(style, piece)

  raise "Should return Actor instance" unless actor.is_a?(Sashite::Gan::Actor)
  raise "Should have correct style" unless actor.style == style
  raise "Should have correct piece" unless actor.piece == piece
end

run_test("Module parse_components splits GAN strings correctly") do
  test_cases = {
    "CHESS:K"    => %w[CHESS K],
    "shogi:+p'"  => ["shogi", "+p'"],
    "XIANGQI:-r" => ["XIANGQI", "-r"],
    "makruk:Q'"  => ["makruk", "Q'"]
  }

  test_cases.each do |gan_string, expected|
    result = Sashite::Gan.parse_components(gan_string)
    raise "#{gan_string} should split to #{expected.inspect}, got #{result.inspect}" unless result == expected
  end
end

run_test("Module parse_components rejects invalid GAN strings") do
  invalid_gans = ["", "CHESS", ":K", "CHESS:", "Chess:K"]

  invalid_gans.each do |gan|
    Sashite::Gan.parse_components(gan)
    raise "Should have raised ArgumentError for #{gan.inspect}"
  rescue ArgumentError => e
    raise "Wrong error message" unless e.message.include?("Invalid GAN format")
  end
end

# Test casing combinations
run_test("All four casing combinations are valid") do
  casing_combinations = [
    %w[CHESS K],  # Uppercase style, uppercase piece
    %w[CHESS k],  # Uppercase style, lowercase piece
    %w[chess K],  # Lowercase style, uppercase piece
    %w[chess k]   # Lowercase style, lowercase piece
  ]

  casing_combinations.each do |style, piece|
    gan_string = "#{style}:#{piece}"
    raise "#{gan_string} should be valid" unless Sashite::Gan.valid?(gan_string)

    actor = Sashite::Gan.actor(style, piece)
    raise "Should create actor for #{gan_string}" unless actor.to_s == gan_string
  end
end

# Test cross-style scenarios
run_test("Cross-style game validation") do
  cross_style_examples = [
    "CHESS:K",     # First player chess
    "makruk:k",    # Second player makruk
    "SHOGI:P",     # First player shogi
    "xiangqi:g",   # Second player xiangqi
    "JANGGI:G",    # First player janggi
    "chess960:k"   # Second player chess960
  ]

  cross_style_examples.each do |gan|
    raise "#{gan} should be valid for cross-style games" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Traditional same-style game validation") do
  same_style_examples = [
    ["CHESS:K", "chess:k"],     # Chess game
    ["SHOGI:P", "shogi:p"],     # Shogi game
    ["XIANGQI:r", "xiangqi:R"], # Xiangqi game
    ["MAKRUK:Q", "makruk:q"]    # Makruk game
  ]

  same_style_examples.each do |first_player, second_player|
    raise "#{first_player} should be valid" unless Sashite::Gan.valid?(first_player)
    raise "#{second_player} should be valid" unless Sashite::Gan.valid?(second_player)
  end
end

# Test piece modifiers in GAN context
run_test("Enhanced pieces validation") do
  enhanced_examples = [
    "CHESS:+P", "chess:+p", "SHOGI:+P", "shogi:+p",
    "XIANGQI:+r", "xiangqi:+R", "MAKRUK:+Q", "makruk:+q"
  ]

  enhanced_examples.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Diminished pieces validation") do
  diminished_examples = [
    "CHESS:-R", "chess:-r", "SHOGI:-G", "shogi:-g",
    "XIANGQI:-a", "xiangqi:-A", "MAKRUK:-N", "makruk:-n"
  ]

  diminished_examples.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Intermediate pieces validation") do
  intermediate_examples = [
    "CHESS:K'", "chess:k'", "SHOGI:R'", "shogi:r'",
    "XIANGQI:P'", "xiangqi:p'", "MAKRUK:B'", "makruk:b'"
  ]

  intermediate_examples.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Combined modifiers validation") do
  combined_examples = [
    "CHESS:+K'", "chess:+k'", "SHOGI:-P'", "shogi:-p'",
    "XIANGQI:+r'", "xiangqi:+R'", "MAKRUK:-Q'", "makruk:-q'"
  ]

  combined_examples.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

# Test collision resolution
run_test("Collision resolution between similar pieces") do
  similar_pieces = [
    "CHESS:R",     # Chess rook
    "SHOGI:R",     # Shogi rook
    "MAKRUK:R",    # Makruk rook
    "xiangqi:r"    # Xiangqi chariot (second player)
  ]

  # All should be valid and distinct
  similar_pieces.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end

  # Create actors and verify they're different
  actors = similar_pieces.map { |gan| Sashite::Gan::Actor.parse(gan) }
  unique_actors = actors.uniq
  raise "All actors should be unique" unless actors.length == unique_actors.length
end

# Test variant styles
run_test("Chess variant styles validation") do
  variant_examples = [
    "CHESS960:K", "chess960:k",     # Fischer Random Chess
    "CHESSKING:Q", "chessking:q",   # King of the Hill
    "MINISHOGI:G", "minishogi:g"    # Mini Shogi
  ]

  variant_examples.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

# Test edge cases
run_test("Single character styles and pieces") do
  edge_cases = [
    "A:A", "a:a", "Z:Z", "z:z",
    "A:+B", "a:-b", "Z:C'", "z:+d'"
  ]

  edge_cases.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

run_test("Alphanumeric styles") do
  alphanumeric_examples = [
    "A1:K", "a1:k", "B2:Q", "b2:q",
    "X9:P", "x9:p", "Z123:R", "z123:r"
  ]

  alphanumeric_examples.each do |gan|
    raise "#{gan} should be valid" unless Sashite::Gan.valid?(gan)
  end
end

# Test comprehensive validation boundary
run_test("Boundary validation cases") do
  # Test that colon is required and must be single
  invalid_separators = [
    "CHESS K",     # Space instead of colon
    "CHESS::K",    # Double colon
    "CHESS;K",     # Semicolon
    "CHESS.K",     # Period
    "CHESS_K"      # Underscore
  ]

  invalid_separators.each do |gan|
    raise "#{gan} should be invalid" if Sashite::Gan.valid?(gan)
  end

  # Test that exactly one colon is required
  multiple_colons = ["CHESS:K:extra", "extra:CHESS:K"]
  multiple_colons.each do |gan|
    raise "#{gan} should be invalid" if Sashite::Gan.valid?(gan)
  end
end

# Test integration with SNN and PNN
run_test("Integration with SNN validation") do
  # These should fail SNN validation specifically
  invalid_snn_cases = [
    "Chess:K",      # Mixed case
    "CHESS-960:K",  # Hyphen not allowed
    "9CHESS:K",     # Must start with letter
    "chess_var:k"   # Underscore not allowed
  ]

  invalid_snn_cases.each do |gan|
    raise "#{gan} should be invalid due to SNN" if Sashite::Gan.valid?(gan)
  end
end

run_test("Integration with PNN validation") do
  # These should fail PNN validation specifically
  invalid_pnn_cases = [
    "CHESS:KK",     # Multiple letters
    "CHESS:++K",    # Double prefix
    "CHESS:K''",    # Double suffix
    "CHESS:K+",     # Suffix in wrong position
    "CHESS:'K",     # Prefix in wrong position
    "CHESS:123"     # Numbers not allowed for piece
  ]

  invalid_pnn_cases.each do |gan|
    raise "#{gan} should be invalid due to PNN" if Sashite::Gan.valid?(gan)
  end
end

puts
puts "All GAN module tests passed!"
puts
