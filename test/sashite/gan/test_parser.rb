# frozen_string_literal: true

require_relative "../../../lib/sashite/gan/parser"

puts "Testing Sashite::Gan::Parser..."

# Test 1: Basic functionality with a chess king
result = Sashite::Gan::Parser.parse("CHESS:K")
expected = { game_id: "CHESS", letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 2: Basic functionality with a black chess king (lowercase)
result = Sashite::Gan::Parser.parse("chess:k")
expected = { game_id: "chess", letter: "k" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 3: With prefix (promoted shogi pawn)
result = Sashite::Gan::Parser.parse("SHOGI:+P")
expected = { game_id: "SHOGI", letter: "P", prefix: "+" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 4: With suffix (chess king with castling rights)
result = Sashite::Gan::Parser.parse("CHESS:K'")
expected = { game_id: "CHESS", letter: "K", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 5: With both prefix and suffix
result = Sashite::Gan::Parser.parse("SHOGI:+R'")
expected = { game_id: "SHOGI", letter: "R", prefix: "+", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 6: Error handling - invalid GAN string (missing colon)
begin
  Sashite::Gan::Parser.parse("CHESSK")
  raise "Expected ArgumentError for invalid GAN string, but no error was raised"
rescue ArgumentError => e
  expected_message = "Invalid GAN string: CHESSK"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 7: Error handling - invalid GAN string (empty)
begin
  Sashite::Gan::Parser.parse("")
  raise "Expected ArgumentError for empty GAN string, but no error was raised"
rescue ArgumentError => e
  expected_message = "Invalid GAN string: "
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 8: Error handling - invalid GAN string (invalid PNN part)
begin
  Sashite::Gan::Parser.parse("CHESS:KK")
  raise "Expected ArgumentError for invalid PNN part, but no error was raised"
rescue ArgumentError => e
  expected_message = "Invalid GAN string: CHESS:KK"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 9: Error handling - casing mismatch (uppercase game_id with lowercase letter)
begin
  Sashite::Gan::Parser.parse("CHESS:k")
  raise "Expected ArgumentError for casing mismatch, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID casing (CHESS) must match piece letter casing (k)"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 10: Error handling - casing mismatch (lowercase game_id with uppercase letter)
begin
  Sashite::Gan::Parser.parse("chess:K")
  raise "Expected ArgumentError for casing mismatch, but no error was raised"
rescue ArgumentError => e
  expected_message = "Game ID casing (chess) must match piece letter casing (K)"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

# Test 11: Safe parse with valid GAN string
result = Sashite::Gan::Parser.safe_parse("CHESS:K")
expected = { game_id: "CHESS", letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 12: Safe parse with invalid GAN string
result = Sashite::Gan::Parser.safe_parse("invalid GAN string")
raise "Expected nil, got #{result}" unless result.nil?

# Test 13: String conversion for non-string input
result = Sashite::Gan::Parser.parse(:"CHESS:K")
expected = { game_id: "CHESS", letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 14: Test with single-letter game_id
result = Sashite::Gan::Parser.parse("X:K")
expected = { game_id: "X", letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 15: Test with very long game_id
long_game_id = "VERYLONGGAMEID"
result = Sashite::Gan::Parser.parse("#{long_game_id}:K")
expected = { game_id: long_game_id, letter: "K" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 16: Test with diminished piece (with - prefix)
result = Sashite::Gan::Parser.parse("CHESS:-K")
expected = { game_id: "CHESS", letter: "K", prefix: "-" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 17: Test casing consistency with prefixed and suffixed pieces
# This ensures that the casing check looks at the letter, not the modifiers
result = Sashite::Gan::Parser.parse("SHOGI:+P'")
expected = { game_id: "SHOGI", letter: "P", prefix: "+", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 18: Test with all lowercase, including prefix
result = Sashite::Gan::Parser.parse("shogi:+p'")
expected = { game_id: "shogi", letter: "p", prefix: "+", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 19: Ensure the new suffix format is properly recognized
result = Sashite::Gan::Parser.parse("CHESS:K'")
expected = { game_id: "CHESS", letter: "K", suffix: "'" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Test 20: Ensure the old suffix formats are rejected
begin
  Sashite::Gan::Parser.parse("CHESS:K=")
  raise "Expected ArgumentError for old suffix format, but no error was raised"
rescue ArgumentError => e
  expected_message = "Invalid GAN string: CHESS:K="
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

begin
  Sashite::Gan::Parser.parse("CHESS:K<")
  raise "Expected ArgumentError for old suffix format, but no error was raised"
rescue ArgumentError => e
  expected_message = "Invalid GAN string: CHESS:K<"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

begin
  Sashite::Gan::Parser.parse("CHESS:K>")
  raise "Expected ArgumentError for old suffix format, but no error was raised"
rescue ArgumentError => e
  expected_message = "Invalid GAN string: CHESS:K>"
  raise "Expected error message '#{expected_message}', got '#{e.message}'" unless e.message == expected_message
end

puts "All Sashite::Gan::Parser tests passed!"
