defmodule ElixTorrent.PeerTest do
  use ExUnit.Case

  test "get_peers/1" do
    peers_binary = <<104, 162, 64, 16, 0, 0, 96, 126, 104, 219, 228, 115>>

    {:ok, peers_list} = ElixTorrent.Peer.get_peers peers_binary
    assert 1 == 2
  end
end
