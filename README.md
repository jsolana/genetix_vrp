# GeneticVrp

Genetic algorithm to resolve VRP problems

## Genetic algorithm

We create a permutation type genotype where every value represents a location

```console
  [0,1,2,3,4]
```

## TODO

### VRP Genetic Algorithm

- `crossover`: Current implementation doesnt work
- Implement other select strategies
- Check chunk_size (is a little mess depending of the type of the journey)
- Documentar todas las posibilidades de configuracion

### Matrix providers

- Evaluate different providers and the accuracy between them (specially  `great_circle_distance` implementation)
- [Documentation best practices](https://hexdocs.pm/elixir/1.13.4/writing-documentation.html): `@typedoc, @doc, @moduledoc`

### Design

- Move `genetic` as a independent library and separate from the specific code related to the VRP problem
- Document as a library
- Publish it in `hex.pm`
