#lang racket

(require racket/cmdline)
(require "lib.rkt")

(define benchmark-output-format (make-parameter 'plain))
(define benchmark-output-transposed (make-parameter #f)) ; one type checker per row by default, set to #t to have one type checker per column

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
    (luau (comment-char #\#)
          (extension ".luau")
          (file-base-path ,(build-path (current-directory) "luau"))
          (arguments ,(list (build-path "main.py") "luau-analyze"))
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

(define (process-benchmark-row type-checker benchmark-result-row)
  (append (list (symbol->string type-checker))
          (map (lambda (test)
                 (let ([positive-passed (cadr test)]
                       [negative-passed (caddr test)])
                   (cond
                     [(and positive-passed negative-passed) "O"]
                     [(or positive-passed negative-passed) "x"]
                     [else "X"])))
               benchmark-result-row)))

(define (print-row-markdown row)
  (display (format "| ~a " (car row)))
  (for-each (lambda (test-result)
              (display (format "| ~a " test-result)))
            (cdr row))
  (display "|\n"))

(define (print-row-latex row)
  (display (format "~a " (car row)))
  (for-each (lambda (test-result)
              (display (format "& ~a " test-result)))
            (cdr row))
  (display "\\\\\n"))

(define (print-row row [output-format 'plain])
  (case output-format
    [(markdown) (print-row-markdown row)]
    [(tex) (print-row-latex row)]
    [(plain) (display (format "~a\n" row))]))

(define (transpose l)
  (apply map list l))

(define (pad-columns rows)
  (define transposed-rows (transpose rows))
  (define column-widths (map (lambda (column) (apply max (map string-length column))) transposed-rows))
  (define padded-rows
    (map (lambda (row)
           (map (lambda (column width)
                  (format "~a~a" column (make-string (- width (string-length column)) #\space)))
                row column-widths))
         rows))
  padded-rows)

(define (print-benchmark benchmark-result-rows [output-format 'plain] [table-header null])
  (define transpose-function (if (benchmark-output-transposed) transpose identity))
  (define processed-benchmark-result-rows (map (lambda (row) (process-benchmark-row (car row) (cdr row))) benchmark-result-rows))
  (define printable-rows-pre (transpose (if (not (null? table-header))
                                            (cons table-header processed-benchmark-result-rows)
                                            processed-benchmark-result-rows)))
  (define printable-rows (pad-columns printable-rows-pre))
  (for-each (lambda (row) (print-row row output-format)) printable-rows))

(define (get-benchmark-result-row type-checker)
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
  (cons type-checker benchmark-result))

(define (run-benchmarks type-checker-list)
  (define benchmark-result-rows
    (map get-benchmark-result-row type-checker-list))
  (print-benchmark benchmark-result-rows (benchmark-output-format)
                   (cons "Benchmark" '("positive"
                                       "negative"
                                       "alias"
                                       "connectives"
                                       "nesting_body"
                                       "nesting_condition"
                                       "predicate_2way"
                                       "predicate_1way"
                                       "predicate_checked"
                                       "object_properties"
                                       "tuple_elements"
                                       "tuple_length"
                                       "merge_with_union"))))

(define type-checker
  (command-line
   #:program "main.rkt"
   #:once-each
   [("-v" "--verbose") "Print the output of the benchmarks to the console"
                       (benchmark-verbose #t)]
   [("-f" "--format") output-format "Print the output of the benchmarks in the specified format. Options: plain, markdown, tex. Default: plain."
                      (benchmark-output-format (string->symbol output-format))]
   [("-t" "--transpose") "Transpose the output of the benchmarks"
                         (benchmark-output-transposed #t)]
   ;; #:once-any
   ;; [("-m" "--markdown") "Print the output of the benchmarks in markdown format"
   ;;                      (benchmark-output-format 'markdown)]
   ;; [("-t" "--tex") "Print the output of the benchmarks in LaTeX format"
   ;;                 (benchmark-output-format 'tex)]
   #:args ([type-checker null])
   type-checker))

(if (null? type-checker)
    (run-benchmarks (map car typechecker-parameters-alist))
    (run-benchmarks (list (string->symbol (string-downcase type-checker)))))
