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

Once entered into the Docker container, the work directory will be set to `/ifT`. You can run the benchmark suite directly from this directory. The entry point for the benchmark is the `main.rkt` script, which serves as the driver for executing the tests.

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

#### Running the Core Benchmark

The core benchmark suite consists of 13 benchmark items that test the expressiveness, soundness, and precision of type narrowing features across the five type checkers. The benchmark items are designed to cover a representative set of core features relevant to type narrowing. These benchmark items are implemented in the respective subdirectories for each type checker.

To run the benchmark for all type checkers and get the output in Markdown format, you can execute:

```shell
racket main.rkt --format markdown
```

This will run the core benchmark suite and print the results to the console. The output will include a summary of the results for each type checker, indicating whether they passed or failed each benchmark item. Failures of benchmark items are indicated by an `x` and successes by an `O`.

If you see the following output without errors, the basic setup is complete and functional. This corresponds to Table 2 in the paper. Interpretations of the results are provided in Section 5 of the paper.

```markdown
| Benchmark         | typedracket | typescript | flow | mypy | pyright |
| positive          | O           | O          | O    | O    | O       |
| negative          | O           | O          | O    | O    | O       |
| alias             | O           | O          | x    | x    | O       |
| connectives       | O           | O          | O    | O    | O       |
| nesting_body      | O           | O          | O    | O    | O       |
| nesting_condition | O           | x          | x    | x    | x       |
| predicate_2way    | O           | O          | O    | O    | O       |
| predicate_1way    | O           | x          | O    | O    | O       |
| predicate_checked | O           | x          | O    | x    | x       |
| object_properties | O           | O          | O    | O    | O       |
| tuple_elements    | O           | O          | O    | O    | O       |
| tuple_length      | x           | O          | O    | O    | O       |
| merge_with_union  | O           | O          | O    | x    | O       |
```

#### Evaluating Practical Example Programs

The artifact also includes practical examples to show how the features of type narrowing come together to support useful and practical programs. These examples are described in the `EXAMPLES.md` file inside the root directory in pseudo code, and they are implemented in the respective subdirectories for each type checker.

To evaluate these examples, you can run the benchmark driver with the `--examples` flag:

```shell
racket main.rkt --examples --format markdown
```

If you see the following output without errors, the advanced examples are functional and demonstrate the practical use of type narrowing features. More details about these examples can be found in the `EXAMPLES.md` file and Section 6 of the paper.

```markdown
| Benchmark | typedracket | typescript | flow | mypy | pyright |
| filter    | O           | O          | O    | O    | O       |
| flatten   | O           | O          | O    | O    | O       |
| tree_node | O           | x          | x    | x    | x       |
| rainfall  | O           | O          | O    | O    | O       |
```

## Overview of Claims

This artifact supports the central claims made in the paper regarding the characterization and comparison of type narrowing features across different type systems.

### Claims Supported by the Artifact

1. *If-T characterizes a set of 13 core type narrowing features.* The code of each type checker explicitly lists and implements 13 core benchmark items. After running the benchmark, the results show that every feature is supported by at least one of these popular typecheckers, indicating that these features are relevant and important.

2. *If-T evaluates type checkers by providing runnable implementations of benchmark programs.* The codebase is organized with separate subdirectories for each of the five type checkers. Within each of these directories, there are source files containing the concrete implementations of the 13 benchmark programs for that type checker. Furthermore, each type checker directory contains a `_benchmark.rkt` script that specifies the command and arguments needed to execute the type checker on its respective benchmark files and is directly executable.

3. *If-T enables a comparison of the expressiveness, soundness and precision regarding type narrowing across five type systems.* The results of the `main.rkt` script demonstrates difference of the behavior of the type checkers: some type checkers support certain features while others do not. Failing to pass an item indicates a shortage of either expressiveness, soundness or precision. Comparing the results of the benchmark items across type checkers allows us to see how they differ in their support for type narrowing features.

4. *If-T illustrates challenges and compromises of the design and implementation type narrowing.* The results of the `main.rkt` script show that each of these type checkers, despite being popular and mature, does not implement certain features, indicating the challenges and compromises of implementing type narrowing in practice. For example, the `nesting_condition` benchmark item is not supported by TypeScript and Flow, while `tuple_length` is not supported by Typed Racket.

5. *If-T demonstrates the practicality of type narrowing features with example programs.* The repository includes an `EXAMPLES.md` file that describes more complex, "real-world-like" programs such as `filter`, `flatten`, `TreeNode`, and `Rainfall`. Inside the subdirectory for each type checker, there are implementations of these examples that demonstrate the practical use of type narrowing features. The `main.rkt` script can be used to run these examples and collect results as described above.

### Claims Not Supported by the Artifact

There are no scientific claims in the paper that are not supported by this artifact.

## Troubleshooting

If you encounter any issues while running the benchmarks or if you have questions about the artifact, please refer to the following troubleshooting tips:

- The Dockerfile and Docker image are designed to work on both amd64 and arm64 architectures. In some cases, the build might not work due to some cross-architecture cache issues. The error might look like this:

```shell
...
 > [stage-0  7/11] RUN uv python install --preview --default 3.13.0:
124.8 error: Failed to install cpython-3.13.0-linux-aarch64-gnu
124.8   Caused by: Failed to download <some url>
124.8   Caused by: Request failed after 3 retries
124.8   Caused by: error sending request for url (<some url>)
124.8   Caused by: operation timed out
...
```

If you encounter any issues, try clearing the Docker cache or rebuilding the image without using the cache:

```shell
docker builder prune
docker build --no-cache -t ift .
```

## Evaluate Typecheckers Individually

Inside the root directory of the repository, there are several subdirectories for each type checker, each containing the necessary files to run the benchmarks. Each subdirectory contains the package manager manifest files, the implemention code for core benchmark items and advanced practical examples of that type checker. You may inspect these files to understand how the benchmarks are implemented and how they interact with the type checkers.

To run the benchmarks for a specific type checker, you can navigate to the respective subdirectory and run the `_benchmark.rkt` script. For example, to run the benchmark for TypeScript, you can execute:

```shell
cd TypeScript
racket _benchmark.rkt
```

This will run the benchmark suite for TypeScript and print the results to the console. You may also run the raw command for the type checker directly from the command line. For example, to run the core benchmark suite for TypeScript, you can execute:

```shell
cd TypeScript
npx tsc --noEmit --target es2023 main.ts
```

The raw command for each typechecker is written in the `README.md` file inside the respective subdirectory.

You can also run the advanced examples by executing the `_benchmark.rkt` script with the `--examples` flag:

```shell
cd TypeScript
racket _benchmark.rkt --examples
```

Or use the raw typechecker command:

```shell
cd TypeScript
npx tsc --noEmit --target es2023 examples.ts
```
