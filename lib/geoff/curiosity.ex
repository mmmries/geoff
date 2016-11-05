defmodule Geoff.Curiosity do
  def start_link(genserver_opts) do
    GenServer.start_link(__MODULE__, nil, genserver_opts)
  end

  def init(nil) do
    sensors = [:encoder_counts_left, :encoder_counts_right, :battery_capacity, :battery_charge, :bumps_and_wheeldrops, :light_bumper]
    :timer.send_interval(33, :dj, {:check_on, sensors})
    {:ok, nil}
  end
end
