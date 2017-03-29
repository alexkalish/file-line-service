module Logical

  # Provides access to the contents of the hosted file, which contains newline
  # terminated lines of ASCII text, using the provided file metadata.
  class FileContents

    delegate :close, to: :@file

    def initialize(file_path, file_metadata)
      @file_path = file_path
      @file_metadata = file_metadata
      @file = File.open(file_path, "r")
    end

    # Return the line of text from the file found at the provided index.
    def line(line_index)
      offset = @file_metadata.line_offset(line_index)
      unless offset.nil?
        @file.seek(offset, IO::SEEK_SET)
        @file.gets("\n")
      end
    end

  end
end
