# frozen_string_literal: true

require_relative "../../lib/sashite/gan"

puts "Testing Sashite::Gan module..."

# Test dump method
puts "  Testing Sashite::Gan.dump..."

# Test 1: Basic dump functionality (chess king)
result = Sashite::Gan.dump(game_id: "CHESS", letter: "K")
raise "Expected 'CHESS:K', got '#{result}'" unless result == "CHESS:K"

# Test 2: Dump with prefix (promoted shogi pawn)
result = Sashite::Gan.dump(game_id: "SHOGI", letter: "P", prefix: "+")
raise "Expected 'SHOGI:+P', got '#{result}'" unless result == "SHOGI:+P"

# Test 3: Dump with suffix (chess king with castling rights)
result = Sashite::Gan.dump(game_id: "CHESS", letter: "K", suffix: "'")
raise "Expected 'CHESS:K'', got '#{result}'" unless result == "CHESS:K'"

# Test 4: Dump with both prefix and suffix
result = Sashite::Gan.dump(game_id: "SHOGI", letter: "R", prefix: "+", suffix: "'")
raise "Expected 'SHOGI:+R'', got '#{result}'" unless result == "SHOGI:+R'"

# Test 5: Dump error handling (invalid game_id)
begin
  Sashite::Gan.dump(game_id: "CHESS123", letter: "K")
  raise "Expected ArgumentError for invalid game_id, but no error was raised"
rescue ArgumentError
  # Error raised correctly
end

# Test parse method
puts "  Testing Sashite::Gan.parse..."

# Test 6: Basic parse functionality (chess king)
result = Sashite::Gan.parse("CHESS:K")
expected = { game_id: "CHESS", letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 7: Parse with prefix (promoted shogi pawn)
result = Sashite::Gan.parse("SHOGI:+P")
expected = { game_id: "SHOGI", letter: "P", prefix: "+" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 8: Parse with suffix (chess king with castling rights)
result = Sashite::Gan.parse("CHESS:K'")
expected = { game_id: "CHESS", letter: "K", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 9: Parse with both prefix and suffix
result = Sashite::Gan.parse("SHOGI:+R'")
expected = { game_id: "SHOGI", letter: "R", prefix: "+", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 10: Parse error handling (invalid GAN string)
begin
  Sashite::Gan.parse("invalid")
  raise "Expected ArgumentError for invalid GAN string, but no error was raised"
rescue ArgumentError
  # Error raised correctly
end

# Test safe_parse method
puts "  Testing Sashite::Gan.safe_parse..."

# Test 11: Safe parse with valid input
result = Sashite::Gan.safe_parse("CHESS:K")
expected = { game_id: "CHESS", letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 12: Safe parse with invalid input
result = Sashite::Gan.safe_parse("invalid")
raise "Expected nil for invalid input, got #{result}" unless result.nil?

# Test 13: Safe parse with nil
result = Sashite::Gan.safe_parse(nil)
raise "Expected nil for nil input, got #{result}" unless result.nil?

# Test valid? method
puts "  Testing Sashite::Gan.valid?..."

# Test 14: Validation of valid GAN strings
valid_gan_strings = [
  "CHESS:K",
  "chess:k",
  "SHOGI:+P",
  "chess:+p",
  "CHESS:K'",
  "chess:k'",
  "SHOGI:+R'",
  "shogi:+r'"
]

valid_gan_strings.each do |gan_string|
  result = Sashite::Gan.valid?(gan_string)
  raise "Expected true for valid GAN string '#{gan_string}', got #{result}" unless result == true
end

# Test 15: Validation of invalid GAN strings
invalid_gan_strings = [
  "",
  "CHESS",
  "CHESS:",
  ":K",
  "CHESS:KK",
  "CHESS:K=",  # Old suffix format
  "CHESS:K<",  # Old suffix format
  "CHESS:K>",  # Old suffix format
  "CHESS:k",   # Casing mismatch
  "chess:K",   # Casing mismatch
  "CHESS123:K",
  "CHESS-VARIANT:K",
  "ChEsS:K"    # Mixed case game_id
]

invalid_gan_strings.each do |gan_string|
  result = Sashite::Gan.valid?(gan_string)
  raise "Expected false for invalid GAN string '#{gan_string}', got #{result}" unless result == false
end

# Test 16: Integration test - dump and parse cycle
original_params = { game_id: "CHESS", letter: "K", suffix: "'" }
gan_string = Sashite::Gan.dump(**original_params)
parsed_result = Sashite::Gan.parse(gan_string)
reconstructed_params = { game_id: parsed_result[:game_id], letter: parsed_result[:letter] }
reconstructed_params[:suffix] = parsed_result[:suffix] if parsed_result[:suffix]
reconstructed_params[:prefix] = parsed_result[:prefix] if parsed_result[:prefix]

raise "Expected #{original_params}, got #{reconstructed_params}" unless original_params == reconstructed_params

# Test 17: Integration test - valid? and parse cycle
gan_string = "CHESS:K'"
raise "Expected string to be valid" unless Sashite::Gan.valid?(gan_string)

begin
  Sashite::Gan.parse(gan_string)
  # If we reach here, no exception was thrown, which is correct
rescue ArgumentError => e
  raise "Unexpected error parsing valid GAN string: #{e.message}"
end

# Test 18: Integration test - dump and valid? cycle
gan_string = Sashite::Gan.dump(game_id: "CHESS", letter: "K", suffix: "'")
raise "Expected dumped string to be valid" unless Sashite::Gan.valid?(gan_string)

# Test 19: Test with diminished pieces (with - prefix)
result = Sashite::Gan.dump(game_id: "CHESS", letter: "K", prefix: "-")
raise "Expected 'CHESS:-K', got '#{result}'" unless result == "CHESS:-K"

result = Sashite::Gan.parse("CHESS:-K")
expected = { game_id: "CHESS", letter: "K", prefix: "-" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 20: Test with all lowercase, including prefix and suffix
result = Sashite::Gan.dump(game_id: "shogi", letter: "p", prefix: "+", suffix: "'")
raise "Expected 'shogi:+p'', got '#{result}'" unless result == "shogi:+p'"

result = Sashite::Gan.parse("shogi:+p'")
expected = { game_id: "shogi", letter: "p", prefix: "+", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

puts "All Sashite::Gan module tests passed!"
