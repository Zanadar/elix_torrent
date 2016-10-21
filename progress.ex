defmodule Progress do
  def progress(i) do
    IO.write "\r[#{String.duplicate "=", i}] #{i} %"
  end

  def start_progress() do
    IO.puts "Starting! in  #{inspect(self)}"
    current = self()
    download_pid = spawn_link(Download.run(current,"https://github.com/zemirco/sf-city-lots-json/blob/master/citylots.json?raw=true" ))
    IO.puts "Downloading from #{inspect download_pid}"
    loop(current, download_pid, 1)
  end

  def loop(current, download_pid, i) do
    receive do
      {^download_pid, _message} -> loop(current, download_pid, i+1)
      other -> {other, :other}
    after
      250 -> progress(i)
              loop(current, download_pid, i+1)
    end
  end
end

defmodule Download do
  def run(caller, _path) do
    fn ->
      IO.puts "Downloading!!! in #{inspect self}"
      ## {:ok, binary} = Mix.Utils.read_path(path)
      Process.send_after(caller, {self(), {:ok, :done}}, 10_000)
    end
  end

  def reply(caller) do

  end
end
