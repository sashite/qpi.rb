# frozen_string_literal: true

require_relative "../../../lib/sashite/gan/validator"

puts "Testing Sashite::Gan::Validator..."

# Test 1: Basic validation of a valid GAN string (chess king)
result = Sashite::Gan::Validator.valid?("CHESS:K")
raise "Expected true for valid GAN string 'CHESS:K', got #{result}" unless result == true

# Test 2: Basic validation of a valid GAN string (black chess king)
result = Sashite::Gan::Validator.valid?("chess:k")
raise "Expected true for valid GAN string 'chess:k', got #{result}" unless result == true

# Test 3: Validation with prefix (promoted shogi pawn)
result = Sashite::Gan::Validator.valid?("SHOGI:+P")
raise "Expected true for valid GAN string 'SHOGI:+P', got #{result}" unless result == true

# Test 4: Validation with suffix (chess king with castling rights)
result = Sashite::Gan::Validator.valid?("CHESS:K'")
raise "Expected true for valid GAN string 'CHESS:K'', got #{result}" unless result == true

# Test 5: Validation with both prefix and suffix
result = Sashite::Gan::Validator.valid?("SHOGI:+R'")
raise "Expected true for valid GAN string 'SHOGI:+R'', got #{result}" unless result == true

# Test 6: Validation with diminished piece (with - prefix)
result = Sashite::Gan::Validator.valid?("CHESS:-K")
raise "Expected true for valid GAN string 'CHESS:-K', got #{result}" unless result == true

# Test 7: Invalid GAN string (missing colon)
result = Sashite::Gan::Validator.valid?("CHESSK")
raise "Expected false for invalid GAN string 'CHESSK', got #{result}" unless result == false

# Test 8: Invalid GAN string (empty string)
result = Sashite::Gan::Validator.valid?("")
raise "Expected false for empty GAN string, got #{result}" unless result == false

# Test 9: Invalid GAN string (nil)
result = Sashite::Gan::Validator.valid?(nil)
raise "Expected false for nil GAN string, got #{result}" unless result == false

# Test 10: Invalid GAN string (invalid PNN part - multiple letters)
result = Sashite::Gan::Validator.valid?("CHESS:KK")
raise "Expected false for invalid GAN string 'CHESS:KK', got #{result}" unless result == false

# Test 11: Invalid GAN string (casing mismatch - uppercase game_id with lowercase letter)
result = Sashite::Gan::Validator.valid?("CHESS:k")
raise "Expected false for casing mismatch 'CHESS:k', got #{result}" unless result == false

# Test 12: Invalid GAN string (casing mismatch - lowercase game_id with uppercase letter)
result = Sashite::Gan::Validator.valid?("chess:K")
raise "Expected false for casing mismatch 'chess:K', got #{result}" unless result == false

# Test 13: Validation with non-string input (should return false)
result = Sashite::Gan::Validator.valid?(123)
raise "Expected false for non-string input, got #{result}" unless result == false

# Test 14: Validation with single-letter game_id
result = Sashite::Gan::Validator.valid?("X:K")
raise "Expected true for valid GAN string 'X:K', got #{result}" unless result == true

# Test 15: Validation with very long game_id
long_game_id = "VERYLONGGAMEID"
result = Sashite::Gan::Validator.valid?("#{long_game_id}:K")
raise "Expected true for valid GAN string '#{long_game_id}:K', got #{result}" unless result == true

# Test 16: Invalid GAN string (game_id with non-letter characters)
result = Sashite::Gan::Validator.valid?("CHESS123:K")
raise "Expected false for invalid game_id 'CHESS123:K', got #{result}" unless result == false

# Test 17: Invalid GAN string (game_id with special characters)
result = Sashite::Gan::Validator.valid?("CHESS-VARIANT:K")
raise "Expected false for invalid game_id 'CHESS-VARIANT:K', got #{result}" unless result == false

# Test 18: Invalid GAN string (mixed case game_id)
result = Sashite::Gan::Validator.valid?("ChEsS:K")
raise "Expected false for mixed case game_id 'ChEsS:K', got #{result}" unless result == false

# Test 19: Validation of lowercase piece with prefix and suffix
result = Sashite::Gan::Validator.valid?("shogi:+p'")
raise "Expected true for valid GAN string 'shogi:+p'', got #{result}" unless result == true

# Test 20: Reject old suffix formats
result = Sashite::Gan::Validator.valid?("CHESS:K=")
raise "Expected false for old suffix format 'CHESS:K=', got #{result}" unless result == false

result = Sashite::Gan::Validator.valid?("CHESS:K<")
raise "Expected false for old suffix format 'CHESS:K<', got #{result}" unless result == false

result = Sashite::Gan::Validator.valid?("CHESS:K>")
raise "Expected false for old suffix format 'CHESS:K>', got #{result}" unless result == false

# Test 21: Invalid GAN string (multiple suffixes)
result = Sashite::Gan::Validator.valid?("CHESS:K''")
raise "Expected false for multiple suffixes 'CHESS:K''', got #{result}" unless result == false

# Test 22: Invalid GAN string (invalid prefix)
result = Sashite::Gan::Validator.valid?("CHESS:*K")
raise "Expected false for invalid prefix 'CHESS:*K', got #{result}" unless result == false

# Test 23: Invalid GAN string (multiple prefixes)
result = Sashite::Gan::Validator.valid?("CHESS:++K")
raise "Expected false for multiple prefixes 'CHESS:++K', got #{result}" unless result == false

puts "All Sashite::Gan::Validator tests passed!"
