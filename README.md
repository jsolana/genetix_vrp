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
