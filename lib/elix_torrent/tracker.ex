defmodule ElixTorrent.Tracker do
  alias ElixTorrent.Peer.Util

  def start(path) do
    {:ok, metafile} = File.read path
    with {:ok, tracker_response} <- make_request({ :ok, metafile }),
         {:ok, decoded_reponse} <- Bencode.decode(tracker_response.body),
         {:ok, peers_list} <- Util.get_peers(decoded_reponse["peers"]),
         [peer1 | rest] = peers_list,
         {:ok, pid} = Peer.start_link(peer1) do
           {:ok, pid, metafile}
       else
         :error -> {:error, :cannot_connect}
         error -> error
       end
  end

  defp make_request({:ok, torrent_dict}) do
    case Bencode.decode_with_info_hash torrent_dict do
      {:ok, data, checksum} -> get({data, checksum})
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
