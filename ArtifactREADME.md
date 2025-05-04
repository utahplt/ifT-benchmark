# Artifact Evaluation for "If-T: A Benchmark for Type Narrowing"

This document provides instructions for evaluating the artifact associated with the paper "If-T: A Benchmark for Type Narrowing". The artifact consists of the If-T benchmark suite, implementations for five type checkers (Typed Racket, TypeScript, Flow, mypy, Pyright), and scripts to run the benchmarks and collect results.

## Getting Started Guide

### Set Up the Environment
For your convenience, we provide a Dockerfile to create a container with the necessary environment. The Dockerfile should work for both amd64 and arm64 architectures. You can also import the provided Docker image.

To use the Dockerfile, first clone the repository:

```shell
git clone https://github.com/utahplt/ifT-benchmark.git
cd ifT-benchmark
```

Then, build the Docker image using the provided Dockerfile, and run the container.

```shell
# Build the Docker image
docker build -t ift .
# Run the Docker container
docker run -it --rm ift
```

Alternatively, you can import the pre-built Docker image from the provided link. This image contains all the necessary dependencies and configurations to run the benchmark suite.

```shell
# Pull the pre-built Docker image (replace <image-link> with the actual link)
curl -L -O <image-link>
docker load -i <image-name>.tar
# Run the Docker container
docker run -it --rm -v ifT-benchmark
```

### Running the Benchmark

Once entered into the Docker container, the work directory will be set to `/ifT-benchmark`. You can run the benchmark suite directly from this directory. The entry point for the benchmark is the `main.rkt` script, which serves as the driver for executing the tests.

```
$ racket main.rkt --help
usage: main.rkt [ <option> ... ] [<type-checker>]

<option> is one of

  -v, --verbose
     Print the output of the benchmarks to the console
  -f <output-format>, --format <output-format>
     Print the output of the benchmarks in the specified format. Options: plain, markdown, tex. Default: plain.
  -t, --transpose
     Transpose the output of the benchmarks
  -e, --examples
     Run the advanced examples
  --help, -h
     Show this help
  --
     Do not treat any remaining argument as a switch (at this level)

 Multiple single-letter switches can be combined after
 one `-`. For example, `-h-` is the same as `-h --`.
```

When parameter `<type-checker>` is not provided, the benchmark will run all type checkers. Otherwise, it will run only the specified type checker. For now, the supported type checkers are `TypedRacket`, `TypeScript`, `Flow`, `mypy`, and `Pyright`.

For example, to run the benchmark for all type checkers and get the output in Markdown format, you can execute:

```shell
racket main.rkt --format markdown
```

This will run the benchmark suite and print the results to the console. The output will include a summary of the results for each type checker, indicating whether they passed or failed each benchmark item. Failures of benchmark items are indicated by an `x` and successes by an `O`.

If you see the following output without errors, the basic setup is complete and functional.

```markdown
| Benchmark         | typedracket | typescript | flow | mypy | pyright |
| positive          | O           | O          | O    | x    | O       |
| negative          | O           | O          | O    | x    | O       |
| alias             | O           | O          | x    | x    | O       |
| connectives       | O           | O          | O    | x    | O       |
| nesting_body      | O           | O          | O    | x    | O       |
| nesting_condition | O           | x          | x    | x    | x       |
| predicate_2way    | O           | O          | O    | x    | O       |
| predicate_1way    | O           | x          | O    | x    | O       |
| predicate_checked | O           | x          | O    | x    | x       |
| object_properties | O           | O          | O    | x    | O       |
| tuple_elements    | O           | O          | O    | x    | O       |
| tuple_length      | x           | O          | O    | x    | O       |
| merge_with_union  | O           | O          | O    | x    | O       |
```

## Overview of Claims

This artifact supports the central claims made in the paper regarding the characterization and comparison of type narrowing features across different type systems.

### Claims Supported by the Artifact

1.  **Characterization of Type Narrowing Features:** The If-T benchmark suite consists of the 13 core features of type narrowing identified in the paper (see section 3 & 4 of the paper). Running the artifact executes these benchmark items against each type checker.
    *   *Evaluation:* Run the benchmark for all type checker and note that it evaluates 13 benchmark items for each type checker.
2.  **Comparison Across Type Systems:** The artifact enables the reproduction of the comparison results presented in Table 2 of the paper, showing how Typed Racket, TypeScript, Flow, mypy, and Pyright behave differently on type narrowing.
    *   *Evaluation:* Run the full benchmark suite (see Step-by-Step Instructions) and compare the generated summary table with Table 2 in the paper.
3.  **Practicality of the Core Features:** The artifact includes example programs (see EXAMPLES.md and section 6 of the paper) that demonstrate how the features of type narrowing come together to support useful and practical programs.
    *   *Evaluation:* Run the main benchmark driver with the `--examples` flag to execute the advanced examples. The results should match the discussion in the paper.

**Claims Not Supported by the Artifact:**

1.  **Performance Evaluation:** The benchmark is designed to test the *expressiveness* and *correctness* of type narrowing features, not the *performance* of the type checkers. No performance claims are made in the paper, and the artifact does not include timing mechanisms. Performance comparisons would likely be unreliable within a VM environment anyway.
2.  **Exhaustiveness:** While the benchmark covers core features identified through literature and documentation review (\Cref{s:design}), it does not claim to be an exhaustive list of *all possible* type narrowing behaviors or edge cases.
3.  **Type Checkers Not Included:** The artifact only provides implementations and results for the five type checkers mentioned. Claims about other type systems cannot be directly evaluated using this artifact.
