defmodule ElixTorrent.Peer do
  defstruct ip: nil, port: nil

  def get_peers(peers_binary) do
    parse_peers([], peers_binary)
  end

  defp parse_peers(peers_list, <<>>) do
    {:ok, peers_list}
  end

  defp parse_peers(peers_list, <<ip::binary-size(4), port::binary-size(2), rest::binary>>) do
    peers_list = [%__MODULE__{ip: ip, port: port} | peers_list]
    parse_peers(peers_list, rest)
  end
end
