#lang racket

(require racket/cmdline
         racket/port
         racket/string)

(define input-file
  (command-line
   #:program "check-mlsem.rkt"
   #:args (input-file)
   input-file))

(define mlsem-path
  (or (find-executable-path "mlsem")
      (begin
        (displayln "cannot find executable 'mlsem', please install and try again"
                   (current-error-port))
        (exit 1))))

(define-values (process stdout stdin stderr)
  (subprocess #f #f #f mlsem-path "-notime" input-file))

(close-output-port stdin)

(define output (port->string stdout))
(define errors (port->string stderr))

(subprocess-wait process)
(define exit-code (subprocess-status process))

(define combined-output (string-append output errors))
(define error-markers
  '(" syntax error"
    "File \""
    "untypeable"
    "unbound"
    "ill-formed"
    "Invalid"
    "Error"))

(define mlsem-reported-error?
  (for/or ([marker (in-list error-markers)])
    (string-contains? combined-output marker)))

(exit (if (and (zero? exit-code) (not mlsem-reported-error?)) 0 1))
