# This will load the file to be served by the app.  It assumes the the file is located
# at config/file.txt.

Rails.configuration.current_file = Logical::File.new(Rails.root.join("config", "file.txt"))
