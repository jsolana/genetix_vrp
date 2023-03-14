defmodule GeneticVrp.Endpoint.Http do
  use Plug.Router

  @moduledoc false

  require Logger

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  )

  def init(options) do
    Logger.info("Running GeneticVrp.Endpoint.Http with Cowboy using http://0.0.0.0:4001")

    options
  end

  post "/routes/calculate" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])

    locations = Poison.decode!(body)["locations"]

    case GeneticVrp.calculate_routes(locations) do
      {:ok, response} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(response))

      {:error, status} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, "")
    end
  end

  get "/routes/matrix" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])

    locations = Poison.decode!(body)["locations"]

    case GeneticVrp.get_matrix(locations) do
      {:ok, response} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(response))

      {:error, status} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, "")
    end
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
