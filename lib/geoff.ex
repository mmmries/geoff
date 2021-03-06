defmodule Geoff do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Geoff.Navigator, [[name: Geoff.Navigator]]),
      worker(Geoff.Whisker, [[name: Geoff.Whisker]]),
      worker(Roombex.DJ, [[tty: '/dev/ttyUSB0', report_to: Geoff.Whisker],[name: :dj]]),
      worker(Geoff.Curiosity, [[name: Geoff.Curiosity]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Geoff.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
