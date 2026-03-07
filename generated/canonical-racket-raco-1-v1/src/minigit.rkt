#lang racket

;;; MiniHash: FNV-1a variant, 64-bit unsigned
(define MODULUS (expt 2 64))

(define (minihash data)
  (let loop ([h 1469598103934665603]
             [i 0])
    (if (= i (bytes-length data))
        (let ([hex (number->string h 16)])
          (string-append (make-string (max 0 (- 16 (string-length hex))) #\0) hex))
        (let* ([b  (bytes-ref data i)]
               [h1 (bitwise-xor h b)]
               [h2 (modulo (* h1 1099511628211) MODULUS)])
          (loop h2 (+ i 1))))))

;;; Path helpers (all relative to cwd)
(define (minigit-dir)   (build-path (current-directory) ".minigit"))
(define (objects-dir)   (build-path (minigit-dir) "objects"))
(define (commits-dir)   (build-path (minigit-dir) "commits"))
(define (index-file)    (build-path (minigit-dir) "index"))
(define (head-file)     (build-path (minigit-dir) "HEAD"))

;;; Read HEAD (returns hash string or #f)
(define (read-head)
  (define f (head-file))
  (if (file-exists? f)
      (let ([s (string-trim (file->string f))])
        (if (string=? s "") #f s))
      #f))

;;; Read index (list of non-empty filenames)
(define (read-index)
  (define f (index-file))
  (if (file-exists? f)
      (filter (lambda (l) (not (string=? l "")))
              (file->lines f))
      '()))

;;; init
(define (cmd-init)
  (cond
    [(directory-exists? (minigit-dir))
     (displayln "Repository already initialized")]
    [else
     (make-directory* (objects-dir))
     (make-directory* (commits-dir))
     (with-output-to-file (index-file) (lambda () (display "")) #:exists 'replace)
     (with-output-to-file (head-file)  (lambda () (display "")) #:exists 'replace)])
  (exit 0))

;;; add <file>
(define (cmd-add filename)
  (unless (file-exists? filename)
    (displayln "File not found")
    (exit 1))
  (define data (file->bytes filename))
  (define hash (minihash data))
  ;; Store blob (idempotent)
  (define blob-path (build-path (objects-dir) hash))
  (unless (file-exists? blob-path)
    (with-output-to-file blob-path
      (lambda () (write-bytes data))
      #:exists 'replace))
  ;; Append to index if not already listed
  (define current-index (read-index))
  (unless (member filename current-index)
    (with-output-to-file (index-file)
      (lambda () (displayln filename))
      #:exists 'append))
  (exit 0))

;;; commit -m <message>
(define (cmd-commit message)
  (define index (read-index))
  (when (null? index)
    (displayln "Nothing to commit")
    (exit 1))
  (define parent    (or (read-head) "NONE"))
  (define timestamp (number->string (inexact->exact (floor (/ (current-inexact-milliseconds) 1000)))))
  ;; Build sorted file entries: "filename blobhash"
  (define sorted-files (sort index string<?))
  (define file-entries
    (map (lambda (f)
           (string-append f " " (minihash (file->bytes f))))
         sorted-files))
  ;; Assemble commit content (exact format from spec)
  (define commit-content
    (string-append
     "parent: "    parent    "\n"
     "timestamp: " timestamp "\n"
     "message: "   message   "\n"
     "files:\n"
     (string-join file-entries "\n")
     "\n"))
  (define commit-hash (minihash (string->bytes/utf-8 commit-content)))
  ;; Write commit file
  (with-output-to-file (build-path (commits-dir) commit-hash)
    (lambda () (display commit-content))
    #:exists 'replace)
  ;; Update HEAD
  (with-output-to-file (head-file)
    (lambda () (display commit-hash))
    #:exists 'replace)
  ;; Clear index
  (with-output-to-file (index-file)
    (lambda () (display ""))
    #:exists 'replace)
  (displayln (string-append "Committed " commit-hash))
  (exit 0))

;;; Parse a commit file; returns (values parent timestamp message)
(define (parse-commit-file hash)
  (define path (build-path (commits-dir) hash))
  (define port (open-input-file path))
  (define parent-line    (read-line port 'any))
  (define timestamp-line (read-line port 'any))
  (define message-line   (read-line port 'any))
  (close-input-port port)
  (values (substring parent-line    8)   ; "parent: " = 8 chars
          (substring timestamp-line 11)  ; "timestamp: " = 11 chars
          (substring message-line   9))) ; "message: " = 9 chars

;;; log
(define (cmd-log)
  (define head (read-head))
  (if (not head)
      (displayln "No commits")
      (let loop ([hash head])
        (define-values (parent timestamp message) (parse-commit-file hash))
        (displayln (string-append "commit " hash))
        (displayln (string-append "Date: " timestamp))
        (displayln (string-append "Message: " message))
        (newline)
        (unless (string=? parent "NONE")
          (loop parent)))))

;;; Main dispatcher
(define (main)
  (define args (current-command-line-arguments))
  (when (= (vector-length args) 0)
    (displayln "Usage: minigit <command> [args]" (current-error-port))
    (exit 1))
  (define cmd (vector-ref args 0))
  (cond
    [(string=? cmd "init")
     (cmd-init)]
    [(string=? cmd "add")
     (when (< (vector-length args) 2)
       (displayln "Usage: minigit add <file>" (current-error-port))
       (exit 1))
     (cmd-add (vector-ref args 1))]
    [(string=? cmd "commit")
     (when (or (< (vector-length args) 3)
               (not (string=? (vector-ref args 1) "-m")))
       (displayln "Usage: minigit commit -m <message>" (current-error-port))
       (exit 1))
     (cmd-commit (vector-ref args 2))]
    [(string=? cmd "log")
     (cmd-log)]
    [else
     (displayln (string-append "Unknown command: " cmd) (current-error-port))
     (exit 1)]))

(main)
