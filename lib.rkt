#lang racket

(provide run-benchmark-item)
(provide shell-command)
(provide benchmark-verbose)

(require file/sha1)
(require gtp-util)

(define benchmark-verbose (make-parameter #f))

(define (with-current-directory dir thunk)
  (parameterize ([current-directory (build-path dir)])
    (thunk)))

(define (with-temp-file content thunk extension)
  (let* ([temp-file-name (string-append-immutable (bytes->hex-string (sha1-bytes (string->bytes/utf-8 content))) extension)]
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

(define (split-header lines comment-char)
  (let ([header-body-split (string-append-immutable (make-string 3 comment-char) " Code:")])
    (let loop ([header '()] [lines lines])
      (if (or (null? lines) (string-prefix? (car lines) header-body-split))
          (values (reverse header) lines)
          (loop (cons (car lines) header) (cdr lines))))))

(define (split-body lines comment-char)
  (let ([body-footer-split (string-append-immutable (make-string 3 comment-char) " End")])
    (let loop ([body '()] [lines lines])
      (if (or (null? lines) (string-prefix? (car lines) body-footer-split))
          (values (reverse body) lines)
          (loop (cons (car lines) body) (cdr lines))))))

(define (split-file lines comment-char)
  (let-values ([(header-lines body-lines) (split-header lines comment-char)])
    (let-values ([(body-lines footer-lines) (split-body (cdr body-lines) comment-char)])
      (values header-lines body-lines footer-lines))))

(define (split-test-cases-pre body-lines comment-char)
  (let ([test-case-start (string-append-immutable (make-string 2 comment-char) " Example")])
    (let loop ([test-cases '()] [test-case '()] [lines body-lines])
      (if (null? lines)
          (reverse (cons (reverse test-case) test-cases))
          (if (string-prefix? (car lines) test-case-start)
              (loop
               (if (not (null? test-case))
                   (cons (reverse test-case) test-cases)
                   test-cases)
               (list (car lines))
               (cdr lines))
              (loop test-cases (cons (car lines) test-case) (cdr lines)))))))

(define (split-test-case test-case-pre comment-char)
  (let ([first-line (car test-case-pre)]
        [following-lines (cdr test-case-pre)])
    (define comment-start (make-string 2 comment-char))
    (define test-case-name
      (cadr (regexp-match
             (regexp
              (string-append-immutable
               comment-start
               " Example ([0-9a-zA-Z_]+)"))
             first-line)))
    (define (split-by-marker lst)
      (define (helper lst selector res-lists)
        (cond
          [(null? lst) (cons (reverse (car res-lists)) (reverse (cdr res-lists)))]
          [(regexp-match (regexp (string-append-immutable comment-start " success"))
                         (car lst))
           (helper (cdr lst) 'success res-lists)]
          [(regexp-match (regexp (string-append-immutable comment-start " failure"))
                         (car lst))
           (helper (cdr lst) 'failure res-lists)]
          [else (helper
                 (cdr lst) selector
                 (if (eq? selector 'success)
                     (cons (cons (car lst) (car res-lists))
                           (cdr res-lists))
                     (cons (car res-lists)
                           (cons (car lst) (cdr res-lists)))))]))
      (helper lst 'whatever (cons '() '())))
    `(,test-case-name ,@(split-by-marker following-lines))))

(define (split-test-cases body-lines comment-char)
  (let ([test-cases-pre (split-test-cases-pre body-lines comment-char)])
    (map (lambda (tcp) (split-test-case tcp comment-char)) test-cases-pre)))

(define (join-lines lines)
  (string-join lines "\n"))

;; find-exe : path-string? -> path-string?
(define (find-exe pre-exe)
  (define fep (find-executable-path pre-exe))
  (if (path? fep)
      fep
      (raise-user-error 'shell-command "cannot find executable '~a', please install and try again" pre-exe)))

(define (shell-command pre-exe pre-arguments pre-cmd)
  (define exe (find-exe pre-exe))
  (define cmd* (if (and (not (null? pre-arguments))
                        (procedure? (car pre-arguments)))
                   (apply (car pre-arguments) `(,pre-cmd))
                   (append
                    pre-arguments
                    (map path-string->string (if (path-string? pre-cmd) (list pre-cmd) pre-cmd)))))
  (parameterize ([current-output-port (open-output-nowhere)]
                 [current-error-port (open-output-nowhere)])
    (apply system* exe cmd*)))

(define (run-test-case test-case header-lines footer-lines command arguments extension)
  (let ([test-case-name (car test-case)]
        [success-input (join-lines (append header-lines (cadr test-case) footer-lines))]
        [failure-input (join-lines (append header-lines (cddr test-case) footer-lines))])
    (when (benchmark-verbose)
      (displayln (format "Running test case ~a ..." test-case-name)))
    (define succeeded (eq? #t
                           (with-temp-file success-input
                             (lambda (input-file)
                               (shell-command command arguments input-file))
                             extension)))
    (define failed (eq? #f
                        (with-temp-file failure-input
                          (lambda (input-file)
                            (shell-command command arguments input-file))
                          extension)))
    (list test-case-name
          succeeded
          failed)))

(define (run-test-cases test-cases header-lines footer-lines command arguments extension)
  (map (lambda (test-case)
         (run-test-case test-case header-lines footer-lines command arguments extension))
       test-cases))

(define (run-benchmark-item file-base-path command arguments comment-char extension
                            #:pre-benchmark-func [pre-func #f] #:pre-benchmark-func-dir [pre-dir (find-system-path 'temp-dir)]
                            #:post-benchmark-func [post-func #f] #:post-benchmark-func-dir [post-dir (find-system-path 'temp-dir)])
  (when pre-func
    (with-current-directory pre-dir
      (lambda () (apply pre-func null))))
  (define result
    (with-current-directory file-base-path
      (lambda ()
        (let* ([file-name-to-read (car arguments)]
               [lines (read-file-into-lines file-name-to-read)])
          (let-values ([(header-lines body-lines footer-lines) (split-file lines comment-char)])
            (let ([test-cases (split-test-cases body-lines comment-char)])
              (run-test-cases test-cases header-lines footer-lines command (cdr arguments) extension)))))))
  (when post-func
    (with-current-directory post-dir
      (lambda () (apply post-func null))))
  result)
