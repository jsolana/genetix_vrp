# GeneticVrp

Genetic algorithm to resolve VRP problems

## Genetic algorithm

We create a permutation type genotype where every value represents a location

```console
  [0,1,2,3,4]
```

## TODO

### VRP Genetic Algorithm

- `crossover`: Implementation (we can't delegate the validation of springs only applying the penalty score in the `fitness_function`).
- Check chunk_size (is a little mess depending of the type of the journey)

### Matrix providers

- Evaluate different providers and the accuracy between them (specially  `great_circle_distance` implementation)
- [Documentation best practices](https://hexdocs.pm/elixir/1.13.4/writing-documentation.html): `@typedoc, @doc, @moduledoc`

### Design

- Move `genetic` as a independent library and separate from the specific code related to the VRP problem
- Document as a library
- Publish it in `hex.pm`
