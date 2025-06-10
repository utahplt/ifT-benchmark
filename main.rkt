#lang racket

(require racket/cmdline)
(require "lib.rkt")

(define typechecker-parameters-alist
  `((typedracket (name "TypedRacket")
                 (comment-char #\;)
                 (extension ".rkt")
                 (file-base-path ,(build-path (current-directory) "TypedRacket"))
                 (examples-file-base-path ,(build-path (current-directory) "TypedRacket"))
                 (arguments ,(list "main.rkt"))
                 (examples-arguments ,(list "examples.rkt"))
                 (command "racket"))
    (typescript (name "TypeScript")
                (comment-char #\/)
                (extension ".ts")
                (file-base-path ,(build-path (current-directory) "TypeScript"))
                (examples-file-base-path ,(build-path (current-directory) "TypeScript"))
                (arguments ,(list "main.ts" "tsc" "--noEmit" "--target" "es2023"))
                (examples-arguments ,(list "examples.ts" "tsc" "--noEmit" "--target" "es2023"))
                (command "npx"))
    (flow (name "Flow")
          (comment-char #\/)
          (extension ".js")
          (file-base-path ,(build-path (current-directory) "Flow"))
          (examples-file-base-path ,(build-path (current-directory) "Flow"))
          (arguments ,(list "src/index.js" "flow" "focus-check"))
          (examples-arguments ,(list "src/examples.js" "flow" "focus-check"))
          (command "npx")
          (pre-benchmark-func ,(lambda () (shell-command "touch" '() ".flowconfig")))
          (post-benchmark-func ,(lambda () (shell-command "npx" '("flow" "stop") "src/index.js")))
          (post-benchmark-func-dir ,(build-path (current-directory) "Flow")))
    (mypy (name "mypy")
          (comment-char #\#)
          (extension ".py")
          (file-base-path ,(build-path (current-directory) "mypy"))
          (examples-file-base-path ,(build-path (current-directory) "mypy"))
          (arguments ,`(,"main.py"
                        ,(lambda (input-file)
                           (list "-c"
                                 (string-append-immutable
                                  "source .venv/bin/activate; mypy "
                                  (path->string input-file))))))
          (examples-arguments ,`(,"examples.py"
                                 ,(lambda (input-file)
                                    (list "-c"
                                          (string-append-immutable
                                           "source .venv/bin/activate; mypy "
                                           (path->string input-file))))))
          (command "bash"))
    (pyright (name "Pyright")
             (comment-char #\#)
             (extension ".py")
             (file-base-path ,(build-path (current-directory) "Pyright"))
             (examples-file-base-path ,(build-path (current-directory) "Pyright"))
             (arguments ,(list "main.py" "pyright"))
             (examples-arguments ,(list "examples.py" "pyright"))
             (command "npx"))
    (sorbet (name "Sorbet")
            (comment-char #\#)
            (extension ".rb")
            (file-base-path ,(build-path (current-directory) "Sorbet"))
            (examples-file-base-path ,(build-path (current-directory) "Sorbet"))
            (arguments ,(list "main.rb" "tc"))
            (examples-arguments ,(list "examples.rb" "tc"))
            (command "srb"))))

(define (get-benchmark-result-row type-checker-symbol)
  (when (benchmark-verbose)
    (displayln (format "Running benchmark for ~a" type-checker-symbol)))
  (define typechecker-specific-params (cdr (assoc type-checker-symbol typechecker-parameters-alist)))
  (if (not typechecker-specific-params)
      (error (format "Type checker ~a not found." type-checker-symbol))
      (cons type-checker-symbol (execute-benchmark-for-one-typechecker typechecker-specific-params))))

(define (run-benchmarks type-checker-list)
  (define benchmark-result-rows
    (map get-benchmark-result-row type-checker-list))

  (define results-for-printing
    (map (lambda (row)
           (cons (symbol->string (car row))
                 (cdr row)))
         benchmark-result-rows))

  (define header-row
    (cons "Benchmark"
          (if (benchmark-run-examples)
              examples-benchmark-items
              core-benchmark-items)))

  (print-benchmark results-for-printing (benchmark-output-format) header-row))

(define type-checker-arg
  (command-line
   #:program "main.rkt"
   #:once-each
   [("-v" "--verbose") "Print the output of the benchmarks to the console"
                       (benchmark-verbose #t)]
   [("-f" "--format") output-format "Print the output of the benchmarks in the specified format. Options: plain, markdown, tex. Default: plain."
                      (benchmark-output-format (string->symbol output-format))]
   [("-t" "--transpose") "Transpose the output of the benchmarks"
                         (benchmark-output-transposed #t)]
   [("-e" "--examples") "Run the advanced examples"
                        (benchmark-run-examples #t)]
   #:args ([type-checker-name null])
   type-checker-name))

(if (null? type-checker-arg)
    (run-benchmarks (map car typechecker-parameters-alist))
    (run-benchmarks (list (string->symbol (string-downcase type-checker-arg)))))
