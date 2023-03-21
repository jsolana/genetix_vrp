# GenetixVrp

`GenetixVrp` is an elixir application that provides a way to solve Vehicle Routing Problems (AKA `VRP`) using genetic algorithms using [Genetix](https://hex.pm/packages/genetix).

The vehicle routing problem (VRP) is a combinatorial optimization and integer programming problem which asks  "What is the optimal set of routes for a fleet of vehicles to traverse in order to deliver to a given set of riders?". It generalizes the traveling salesman problem (TSP).

<div align="center">
  <img width="400" height="300" src="guides/logo.png" onerror="this.onerror=null; this.src='assets/logo.png'">
</div>

## Genetic algorithm details

A genetic algorithm is a search heuristic that is inspired by Charles Darwin’s theory of natural evolution. This algorithm reflects the process of natural selection where the fittest individuals are selected for reproduction in order to produce offspring of the next generation.

Five phases are considered in a genetic algorithm:

- `Initial population`: The process begins with a set of individuals which is called a `Population`. Each `individual` is a solution to the problem you want to solve.
- `Fitness function`: The fitness function determines how fit an individual is (the ability of an individual to compete with other individuals). It gives a fitness score to each individual. The probability that an individual will be selected for reproduction is based on its fitness score.
- `Selection`: The idea of the selection phase is to select the fittest individuals and let them pass their genes to the next generation. Two pairs of individuals (parents) are selected based on their fitness scores. Individuals with high fitness have more chances to be selected for reproduction.
- `Crossover`: Crossover is the most significant phase in a genetic algorithm. For each pair of parents to be mated, Offspring are created by exchanging the genes of parents among themselves.
- `Mutation`: In certain new offspring formed, some of their genes can be subjected to a mutation with a low random probability..

The algorithm terminates when achieving the termination criteria specified as a specific value, a max generation, etc.

### Encoding

An individual is characterized by a set of parameters (variables) known as Genes. Genes are joined to form a Chromosome (solution). `Encoding` is the action to represent chromosomes. There are differents ways to encode a chromosome:

- `Binary genotypes`: They are represented as bitstrings, strings with only 0s and 1s. Ex: `[0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1]`.
- `Permutation genotypes`: Useful to represent ordered lists. The traveling salesman problem is an example that you can implement using permutation genotypes. Each city is encoded as a number and the path is an order of cities. Ex: `[9, 8, 6, 5, 4, 0, 1, 2, 3]`.
- `Real-Value genotypes`: Represent solutions using real values. Very common in problems involving weights or similar. Ex `[0.25, 1.12, 9.90, 6.01]`.
- `Tree/Graph genotypes`: Based on tree / graph structures.

`GenetixVrp` encoding the chromosomes as `permutation genotypes` with a little custom characteristics. 
We use a list of  numbers to represent the locations to stop, ORDERED, and have to be splitted in different vehicles. 
In our case we have two uses cases very well defined:

- `go_home`: Represent a bunch of locations to be splitted in different vehicles with a common start (single pickup) and different ends (drop-offs). We use the term `go_home` because it is the typical use case. N Riders want to go home, all of them are picked-up in the same point and dropped-off each one in a specific location.
- `go_office`:  Represent a bunch of locations to be splitted in different vehicles with different starts (pickups) and a common end (drop-off). We use the term `go_office` because it is the typical use case. N Riders want to go to the office, each one is picked-up in a specific location (their homes) and dropped-off at the same place (the office).

An example of a how to encode `go_home` bunch of locations:

- The initial locations are represented as a `permutation`. For example: `[0, 1, 2, 3, 4, 5, 6, 7, 8]`.
- Because is a `go_home` we define one of them is going to ve the common starting point. In this example we choose `0`.
- We define the capacity of each vehicle in `4`.
- We encode the  initial location to represent the `go_home` for each vehicle. An example could be this: `[0, 1, 2, 3, 4, 0, 5, 6, 7, 8]` (or also `[0, 7, 5, 4, 3, 0, 8, 1, 2, 6]`). In detail we distinguish two different vehicles:
  
  - `vehicle 1`: With a `[0, 1, 2, 3, 4]` route. The vehicle starts at 0 and picks up all the riders and must stop on 1, 2, 3, 4 to drop-off each of them.
  - `vehicle_2`: With a `[0, 5, 6, 7, 8]` route.

### Avoid premature convergence

You can use `hyperparameters` to customize the operators to apply during the execution to obtain better results and to avoid premature convergence (due to converged alelled). Premature convergence refers to the stalling of progress in your algorithms as a result of a lack of genetic diversity in your population.

Sometimes, selection and crossover are enough for a complete genetic algorithm.

The `VehicleRoutingProblem` defines its own custom hyperparameters. For more information you can take a look at the [VehicleRoutingProblem module](lib/genetix_vrp/vehicle_routing_problem.ex).

#### Custom mandatory hyperparameters

- `crossover_type`: Crossover operator. By default `crossover_cx_one_point/3`. To run successfully this problem, you need to override this property using `custom_crossover` function.
- `mutation_type`: Mutation operator. By default `mutation_shuffle/2`. To run successfully this problem, you need to override this property using `custom_mutation` function.
- `sort_criteria`: How to sort the population by its fitness score (max or min). By default min first.
- `matrix`: `GenetixVrp.Types.DistanceDurationMatrix` data for the locations provided.

#### Optional hyperparameters

- `fix_start`: If all vehicles must start in a specific location. By default `-1` (no fix_start).
- `fix_end`: If all vehicles must end in a specific location. By default `-1` (no fix_start).
- `size`: Total number of locations. By default `10`.
- `population_size`: Total number of individuals to run the algorithm. By default `100`.
- `vehicle_capacity`: Number of riders / stops the vehicle can handle. By default `4`.
- `max_generation`: Termination criteria. The max number of generation to  generate the optimal routes. By default `10_000`.

#### For matrix providers

- `speed_in_meters`: To calculate the duration matrix for `GreatCircleDistance` provider. By default `50_000`.
- `matrix_profile`: Used for `OpenRouteServiceClient` provider to calculate the distante_duration matrix. By default `driving-car`.

## TODO

### VRP Genetic Algorithm

- Improve the documentation (run `mix docs` and fix the misdocumentations)
- Interactive algorithm?

### Matrix providers

- Evaluate different providers and the accuracy between them (specially  `great_circle_distance` implementation)
- [Documentation best practices](https://hexdocs.pm/elixir/1.13.4/writing-documentation.html): `@typedoc, @doc, @moduledoc`

### Design

- Move `genetic` as a independent library and separate from the specific code related to the VRP problem
- Document as a library
- Publish it in `hex.pm`

### Routific comparation

An example of input:

```json
{
	"fleet": {
		"0": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"1": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"2": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"3": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"4": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"5": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"6": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"7": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"8": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"9": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"10": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"11": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"12": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"13": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"14": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"15": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"16": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"17": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"18": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		},
		"19": {
			"capacity": 4,
			"start_location": {
				"lat": 4.6751574,
				"lng": -74.048305
			}
		}
	},
	"options": {
		"balance": false,
		"min_vehicles": 12,
		"polylines": true,
		"shortest_distance": true,
		"traffic": "normal"
	},
	"visits": {
		"53165614": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.69719748864374,
					"lng": -74.0574106033658
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"63344046": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.73620570165221,
					"lng": -74.0641648187097
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52931807": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7459503,
					"lng": -74.0563466
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"91440311": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.699098,
					"lng": -74.0981956
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52957556": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6439135,
					"lng": -74.125874
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1090370488": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7561841,
					"lng": -74.0825322
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"9772576": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6413654,
					"lng": -74.0888909
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1032446405": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6128778,
					"lng": -74.1211956
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"74085398": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7409836,
					"lng": -74.0438357
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"51859777": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.68435845660898,
					"lng": -74.0442664168578
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52790496": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.692085,
					"lng": -74.110398
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1049608213": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7243017,
					"lng": -74.0432946999999
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"80802584": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.57175429999999,
					"lng": -74.0999985
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1020744163": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.65845129999999,
					"lng": -74.0470296
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"80213136": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7059742,
					"lng": -74.1184632
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1019024488": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.753012,
					"lng": -74.057126
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"72278279": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6704498,
					"lng": -74.1031462
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"73595443": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.73433816549109,
					"lng": -74.0561401031017
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"22523137": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7438343,
					"lng": -74.0345847
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"85441849": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.743629,
					"lng": -74.064241
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"31714794": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.72012859088824,
					"lng": -74.0327926322018
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1092343332": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7230753,
					"lng": -74.0340286
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"74282226": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6932655,
					"lng": -74.0845358999999
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1032465163": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.63339729999999,
					"lng": -74.0898392
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"40401504": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.70758904211561,
					"lng": -74.0616108745298
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"79652080": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7431974,
					"lng": -74.0613427
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"60251436": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7547252318581,
					"lng": -74.037722318708
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"63478946": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.71613,
					"lng": -74.0418937
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52533963": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7511865,
					"lng": -74.0576541
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52377064": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.69564638900156,
					"lng": -74.0808344033659
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"79978411": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.62313286918817,
					"lng": -74.2064461322019
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1022944599": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.64441921123479,
					"lng": -74.126739438725
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"57294302": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6491295,
					"lng": -74.1517435
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1014221625": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6498854,
					"lng": -74.1726019
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1000130108": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6405075,
					"lng": -74.065206
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"46384770": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.67732068891894,
					"lng": -74.1071839400826
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1116244835": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.72472952798987,
					"lng": -74.0450687456939
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"79970344": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7525624,
					"lng": -74.0963518
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"91533929": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.716461,
					"lng": -74.030609
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"47442661": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.73528692651519,
					"lng": -74.0511594033657
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1014199855": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.6678739,
					"lng": -74.1347773
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"1020792730": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7347633,
					"lng": -74.0573678
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52047440": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.684302,
					"lng": -74.068784
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"53088825": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.67359459999999,
					"lng": -74.1056751
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"88267234": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.72930189999999,
					"lng": -74.047413
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"37514608": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.7279618,
					"lng": -74.0427496
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		},
		"52558177": {
			"dropoff": {
				"duration": 1,
				"end": 1677842497,
				"location": {
					"lat": 4.73,
					"lng": -74.117931
				},
				"start": 1677837997
			},
			"load": 1,
			"pickup": {
				"duration": 1,
				"location": {
					"lat": 4.6751574,
					"lng": -74.048305
				},
				"start": 1677837997
			}
		}
	}
}
```


Solution:

```json
{
	"distances": {
		"0": 17.3646,
		"1": 20.0772,
		"10": 15.4825,
		"11": 8.1311,
		"12": 0,
		"13": 14.5829,
		"14": 13.1478,
		"15": 10.9052,
		"16": 19.359900000000003,
		"17": 14.038200000000002,
		"18": 15.6554,
		"19": 0,
		"2": 15.214799999999999,
		"3": 15.3824,
		"4": 21.4157,
		"5": 0,
		"6": 0,
		"7": 4.3557,
		"8": 16.463099999999997,
		"9": 9.8784
	},
	"num_late_visits": 0,
	"num_unserved": 1,
	"office_location": {
		"latitude": 4.6751574,
		"longitude": -74.048305
	},
	"pl_precision": 6,
	"polylines": {
		"0": ["_bj|GjmpflC????????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCwLwBw[gE_NoAwVwBsNcB{Y_Ds]sDkCSoASgYcBkk@wGkWSkWf@oPg@c[Ssl@cGgOoA_XwB_]_Dc`@sDk\\kC{c@gEo_@gEsyA{OgEg@sSsDwLcBoKoAsSwBsb@gEs]sD{OkCwLwBgYcGwLkCoZkCoFg@{J{@we@sDoK{@wBSkWwBsDg@kf@{E{ESkRcB{Eg@{OcB{c@gEgJ{@sDg@wBSwBS_S{@gTg@oKg@{Jg@cQwBwBSwo@{JkH{@sIoAsDg@oFg@wLoAcQcBw`@sDsDg@gm@oFcL{@k\\_D{h@oFkCScB?sI{@oPcB_eA{J_XwBg@ScBS{@?wBSkCScBSoFg@gEg@{h@oFgOoAoASoA?sNoA{TwB_I{@w`@sDwBSoZkCwVwB_Ig@oF?oK?oFR{J?sD?_D?gESsDg@gTwBgm@wGcLoAcLcB_N_DoKkCcLwBsSwB{OcBoKoA_Dg@oUwB_NoAkCSoAScB?kHg@gm@cGgc@sD{^_D_Ig@o_@sDwQcBs]sDw[kC{OcBgJg@gOoAcLoAwBS{c@gEgc@{Eo_@_D{YkCkHg@{@SkWkCkCSo_@sDwGg@{Eg@oKoAkCSgc@gEo_@sD_ScBsSwB_]_Doi@oFkp@oF_Dg@oZkCwQoAg^sDkRcBgJg@oPwBkk@{Egc@gEsDcBcBcB{@oAg@cBSoAScBf@kCnAwBvBwB~CoArDoA~CS~CRz@RnARz@z@nAz@nAjCz@zEoUzzAsDvB_Dz@wBf@wBR_DSkC{@kCcBkCkCg@oASoAScB?wBf@kCnAwBbBwBbB{@bBg@jHoA~\\jCbt@vGnFf@fYjCz@?fEf@vVvBzObBfJz@bGf@jHf@fJz@f@z@?z@?nAoFfm@cGnn@g@vG{@S{@?z@?z@RcBnP_Ivy@?nAg@rD{@zJcBrSkHvt@g@nF?nAg@vGSbGSfJ?bB{@rb@S~C{@jMSjC~Cf@jCf@~sAfO?bVgERfESg@bfB?fEct@_DSgERfE{OoAkW{@oAS_Dg@sDg@SfESrD?R?z@cBzYoArXsD~p@SnFS~C?bBSrDoAvVoAnUg@~MsDfw@?RSvBSzJz^zJfTnFf^~H~HbBjMjC~Hz@rDRrDRjHSzc@cBbGSnKbB~HnA~k@~Mf@?vo@rNrDz@nFnAbVzEnKjC~Cz@zpAnZ~WbGja@fJ~Cz@nAf@rDnAoA~C{ErNkC~HwBrIcBvGkCbLsNfm@sDfO{@zE{@~C{@rD{@~CoKrb@oFnP{@jCkHzYkCzJcBvLkCnKoAnFcBvGgEvQ_DfJg@nAwGrXoAzJwBrIg@vBgJr]wB~HgEzO{Jf^{EbQwGzTg@vBkCzJoFnZwLbe@_DnKg@nA{@z@{@z@cBf@kCf@{Ez@w[jC{JbBoA?_DRsD?cGg@gEg@{JoAg@R{@RSf@Sz@Sf@RnAnF~CzEjCvLbGjMfEjHfEz@z@f@nARnAg@nA{@z@{EbB_DnAwBnAgErDwBjCwB~C{@jC{@rDoAfE{@zE{@vG{@~RSjCSvGS~M?jCS~C{@bG{@~C{@jCg@bBg@nAg@z@_IjM{Tv[wGbLoFnKg@vBkHjWgEnPoFbVkC~HsDjHcBjCkC~CoAnAkMvLcBvB_DjCwGvGwLvLoFbGwL~M_NzOoFjHcG~HcGzJoAnAsDbGoFbG_I~HwBjCgEzEsDrDsDvGkCnFcBrDoAfE{@bGoAjH_DnPwBzJkHn_@cLrl@wBrIgEfT_DzOkCjMoAzEcBfEoAvB{@vBcBjCcBvBgJnKcVbVgYzY{EzEwLvLkf@ve@c`@n_@cLbLwG~H{EjHsb@~p@wB~CkMbQgJvLsb@vj@wBjCsS~WcQnUsNfToPnUkMjRwB~CwGnK_DrDcBrDwLvQoFfJoKnPcGjHkCfEg@z@sDfEoAnAoAnAgJrIsDrDsDzE{OvVsN~R_DzEsDzEcBjCgJjMcBjCwBjC_IjMoAjCcBzE{EnKgE~HcGzJ_DnF_DvG_IvQkHbQkMr]gEbL_DrIsIzToKrXsIbVoAz@cBf@wB?oA?oAg@_SgJgJ{Ewo@oZc[_NgEwB{TgJ_NcGs{@{^ct@gYsDcBns@waBrIkR"],
		"1": ["_bj|GjmpflC??????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCcB{@oA{@??g@g@g@{@g@g@S{@S{@S{@?{@?oA?SRwBbGwj@f@sDz@gEf@kCf@oAnAg@nASnARf@Rf@f@f@z@f@nAz@~CoAvG{@zE{@fEwVbuB{@nF{@zEsDzOoArDg@~CoAbGoAvG{@jHSbBSnFg@zE?z@SjCnAzE{EnUcGn_@sD~RcBrIsNvt@cBfJcBrIcGv[g@bB??oAvGsDvQkHv`@oUnlAg@rDg@jCg@vBg@zE{@fEg@fEg@rDwBzOcG~a@gErXoAvG{@vG_DbBSvBcBjMcBvQSz@g@vGg@rISvGSvB?fE?~CS~RSjRRvL?jHRfERbGf@rNRz@f@nKz@~MbBzOjCvQRz@bBnKf@vBrDnP~C~MvB~HbBnFvB~Hz@rDjCrInFnPf@bBzEjMrDfJbGbLnFzJnKvQvLvQ?RnFjHjCfEjC~CfYb`@rb@jk@bQjWfEbGbBjCnKrNbLrNbVrXbQrSnAbBg@jCSf@g@nA{@vBoAbBoAnAkMzJcj@b`@oAvB{@bB{@vBSbBRfEf@jCf@nA~HbL~CrDfY~a@nAbBf@vBf@rD?jCg@vB{@jCcBjC_l@~a@oi@ja@c`@rXsg@n_@kCjC_InF_yAzfAw|AjiAw[bV_NfJgErD{m@zc@{TbQce@rb@kRjRkRfT{EbGsDnFgEjHkCzEsDbGwt@~xAsDjHkCjHsDzJ_DrI{EzOcBnFcBnFoArDsDrIkCvGkHzOkHzOgJfTsDrI{Of^kHvQcBfEkMfYwLrXg@bBwBzEsSbe@wLvVcGjMwQj\\wBrDcGzJsDbGkCrD_IjMkCrDsIjMsIbLcGfJsInKwGfJsN~R_NbQsb@vj@c[ja@cQzTkMbQgEbGcGrI_DnFkCfE_DvGoFzJ{EfJsI~R{@jCoFnP{@bBcBR{@?g@?oAS_b@g@gc@g@o}@{@gTkRwBcBwV{T?cLRcLRka@?oAf@sXRwQRwQ?_IbGwGnUsXf@{@jW~WnKzJbGzE~C~CbVnPvGnFfEjCrDvBbLfJvVrS~z@zr@fY~RjWvQfJbGvQfJvQzJrNzJnUnPn_@zYvGzEbQbLzE~CrInFbBz@rDvBjCbBrSvLbBnAzOfJrg@zYjMjHnUjMz@f@zEjC~HfEvG~CzEbBzEnAfOjCbGbBfEz@vGjC~HrDrIrDvBnA~CbBvBz@f@R~HzEvBz@bBnAjCjCbGzErDjCrDjCbG~CrIfErIrDnPvGja@fO~MnFfO~Hv[fOzY~MnUfJvLnFfJfEzJ~CrI~CbLrDnPzEbQnFjMfEnFvB~CnA~H~Cz@z@z@f@bBbBfEbGRRbG~HvBvBvGjHjM~MjMzJbQ~MzErDbGrDfJjHfOvLz@z@bGbGrIjH~M~MzOrNjHvGrD~CrN~MbQzOnFzEnFnFfOrNfJfJnKnKvBbBbBbBfTrSjCjCrXbVfTfTbVvVbLvLrIrIf_BbwAnFnFrIjH~WvVbe@zh@fJnKrX~\\bBbBfnBbpB~MjMfT~R~MnKjMzJjHzEfJnFvLjHnKvGvQ~M~MbLnFrDz@f@jWvQvGnFfErDrDfErDzEzEvGzEzEbGnFjHrDvLrDrDnA~CbBrIzEbLjHvQrNrIbGb`@b[~CjC~HjHbGzEvBbBrD~CbBnAnFfEbQrNfE~CvLfJnPvL~MzJnFzEfEfErDzErDnFf@nAbBvBjCfEbBvBvBvBvBvBvBnAbBnAjCz@jCz@rDbBrDnAvBz@jCbB~CbBjCvBbBnAfEjCvGnFfOjMv[vVnKfJnAz@ja@zYnUvQrSzOjMzJvLzJnKfJzEfE_DrDgErDc[b[wLjMgJrIkHjHw`@z^gOrNc`@n_@gOrNsNjM{OrNcGvG{@vB?vBRbBf@bBf@z@RRf@Rf@f@nARnA?z@?z@?bBcBvBbBja@rb@bGvGnP{ObV{Tfc@fc@kMjMcGcGbGbGjMkMzTnUzEzEvBvBrI~Mrb@bj@jCrDbQ_Nrl@{c@zm@od@nd@c[rb@k\\nKkHzE{EzEsDvBwBrD{@nA?z@SbB?bB?jCf@v[zTrSfOvLrInKfJ~RbQnKfJ~R~RjCvB~iAzaAz@z@z@nFRbB?vBSvBg@bBoAz@kCz@cBf@wB?kCg@wBcBsIwG{@cB{@oAScBScB?oARoAf@cBnAkCbBwBrDoF~C{EfJ_NnPkMRSjHcG~\\gYzOsN~C_Dfr@wo@ja@{^f^_]zOsNrS_Sbj@sg@jk@oi@jMcLfEsDrI_IfTsSfESr]cBrS_S~a@gc@f@kM?kCRoAR{@?SnAcGve@gc@jp@sg@nUwQzuAgfAnA{@zOkMvQkMrN{JrIcGbLkHfEwBjCcBnK{ErI_DjHkCzOgErNsDjCf@bBz@nAz@f@z@Rf@fOvj@bBbGf@bBvG~Wz@~CvBzJnAnFz@rD~Hv[f@jCf@jCrD{@nAg@zOgEjMgE~MsD~HcB{@{Ez@zE_IbB_NrDwLnA"],
		"10": ["_bj|GjmpflC??????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bBoAvBsDfJ{Oz^_IbQwLzYoPv`@gEnK{@bBgEzJ_Nv[cBrD{^z|@~p@jWz@f@cVjk@cBnFSz@cBjHcGzTkCjHcBfEoAbBwBvB_DjCsDbBwBf@gEz@wB?cBRgESkRwB_NwBkCwBoA{@{@cB?{@?g@?S?g@Rg@?SRSRg@RSRSRSR?f@Sf@Sf@?f@?f@?R?f@Rf@?RRf@Rf@Rz@f@rIjMvBvGjCvG~HzO~CfJvBnFz@rDz@nFnAzEbBjCbG~HvGjHvB~C~CbGrNfYjCzE~M~RvGnKnAbBnKjR~a@nx@jMzYjMfYbLbVf@nAjMrXzc@~_ArDjHbBjCnK~RzJfTfJjRrInPvBrDjHfOfE~MjCjHnFjRjCvGz@jCnAbBnAvBbBbBvBvBzEfEnAnAbBbBfOnUfEbGbLrNrI~MrIbLjC~CnFvGvGvGzEzEnFzEzErD~z@jp@vLbLnAz@fpAffAvGnFfJbGzTnPrSzOzJ~HbLrIbQzOz@z@jHbGrI~H~HjHzJfJf@RjMnKzO~Mr{@fr@bGzEfEvBfJzE~RvGbGvBzJbGbBnAvB~CbBjCrDvGz@bBz@nAnAnAz@z@bBf@jHbBfOjCrDz@vo@bLrg@zJjRnFnP~Crl@vLvBf@fEf@zEz@zEnAr]jH~MvBzJbBjRbBfm@zEfEf@jHf@nFf@zEf@bGf@~C?~f@bBzc@bBrDRz|@rDzm@~CnFf@ju@jCzOz@~f@~Cjf@bBvLf@vVRnA?fES~CSjC?jC?vLRz|@rDrD?~Mf@rNf@fh@nAbcA~C~f@vBbj@bBzTf@rXz@SjCsDrjA?f@?f@kCzw@?z@?f@cBnd@?z@?nA{@rSoA~k@cBbe@?vBSzE~RbBvBRnARf@f@f@f@f@nA?z@?nA{@rDcBrD_D~CgEzEoFjHoFzJSbBRbBRnAz@z@z@nAnARnA?nA?bBSbBg@nPkWbBkCvB_DvB_DbBcBzESvBSbB?vBRbBf@f^nZjf@fc@fkAffAzEfEv~@fw@z@nAf@nARnASbBSz@g@z@wBjCbe@rb@wBjCwB~CvB_DvBkCjk@zh@_jAbo@_q@z^sDvBwBnA{@R{@f@rInPnAbBjk@zaAfOzYnd@f|@rSrb@z@bBrXjf@nd@vy@vBrDz@~Cf@vB?jC?rDSnAg@bBwBfEsDjCgEbBgEf@gERwBSoA?{EoAgEcB_DwBwBkCcBgE{@{E?_D?cBf@cBf@wBf@cBnAcBrIcLrDwBjk@k\\r{@kf@jk@w[zkAco@bV{O~McLfEsD~R{J~CcBnbAwj@fE_NRoAjHkWvLsb@~CcLjHcVf@cBjHbBbBz@bBz@nAvBzYrg@nAjCf@f@nAvBrNbVnPzYbt@vmAjMfTbBjCf@z@nAjCnAbBfOjWbQrXzOjWvGbLvB~CbBvBrIfJjCrDfE~HnAvBRf@Rf@z@bBf@f@bB~CbBvBbBjCnFrDnAz@jCbBrDjCvBnA~CnAvBnAbBf@bBRnAf@~HnAzEz@nFf@r]nAzw@fEvBRSjCoAnZcGrjAwBf^_Dvo@SnF{@bQSbB{@rS{@rNoAzYrD~W?f@wBfc@wBve@~CrIf@nAnAnAnAf@nARnASz@{@z@{@f@oAzE_NjCkf@bBc[~C_IrN_Xz@{TRcBbBf@vQzEvGjCjCnAfEjCjHnFjz@bt@v`@f^rSvQz@nAbBnA~CjCvBnAvBbBz^nZ~a@z^ja@z^bBnA~a@z^~\\v[fEvBjHrD~CnFvBzEvBnF~CnKvBjHvB~HnAnFRbB{Jz@kCRkCbBoAz@g@z@g@z@SnA?~CRfEjHg@bQoAjk@gEzYwBrDSf@bBn_@brAjHnZrIj\\fEjMnFrNzJzTbBrDnA~C~CnKjRrq@zEzOjCzJjWby@vVnx@nArDn_@zpARf@f@jCRbB{@nAoAz@cBjC{@jC{@jCS~C?vGz@fEnA~CvB~CjCvB~CbB~Cz@z@f@z@f@nAnAf@z@f@f@??z@bBnAbBz@bBnAnAz@z@f@z@nAz@z@z@f@z@f@nAf@bBz@bBvLzc@zEvQ~Mjf@zTby@z@jCbVf|@f@z@RnAfJj\\w[jHz^jsA"],
		"11": ["_bj|GjmpflC??????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCwLwBw[gE_NoAwVwBsNcB{Y_Ds]sDkCSoASgYcBkk@wGkWSkWf@oPg@c[Ssl@cGgOoA_XwB_]_Dc`@sDk\\kC{c@gEo_@gEsyA{OgEg@sSsDwLcBoKoAsSwBsb@gEs]sD{OkCwLwBgYcGwLkCoZkCoFg@{J{@we@sDoK{@wBSkWwBsDg@kf@{E{ESkRcB{Eg@{OcB{c@gEgJ{@sDg@wBSwBS_S{@gTg@oKg@{Jg@cQwBwBSwo@{JkH{@sIoAsDg@oFg@wLoAcQcBw`@sDsDg@gm@oFcL{@k\\_D{h@oFkCScB?sI{@oPcB_eA{J_XwBg@ScBS{@?wBSkCScBSoFg@gEg@{h@oFgOoAoASoA?sNoA{TwB_I{@w`@sDwBSoZkCwVwB_Ig@oF?oK?oFR{J?sD?_D?gESsDg@gTwBgm@wGcLoAcLcB_N_DoKkCcLwBsSwB{OcBoKoA_Dg@oUwB_NoAkCSoAScB?kHg@gm@cGgc@sD{^_D_Ig@o_@sDRwBzEgh@RcBfEce@vLcrAR{@fEkf@bGsq@f@_DRkCR_Df@_DvBw[z@oKkC?od@sDf@oKnA{^vBcy@z@{TnAo_@gw@wBwV{@{@~_ASz@co@oAwt@wBct@cBjCwt@"],
		"12": [null],
		"13": ["_bj|GjmpflC????????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCwLwBw[gE_NoAwVwBsNcB{Y_Ds]sDkCSoASgYcBkk@wGkWSkWf@oPg@c[Ssl@cGgOoA_XwB_]_Dc`@sDk\\kC{c@gEo_@gEsyA{OgEg@sSsDwLcBoKoAsSwBsb@gEs]sD{OkCwLwBgYcGwLkCoZkCoFg@{J{@we@sDoK{@wBSkWwBsDg@kf@{E{ESkRcB{Eg@{OcB{c@gEgJ{@sDg@wBSwBS_S{@gTg@oKg@{Jg@cQwBwBSwo@{JkH{@sIoAsDg@oFg@wLoAcQcBw`@sDsDg@gm@oFcL{@k\\_D{h@oFkCScB?sI{@oPcB_eA{J_XwBg@ScBS{@?wBSkCScBSoFg@gEg@{h@oFgOoAoASoA?sNoA{TwB_I{@w`@sDwBSoZkCwVwB_Ig@oF?oK?oFR{J?sD?_D?gESsDg@gTwBgm@wGcLoAcLcB_N_DoKkCcLwBsSwB{OcBoKoA_Dg@oUwB_NoAkCSoAScB?kHg@gm@cGgc@sD{^_D_Ig@o_@sDwQcBs]sDw[kC{OcBgJg@gOoAcLoAwBS{c@gEgc@{Eo_@_D{YkCkHg@{@SkWkCkCSwBcBg@wBSwBf@{JzE_tAf@oZvBR~WjC_XkCwBSvBg|@f@sXRsIRoFz@wV?oA?sDRkC?oARsI?{@vBRnA?ja@jCSjHSz@g@nA??Sf@Sf@c`@sDkCSoFg@oASoPcB{YsDkCScBS_{@{JoAS{@SgfAoPcBSkCSsl@sIkCg@cBSgh@kHwj@_IgaAsNcLcBgEg@sIoAkCg@ce@wGogA{OoAScBSgdBcVoUsDoASoAScBSoAjHSbBgEv[gEnZsIvj@gO~dASbBsNnbAgJ~p@g@vBcBSgc@gEwe@gEkf@{E_g@gE{c@gEoFg@_I{@gESod@gEw[_DoZkCgES_NoAoUkCcVcBsDS{J{@o_@wBsNS_S{@gT{@sN{@cBSoAScBoAoAcBg@oAcQoi@kHsS_D_IcBwGg@oFg@oK{@sSnAoFnAwGvBsNnKct@f@_DzJ{m@nFc`@R{@b[{nBz@oFf@_Dn_@ggCnAsIz@sIf@sDbBwQ~MgzAz@oAnAoAf@Sz@Sz@?nARbBRvQnAb[~CjCRja@rDvBRbBSz@?bBSnAoAnAkCzm@gc@zJwGja@_XfJoFfT_NrD?z@?vB?vBRzYjC~k@nFg@vGwBzOcBzObB{OvB{Of@wG_l@oF{YkCwBSwB?{@?sD?gT~MgJnFka@~W{Y_b@oUs]co@cG_DSw`@sDkMoA{@SkCS_NoAsNf_BoFfm@_In}@{E~k@g@nFkCSkCSobAoF{Ef@cGz@gERs{@kCsDg@{JgEoK{@{O{@gJg@_D?cBnAg@nASb[cBvG{JrIsIfJ_Dz@{@?gw@g@w[?"],
		"14": ["_bj|GjmpflC????????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCcB{@oA{@??g@g@g@{@g@g@S{@S{@S{@?{@?oA?SRwBbGwj@f@sDz@gEf@kCf@oAnAg@nASnARf@Rf@f@f@z@f@nAz@~CoAvG{@zE{@fEwVbuB{@nF{@zEsDzOoArDg@~CoAbGoAvG{@jHSbBSnFg@zE?z@SjCnAzE{EnUcGn_@sD~RcBrIsNvt@cBfJcBrIcGv[g@bB??oAvGsDvQkHv`@oUnlAg@rDg@jCg@vBg@zE{@fEg@fEg@rDwBzOcG~a@gErXoAvG{@vG_DbBSvBcBjMcBvQSz@g@vGg@rISvGSvB?fE?~CS~RSjRRvL?jHRfERbGf@rNRz@f@nKz@~MbBzOjCvQRz@bBnKf@vBrDnP~C~MvB~HbBnFvB~Hz@rDjCrInFnPf@bBzEjMrDfJbGbLnFzJnKvQvLvQ?RnFjHjCfEjC~CfYb`@rb@jk@bQjWfEbGbBjCnKrNbLrNbVrXbQrSnAbBg@jCSf@g@nA{@vBoAbBoAnAkMzJcj@b`@oAvB{@bB{@vBSbBRfEf@jCf@nA~HbL~CrDfY~a@nAbBf@vBf@rD?jCg@vB{@jCcBjC_l@~a@oi@ja@c`@rXsg@n_@kCjC_InF_yAzfAw|AjiAw[bV_NfJgErD{m@zc@kC?wBScBg@_DcB{EgEs{@wt@oAoAvBkCrXoZvV_]~HwQvBbBz@nAf@f@bVbVcVcVg@g@{@oAwBcBzEsNvL{OfE_DoAoAoFrDoK~MkHjRkHbQ_Xr]oU~WkCjCwBvB_D~C_IjH{ErDsDjCgEvBoFvBkMfE{YbGoKz@{@RcB?wBScBg@_DoA{@gE{@{E_Ikf@kCsNwG{^cBgJsDsSgEcV_D{JcBsDoA_DsDkHgEwGvBwBbQkR~RoUbV_X~\\o_@fJoKvBkCnK{J?kCcBgEcQcj@gEgO_DoFcBkCwBcB_DkCwQ{JkCoAoF_Dg^kRsDwBwGgEgE_DoF{EoUoPcGgEwGgEwQ{JgEwBcLoFwQsI{@g@z@wBf@cBzJ_X~CsIvBkHvB{Jf@wGf@oKR_I?{@?oFSoFg@{Jg@oFcGo_@oFs]g@kCSoAgOs`AgJoi@g@wBoA_IcB{JsIwe@wGg^cBwL{@cGg@_Dg@kC{@{ES_D{@_D?{@cB{Jg@cBSoA{@cB{@cBoK_NcL{O_DgE_SkWcLgO{JkMcBsDoAsDoAkCg@kCcB_Ig@_DScBg@wG?sDSwBR{@?wBf@sDnFo_@bBwL?Sz@gJnA_InAkHnAcG~CcLbBkHf@kCRoAbBsNjHox@~MovAz@gJRgEf@{EjHos@fO{dBRcBz@kHRwBjHct@f@oF?{@nFcj@jCf@ja@~Cf^~CfEf@nZjCbj@zE~MnA_NoAcj@{EwG~p@SjHRjH{E~f@SnAc[kCsDg@c[_DsDS{TkC_I{@wBScBScB?wBSwBS{^_DwBSco@oFkCSce@gEkCg@g^_DwBSw`@gE_DScBSwcAoKsb@sD_XwBsDSsXwBoA{@cQcBoA?Sz@?nAoKvcAoKbhAcLjiAkCSgOoA"],
		"15": ["_bj|GjmpflC??????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCwLwBw[gE_NoAwVwBsNcB{Y_Ds]sDkCSoASgYcBkk@wGkWSkWf@oPg@c[Ssl@cGgOoA_XwB_]_Dc`@sDk\\kC{c@gEo_@gEsyA{OgEg@sSsDwLcBoKoAsSwBsb@gEs]sD{OkCwLwBgYcGwLkCoZkCoFg@{J{@we@sDoK{@wBSkWwBsDg@kf@{E{ESkRcB{Eg@{OcB{c@gEgJ{@sDg@wBSwBS_S{@gTg@oKg@{Jg@cQwBwBSwo@{JkH{@sIoAsDg@oFg@wLoAcQcBw`@sDsDg@gm@oFcL{@k\\_D{h@oFkCScB?sI{@oPcB_eA{J_XwBg@ScBS{@?wBSkCScBSoFg@gEg@{h@oFgOoAoASoA?sNoA{TwB_I{@w`@sDwBSoZkCwVwB_Ig@oF?oK?oFR{J?sD?_D?gESsDg@gTwBgm@wGwGkCkCoA{@g@g@oASg@?{@?oAf@cBbLkRrI{OvBcBbB{@~CS~CR~CnAvBvBf@vBz@fEoAjRsIrtA{@~MSrI?rD?fERbGf@fE~Cz^?bBRnA?jC?rDSvBSfESrD{@fOgEns@kCbj@SvBSjCg@zEkHbj@cBrIcBnFcBvG_DnKcQve@g@bBoAjCoZvo@{EnK_DzE_N~RkMbQcGrIoFjH_b@ni@oAbBoAvBkCfEkCrDsDjHkCvGoFbQcGnPcLn_@wVrv@kR~k@{Ove@_IjWgEnFcBvBkCvBsIzEcBf@{Jf@sD?_D?wGoAoKsDc`@_NwVsI{EcBw[{JgJ_DoUkHoU_I{J_DoZoK{EcBgEoAkC{@_Dg@sS{EsIcBwGcBo_@sIku@cQcL_DsDg@oUoFwVcGsq@gOsl@_NoF?_D?oKf@cGR{c@bBkHRsDSsDS_I{@kMkC_IcBg^_IgToF{^{JwBbG{@rD_DrIgJrX{EfOcBbGcBfE{@jC~Cf@fOvBvB~HjCz@zEf@rD?????sD?{Eg@kC{@wB_IgOwB_Dg@{@?seAgOos@{JgEg@wG{@kH{@_g@wGgc@wG{^oFwBSkCoAoAg@oA{@gEcBwB{@{nB_l@jCgOf@kCg@jCkCfOoKzh@cGj\\kCjMSz@g@vBcBnKsDvQSbB_DfOsDrSg@jC{@rDSz@bG?f@?fOR"],
		"16": ["_bj|GjmpflC????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bBoAvBsDfJ{Oz^_IbQwLzYoPv`@gEnK{@bBgEzJ_Nv[cBrD{^z|@~p@jWz@f@cVjk@cBnFSz@cBjHcGzTkCjHcBfEoAbBwBvB_DjCsDbBwBf@gEz@wB?cBRgESkRwB_NwBkCwBoA{@{@cB?{@?g@?S?g@Rg@?SRSRg@RSRSRSR?f@Sf@Sf@?f@?f@?R?f@Rf@?RRf@Rf@Rz@f@rIjMvBvGjCvG~HzO~CfJvBnFz@rDz@nFnAzEbBjCbG~HvGjHvB~C~CbGrNfYbBvG?bB?vBg@nAg@f@oAz@g@RoARwB?wB?{E?_DScB?_v@wGos@wGoASsDn_@SnAkCv[SbB_Df^Sz@SrD_DrXSbBkCv[SbBsDf^?nA_Df^SjCSjC{@vGSvBjCvB~HfErInFnAf@~HzEvQzJ?bBcBjWg@~HcBrSkCn_@gEbo@{@rInPzOce@rg@kf@bj@wBjCwVfTgJzJw|A_oAoZb[{@jCSf@{JnU_NnZ{Or]gOb`@gm@gYcGwB{w@c[ox@k\\g^sNwVoKoPwGkRsIsI_D_DoAsDoA?fERvG{EzESjRRvL?jHRfERbGf@rNRz@f@nKz@~MbBzOjCvQRz@bBnKf@vBrDnP~C~MvB~HbBnFvB~Hz@rDjCrInFnPf@bBzEjMrDfJbGbLnFzJnKvQvLvQ?RnFjHjCfEjC~CfYb`@rb@jk@bQjWfEbGbBjCnKrNbLrNbVrXbQrSnAbB~HbLrDnF~CfEvLvQzTfYvLzOjRvVnKrNvQjWz@nArNjRnKfObQbVvGrI~\\nd@f@f@z@nAbBvBja@zh@vB~CjC~CvQvVfJbLbL~MnKjMfOjRnUv[fEbGvGjHfEnFjCvBjCjCzErDrDvBrDvBbGrD~MvGrSnKbG~Cz^bQnKnFjHfE~HnFnPrIzEvBnUbLnKzEfO~HjRfJrIfEnKzErIfEbVzJfJzEj\\fObLnFzEvB~CbBfOjHfc@rS~HfEfJnFfYnP~CvBrNfJzOzJb~@~k@fE~CbQfO~HbGbBnAz@z@bBnAz@z@~CjCrDjCbVnPnUfObLjHrN~HbGrD~u@b`@zc@jWzOfJzOrI~HfEjHfEzEzE~HjH~a@be@bGvGbGjHzEzErDjCzEfE~iAby@jR~MzY~R~R~M~WjR~HzEjHnFbBnA~CvBbBnA~_A~p@vLrIb`@~WrDvBv[nUvQvLjHnF~CvBvj@ja@bLrInFzEf@f@bBbBbBbBbBbB~H~HnFfE~MzJbQjM~HvG~C~CbGbG~HvGrDrD~CjCrD~CbGrD~MvGfEjCnPfJrInFjeCvfBfw@jf@rb@zYzJvGz^~WjHzEbe@j\\fJbGjCbBz^rXfc@j\\jHnFnFrDr]nZzO~MfErDjHjHbBbBz@f@bBvB~H~HjHjH~C~C~k@fm@~C~C~M~MbGbGnFzEnAbBrv@ju@bGbG~C~Cf@f@jCjCnAnArSjRv[fYbVfTnFzEzEzEvVjWzJnKjR~RnK~MvL~MvBjCjHjHnKbLrD~C~C~CzJfJvBbBnFzEvBvBrIrIrD~CnAnAjCjCbBnArNrNbGbGzEzEfJzJbmAfpArDfEvBvBvBjCjCjCf^v`@vBvB~HfJ~CfEfEfEzEfEvGzErN~HvGfErN~HzJbGbG~CvGvBbL~CbBf@rDf@vLvBrNbBnFnAvBR~HbBzOfEzJ~Cf^nKni@bQrv@vVjMfEz@RzYnKvGvBfJ~Cr]vLRz@RnARnAg@bBoAvBovAvzBoAjCg@jCSvBf@jCz@~Cz@jCbBbBz@f@vBnArDnAzw@fObe@fJbBf@vBnAvBbBf@nAf@Rz@vBbBfER~Cz@jHS~Cg@zOcBv[gEbt@wBjf@{@rSg@nFcBrb@g@vGoFb~@?z@wGnbAoAnUwGnlAwBrb@wGvrA?fYSbV?fTSzT{@fT{@j\\_IfzASvB{@vLoA~MkCfTkCbVoA~MkCjW{EbmA{@nPsDzaAg@~H{@bVSzE_IvpB?z@cB~a@{@fO{@vLSrDg@nF{@rD{@bGcBnF{Eb`@cBjH{@bGoA~Hg@rI{@zJg@fJ{@zJSfEg@rD{@fE{@fEoAjC{@vBoAvBcBjCcBvBsX~\\gObQkM~Mco@bo@w`@ja@oi@zh@we@jf@s]j\\_SzOoF~CoF~C{aA~a@kdAbe@sI~CcQrIgYfJcL~CcBRgEf@cGf@kCSwGz@oFjCsDfEoAfESf@SvGkCbB_DvB_N~HoKnFkf@rX{JrDoKfEoAf@oA?{@S{@g@kCcBsl@{|@{@g@oAg@{@?oA?sDRwBSoAS{@ScBoAg@g@sSg^{@{@s]gm@_NgTg@{@oFvBoUvL{JcLsD{EcBcBoAcBwBg@wGcB_DgEcBkC{@kC{@_DcBgEwB{EcBwB{^{c@k\\w`@oUs]gh@wj@kCvBo_@jWwBkC"],
		"17": ["_bj|GjmpflC????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCcB{@oA{@??g@g@g@{@g@g@S{@S{@S{@?{@?oA?SRwBbGwj@f@sDz@gEf@kCf@oAnAg@nASnARf@Rf@f@f@z@f@nAz@~CoAvG{@zE{@fEwVbuB{@nF{@zEsDzOoArDg@~CoAbGoAvG{@jHSbBSnFg@zE?z@SjCnAzE{EnUcGn_@sD~RcBrIsNvt@cBfJcBrIcGv[g@bB??oAvGsDvQkHv`@oUnlAg@rDg@jCg@vBg@zE{@fEg@fEg@rDwBzOcG~a@gErXoAvG{@vG_DbBSvBcBjMcBvQSz@g@vGg@rISvGSvB?fE?~CS~RSjRRvL?jHRfERbGf@rNRz@f@nKz@~MbBzOjCvQRz@bBnKf@vBrDnP~C~MvB~HbBnFvB~Hz@rDjCrInFnPf@bBzEjMrDfJbGbLnFzJnKvQvLvQ?RnFjHjCfEjC~CfYb`@rb@jk@bQjWfEbGbBjCnKrNbLrNbVrXbQrSnAbBg@jCSf@g@nA{@vBoAbBoAnAkMzJcj@b`@oAvB{@bB{@vBSbBRfEf@jCf@nA~HbL~CrDfY~a@nAbBf@vBf@rD?jCg@vB{@jCcBjC_l@~a@oi@ja@c`@rXsg@n_@kCjC_InF_yAzfAw|AjiAw[bV_NfJgErD{m@zc@{TbQce@rb@kRjRkRfT{EbGsDnFgEjHkCzEsDbGwt@~xAsDjHkCjHsDzJ_DrI{EzOcBnFcBnFoArDsDrIkCvGkHzOkHzOgJfTsDrI{Of^kHvQcBfEkMfYwLrXg@bBwBzEsSbe@wLvVcGjMwQj\\wBrDcGzJsDbGkCrD_IjMkCrDsIjMsIbLcGfJsInKwGfJsN~R_NbQsb@vj@c[ja@cQzTkMbQgEbGcGrI_DnFkCfE_DvGoFzJ{EfJsI~R{@jCoFnP{@bBcBR{@?g@?oAS_b@g@gc@g@o}@{@gTkRwBcBwV{T?cLRcLRka@?oAf@sXRwQRwQ?_IbGwGnUsXf@{@jW~WnKzJbGzE~C~CbVnPvGnFfEjCrDvBbLfJvVrS~z@zr@fY~RjWvQfJbGvQfJvQzJrNzJnUnPn_@zYvGzEbQbLzE~CrInFbBz@rDvBjCbBrSvLbBnAzOfJrg@zYjMjHnUjMz@f@zEjC~HfEvG~CzEbBzEnAfOjCbGbBfEz@vGjC~HrDrIrDvBnA~CbBvBz@f@R~HzEvBz@bBnAjCjCbGzErDjCrDjCbG~CrIfErIrDnPvGja@fO~MnFfO~Hv[fOzY~MnUfJvLnFfJfEzJ~CrI~C{@bBkHfOgYvj@sXni@bQfJcQgJgm@{YfE_IrDkHkW_NgTcL{@g@_X_N_XsNoAvBoZrl@kRn_@_N~WsD~HsXni@oAvBoKfToFnKgJbQoA~Ck\\bo@{@nAwG~M_NjWwG~MwVjf@{Tfc@{@nAkRsIcVoKoAg@{@g@wGkCoFwBsg@{TcQ_IoA{@sNwGgOwGwL{EoAg@gEcBg@z@g@f@sX~\\wB~CkHrIgEzE_NnP{OjRwGrIwG~HoP~RsNvQcQfTsInK_IfJoP~R_NnPg@z@sIzJsXr]sXj\\{@{@sNwLoAnAoAnAnAbB?nASf@gJzJwBjC"],
		"18": ["_bj|GjmpflC??nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bBoAvBsDfJ{Oz^_IbQwLzYoPv`@gEnK{@bBgEzJ_Nv[cBrD{^z|@~p@jWz@f@rDnAjCnAfJ{TnAf@rNbGfaAb`@wVjk@_D~HcBrDkMnZgEzJSf@g@f@g@z@g@Rg@RsNcB_DSoU_DcQkCwBf@oARoAz@oAnAg@nASbB?nA?bBz@jCz@jCnAvBbB~Cz@vBf@vBf@nAz@vBz@nAbBf@fOR~Mz@bQvBrXjCbLz@z@RnARbLnAbB?z@RrIz@~Mz@~RvBjf@fEz@?b[jCzY~Crb@~CnARz^~CvBf@zERnKnAf^~Cv`@fEbVvBrb@fEf|@fJ~Hf@fr@bGvGSzEg@rD?jRf@zObBni@vGvQjCrDf@~MvB~MnAjHz@jCRjCRjCRjC?rNRz^z@vL?~C?rDRbGf@jHz@rIz@fEf@b`@rDj\\~CbcAfJbGf@~WjCz@Rv`@rDvBRnd@zE~f@nFvBRnA?rDf@rDR~RnAzObB~RbBbe@fEn_@zEfEf@zEf@r]rDfJz@rNnA~Cf@rDf@~Cz@~CnAz@R~CnAf@RzEvBbj@vV~\\zO~HrDrDnAnFvBnFvBzh@vQ~Cz@nARjCz@zEz@fEz@zJnAz^fEb[fEvLnAnUjCve@nFv`@zEzObBrDf@~CR~\\rD~W~Cj\\rDnPbBz@?jf@fE~CRbGf@bo@vGju@~HfTvBrNbBrb@fErDRjCf@~CRjf@zEzm@vGjMnAvVvBvBRvLnAvy@rI~MnAvBRjCR~Cf@zYjCnZ~Cfw@jHrDf@~MnArl@bGzTvBrX~C~Hf@jCf@vBRj\\~Cv[jCbVvBbQbBrNnAjCf@vQbB~p@~HvV~CbVvBvBRfEf@vBRfEf@v`@rDrDf@zm@nFrg@zEjMbBzEf@~CR~k@vG~W~CjRvBbQvBrDRzEf@~Cf@rXjCni@zEnx@jHrNnAbVjCv`@rD~Cf@~CR~p@~HzEf@fh@vGfJz@fEf@fY~CzEz@rNvB~MjCfJvBzJvBjp@fTrDnA{@bBg@f@cBrDwBzEsDrIkCvGkCjHoAfE{@fEg@fE{@rISnFSbB?f@?nFRvGRjCf@~Cf@rDz@zEf@fEbBfJf@rDvLrv@~Hfh@RbBz@Rf@f@z@z@f@z@RbBjCfTRbBRnARfEf@bB?z@RnAf@vBz@jCz@bBz@bBrDzErIbLz@nAnAvBvBrDbBjCrXcQfYoPb[wQzE_DrNsIvVsNb`@cVf^sXz|@cj@jCoAbL_IjHgEz^{TbLwG~M{ERSzOkH??fOsInUwLvLoFbV_I~H_DrNgEbGcBbB?bB?bB?R?jCf@zEf@~CnAvBz@~f@jRvG~CjCnAbBz@rl@fYzEjCvBnArg@jW~CbB~CbBb`@jRjf@vVrg@jWrIfEbBz@nFjCrDbBfOjHnUvLbt@f^rDvBjz@~a@f|@zc@jp@j\\zJzErIfEz@f@fEvB~CbBbLvG~p@n_@bBnArq@b`@zEjCjk@nZjCbBzw@fc@bBz@ntBreAbLbGrg@jWjCbB~CjCvBjCz@vBRbB?z@?nAf@vBf@bBnAbBnAnAbBz@bBf@vBRbB?bBSfERjCf@vBf@jCnAvBz@jk@b[rXnPzYjRbGrDzE~CrIzErDvBfEvBbLbGnPjHfYrNjCnA~CbBbG~C~W~MzYnPbe@rXzJbGzEvBfEjC~CbBjHfEb`@nUbBz@b`@fTRR~a@nUvGfErIzEjCbBfEjCvBbBrN~Hf^fTzOzJjMjH~CbBrN~HbLjHnUfOzOzJja@jWvL~HrNzJbLfJ~HnFvLfJfEjC~HnFfJjHfE~CbBz@RRfE~CnAz@z@f@bGrDbLjHvLjHzJvGfErDvBnArDjCzEjCfEvB~CnAzJvGrNnKj\\zT~RjMzOzJrXvQvQvLfEjCrDjCz@z@rDvBrIbGzh@r]rIbGzm@~a@f^bVfE~CnFfEzE~CfaAr{@~k@zh@vj@fh@v[b[v[nZ~CjCnAnAnFzEzJfJrIjHjWzT{@bBwQnZ{OjWnKvG"],
		"19": [null],
		"2": ["_bj|GjmpflC????????nUzJsNnZwG~MwmA_g@bVkk@zT{h@z@cBbBgEf@g@zpAni@nd@jRf@RrDnA~CbBRg@~Won@nUwj@zEwLfTgh@nPo_@zY{r@f@oAvB{Ez@wBbBcBnAg@vB{@zEg@zJrDfTfJr]rNvGjCbQbGbQvGzc@fOrNzEnFvBnFvBrDbBnF~CzEjCrDbBrDnAbGvBjp@fTfTvGzYzJfJ~CrSzJvVnKbBz@jCz@nF~CvBz@zEvBfE~CfE~CzOjMbBz@nAnAfOnPfYzYzObQzJzJ~C~CbBbB~MvLzErDbLrIrD~CnK~HnU~RjRnPzJnKjC~CjCvBnAbBzEnFbLbLfEzEjMvLbVnUnAnAzJbLjCjC~CfE~C~CfEfEvGjHjCjCbGbGbLnK~MvLfOrN~CvBjCbBbLjHvGfEb[vQvLjHvBnAR?jWzOr]rSvGfEvGrDjWjMvG~CjH~CnAf@vLfEbGbBrDnAbGvBjCf@~HjCzOnFjHjCvGjCrSfJ~HrDrNjHrNjHzEvBjHfEbBnA~CnA~RbLzYnPzEjCnF~CzErDzEfErDfEnKbLvG~HbGbGrDrDz@nAvBbB~CjCbBnA~CbBvBbBrDbB~CbBfEvBzTnKr]zOzEvBnKzEja@fOzc@bQvGjCzTrIfEbBfEbBbGjCfEvB~CbBzh@rXzJvG~RjMjM~HnAz@vBz@jCz@rDbB~Cz@~Cf@nKvB~RrDvLbBnFz@rInAnKbBnUrDnP~CjMjC~RrDbLvBjWfEbQjCfTfEzh@zJzO~CjHnAvGz@fJnA{@~CoKr]sNzc@wVvy@{@bBnFf@vQvBbLz@z@RSjC_Db[_DzYSfE?nASvBg@fE?jCSjCkHbt@gEv`@kCjWSjCSbBkHrv@Sz@SjCkCfYg@jCS~C_D~W_Dj\\g@rDkCfTSjCg@rDgEb`@SbBSzEg@zEkMjnASnAkCjWS~Cg@rDkCrXSvB_Db[g@vBkHzr@?bBg@jCkC~WwBnU{E~a@wBvV{^vlDg@rD{@bG{EzYcBjH{@zEoAjC{@jCoAjCcBjCgOnUkRrXsSfYgEbGkR~WkRrXoAz@cBz@gEnAcGbBwGjCcG~C_DbBcBnAcBbB_D~CgEzEoFjHoFzJ{Yzc@_NfJwGnFkHzEsDvBwBz@{@RwBRwBRsISsD{@seAc[_oAg^obA{Y{EoAkWkHcGcBsq@_S_DoAcB{@{@{@oAcBoAkCkCgESkCSkCg@wBg@oA{@oA{@{@Sg@g@ScBoAcB{@wBg@kCg@wB?kC?kCf@cBf@kCnAcBbBcBbBoAbBcBjCg@vBg@jCS~C?~C?jCRjCf@~Cz@jCS~C?jCSbBSnAg@bBg@nAoAvBkRvVsNfOoKnKc`@~WgJbGsSvLgT~M_b@jWoi@v[{JnF_`A~k@{E~CgEvBgEbBkCf@wBf@oPz@cBg@{Eg@kC?_DRkCRwBf@{EjCkCjCoAjC{@rDSzERjC?z@cBvGg@bB{@nAoAvBoAz@oAnAoAz@cGfE{E~CcpBnlAkHfEwy@rg@_q@ja@wVfOkRvL{YvQoF~CgEjCgEbBoFnAwGz@wGf@oFRoFf@cGvB{@f@_D~CkCnF{@rD?~CRbGRRz@~CnAjC?bLSnFg@~Cg@jCwGbQkHzOkCbGoFrIgEjHsSnZ_]~f@_DnFwGbLwLbVsD~HcLvVwBfEkHfOsSja@oKrSoZzm@{@bB_IzO_Xfh@g@z@cBjC_D~CcGbGcBbBcBbBgEfEcBnAsI~HgOzOgJ~HwB?wBg@{@{@SoA?wBf@cBz@cBnUgYvBwBjCoAvBoA~C{@fE~HRRz@nAvBrDvBzErDnF~MfTvGnKnFrIvGjHrDfE~CfEwBbBoZ~WwLjMcGvGsXj\\oi@fm@wBvBvBvBni@ni@bj@jk@z@z@oAnAgOfOk\\j\\g@RoAnAcBbBsDrDwBbB{@z@oFnFcLzJcGfEsDjC_DvB_IrD{JfE_SfJ_g@nUkH~CkHrDsDbBkCz@wy@n_@{dBby@gr@j\\{@z@g@Rg@z@{@z@cBoAk\\cVkf@_]kHoFoFgE{OoKwBoAnAcBvBkCvLsNbV{YfEoFvBwBzc@oi@bBwB~MoP~MgOf@oAnFcGz@oArI{JzEoFzJwLvG_InAoAzY{^rI{E~CwBjCwBjCkCzEcG~CsDb[w`@jCkCz@g@nA{@z@g@vB{@bBg@fE{@bBf@fEvBfEvBzJbGrD~CfOjMzOrNRRvGbGvBbBvBvBbQfOcBbBkHvGcLvL_NkM"],
		"3": ["_bj|GjmpflC????????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCwLwBw[gE_NoAwVwBsNcB{Y_Ds]sDkCSoASgYcBkk@wGkWSkWf@oPg@c[Ssl@cGgOoA_XwB_]_Dc`@sDk\\kC{c@gEo_@gEsyA{OgEg@sSsDwLcBoKoAsSwBsb@gEs]sD{OkCwLwBgYcGwLkCoZkCoFg@{J{@we@sDoK{@wBSkWwBsDg@kf@{E{ESkRcB{Eg@{OcB{c@gEgJ{@sDg@wBSwBS_S{@gTg@oKg@{Jg@cQwBwBSwo@{JkH{@sIoAsDg@oFg@wLoAcQcBw`@sDsDg@gm@oFcL{@k\\_D{h@oFkCScB?sI{@oPcB_eA{J_XwBg@ScBS{@?wBSkCScBSoFg@gEg@{h@oFgOoAoASoA?sNoA{TwB_I{@w`@sDwBSoZkCwVwB_Ig@oF?oK?oFR{J?sD?_D?gESsDg@gTwBgm@wGcLoAcLcB_N_DoKkCcLwBsSwB{OcBoKoA_Dg@oUwB_NoAkCSoAScB?kHg@gm@cGgc@sD{^_D_Ig@o_@sDwQcBs]sDw[kC{OcBgJg@gOoAcLoAwBS{c@gEgc@{Eo_@_D{YkCkHg@{@SkWkCkCSo_@sDwGg@{Eg@oKoAkCSgc@gEo_@sD_ScBsSwB_]_Doi@oFkp@oF_Dg@oZkCwQoAg^sDkRcBgJg@oPwBkk@{Egc@gEsDcBcBcB{@oAg@cBSoAScBf@kCnAwBvBwB~CoArDoA~CS~CRz@RnARz@z@nAz@nAjCz@zEoUzzAkHfc@g@nF{@~HoAbL_DfY{@nKwBrNoAjHoArIcBzJsb@flC{@vGcB~MSvBsXwG_ScGgJkCgJcBkH{@wGSwo@cBstAwBklB{EkRg@{r@{@_Ng@g@zEwBfY{Ezm@g@vGkCv[SzEkCfY?R?rD?rD?~C?vB?bBSbBg@nKSvB?bB_eAwLoASkMoA_NcBwQwBoUkCSfEgErl@_v@_I_DSg@SgYgEsIg@{@RkCnK{@bGwBg@oASkW_DcG{@cGoAgTkCoASgE{@oFg@sDzYRrDnAbB~WrD_XsDoAcBSsDrD{YoAS{E{@g@?oPkCwG{@_Dg@S?oPkCkWwBoAS{@?{^oFcBSzEo_@f@sDf@{Ef@kCf@oFzEk\\z@gO?wQ?wBScBoAoAoA{@{@?oA?oAf@{@z@{@bB_D~HoAzJoFve@_Ifm@cGjf@cB~Hg@bBoAnFoArD_D~HwBnFkCrDgEzEsIzJwQrS_I~HsIrIsSnUwBjCsSzT_DrD_DfE_IbLoPbVoAbBcBjCsNzTo_@vj@{EvG_SzYsSnZcGfJ{JfOkHnKcBvBSR{ObVgEbG_DnFgOfTcB~Cg@f@cLnPoKzO{E~HcQjW_DnFoAbB_IbLwBjCkCrDsIjMkMvQsI~M{OnUos@reAkHbLkCbG_DjHcB~H{@bGg@zEg@zE?nF?vGRzEz@fJbBvGfOjk@~CbLjC~HzEnPRz@f@f@nARjCf@bBRvBf@z@Rf@Rz@f@z@bBbBjCrDvGfEbGrDfEbGbGfOfOjM~MnUzTjMvLvLvLjM~MrIrIjMbLvGnFnFzE~CzEvBvBbBjCbB~CvB~CnFnKrDjHz@vBf@vB?bBRrD?~Cf@~Cf@jCf@vBRnARbBRvBRjC?jC{@jR?vGRnK?jHg@zE{@nFcBbGoA~CoAbBgEbG_DfE{@nA~Cz@rDz@zEnAfEbBvBnAjCbBvBvBjCrDjC~CjCfEnAvBbLnPz@nAzEjHjMjRbBjCbBnAbBvBnAz@z@z@nAz@jHfEnAz@fYvQzEjCjCnAbBz@fJfEfEvBvBf@bQzEnFbBvGnAzEnAbQ~CbBR{@nAoFbL{EbLoAvBoPb`@sDzJg@z@{@bBkH~Rg@bBgJnUkCvGcBfEcBrDjCnARRfEbB"],
		"4": ["_bj|GjmpflC??nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkCoA~C_IjR{JzT{Of^_Snd@sDzJsDrIoPzh@_DzJ{@zEg@bB{@zEg@~C{@rIoArIg@rDg@jCSbB{@bBcBz@cBz@oAnAoAnA?RoAvBg@vBSjCRjCRjCz@vBnAvBbBbBRf@RnA?vB?vBSvB{@~H{@jM{@nPg@rIoAbLwBrNg@rDg@fEcBbQ?z@oAvL{@zJg@jC_SwBcVwBwGg@wGg@gYkCkCg@cB?kMoAcQcBoPcB_Ig@cLoAkM{@_Ig@cB?gE?gJ?sISwBS_NoAkM{@_NoAwGg@_XkCgTkCcB{@oA{@??g@g@g@{@g@g@S{@S{@S{@?{@?oA?SRwBbGwj@f@sDz@gEf@kCf@oAnAg@nASnARf@Rf@f@f@z@f@nAz@~CoAvG{@zE{@fEwVbuB{@nF{@zEsDzOoArDg@~CoAbGoAvG{@jHSbBSnFg@zE?z@SjCnAzE{EnUcGn_@sD~RcBrIsNvt@cBfJcBrIcGv[g@bB??oAvGsDvQkHv`@oUnlAg@rDg@jCg@vBg@zE{@fEg@fEg@rDwBzOcG~a@gErXoAvG{@vG_DbBSvBcBjMcBvQSz@g@vGg@rISvGSvB?fE?~CS~RSjRRvL?jHRfERbGf@rNRz@f@nKz@~MbBzOjCvQRz@bBnKf@vBrDnP~C~MvB~HbBnFvB~Hz@rDjCrInFnPf@bBzEjMrDfJbGbLnFzJnKvQvLvQ?RnFjHjCfEjC~CfYb`@rb@jk@bQjWfEbGbBjCnKrNbLrNbVrXbQrSnAbB~HbLrDnF~CfEvLvQzTfYvLzOjRvVnKrNvQjWz@nArNjRnKfObQbVvGrI~\\nd@f@f@z@nAbBvBja@zh@vB~CjC~CvQvVfJbLbL~MnKjMfOjRnUv[fEbGvGjHfEnFjCvBjCjCzErDrDvBrDvBbGrD~MvGrSnKbG~Cz^bQnKnFjHfE~HnFnPrIzEvBnUbLnKzEfO~HjRfJrIfEnKzErIfEbVzJfJzEj\\fObLnFzEvB~CbBfOjHfc@rS~HfEfJnFfYnP~CvBrNfJzOzJb~@~k@fE~CbQfO~HbGbBnAz@z@bBnAz@z@~CjCrDjCbVnPnUfObLjHrN~HbGrD~u@b`@zc@jWzOfJzOrI~HfEjHfEzEzE~HjH~a@be@bGvGbGjHzEzErDjCzEfE~iAby@jR~MzY~R~R~M~WjR~HzEjHnFbBnA~CvBbBnA~_A~p@vLrIb`@~WrDvBv[nUvQvLjHnF~CvBvj@ja@bLrInFzEf@f@bBbBbBbBbBbB~H~HnFfE~MzJbQjM~HvG~C~CbGbG~HvGrDrD~CjCrD~CbGrD~MvGfEjCnPfJrInFjeCvfBfw@jf@rb@zYzJvGz^~WjHzEbe@j\\fJbGjCbBz^rXfc@j\\jHnFnFrDr]nZzO~MfErDjHjHbBbBz@f@bBvB~H~HjHjH~C~C~k@fm@~C~C~M~MbGbGnFzEnAbBrv@ju@bGbG~C~Cf@f@jCjCnAnArSjRv[fYbVfTnFzEzEzEvVjWzJnKjR~RnK~MvL~MvBjCjHjHnKbLrD~C~C~CzJfJvBbBnFzEvBvBrIrIrD~CnAnAjCjCbBnArNrNbGbGzEzEfJzJbmAfpArDfEvBvBvBjCjCjCf^v`@vBvB~HfJ~CfEfEfEzEfEvGzErN~HvGfErN~HzJbGbG~CvGvBbL~CbBf@rDf@vLvBrNbBnFnAvBR~HbBzOfEzJ~Cf^nKni@bQrv@vVjMfEz@RzYnKvGvBfJ~Cr]vLRz@RnARnAg@bBoAvBovAvzBoAjCg@jCSvBf@jCz@~Cz@jCbBbBz@f@vBnArDnAzw@fObe@fJbBf@vBnAvBbBf@nAf@Rz@vBbBfER~Cz@jHS~Cg@zOcBv[gEbt@wBjf@{@rSg@nFcBrb@g@vGoFb~@?z@wGnbAoAnUwGnlAwBrb@wGvrA?fYSbV?fTSzT{@fT{@j\\_IfzASvB{@vLoA~MkCfTkCbVoA~MkCjW{EbmA{@nPsDzaAg@~H{@bVSzE_IvpB?z@cB~a@{@fO{@vLSrDg@nF{@rD{@bGcBnF{Eb`@cBjH{@bGoA~Hg@rI{@zJg@fJ{@zJSfEg@rD{@fE{@fEoAjC{@vBoAvBcBjCcBvBsX~\\gObQkM~Mco@bo@w`@ja@oi@zh@we@jf@s]j\\_SzOoF~CoF~C{aA~a@kdAbe@sI~CcQrIgYfJcL~CcBRgEf@cGf@kCSwGz@oFjCsDfEoAfESf@SvGz@bGjCnFzErDnFbBjH?vGz@zEz@bBz@jC~C~_ArjArDzEv`@be@jf@rl@jHfJvBjCj\\r]rDrDvj@rl@rIrIjH~HzJnKrDfEnAnAjM~MnKbLjC~CfEfEzJnKjH~H~HrIcBbB{ErD{r@jf@oKjHsDjC_]nUgOnK_DvBsIbG_NfJsNzJc`@rXwBbBod@nZkCvBkHzEwLrIs]nUcBz@kCz@wBf@oA?cB?kC?kCSSg@oAkCkHwLsIkMgEoF_DgE_IcLsIwL_IoK{@oAcBwBwB_DkCvBwBnA{@f@oPjMgTrN{YfTcj@b`@kCsDcBwB_IoK_IoK_IoKsIcLsIcLgJkMcG_IkCbB_DjCk\\bVoKjHsD~CoF~Cs]jWwBbBoAz@{@f@wVvQ{JjHg@f@sIvGgYfToK~HcBz@oAz@wBf@wBR_DRsDf@cBRcBf@oAz@oAf@cBvBwLzJ{@z@kMnKkCvBgJ~HgErDcLzJ{@f@cGzEoP~Mco@jk@kf@~a@gEbBkCf@wBR_D?{@S{@R{@Rg@Rg@z@Sz@?z@Rz@f@z@z@f@z@RnA?z@g@f@SRg@fEwBnAcBv`@be@ja@ve@vQbV{^nURf@"],
		"5": [null],
		"6": [null],
		"7": ["_bj|GjmpflC??nUzJsNnZwG~MwmA_g@bVkk@zT{h@z@cBbBgEf@g@zpAni@nd@jRf@RrDnA~CbBRg@~Won@nUwj@zEwLfTgh@nPo_@zY{r@f@oAvB{Ez@wBbBcBnAg@vB{@zEg@zJrDfTfJr]rNvGjCbQbGbQvGzc@fOrNzEnFvBnFvBrDbBnF~CzEjCrDbBrDnAbGvBjp@fTfTvGzYzJfJ~CrSzJvVnKbBz@jCz@nF~CvBz@zEvBfE~CfE~CzOjMbBz@nAnAfOnPfYzYzObQzJzJ~C~CbBbB~MvLzErDbLrIrD~CnK~HnU~RjRnPzJnKjC~CjCvBnAbBzEnFbLbLfEzEjMvLbVnUnAnAzJbLjCjC~CfE~C~CfEfEvGjHnAg@jCcBf@{@z@oA~C{Ef@{@RoASwBSwB{@wBwBgE{EcLgE_Ig@oA?cBRoAf@oAz@oAz@{@bBSjCSbB?jCz@fOfJfEvBzT~MrDjCfESjCS~C{@fO_IfEcB~CwBrDoAbBg@nFcBby@{ToK_g@nP_Db`@kHfJoAfJoAjp@cGz@g@f@Sz@{@nAwBf@cBf@cBf@_DRoF{@{EoAgEgEkHwBkCkCwBkCcBoU{JoU_IoKgEgEoA{TgJcQkHfOw`@{^gOwGcB{OSwLkC{OcBoPScL{@{JkC"],
		"8": ["_bj|GjmpflC??????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkC{@g@gpA{h@wB{@kk@oUcL{E_]gO{JsDka@cQwG_DoFcB{EoA{E{@gTkCkHcB{EoAsDwB_D_DwBwBcBwBcBkC{@wBoA_DcBkCwBwB_DcB_D{@_Dg@oFsD{@{@g@g@{@oAoAkCkCgEoZwo@{@wB{E_IgEkH_NkR_b@ox@{JcQwQ{^sX_l@kRka@oFcLsN{YwB{E{@wBnA_DnAwBzEcL~CoKnKkWz@g@nA{@z@g@nASnASnASnA?vLzEj\\jMja@zO~R~Hjz@j\\rg@~Rz^rNnAjCf@nAf@z@?z@Rf@?nASnA{@~CwBvGgTzm@bBz@cB{@fT{m@vBwGz@_DbBoAz@g@nASnAg@nA?~C?rXnK~CvBrDrDz@z@z@bBRvBf@rDcB~CgEbLwVrq@gYzw@wG~RsIjWsq@~gB{E~MkC~HkCrIkCrI{ErS_DjMwBnKoA~HcBjMgEzc@kC~RgEb[gEzh@g@rDS~Cg@~Cg@~H{Efh@_DnZgJ~dA_D~W{@vG_DfT_DfToAvG{@zE{@fEwVbuB{@nF{@zEsDzOoArDg@~CoAbGoAvG{@jHSbBSnFg@zE?z@SjCnAzE{EnUcGn_@sD~RcBrIsNvt@cBfJcBrIcGv[g@bB??oAvGsDvQkHv`@oUnlAg@rDg@jCg@vBg@zE{@fEg@fEg@rDwBzOcG~a@gErXoAvG{@vG_DbBSvBcBjMcBvQSz@g@vGg@rISvGSvB?fE?~CS~RSjRRvL?jHRfERbGf@rNRz@f@nKz@~MbBzOjCvQRz@bBnKf@vBrDnP~C~MvB~HbBnFvB~Hz@rDjCrInFnPf@bBzEjMrDfJbGbLnFzJnKvQvLvQ?RnFjHjCfEjC~CfYb`@rb@jk@bQjWfEbGbBjCnKrNbLrNbVrXbQrSnAbBg@jCSf@g@nA{@vBoAbBoAnAkMzJcj@b`@oAvB{@bB{@vBSbBRfEf@jCf@nA~HbL~CrDfY~a@nAbBf@vBf@rD?jCg@vB{@jCcBjC_l@~a@oi@ja@c`@rXsg@n_@kCjC_InF_yAzfAw|AjiAw[bV_NfJgErD{m@zc@{TbQce@rb@kRjRkRfT{EbGsDnFgEjHkCzEsDbGwt@~xAsDjHkCjHsDzJ_DrI{EzOcBnFcBnFoArDsDrIkCvGkHzOkHzOgJfTsDrI{Of^wBz@wBRkCRoAS{@g@wBcBcBoAg@{@oK_NkM{OwLsNcBwBwBcBwBoA_DoAsDSwj@?s]??jCf^?nd@SfERjCRjCz@vBnAbBvBfOvQfYf^zJvLfEbGvB~C~CfEjCrDnAnAz@nAvLvLjCbBvQfOfTfOfJjH~HnFnPbL{@z@w[fc@_]nd@_]be@k\\fc@sN~RwLzOs]nd@cQwL{TgO{^kWoAg@oA{@gE{@oFg@{Eg@sInKwGfJsN~R_NbQsb@vj@c[ja@cQzTkMbQgEbGcGrI_DnFkCfE_DvGoFzJ{EfJsI~R{@jCoFnP{@bBoKb[wGjRwQzh@cBfEgEjMsN~a@{Ove@c[v~@sNb`@sInUcQbe@cGrNcBfE{EzJsDjHwLnUkHvLwGfJ{J~M{JvLg@z@kCjC{JbLo_@b`@gOzOkC~CgE~M_DrD_v@fw@ce@~f@oi@vj@_N~MsNjM{JfJkRzOcQfO_IbGgJjH{TfOwVfOkCbBwVrNc[~Rcj@r]gc@~WcGrD{@f@oPnK{OzJ_]fTkRvL_DjCoUrNka@vVg^nU_b@rXw[~RkdAjp@kz@ni@{OnKwBbBsIvG{h@rb@kMbBwLfJkHbGkp@bj@kMnKcGf@_D?oAS{@g@oAoA_ScVg@g@kRkWkC_DoUsXg@{@S{@R{@f@{@rD_DrIkHjCcBcBwB_ScVcV{Y_DsDsSsX_DoF{EgJwQka@{@wBz@oA?cBg@cB{@g@g@S{@?g@?{@Rg@f@g@f@Sz@?z@wVv`@{EnFgEfEgTjRSg@_b@_g@sNcQgc@cj@cGkHkCwBnAwBf@oAoPwG_Dg@"],
		"9": ["_bj|GjmpflC????????nUzJsNnZwG~MgYrl@Sz@g@f@wVfh@sIbQoA~C_IbQ_Xbj@{@bB_IsDw`@oPgYwLwV{JgTgJc[_NgOcGcB{@wGkC{@g@gpA{h@wB{@kk@oUcL{E_]gO{JsDka@cQwG_DoFcB{EoA{E{@gTkCkHcB{EoAsDwB_D_DwBwBcBwBcBkC{@wBoA_DcBkCwBwB_DcB_D{@_Dg@oFsD{@{@g@g@{@oAoAkCkCgEoZwo@{@wB{E_IgEkH_NkR_b@ox@{JcQwQ{^sX_l@kRka@oFcLsN{YwB{E{@wBcBsDg@{@_DwGka@wy@cGkMgJ{T_IoP{@wBgOoZSoA_DcGwBoFwBwGwVsq@oFsNgJsScLkWwB{EoAwBcBkCwBcBgE{E{JcLcBwBkCsDcBsDkM_X{EkH_DgEcBwBkCsDwGwGsIcGoUwLco@cV_D{@{EwBsl@gTcLsDwt@sXwy@{YsDoA{EwBgO{E{T{EwGoAsSwB{Og@kMScG?_v@oAkH?sb@{@gJSw`@g@w`@g@oA?we@S_oA{@wVRc`@?{@Skp@g@ckBcB_D?g|@{@od@S_ISwcA{@sI?sXScGSwcAoA{J?o_@g@o_@?_D?_ISgE?oA?cQSwaBoAcB?co@g@gJ?{r@{@_]SkWg@oA?kC?z@wBR{@z@kCfEsNnKk\\R{@nFcQrD{JbQwj@z@wBbBf@fTbGgTcGcBg@{@vBcQvj@sDzJoFbQSz@oKj\\gErN{@jCSz@{@vBcBnFSnAg@nAoArDSnAoFbQoK~\\kCrI{@jCg@bBsDvLcGbQ{EzOcLf^kC~Hg@nAoASccAcVgOsDwGoAwBg@_D{@oKkCcBSwBg@gr@{Oc[kHk_A_XsDrIrDsI~Rwo@nKk\\z@kCfkAnArl@f@j\\f@?vBSbGRf@Rf@R?z@f@{@g@S?Sg@Sg@RcG?wBbQRzw@?reAnAvB?nA?rD?~xAbBzpAnAbrAz@jRRfORrD?{@vBg@bB{Orv@oPfw@sD~RoAnFkHz^gJve@oKfc@_Snx@_D~Mw`@~}AgEbQSbBgO~k@k\\~nAcBvG"]
	},
	"solution": {
		"0": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "0_start",
			"location_name": "0_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "73595443",
			"location_name": "73595443_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "79970344",
			"location_name": "79970344_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "47442661",
			"location_name": "47442661_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838177,
			"distance": 0,
			"finish_time": 1677838237,
			"location_id": "1020792730",
			"location_name": "1020792730_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839954,
			"distance": 9078.7,
			"finish_time": 1677840014,
			"location_id": "47442661",
			"location_name": "47442661_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840206,
			"distance": 717.7,
			"finish_time": 1677840266,
			"location_id": "73595443",
			"location_name": "73595443_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840402,
			"distance": 311.4,
			"finish_time": 1677840462,
			"location_id": "1020792730",
			"location_name": "1020792730_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842269,
			"distance": 7256.8,
			"finish_time": 1677842329,
			"location_id": "79970344",
			"location_name": "79970344_dropoff",
			"type": "dropoff"
		}],
		"1": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "1_start",
			"location_name": "1_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "1014199855",
			"location_name": "1014199855_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "1022944599",
			"location_name": "1022944599_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "52957556",
			"location_name": "52957556_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677841271,
			"distance": 16071,
			"finish_time": 1677841331,
			"location_id": "1014199855",
			"location_name": "1014199855_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842329,
			"distance": 3921.5,
			"finish_time": 1677842389,
			"location_id": "52957556",
			"location_name": "52957556_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842424,
			"distance": 84.7,
			"finish_time": 1677842484,
			"location_id": "1022944599",
			"location_name": "1022944599_dropoff",
			"type": "dropoff"
		}],
		"10": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "10_start",
			"location_name": "10_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "1032446405",
			"location_name": "1032446405_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "9772576",
			"location_name": "9772576_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "1032465163",
			"location_name": "1032465163_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677840108,
			"distance": 7881.6,
			"finish_time": 1677840168,
			"location_id": "9772576",
			"location_name": "9772576_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840719,
			"distance": 2305.8,
			"finish_time": 1677840779,
			"location_id": "1032465163",
			"location_name": "1032465163_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842178,
			"distance": 5295.1,
			"finish_time": 1677842238,
			"location_id": "1032446405",
			"location_name": "1032446405_dropoff",
			"type": "dropoff"
		}],
		"11": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "11_start",
			"location_name": "11_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "37514608",
			"location_name": "37514608_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "1049608213",
			"location_name": "1049608213_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "1116244835",
			"location_name": "1116244835_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839662,
			"distance": 7240.3,
			"finish_time": 1677839722,
			"location_id": "1116244835",
			"location_name": "1116244835_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677839804,
			"distance": 199.5,
			"finish_time": 1677839864,
			"location_id": "1049608213",
			"location_name": "1049608213_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840160,
			"distance": 691.3,
			"finish_time": 1677840220,
			"location_id": "37514608",
			"location_name": "37514608_dropoff",
			"type": "dropoff"
		}],
		"12": [{
			"arrival_time": 1677751597,
			"distance": 0,
			"location_id": "12_start",
			"location_name": "12_start"
		}],
		"13": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "13_start",
			"location_name": "13_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "22523137",
			"location_name": "22523137_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "88267234",
			"location_name": "88267234_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "74085398",
			"location_name": "74085398_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838177,
			"distance": 0,
			"finish_time": 1677838237,
			"location_id": "60251436",
			"location_name": "60251436_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839655,
			"distance": 7423.7,
			"finish_time": 1677839715,
			"location_id": "88267234",
			"location_name": "88267234_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840154,
			"distance": 1886.4,
			"finish_time": 1677840214,
			"location_id": "74085398",
			"location_name": "74085398_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841039,
			"distance": 3366.3,
			"finish_time": 1677841099,
			"location_id": "22523137",
			"location_name": "22523137_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841766,
			"distance": 1906.5,
			"finish_time": 1677841826,
			"location_id": "60251436",
			"location_name": "60251436_dropoff",
			"type": "dropoff"
		}],
		"14": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "14_start",
			"location_name": "14_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "40401504",
			"location_name": "40401504_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "53165614",
			"location_name": "53165614_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "52377064",
			"location_name": "52377064_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838177,
			"distance": 0,
			"finish_time": 1677838237,
			"location_id": "74282226",
			"location_name": "74282226_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677840029,
			"distance": 7001.4,
			"finish_time": 1677840089,
			"location_id": "74282226",
			"location_name": "74282226_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840593,
			"distance": 1312.7,
			"finish_time": 1677840653,
			"location_id": "52377064",
			"location_name": "52377064_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841512,
			"distance": 3177,
			"finish_time": 1677841572,
			"location_id": "53165614",
			"location_name": "53165614_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842211,
			"distance": 1656.7,
			"finish_time": 1677842271,
			"location_id": "40401504",
			"location_name": "40401504_dropoff",
			"type": "dropoff"
		}],
		"15": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "15_start",
			"location_name": "15_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "63344046",
			"location_name": "63344046_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "79652080",
			"location_name": "79652080_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "85441849",
			"location_name": "85441849_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677840285,
			"distance": 9642.3,
			"finish_time": 1677840345,
			"location_id": "63344046",
			"location_name": "63344046_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840677,
			"distance": 857.5,
			"finish_time": 1677840737,
			"location_id": "79652080",
			"location_name": "79652080_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840896,
			"distance": 405.4,
			"finish_time": 1677840956,
			"location_id": "85441849",
			"location_name": "85441849_dropoff",
			"type": "dropoff"
		}],
		"16": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "16_start",
			"location_name": "16_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "52047440",
			"location_name": "52047440_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "57294302",
			"location_name": "57294302_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839517,
			"distance": 3594.7,
			"finish_time": 1677839577,
			"location_id": "52047440",
			"location_name": "52047440_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842077,
			"distance": 15765.2,
			"finish_time": 1677842137,
			"location_id": "57294302",
			"location_name": "57294302_dropoff",
			"type": "dropoff"
		}],
		"17": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "17_start",
			"location_name": "17_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "52790496",
			"location_name": "52790496_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "80213136",
			"location_name": "80213136_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677840476,
			"distance": 11636.4,
			"finish_time": 1677840536,
			"location_id": "52790496",
			"location_name": "52790496_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841426,
			"distance": 2401.8,
			"finish_time": 1677841486,
			"location_id": "80213136",
			"location_name": "80213136_dropoff",
			"type": "dropoff"
		}],
		"18": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "18_start",
			"location_name": "18_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "80802584",
			"location_name": "80802584_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677841321,
			"distance": 15655.4,
			"finish_time": 1677841381,
			"location_id": "80802584",
			"location_name": "80802584_dropoff",
			"type": "dropoff"
		}],
		"19": [{
			"arrival_time": 1677751597,
			"distance": 0,
			"location_id": "19_start",
			"location_name": "19_start"
		}],
		"2": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "2_start",
			"location_name": "2_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "1000130108",
			"location_name": "1000130108_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "72278279",
			"location_name": "72278279_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "46384770",
			"location_name": "46384770_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838177,
			"distance": 0,
			"finish_time": 1677838237,
			"location_id": "53088825",
			"location_name": "53088825_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839996,
			"distance": 5685.2,
			"finish_time": 1677840056,
			"location_id": "1000130108",
			"location_name": "1000130108_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841554,
			"distance": 6816.9,
			"finish_time": 1677841614,
			"location_id": "72278279",
			"location_name": "72278279_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842155,
			"distance": 1911.7,
			"finish_time": 1677842215,
			"location_id": "46384770",
			"location_name": "46384770_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842389,
			"distance": 801,
			"finish_time": 1677842449,
			"location_id": "53088825",
			"location_name": "53088825_dropoff",
			"type": "dropoff"
		}],
		"3": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "3_start",
			"location_name": "3_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "52931807",
			"location_name": "52931807_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "52533963",
			"location_name": "52533963_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "1019024488",
			"location_name": "1019024488_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838177,
			"distance": 0,
			"finish_time": 1677838237,
			"location_id": "1090370488",
			"location_name": "1090370488_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677840166,
			"distance": 9964.1,
			"finish_time": 1677840226,
			"location_id": "52931807",
			"location_name": "52931807_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840664,
			"distance": 918.4,
			"finish_time": 1677840724,
			"location_id": "52533963",
			"location_name": "52533963_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840874,
			"distance": 270.4,
			"finish_time": 1677840934,
			"location_id": "1019024488",
			"location_name": "1019024488_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841892,
			"distance": 4229.5,
			"finish_time": 1677841952,
			"location_id": "1090370488",
			"location_name": "1090370488_dropoff",
			"type": "dropoff"
		}],
		"4": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "4_start",
			"location_name": "4_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "1014221625",
			"location_name": "1014221625_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677841993,
			"distance": 21415.7,
			"finish_time": 1677842053,
			"location_id": "1014221625",
			"location_name": "1014221625_dropoff",
			"type": "dropoff"
		}],
		"5": [{
			"arrival_time": 1677751597,
			"distance": 0,
			"location_id": "5_start",
			"location_name": "5_start"
		}],
		"6": [{
			"arrival_time": 1677751597,
			"distance": 0,
			"location_id": "6_start",
			"location_name": "6_start"
		}],
		"7": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "7_start",
			"location_name": "7_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "1020744163",
			"location_name": "1020744163_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839453,
			"distance": 4355.7,
			"finish_time": 1677839513,
			"location_id": "1020744163",
			"location_name": "1020744163_dropoff",
			"type": "dropoff"
		}],
		"8": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "8_start",
			"location_name": "8_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "51859777",
			"location_name": "51859777_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "91440311",
			"location_name": "91440311_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "52558177",
			"location_name": "52558177_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839168,
			"distance": 3019.1,
			"finish_time": 1677839228,
			"location_id": "51859777",
			"location_name": "51859777_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677841027,
			"distance": 8154.1,
			"finish_time": 1677841087,
			"location_id": "91440311",
			"location_name": "91440311_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677842259,
			"distance": 5289.9,
			"finish_time": 1677842319,
			"location_id": "52558177",
			"location_name": "52558177_dropoff",
			"type": "dropoff"
		}],
		"9": [{
			"arrival_time": 1677837997,
			"distance": 0,
			"location_id": "9_start",
			"location_name": "9_start"
		}, {
			"arrival_time": 1677837997,
			"distance": 0,
			"finish_time": 1677838057,
			"location_id": "63478946",
			"location_name": "63478946_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838057,
			"distance": 0,
			"finish_time": 1677838117,
			"location_id": "31714794",
			"location_name": "31714794_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838117,
			"distance": 0,
			"finish_time": 1677838177,
			"location_id": "1092343332",
			"location_name": "1092343332_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677838177,
			"distance": 0,
			"finish_time": 1677838237,
			"location_id": "91533929",
			"location_name": "91533929_pickup",
			"type": "pickup"
		}, {
			"arrival_time": 1677839857,
			"distance": 6305.4,
			"finish_time": 1677839917,
			"location_id": "91533929",
			"location_name": "91533929_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840309,
			"distance": 1176.7,
			"finish_time": 1677840369,
			"location_id": "1092343332",
			"location_name": "1092343332_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840504,
			"distance": 481.1,
			"finish_time": 1677840564,
			"location_id": "31714794",
			"location_name": "31714794_dropoff",
			"type": "dropoff"
		}, {
			"arrival_time": 1677840936,
			"distance": 1915.2,
			"finish_time": 1677840996,
			"location_id": "63478946",
			"location_name": "63478946_dropoff",
			"type": "dropoff"
		}]
	},
	"status": "success",
	"total_break_time": 0,
	"total_distance": 231.4549,
	"total_idle_time": 0,
	"total_travel_time": 885,
	"total_vehicle_overtime": 0,
	"total_visit_lateness": 0,
	"total_working_time": 977,
	"unserved": {
		"79978411": "cannot be visited within the constraints"
	},
	"vehicle_overtime": {
		"0": 0,
		"1": 0,
		"10": 0,
		"11": 0,
		"12": 0,
		"13": 0,
		"14": 0,
		"15": 0,
		"16": 0,
		"17": 0,
		"18": 0,
		"19": 0,
		"2": 0,
		"3": 0,
		"4": 0,
		"5": 0,
		"6": 0,
		"7": 0,
		"8": 0,
		"9": 0
	}
}
```
