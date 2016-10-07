defmodule ElixTorrent.PeerTest do
  alias ElixTorrent.Peer
  use ExUnit.Case

  describe "Peer.get_peers/1" do
    test "it parses a binary into peer structs" do
      peers_binary = <<104, 162, 64, 16, 0, 0, 96, 126, 104, 219, 228, 115>>

      {:ok, peers_list} = Peer.get_peers peers_binary
      assert length(peers_list) == 2
      assert peers_list == [%Peer{ip: <<96, 126, 104, 219>>, port: <<228, 115>>}, %Peer{ip: <<104, 162, 64, 16>>, port: <<0, 0>>}]
    end

    test "rejects binaries not composed of proper peer strucuture" do
      peers_binary = <<104, 162, 64, 16, 0, 0, 96, 126, 104, 219, 228, 115, 17>>

      assert {:error, _} = Peer.get_peers peers_binary
    end
  end

  describe "Peer.print_peer/1" do
    test "returns a tuple of formatted ip and port for connecting" do
      result = %ElixTorrent.Peer{ip: <<96, 126, 104, 219>>, port: <<228, 115>>} |> Peer.print_peer
      assert {'96.126.104.219', (228 * 256 + 115)} == result
    end
  end
end
