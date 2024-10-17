#lang racket

(require "../lib.rkt")

(define comment-char #\;)
(define extension ".rkt")

(define file-base-path (build-path (current-directory)))
(define filename-to-read (build-path "main.rkt"))
(define arguments (list filename-to-read))
(define command "racket")

(run-benchmark-item file-base-path command arguments comment-char extension)
