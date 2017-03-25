module Logical

  # Represents a text file containing newline termined lines of ASCII text.
  class File

    delegate :total_lines, :line_exists?, to: :@file_meta

    def initialize(file_path)
      @file_path = file_path
      @file = ::File.open(file_path, "r")
      @file_meta = Logical::FileMetadata.generate(file_path)
    end

    def line(line_num)
      offset = @file_meta.line_offset(line_num)
      unless offset.nil?
        @file.seek(offset, IO::SEEK_SET)
        @file.gets("\n")
      end
    end
    
  end
end
