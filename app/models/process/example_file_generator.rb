module Process
  class ExampleFileGenerator 

    # Generates an example file of ASCII text lines that are prefixed with a carrot and the
    # line number, followed by space dash space, a random number of "a"s, a space and a dollar
    # sign.
    def self.create(max_line_length: 50, line_count: 100)
      path = Rails.root.join("tmp", "example_file.txt")
      file = File.new(path, "w:ascii")

      puts "Generating file #{path} with #{line_count} lines of max #{max_line_length} chars each"

      1.upto(line_count) do |n|
        line_prefix = "^#{n} - "
        line_length = max_line_length - Random.rand(max_line_length * 0.25) - line_prefix.length - 2
        file.write("#{line_prefix}#{"a" * line_length} $\n")
      end

      file.close

      puts "Complete"
    end

  end
end
