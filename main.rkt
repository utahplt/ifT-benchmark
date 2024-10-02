#lang racket

(require file/sha1)
(require gtp-util)

(define comment-char #\;)

(define file-base-path (build-path "TypedRacket"))
(define filename-to-read (build-path "main.rkt"))
(define command-to-run "racket")

(define (with-current-directory dir thunk)
  (parameterize ([current-directory (build-path dir)])
    (thunk)))

(define (with-temp-file content thunk)
  (let* ([temp-file-name (bytes->hex-string (sha1-bytes (string->bytes/utf-8 content)))]
         [temp-file-path (build-path (find-system-path 'temp-dir) temp-file-name)])
    (with-output-to-file temp-file-path
      (lambda ()
        (display content))
      #:exists 'truncate)
    (apply thunk (list temp-file-path))))

(define (read-file-into-lines filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ([lines '()])
        (let ([line (read-line)])
          (if (eof-object? line)
              (reverse lines)
              (loop (cons line lines))))))))

(define (split-header lines)
  (let ([header-body-split (string-append-immutable (make-string 3 comment-char) " Code:")])
    (let loop ([header '()] [lines lines])
      (if (or (null? lines) (string-prefix? (car lines) header-body-split))
          (values (reverse header) lines)
          (loop (cons (car lines) header) (cdr lines))))))

(define (split-body lines)
  (let ([body-footer-split (string-append-immutable (make-string 3 comment-char) " End")])
    (let loop ([body '()] [lines lines])
      (if (or (null? lines) (string-prefix? (car lines) body-footer-split))
          (values (reverse body) lines)
          (loop (cons (car lines) body) (cdr lines))))))

(define (split-file lines)
  (let-values ([(header-lines body-lines) (split-header lines)])
    (let-values ([(body-lines footer-lines) (split-body (cdr body-lines))])
      (values header-lines body-lines footer-lines))))

(define (split-test-cases body-lines)
  (let ([test-case-start (string-append-immutable (make-string 2 comment-char) " Example")])
    (let loop ([test-cases '()] [test-case '()] [lines body-lines] [prev-should-not-fail #t])
      (if (null? lines)
          (reverse (cons (cons (reverse test-case) prev-should-not-fail) test-cases))
          (if (string-prefix? (car lines) test-case-start)
              (loop
               (if (not (null? test-case))
                   (cons (cons (reverse test-case) prev-should-not-fail) test-cases)
                   test-cases)
               (list (car lines))
               (cdr lines)
               (not (string-contains? (car lines) "fail")))
              (loop test-cases (cons (car lines) test-case) (cdr lines) prev-should-not-fail))))))

(define (join-lines lines)
  (string-join lines "\n"))

;; find-exe : path-string? -> path-string?
(define (find-exe pre-exe)
  (define fep (find-executable-path pre-exe))
  (if (path? fep)
      fep
      (raise-user-error 'shell-command "cannot find executable '~a', please install and try again" pre-exe)))

(define (shell-command pre-exe pre-cmd)
  (define exe (find-exe pre-exe))
  (define cmd* (map path-string->string (if (path-string? pre-cmd) (list pre-cmd) pre-cmd)))
  (parameterize ([current-output-port (open-output-nowhere)]
                 [current-error-port (open-output-nowhere)])
    (apply system* exe cmd*)))

(define (run-test-case test-case header-lines)
  (let ([input (join-lines (append header-lines (car test-case)))]
        [should-not-fail (cdr test-case)])
    (eq? should-not-fail
         (with-temp-file input
           (lambda (input-file)
             (shell-command command-to-run input-file))))))

(define (run-test-cases test-cases header-lines)
  (map (lambda (test-case)
         (run-test-case test-case header-lines))
       test-cases))

(with-current-directory file-base-path
  (lambda ()
    (let ([lines (read-file-into-lines filename-to-read)])
      (let-values ([(header-lines body-lines footer-lines) (split-file lines)])
        (let ([test-cases (split-test-cases body-lines)])
          (run-test-cases test-cases header-lines))))))
