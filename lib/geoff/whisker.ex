defmodule Geoff.Whisker do
  alias Roombex.{WhereAmI,DeadReckoner,DJ}

  # Public Interface
  def start_link(genserver_opts) do
    GenServer.start_link(__MODULE__, nil, genserver_opts)
  end

  def whereami(pid \\ __MODULE__), do: GenServer.call(pid, :whereami)
  def reset(pid \\ __MODULE__, %WhereAmI{}=whereami), do: GenServer.call(pid, {:reset, whereami})

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
  def handle_call({:reset, whereami}, _from, state) do
    sensors = DJ.sensors(:dj)
    next = WhereAmI.init(sensors)
    next = Map.merge(next, %{x: whereami.x, y: whereami.y, heading: whereami.heading})
    publish_update(sensors, next)
    {:reply, :ok, Map.put(state, :whereami, next)}
  end

  def handle_info({:roomba_status, sensors}, %{whereami: previous}=state) do
    next = DeadReckoner.update(previous, sensors)
    publish_update(sensors, next)
    {:noreply, %{state | whereami: next}}
  end
  def handle_info({:roomba_status, sensors}, state) do
    next = WhereAmI.init(sensors)
    publish_update(sensors, next)
    {:noreply, Map.put(state, :whereami, next)}
  end

  defp publish_update(sensors, whereami) do
    send Geoff.Navigator, {:whisker, sensors, whereami}
  end
end
