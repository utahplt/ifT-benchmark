#lang racket

(require "../lib.rkt")

(define comment-char #\/)
(define extension ".ts")

(define file-base-path (build-path (current-directory)))
(define filename-to-read (build-path "main.ts"))
(define arguments `(,filename-to-read "tsc" "--noEmit" "--target" "es2023"))
(define command "npx")

(run-benchmark-item file-base-path command arguments comment-char extension)
