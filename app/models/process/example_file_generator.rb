require 'benchmark'

module Process
  class ExampleFileGenerator 

    # Generates an example file of ASCII text lines in the following format:
    #   ^<line index> - <number of a's> $
    #
    # Example Usage:
    #   bin/rails runner "Process::ExampleFileGenerator.run(max_line_length: 100, line_count: 10_000)"
    #
    def self.run(max_line_length: 50, line_count: 100)
      path = Rails.root.join("tmp", "example_file.txt")
      puts "Generating file #{path} with #{line_count} lines of max #{max_line_length} chars each"

      File.open(path, "w:ascii") do |file|
        1.upto(line_count) do |n|
          line_prefix = "^#{n} - "
          line_length = max_line_length - Random.rand(max_line_length * 0.25) - line_prefix.length - 2
          file.write("#{line_prefix}#{"a" * line_length} $\n")
        end
      end

      puts "Complete"
    end

  end
end
