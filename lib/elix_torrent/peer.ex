defmodule Peer do
  use GenServer
  alias ElixTorrent.Peer.Util

  @initial_state %{socket: nil}

  def start_link(peer_info) do
    GenServer.start_link(__MODULE__, [@initial_state, peer_info])
  end

  def command(pid, cmd) do
    GenServer.call(pid, {:command, cmd})
  end

  def init([state, peer_info]) do
    opts = [:binary, active: false]
    with {ip, port} <- Util.print_peer(peer_info),
        {:ok, socket} <- :gen_tcp.connect(ip, port, opts),
        do: {:ok, %{state | socket: socket}}
  end

  def handle_call({:command, cmd}, from, %{socket: socket} = state) do
    {type, _} = cmd
    :ok = :gen_tcp.send(socket, Peer.Wire.encode(cmd))

    {:ok, msg} = :gen_tcp.recv(socket, 0)
    {:reply, Peer.Wire.decode({type, msg}), state}
  end
end

defmodule Peer.Wire do
  # TDD this
  def encode({:handshake, info_hash}) do
    pstrlen = <<19>>
    pstr = "BitTorrent protocol"
    reserved = <<0::size(64)>>
    peer_id = "-TZ-0000-00000000000"
    pstrlen<>pstr<>reserved<>info_hash<>peer_id
  end

  def decode({:handshake, peer_handshake}) do
    <<pstrlen, rest::binary>> = peer_handshake
    <<pstr::bytes-size(pstrlen), reserved::bytes-size(8), info_hash::bytes-size(20), peer_id::bytes-size(20), rest::binary>> = rest
    {pstrlen, pstr, reserved, info_hash, peer_id, rest}
  end
end
