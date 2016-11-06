defmodule Geoff.Navigator do
  alias Roombex.DJ
  @accuracy 5.0

  def start_link(genserver_opts) do
    GenServer.start_link(__MODULE__, nil, genserver_opts)
  end

  def set_destination(pid \\ __MODULE__, %{x: x, y: y}) do
    GenServer.call(pid, {:set_destination, %{x: x, y: y}})
  end

  # Server Callbacks
  def init(nil) do
    {:ok, %{}}
  end

  def handle_call({:set_destination, destination}, _from, state) do
    {:reply, :ok, Map.merge(state, %{destination: destination, tactic: :init})}
  end

  def handle_info({:whisker, _sensors, whereami}, %{destination: _destination}=state) do
    state = issue_drive_command(state, whereami)
    {:noreply, state}
  end
  def handle_info({:whisker, _sensors, _whereami}, state) do
    {:noreply, state}
  end

  defp issue_drive_command(state, whereami) do
    dx = state.destination.x - whereami.x
    dy = state.destination.y - whereami.y
    distance = :math.sqrt( :math.pow(dx, 2) + :math.pow(dy, 2) )
    case distance < @accuracy do
      true -> state |> Map.delete(:destination) |> Map.delete(:tactic)
      false ->
        case state.tactic do
          :init ->
            IO.puts "starting turn"
            DJ.command(:dj, Roombex.drive(100, -1))
            Map.put(state, :tactic, :turning)
          :turning ->
            desired_heading = heading_from_vector(dx, dy)
            dh = abs(desired_heading - whereami.heading)
            case dh < 0.1 do
              true ->
                DJ.command(:dj, Roombex.drive(0,0))
                IO.puts "done driving"
                Map.put(state, :tactic, :driving)
              false ->
                state
            end
        end
    end
  end

  defp heading_from_vector(dx, dy) do
    :math.atan2(dx, dy)
  end
end
