defmodule ElixTorrent.Tracker do
  def start(path) do
    {:ok, metafile} = File.read path
    opts = [:binary, active: false]
    with {:ok, tracker_response} <- make_request({ :ok, metafile }),
         {:ok, decoded_reponse} <- Bencode.decode(tracker_response.body),
         {:ok, peers_list} <- ElixTorrent.Peer.get_peers(decoded_reponse["peers"]),
         [peer1 | rest] = peers_list,
         {ip, port} <- ElixTorrent.Peer.print_peer(peer1),
         {:ok, socket} <- :gen_tcp.connect(ip, port, opts) do
        {:ok, socket}
       else
         :error -> {:error, :cannot_connect}
         error -> error
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
