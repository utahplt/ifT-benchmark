# Contributing to ifT-benchmark

First of all, thank you for considering contributing to the ifT-benchmark project! We welcome contributions from everyone. The following is a short guide on how to contribute to the project.

## Benchmark Items

If you have ideas for new benchmark items, please open an issue on the GitHub repository. We will discuss the new benchmark items and decide whether and how to include them in the benchmark.
If you have suggestions for improving existing benchmark items, please open an issue too.
Don't forget to check the existing issues to see if someone else has already opened an issue for the same topic.

## Type Checkers

We welcome contributions of new type checkers as well as improvements to existing ones. For existing ones, please open an issue if you have suggestions for improvements. For new type checkers, following is a detailed guide on how to add a new type checker to the benchmark.

### Adding a New Type Checker

To add a new type checker to the benchmark, please fork the repository and make a pull request with the new type checker. The following is a step-by-step guide on how to add a new type checker to the benchmark.

#### Create a New Directory

Create a new directory for the new type checker in the root directory of the repository. The name of the directory should be the name of the type checker. For example, if the new type checker is called `NewTypeChecker`, the name of the directory should be `NewTypeChecker`.

#### Fill in the Datasheet

Create a `README.md` file in the new directory based on the template provided in the `DatasheetTemplate.md` file in the root directory. Fill in the datasheet with the information about the new type checker.

#### Write Test Cases for the Type Checker

All the test cases should lie in one single code file. When these test cases are checked, they will be extracted from the file and run against the type checker by the benchmark script. To achieve this, the file structure should be as follows:

```text
# Common beginning code for all test cases
# ...

### Code:
## Example benchmark_item_name
## success
# Code snippet that should pass the type checker goes here
## failure
# Code snippet that should be rejected by the type checker goes here

## Example another_benchmark_item_name
## success
# ...
## failure
# ...

### End:
# Common ending code for all test cases
```

Here we use `#` as the comment character as an example. This file, when checked, will be split into multiple temporary files, each containing one test case. For example, the above file will be split into two files, one containing the test case for `Example benchmark_item_name` and the other containing the test case for `Example another_benchmark_item_name`. Both of them have the common beginning and ending code before and after their test cases.

#### Implement `_benchmark.rkt`

The ifT-benchmark is designed to make it available that the test cases for each type checker can be checked on its own, and also all the test cases for all type checkers can be checked together. To achieve the former, you need to implement a `_benchmark.rkt` file in the new directory, which defines several important values and calls the `run-benchmark-item` function. The following is an example of the `_benchmark.rkt` file:

```racket
#lang racket

(require "../lib.rkt")

(define comment-char #\/)
(define extension ".js")

(define file-base-path (build-path (current-directory)))
(define filename-to-read (build-path "src/index.js"))
(define arguments `(,filename-to-read "flow" "focus-check"))
(define command "npx")

(run-benchmark-item file-base-path command arguments comment-char extension
                    #:pre-benchmark-func (lambda () (shell-command "touch" '() ".flowconfig"))
                    #:post-benchmark-func (lambda () (shell-command "npx" '("flow" "stop") filename-to-read))
                    #:post-benchmark-func-dir file-base-path)
```

`comment-char` is the character used for comments in the host language of the type checker. `extension` is the file extension of the generated temporary files (their names are the hash values of their content). `file-base-path` is the path to the directory containing the test cases relative to the directory for the type checker. `arguments` is a list: its first element is the path to the file to be checked, and the rest are the command line arguments to be passed to the program indicated by `command`; it can also have a function as its second element, which will take the path to the file to be checked as its argument and return the list of arguments. `command` is the command to run the type checker.

The function `run-benchmark-item` takes several positional arguments and several keyword arguments. The positional arguments are the values mentioned above. The keyword arguments are optional and have the following meanings:

`pre-benchmark-func` is a function to be called before running the benchmark item with the value of `pre-benchmark-func-dir` as its working directory. `pre-benchmark-func-dir` is the directory where the pre-benchmark function should be called, which defaults to the system temporary directory.
`post-benchmark-func` and `post-benchmark-func-dir`are similar to `pre-benchmark-func` and `pre-benchmark-func-dir`, but they are called after running the benchmark item.

#### Fill in the `main.rkt` File

Most of the above mentioned values are also used in the `main.rkt` file. You should fill in the `main.rkt` file with the information about the new type checker. You should add them to the list value `typecheckers-parameter-alist` in the `main.rkt` file accordingly.

#### Add setup instructions to `SETUP.md`

The `SETUP.md` file contains the setup instructions and relevant version information for the type checkers, their host languages and dependencies.You should add the setup instructions for the new type checker to the `SETUP.md` file.

#### Create a Pull Request

Finally, when the test cases for the new type checker are ready, create a pull request with the new type checker. We will review the pull request and merge it if everything is in order.
