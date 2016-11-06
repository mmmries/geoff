defmodule Geoff.Navigator do
  alias Roombex.DJ
  @accuracy 10.0

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
      true ->
        DJ.command(:dj, Roombex.drive(0,0))
        state |> Map.delete(:destination) |> Map.delete(:tactic)
      false ->
        case state.tactic do
          :init ->
            DJ.command(:dj, Roombex.drive(50, -1))
            Map.put(state, :tactic, :turning)
          :turning ->
            desired_heading = heading_from_vector(dx, dy)
            dh = abs(desired_heading - whereami.heading)
            case dh < 0.1 do
              true ->
                DJ.command(:dj, Roombex.drive(0,0))
                Map.put(state, :tactic, :driving)
              false ->
                DJ.command(:dj, Roombex.drive(50, -1))
                state
            end
          :driving ->
            desired_heading = heading_from_vector(dx, dy)
            dh = turn_diff(whereami.heading, desired_heading);
            radius = turn_diff_to_radius(dh)
            speed = distance_to_speed(distance)
            DJ.command(:dj, Roombex.drive(speed, radius))
            state
        end
    end
  end

  defp distance_to_speed(distance) when distance >= 200.0, do: 200
  defp distance_to_speed(distance) when distance <= 50.0, do: 50
  defp distance_to_speed(distance), do: distance |> Float.round |> trunc

  defp heading_from_vector(dx, dy) do
    :math.atan2(dy, dx)
  end

  defp turn_diff(current_heading, desired_heading) do
    dh = desired_heading - current_heading
    cond do
      dh > :math.pi ->
        -((:math.pi * 2) - dh)
      dh < -:math.pi ->
        (:math.pi * 2) + dh
      true ->
        dh
    end
  end

  defp turn_diff_to_radius(dh) do
    radius = 100 * (1.0 / dh)
    cond do
      radius > 1999.9 ->
        2000
      radius < -1999.9 ->
        -2000
      true ->
        Float.round(radius) |> trunc
    end
  end
end
