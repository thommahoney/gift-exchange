#!/usr/bin/env ruby

##
# Script to assign participants in a gift exchange.
# 
# Accepts an arbitrary number of participants and assigns them randomly. The first
# two names in the list of participants are considered organizers. The script will
# create files for each organizer to read, keeping assignments related to each
# organizer a secret!  Organizers will never be assigned to each other.
#
# TODO:
#   - accept forbidden assignments
##

def print_usage_and_exit
    STDERR.puts "Usage: ./gift-exchange.rb <name1> <name2> <name3> [<name4> ...]"
    exit 1
end

print_usage_and_exit unless ARGV.length >= 3

DEBUG = ENV["DEBUG_GIFT_EXCHANGE"] == "1"

participants = ARGV.clone
organizer1, organizer2 = participants[0..1]
assignments = participants.clone.shuffle

loop do
  no_self_assignments = participants.map.each_with_index { |p, idx| p != assignments[idx] }.all?
  no_org_assignments = assignments[0] != organizer2 && assignments[1] != organizer1

  break if no_self_assignments && no_org_assignments

  assignments.shuffle!
end

outcome = participants.zip(assignments).to_h

org1_contents = []
org2_contents = []

outcome.each_with_index do |(purchaser, recipient), idx|
  contents = "#{purchaser} buys a gift for #{recipient}"
  if purchaser == organizer2 || recipient == organizer1
    org2_contents << contents
  elsif purchaser == organizer1 || recipient == organizer2
    org1_contents << contents
  else
    if idx % 2 == 0
      org1_contents << contents
    else
      org2_contents << contents
    end
  end
end

if DEBUG
  STDOUT.puts "Organizer 1 (#{organizer1}) sees:"
  STDERR.puts "\t#{org1_contents.join "\n\t"}"
  STDOUT.puts
  STDOUT.puts "Organizer 2 (#{organizer2}) sees:"
  STDOUT.puts "\t#{org2_contents.join "\n\t"}"
else
  File.write("assignments-for-#{organizer1}.txt", org1_contents.join("\n"))
  File.write("assignments-for-#{organizer2}.txt", org2_contents.join("\n"))
end

