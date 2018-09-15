#!/usr/bin/env ruby
require 'json'
require_relative 'result'
require_relative 'alfred3_workflow'

class DictWorkFlow
  FILENAME = 'cmodbnkkcf-52898166-ea5ea5.txt'.freeze
  ALPHABET = ('a'..'z').map(&:upcase).to_a

  def indexing_required?
    !File.exist?('A' + '_' + FILENAME)
  end

  def dictionary_missing?
    !File.exist?(FILENAME)
  end

  def clear_index
    ALPHABET.append '@'
    ALPHABET.each do |letter|
      File.delete(letter + '_' + FILENAME)
    end
  end

  def first_letter_from_line(line)
    first_letter = line[0].upcase
    first_letter = '@' unless ALPHABET.include? first_letter
    first_letter
  end

  def generate_index
    full = File.readlines(FILENAME)
    full.select! do |line|
      ALPHABET.include?(first_letter_from_line(line)) && line.split("\t").include?('noun')
    end
    memo = {}
    full.each do |line|
      first_letter = first_letter_from_line(line)
      memo[first_letter] = [] if memo[first_letter].nil?
      memo[first_letter] << line
    end
    memo.each do |initial, line|
      File.open(initial + '_' + FILENAME, 'w+') { |f| f.puts(line.sort) }
    end
  end

  def gender_from_word(word)
    if word.split(' ').include? '{f}'
      'icons/f.png'
    elsif word.split(' ').include? '{n}'
      'icons/n.png'
    elsif word.split(' ').include? '{m}'
      'icons/m.png'
    elsif word.split(' ').include? '{pl}'
      'icons/pl.png'
    else
      'icons/unknown.png'
    end
  end

  def row_matches(input)
    first_letter = input[0]
    lines = File.readlines(first_letter.downcase + '_' + FILENAME)
    lines.select! { |line| line.downcase.start_with? input }
    lines
  end

  def rows_to_hash(rows)
    rows.map do |row|
      component = row.split("\t")
      everything_else = component[1..-1].join(' ').strip!
      name = component.first
      { name: name,
        definition: everything_else,
        gender: gender_from_word(name) }
    end
  end

  def hashes_to_alfred_output(hashes)
    hashes = hashes[0...15]
    workflow = Alfred3::Workflow.new
    hashes.each do |hash|
      name = hash[:name]
      gender_icon = gender_from_word(name)
      workflow.result
              .uid('create_index')
              .title(name.gsub(/{.*}/, ''))
              .subtitle(hash[:definition])
              .icon(gender_icon)
    end
    print workflow.output
  end
end

input = ARGV[0].downcase.unicode_normalize
workflow = Alfred3::Workflow.new
dw = DictWorkFlow.new

if input == 'wf:generate_index'
  dw.generate_index
  workflow.result
          .uid('create_index')
          .title('Indexes created')
          .subtitle('You can now perform a new search')
          .icon('icons/checked.png')
  print workflow.output
  exit 0
end

if dw.dictionary_missing?
  workflow.result
          .uid('missing_index')
          .title('Dictionary is missing')
          .valid(true)
          .subtitle('Please read the instruction on github.com/ignazio/dictcc')
          .quicklookurl('http://github.com/ignazioc')
          .icon('icons/warning.png')
  print workflow.output
  exit 0
end

if dw.indexing_required?
  workflow.result
          .uid('missing_index')
          .title('Create the index')
          .subtitle('Select this action to create the index. Takes up to 20 seconds')
          .quicklookurl('http://github.com/ignazioc')
          .icon('icons/warning.png')
          .autocomplete('wf:generate_index')
  print workflow.output
  exit 0
end

rows = dw.row_matches(input)
results = dw.rows_to_hash(rows)
if results.count.zero?
  workflow.result
          .uid('missing')
          .title("No results for: #{input}")
          .subtitle('Sorry ')
          .icon('icons/cancel.png')
  print workflow.output
else
  print dw.hashes_to_alfred_output(results)
end
