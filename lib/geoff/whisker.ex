defmodule Geoff.Whisker do
  alias Roombex.{WhereAmI,DeadReckoner,DJ}
  alias Roombex.State.Sensors

  # Public Interface
  def start_link(genserver_opts) do
    GenServer.start_link(__MODULE__, nil, genserver_opts)
  end

  def whereami(pid \\ __MODULE__), do: GenServer.call(pid, :whereami)

  # Server Callbacks
  def init(nil) do
    {:ok, %{}}
  end

  def handle_call(:whereami, _from, %{whereami: whereami}=state) do
    {:reply, {:ok, whereami}, state}
  end
  def handle_call(:whereami, _from, state) do
    {:reply, {:error, :i_dont_know}, state}
  end

  def handle_info({:roomba_status, sensors}, %{whereami: previous}=state) do
    next = DeadReckoner.update(previous, sensors)
    {:noreply, %{state | whereami: next}}
  end
  def handle_info({:roomba_status, sensors}, state) do
    next = WhereAmI.init(sensors)
    {:noreply, Map.put(state, :whereami, next)}
  end
end
