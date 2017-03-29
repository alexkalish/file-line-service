require 'benchmark'

module Logical
  
  # Represents the metadata about a file containing lines of ASCII text that are
  # each newline terminated.  Line numbers start at 0 and not 1.  Currently, this
  # metadata is only stored in process memory, which is fast but not not ideal
  # (or perhaps even tenable) for large files.
  class FileMetadata

    attr_reader :file_path, :total_lines, :file_identifier

    def initialize(file_path)
      @file_path = file_path
      process_file
      stat = File.stat(file_path)
      # Create a system uniqe identifier for the file to help with caching.
      # NOTE: This isn't the most robust identifier, but is a reasonable first pass.
      @file_identifier = Digest::SHA1.hexdigest("#{stat.ino}#{stat.mtime.to_i}")
    end

    # Returns the length of the line identified by the provided index.
    def line_length(line_index)
      @line_lengths[line_index]
    end

    # Returns true if the line is within bounds of file length, false otherwise.
    def line_exists?(line_index)
      line_index >= 0 && line_index < total_lines
    end

    # Returns the offset in chars/bytes to reach the beginning of the line
    # identified by the provided index. Or returns nil if line is out of
    # bounds.
    def line_offset(line_index)
      return unless line_exists?(line_index)
      line_index == 0 ? 0 : @line_lengths[0..(line_index - 1)].sum
    end

    private

    # Read through the file, line by line, to determine the total number
    # of lines and the length of each line.
    def process_file
      @line_lengths = []
      @total_lines = 0

      Rails.logger.info("Begin processing file: #{@file_path}" )

      time = Benchmark.realtime do
        File.open(@file_path, "r") do |file|
          loop do
            line = file.gets("\n")
            break if line.nil?
            @line_lengths[@total_lines] = line.length
            @total_lines += 1
          end
        end
      end

      Rails.logger.info("File processing done, duration: #{time}" )
    end

  end
end
