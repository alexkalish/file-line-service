module Logical
  
  # Represents the metadata about a file containing lines of ASCII text that are
  # each terminated by a "\n".  Line numbers start at 0 and not 1.
  class FileMetadata

    def self.generate(file_path)

      unless ::File.exist?(file_path)
        raise "Provided file not found: #{file_path}"
      end

      line_lengths = []
      line_num = 0

      ::File.open(file_path, "r") do |file|
        loop do
          line = file.gets("\n")
          break if line.nil?
          line_lengths[line_num] = line.length
          line_num += 1
        end
      end

      new(file_path, line_num, line_lengths)
    end

    def self.from_json(json_str)
      json = JSON.parse(json_str)
      new(json)
    end

    attr_reader :file_path, :total_lines

    def initialize(file_path, total_lines, line_lengths)
      @file_path = file_path
      @total_lines = total_lines
      @line_lengths = line_lengths
    end

    # Returns the length of the line identified by the provided number.
    def line_length(line_num)
      @line_lengths[line_num]
    end

    def line_exists?(line_num)
      line_num >= 0 && line_num < total_lines
    end

    # Returns the offset in chars/bytes to reach the beginning of the line
    # identified by the provided number.
    def line_offset(line_num)
      return unless line_exists?(line_num)
      line_num == 0 ? 0 : @line_lengths[0..(line_num - 1)].sum
    end

    def to_json
      JSON.generate({
        file_path: file_path,
        total_lines: total_lines,
        line_lengths: @line_lengths
      })
    end

  end
end
