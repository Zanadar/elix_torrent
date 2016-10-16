defmodule ElixTorrent.Peer.Util do
  use Bitwise
  require IEx

  defstruct ip: nil, port: nil

  def get_peers(peers_binary) when rem(byte_size(peers_binary), 6) != 0, do: {:error, :bad_length}

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

  def print_peer(peer) do
    <<a, b, c, d>> = peer.ip
    [a, b, c, d] = Enum.map([a, b, c, d], &Integer.to_string/1)
    ip_string = a <> "." <> b <> "." <> c <> "." <> d
    ip_list = to_charlist ip_string
    <<a, b>> = peer.port
    port = (a <<< 8)  + b
    {ip_list, port}
  end
end
