defmodule FCM.MixProject do
  use Mix.Project

  def project do
    [
      app: :itinerary,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:date_time_parser, "~> 1.2.0"}
    ]
  end

  defp aliases do
    [
      print_trips: "run -e \"FCM.print_trips_from_file(System.argv() |> Enum.at(0))\""
    ]
  end
end
