worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

before_fork do |server, worker|
  Signal.trap 'TERM' do
    Process.kill 'QUIT', Process.pid
  end
end
