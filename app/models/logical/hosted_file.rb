module Logical

  # Represents the file hosted by the server.  Since the server only needs to support
  # hosting a single file at a time, the reference to this file is stored here as
  # a class attribute.
  class HostedFile

    # The current file that is being hosted by the application.
    class_attribute :current_file

    attr_reader :file_path

    delegate :total_lines, :line_exists?, :file_identifier, to: :@file_metadata
    delegate :line, :close, to: :@file_contents

    def initialize(file_path)
      unless File.exist?(file_path)
        raise "Provided file not found: #{file_path}"
      end
      @file_path = file_path
      @file_metadata = FileMetadata.new(file_path) 
      reopen_file!
    end

    # Reopen the file from the file system, but avoid regenerating the file
    # metadata.
    def reopen_file!
      @file_contents = FileContents.new(file_path, @file_metadata)
    end

  end
end
