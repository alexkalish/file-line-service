# This will load the file to be served by the app.  It assumes the the file is located
# at config/file.txt.

Logical::HostedFile.current_file = Logical::HostedFile.new(Rails.root.join("config", "file.txt"))
