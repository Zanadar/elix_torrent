defmodule ElixTorrent.Tracker do

  def start(path) do
    {:ok, metafile} = File.read path
    case make_request({ :ok, metafile }) do
      {:ok, response} -> response.body
      other -> other
    end
  end

  defp make_request({:ok, torrent_dict}) do
    case Bencode.decode_with_info_hash torrent_dict do
      {:ok, data, checksum} -> get {data, checksum}
      {:error, reason} -> IO.puts reason
    end
  end

  defp get({data, checksum}) do
    tracker_url = construct_get({data, checksum})
    HTTPoison.get tracker_url
  end

  defp construct_get {data, checksum} do
    params = query_params({data, checksum})
    announce_uri = URI.parse( data["announce"])
    query = URI.encode_query(params)

    %URI{announce_uri | query: query}
  end

  defp query_params({data, checksum}) do
    [info_hash: checksum, left: data["info"]["length"], peer_id: "-TZ-0000-00000000000"]
  end
end
