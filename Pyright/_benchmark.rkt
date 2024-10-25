#lang racket

(require "../lib.rkt")

(define comment-char #\#)
(define extension ".py")

(define file-base-path (build-path (current-directory)))
(define filename-to-read (build-path "main.py"))
(define arguments `(,filename-to-read ,(lambda (input-file) (list "-c" (string-append-immutable "source .venv/bin/activate; pyright " (path->string input-file))))))
(define command "bash")

(run-benchmark-item file-base-path command arguments comment-char extension)
