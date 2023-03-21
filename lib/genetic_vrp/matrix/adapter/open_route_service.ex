defmodule GeneticVrp.Matrix.Adapter.OpenRouteService do
  use Tesla

  @moduledoc """
  Module that define functions to obtain the distance / duration matrix using the [OpenRouteService](https://openrouteservice.org/dev/#/api-docs/matrix).

  You can use `:matrix_profile` hyperparameter to specify the profiles to be applied. By default `driving-car`.

  ## Examples

        iex> alias GeneticVrp.Matrix.Adapter.OpenRouteService, as: MatrixProvider
        iex> locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1]]
        iex> {:ok, matrix} = GeneticVrp.Matrix.Adapter.OpenRouteServiceClient.get_distance_duration_matrix(locations)
        iex> true = matrix.locations  == locations

  Internally the `OpenRouteService Matrix endpoint` returns the distance / duration matrix from a list of locations.
  An example:

  ```json
  {
    "sources": [
        {
            "snapped_distance": 118.92,
            "location": [
                9.700817,
                48.476406
            ]
        },
        {
            "snapped_distance": 10.57,
            "location": [
                9.207772,
                49.153882
            ]
        },
        {
            "snapped_distance": 17.45,
            "location": [
                37.572963,
                55.801279
            ]
        },
        {
            "snapped_distance": 648.79,
            "location": [
                115.665017,
                38.100717
            ]
        }
    ],
    "metadata": {
        "timestamp": 1677347417212,
        "service": "matrix",
        "query": {
            "units": "m",
            "responseType": "json",
            "profile": "driving-car",
            "metrics": [
                "distance",
                "duration"
            ],
            "locations": [
                [
                    9.70093,
                    48.477473
                ],
                [
                    9.207916,
                    49.153868
                ],
                [
                    37.573242,
                    55.801281
                ],
                [
                    115.663757,
                    38.106467
                ]
            ]
        },
        "engine": {
            "version": "6.8.0",
            "graph_date": "2023-02-19T15:04:34Z",
            "build_date": "2022-10-21T14:34:31Z"
        },
        "attribution": "openrouteservice.org | OpenStreetMap contributors"
    },
    "durations": [
        [
            0.0,
            5786.74,
            90559.09,
            394856.69
        ],
        [
            5589.28,
            0.0,
            89296.84,
            393594.44
        ],
        [
            90304.2,
            88731.82,
            0.0,
            308207.47
        ],
        [
            394077.72,
            392505.31,
            307312.97,
            0.0
        ]
    ],
    "distances": [
        [
            0.0,
            140854.56,
            2421359.0,
            9.8709e6
        ],
        [
            139771.17,
            0.0,
            2372830.0,
            9822371.0
        ],
        [
            2369182.5,
            2321244.0,
            0.0,
            7501301.5
        ],
        [
            9801376.0,
            9753437.0,
            7448615.5,
            0.0
        ]
    ],
    "destinations": [
        {
            "snapped_distance": 118.92,
            "location": [
                9.700817,
                48.476406
            ]
        },
        {
            "snapped_distance": 10.57,
            "location": [
                9.207772,
                49.153882
            ]
        },
        {
            "snapped_distance": 17.45,
            "location": [
                37.572963,
                55.801279
            ]
        },
        {
            "snapped_distance": 648.79,
            "location": [
                115.665017,
                38.100717
            ]
        }
    ]
  }
  ```

  """
  alias GeneticVrp.Matrix.Adapter
  alias GeneticVrp.Utils

  @behaviour GeneticVrp.Matrix.Adapter

  require Logger

  plug(Tesla.Middleware.BaseUrl, "https://api.openrouteservice.org/v2/")

  plug(Tesla.Middleware.Headers, [
    {"authorization", "5b3ce3597851110001cf6248075f1fb2dd764e2eabef36b2f69c67b9"}
  ])

  plug(Tesla.Middleware.Headers, [{"content-type", "application/json;charset=utf-8"}])

  plug(Tesla.Middleware.Headers, [
    {"accept", "application/json, application/geo+json; charset=utf-8"}
  ])

  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Timeout, timeout: 5_000)

  @impl Adapter
  def get_distance_duration_matrix(locations, opts \\ []) do
    profile = Keyword.get(opts, :matrix_profile, "driving-car")

    request_body = %{
      locations: locations,
      units: "m",
      resolve_locations: "false",
      metrics: ["distance", "duration"]
    }

    path = "/matrix/" <> profile
    {_, response} = post(path, request_body)

    case response.status do
      status when status < 400 and status >= 200 ->
        # Logger.info("Response: #{inspect(response)}")
        distances = Utils.list_of_lists_to_map(response.body["distances"])
        durations = Utils.list_of_lists_to_map(response.body["durations"])

        matrix = %GeneticVrp.Types.DistanceDurationMatrix{
          locations: locations,
          matrix:
            Enum.reduce(distances, %{}, fn {key, _value}, acc ->
              Map.put(acc, key, {distances[key], durations[key]})
            end)
        }

        {:ok, matrix}

      _ ->
        Logger.error("Error obtaining the matrix from OpenRouteService: #{response}")
        {:error, response.status}
    end
  end
end
