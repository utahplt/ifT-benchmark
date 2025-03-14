# How to Run the Benchmark

To run the benchmark, you need to have the following tools installed:

- [Racket](https://racket-lang.org/)
- [Node.js and npm](https://nodejs.org/)
- [Python and pip](https://www.python.org/)

The tested versions are:

| Tool         | Version | Notes                                                                                                                |
|--------------|---------|----------------------------------------------------------------------------------------------------------------------|
| Typed Racket | 8.15    | Bundled with [Racket 8.15](https://download.racket-lang.org/releases/8.15/)                                                                                             |
| Node.js      | 22.11.0 | See `.node-version` file under relevant directories                                                                  |
| npm          | 10.9.0  | Bundled with Node.js                                                                                                 |
| Python       | 3.13.0  | See `.python-version` file under relevant directories                                                                |
| pip          | 24.2    | Bundled with Python                                                                                                  |
| TypeScript   | 5.6.3   | See [`TypeScript/package-lock.json`](https://github.com/utahplt/ot-benchmark/blob/main/TypeScript/package-lock.json) |
| Flow         | 0.245.2 | See [`Flow/package-lock.json`](https://github.com/utahplt/ot-benchmark/blob/main/Flow/package-lock.json)             |
| Pyright      | 1.1.389 | See [`Pyright/package-lock.json`](https://github.com/utahplt/ot-benchmark/blob/main/Pyright/package-lock.json)       |
| mypy         | 1.13.0  | See [`mypy/requirements.txt`](https://github.com/utahplt/ot-benchmark/blob/main/mypy/requirements.txt)               |

First, clone this repository:

```shell
git clone https://github.com/utahplt/ifT-benchmark.git
cd ifT-benchmark
```

Then, install the dependencies for the benchmark tools:

```shell
chmod +x setup.sh
./setup.sh
```

(or)

```shell
bash setup.sh
```

The benchmark driver is written in Racket (`main.rkt`).
Install the toplevel directory as a package to manage dependencies:

```text
$ raco pkg install --auto
```


The usage of the benchmark tool is as follows:

```text
$ racket main.rkt --help
usage: main.rkt [ <option> ... ] [<type-checker>]

<option> is one of

  -v, --verbose
     Print the output of the benchmarks to the console
  -f <output-format>, --format <output-format>
     Print the output of the benchmarks in the specified format. Options: plain, markdown, tex. Default: plain.
  --help, -h
     Show this help
  --
     Do not treat any remaining argument as a switch (at this level)

 Multiple single-letter switches can be combined after
 one `-`. For example, `-h-` is the same as `-h --`.
```

When parameter `<type-checker>` is not provided, the benchmark will run all type checkers. Otherwise, it will run only the specified type checker.
