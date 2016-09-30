defmodule ElixTorrent.Tracker do

  def start(path) do
    {:ok, metafile} = File.read path
    {:ok, torrent_dict} = Benlixir.Decoder.decode metafile

    make_request({ :ok, torrent_dict })
  end

  defp make_request({:ok, torrent_dict}) do
    {:ok, info} = Bento.Encoder.encode torrent_dict.info
    info_hash - :crypto.hash(:sha, info)
  end
end
