#lang racket

(require "../lib.rkt")

(define comment-char #\#)
(define extension ".py")

(define file-base-path (build-path (current-directory)))
(define filename-to-read (build-path "main.py"))
(define arguments `(,filename-to-read "pyright"))
(define command "npx")
(run-benchmark-item file-base-path command arguments comment-char extension)
