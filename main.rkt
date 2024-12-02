#lang racket

(require racket/cmdline)
(require "lib.rkt")

(define benchmark-output-format (make-parameter 'plain))

(define typechecker-parameters-alist
  `((typedracket (comment-char #\;)
                 (extension ".rkt")
                 (file-base-path ,(build-path (current-directory) "TypedRacket"))
                 (arguments ,(list (build-path "main.rkt")))
                 (command "racket"))
    (typescript (comment-char #\/)
                (extension ".ts")
                (file-base-path ,(build-path (current-directory) "TypeScript"))
                (arguments ,(list (build-path "main.ts") "tsc" "--noEmit" "--target" "es2023"))
                (command "npx"))
    (flow (comment-char #\/)
          (extension ".js")
          (file-base-path ,(build-path (current-directory) "Flow"))
          (arguments ,(list (build-path "src/index.js") "flow" "focus-check"))
          (command "npx")
          (pre-benchmark-func ,(lambda () (shell-command "touch" '() ".flowconfig")))
          (post-benchmark-func ,(lambda () (shell-command "npx" '("flow" "stop") (build-path "src/index.js"))))
          (post-benchmark-func-dir ,(build-path (current-directory) "Flow")))
    (mypy (comment-char #\#)
          (extension ".py")
          (file-base-path ,(build-path (current-directory) "mypy"))
          (arguments ,`(,(build-path "main.py")
                        ,(lambda (input-file)
                           (list "-c"
                                 (string-append-immutable
                                  "source .venv/bin/activate; mypy "
                                  (path->string input-file))))))
          (command "bash"))
    (pyright (comment-char #\#)
             (extension ".py")
             (file-base-path ,(build-path (current-directory) "Pyright"))
             (arguments ,(list (build-path "main.py") "pyright"))
             (command "npx"))))

(define (print-benchmark-row-markdown type-checker benchmark-result)
  (display (format "| ~a " type-checker))
  (for-each (lambda (test)
              (let ([positive-passed (cadr test)]
                    [negative-passed (caddr test)])
                (display (format "| ~a " (if (and positive-passed negative-passed) "V" "X")))))
            benchmark-result)
  (display "|\n"))

(define (print-benchmark-row-latex program-name benchmark-result)
  (display (format "~a & " program-name))
  (for-each (lambda (test)
              (let ([test-name (car test)]
                    [positive-passed (cadr test)]
                    [negative-passed (caddr test)])
                (display (format "~a & " (if (and positive-passed negative-passed) "V" "X")))))
            benchmark-result)
  (display "\\\\ \n"))

(define (print-benchmark-row type-checker benchmark-result)
  (case (benchmark-output-format)
    [(markdown) (print-benchmark-row-markdown type-checker benchmark-result)]
    [(tex) (print-benchmark-row-latex type-checker benchmark-result)]
    [(plain) (display (format "~a: ~a\n" type-checker benchmark-result))]))

(define (run-benchmark type-checker)
  (when (benchmark-verbose)
    (displayln (format "Running benchmark for ~a" type-checker)))
  (define typechecker-parameters (cdr (assoc type-checker typechecker-parameters-alist)))
  (define benchmark-result
    (if (not typechecker-parameters)
        (error (format "Type checker ~a not found." type-checker))
        (let ([comment-char (cadr (assoc 'comment-char typechecker-parameters))]
              [extension (cadr (assoc 'extension typechecker-parameters))]
              [file-base-path (cadr (assoc 'file-base-path typechecker-parameters))]
              [arguments (cadr (assoc 'arguments typechecker-parameters))]
              [command (cadr (assoc 'command typechecker-parameters))]
              [pre-benchmark-func (cadr (or (assoc 'pre-benchmark-func typechecker-parameters) '(#f #f) ))]
              [post-benchmark-func (cadr (or (assoc 'post-benchmark-func typechecker-parameters) '(#f #f)))]
              [pre-benchmark-func-dir (cadr (or (assoc 'pre-benchmark-func-dir typechecker-parameters) `(#f ,(find-system-path 'temp-dir))))]
              [post-benchmark-func-dir (cadr (or (assoc 'post-benchmark-func-dir typechecker-parameters) `(#f ,(find-system-path 'temp-dir))))])
          (run-benchmark-item file-base-path command arguments comment-char extension
                              #:pre-benchmark-func pre-benchmark-func
                              #:post-benchmark-func post-benchmark-func
                              #:pre-benchmark-func-dir pre-benchmark-func-dir
                              #:post-benchmark-func-dir post-benchmark-func-dir))))
  (print-benchmark-row type-checker benchmark-result))

(define (run-all-benchmarks)
  (for-each run-benchmark (map car typechecker-parameters-alist)))

(define type-checker
  (command-line
   #:program "main.rkt"
   #:once-each
   [("-v" "--verbose") "Print the output of the benchmarks to the console"
                       (benchmark-verbose #t)]
   [("-f" "--format") output-format "Print the output of the benchmarks in the specified format. Options: plain, markdown, tex. Default: plain."
                      (benchmark-output-format (string->symbol output-format))]
   ;; #:once-any
   ;; [("-m" "--markdown") "Print the output of the benchmarks in markdown format"
   ;;                      (benchmark-output-format 'markdown)]
   ;; [("-t" "--tex") "Print the output of the benchmarks in LaTeX format"
   ;;                 (benchmark-output-format 'tex)]
   #:args ([type-checker null])
   type-checker))

(if (null? type-checker)
    (run-all-benchmarks)
    (run-benchmark (string->symbol (string-downcase type-checker))))
