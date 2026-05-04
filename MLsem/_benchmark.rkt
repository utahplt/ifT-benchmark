#lang racket

(require racket/cmdline)
(require racket/runtime-path)
(require "../lib.rkt")

(define current-typechecker-symbol 'mlsem)
(define current-typechecker-name "MLsem")
(define-runtime-path mlsem-dir ".")

(define typechecker-parameters
  `((name ,current-typechecker-name)
    (comment-char #\()
    (comment-prefix "(*")
    (extension ".ml")
    (file-base-path ,mlsem-dir)
    (examples-file-base-path ,mlsem-dir)
    (arguments ,(list "main.ml" "check-mlsem.rkt"))
    (examples-arguments ,(list "examples.ml" "check-mlsem.rkt"))
    (command "racket")))

(command-line
 #:program "_benchmark.rkt"
 #:once-each
 [("-v" "--verbose") "Print the output of the benchmarks to the console"
                     (benchmark-verbose #t)]
 [("-f" "--format") output-format "Print the output of the benchmarks in the specified format. Options: plain, markdown, tex. Default: plain."
                    (benchmark-output-format (string->symbol output-format))]
 [("-t" "--transpose") "Transpose the output of the benchmarks"
                       (benchmark-output-transposed #t)]
 [("-e" "--examples") "Run the advanced examples"
                      (benchmark-run-examples #t)]
 #:args ()
 (void))

(define benchmark-data (execute-benchmark-for-one-typechecker typechecker-parameters))
(define benchmark-result-for-printing (list (cons current-typechecker-name benchmark-data)))

(define actual-test-names (map car benchmark-data))
(define header-row (cons "Benchmark" actual-test-names))

(print-benchmark benchmark-result-for-printing
                 (benchmark-output-format)
                 header-row)
