#lang racket

(require racket/cmdline)
(require "../lib.rkt")

(define current-typechecker-symbol 'sorbet)
(define current-typechecker-name "Sorbet")

(define typechecker-parameters
  `((name ,current-typechecker-name)
    (comment-char #\;)
    (extension ".rb")
    (file-base-path ,(current-directory))
    (examples-file-base-path ,(current-directory))
    (arguments ,(list "src/typed_clojure/main.clj" "lein run -m typed-clojure.main"))
    (examples-arguments ,(list "src/typed_clojure/examples.clj" "lein run -m typed-clojure.examples"))
    (command "npx")))

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
