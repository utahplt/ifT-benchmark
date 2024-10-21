#lang racket

(require "../lib.rkt")

(define comment-char #\/)
(define extension ".js")

(define file-base-path (build-path (current-directory)))
(define filename-to-read (build-path "src/index.js"))
(define arguments `(,filename-to-read "flow" "focus-check"))
(define command "npx")

(run-benchmark-item file-base-path command arguments comment-char extension
                    #:pre-benchmark-func (lambda () (shell-command "touch" '() ".flowconfig"))
                    #:post-benchmark-func (lambda () (shell-command "npx" '("flow" "stop") filename-to-read))
                    #:post-benchmark-func-dir file-base-path)
