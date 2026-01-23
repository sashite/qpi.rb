#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/qpi/errors"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "=== Errors Tests ==="
puts

# ============================================================================
# PARSING ERROR MESSAGES
# ============================================================================

puts "Parsing error messages:"

run_test("EMPTY_INPUT is defined") do
  raise "wrong value" unless Sashite::Qpi::Errors::Argument::Messages::EMPTY_INPUT == "empty input"
end

run_test("MISSING_SEPARATOR is defined") do
  raise "wrong value" unless Sashite::Qpi::Errors::Argument::Messages::MISSING_SEPARATOR == "missing colon separator"
end

run_test("MISSING_SIN is defined") do
  raise "wrong value" unless Sashite::Qpi::Errors::Argument::Messages::MISSING_SIN == "missing SIN component"
end

run_test("MISSING_PIN is defined") do
  raise "wrong value" unless Sashite::Qpi::Errors::Argument::Messages::MISSING_PIN == "missing PIN component"
end

run_test("INVALID_SIN is defined") do
  raise "wrong value" unless Sashite::Qpi::Errors::Argument::Messages::INVALID_SIN == "invalid SIN component"
end

run_test("INVALID_PIN is defined") do
  raise "wrong value" unless Sashite::Qpi::Errors::Argument::Messages::INVALID_PIN == "invalid PIN component"
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("Argument inherits from ArgumentError") do
  raise "wrong inheritance" unless Sashite::Qpi::Errors::Argument < ArgumentError
end

run_test("Argument can be raised with message") do
  raise Sashite::Qpi::Errors::Argument, Sashite::Qpi::Errors::Argument::Messages::EMPTY_INPUT
rescue Sashite::Qpi::Errors::Argument => e
  raise "wrong message" unless e.message == "empty input"
end

run_test("Argument can be rescued as ArgumentError") do
  raise Sashite::Qpi::Errors::Argument, "test"
rescue ArgumentError => e
  raise "should be rescuable as ArgumentError" unless e.message == "test"
end

# ============================================================================
# ERROR MESSAGES ARE FROZEN
# ============================================================================

puts
puts "Immutability:"

run_test("EMPTY_INPUT is frozen") do
  raise "should be frozen" unless Sashite::Qpi::Errors::Argument::Messages::EMPTY_INPUT.frozen?
end

run_test("MISSING_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Qpi::Errors::Argument::Messages::MISSING_SEPARATOR.frozen?
end

run_test("MISSING_SIN is frozen") do
  raise "should be frozen" unless Sashite::Qpi::Errors::Argument::Messages::MISSING_SIN.frozen?
end

run_test("MISSING_PIN is frozen") do
  raise "should be frozen" unless Sashite::Qpi::Errors::Argument::Messages::MISSING_PIN.frozen?
end

run_test("INVALID_SIN is frozen") do
  raise "should be frozen" unless Sashite::Qpi::Errors::Argument::Messages::INVALID_SIN.frozen?
end

run_test("INVALID_PIN is frozen") do
  raise "should be frozen" unless Sashite::Qpi::Errors::Argument::Messages::INVALID_PIN.frozen?
end

puts
puts "All Errors tests passed!"
puts
