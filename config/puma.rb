# Do not multithread, as this app isn't necessarily thread-safe.
threads 1,1

# Support concurrent requests using multiple worker processes.
workers 3

# Preload the app to ensure that the file is processed on boot.
preload_app!

on_worker_boot do
  # Each time a new worker boots, have it reopen the hosted file to ensure that
  # it has a new entry in the OS file table (with a new pos).
  Logical::HostedFile.current_file.reopen_file!
end

on_worker_shutdown do
  # Might not be strictkly necessary, but closing the opened file upon worker
  # shutdown seems like the polite thing to do.
  Logical::HostedFile.current_file.close
end
