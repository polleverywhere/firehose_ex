defmodule FirehoseEx do
  @moduledoc """
  FirehoseEx is a rewrite of PollEverywhere's Firehose in Elixir & Erlang/OTP.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(FirehoseEx.WebServer, [web_conf]),
      supervisor(FirehoseEx.Redis, [Application.get_env(:firehose_ex, :redis)])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FirehoseEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config[:version]
  def version do
    @version
  end

  def web_conf do
    conf = Application.get_env(:firehose_ex, :web)
    case System.get_env "PORT" do
      nil -> conf
      p   -> conf |> Keyword.merge(port: p |> String.to_integer)
    end
  end
end
