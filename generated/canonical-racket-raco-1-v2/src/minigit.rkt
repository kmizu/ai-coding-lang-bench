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
  (define blob-path (build-path (objects-dir) hash))
  (unless (file-exists? blob-path)
    (with-output-to-file blob-path
      (lambda () (write-bytes data))
      #:exists 'replace))
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
  (define sorted-files (sort index string<?))
  (define file-entries
    (map (lambda (f)
           (string-append f " " (minihash (file->bytes f))))
         sorted-files))
  (define commit-content
    (string-append
     "parent: "    parent    "\n"
     "timestamp: " timestamp "\n"
     "message: "   message   "\n"
     "files:\n"
     (string-join file-entries "\n")
     "\n"))
  (define commit-hash (minihash (string->bytes/utf-8 commit-content)))
  (with-output-to-file (build-path (commits-dir) commit-hash)
    (lambda () (display commit-content))
    #:exists 'replace)
  (with-output-to-file (head-file)
    (lambda () (display commit-hash))
    #:exists 'replace)
  (with-output-to-file (index-file)
    (lambda () (display ""))
    #:exists 'replace)
  (displayln (string-append "Committed " commit-hash))
  (exit 0))

;;; Parse a commit file fully.
;;; Returns (values parent timestamp message files-alist)
;;; where files-alist is a list of (filename . blobhash) pairs.
(define (parse-commit-full hash)
  (define path (build-path (commits-dir) hash))
  (define lines (file->lines path))
  (define parent-line    (list-ref lines 0))
  (define timestamp-line (list-ref lines 1))
  (define message-line   (list-ref lines 2))
  ;; line 3 is "files:", lines 4+ are file entries
  (define file-lines (if (> (length lines) 4) (drop lines 4) '()))
  (define files
    (filter-map (lambda (l)
                  (if (string=? l "") #f
                      (let ([parts (string-split l " ")])
                        (if (>= (length parts) 2)
                            (cons (car parts) (cadr parts))
                            #f))))
                file-lines))
  (values (substring parent-line    8)   ; "parent: "    = 8 chars
          (substring timestamp-line 11)  ; "timestamp: " = 11 chars
          (substring message-line   9)   ; "message: "   = 9 chars
          files))

;;; log
(define (cmd-log)
  (define head (read-head))
  (if (not head)
      (displayln "No commits")
      (let loop ([hash head])
        (define-values (parent timestamp message _files) (parse-commit-full hash))
        (displayln (string-append "commit " hash))
        (displayln (string-append "Date: " timestamp))
        (displayln (string-append "Message: " message))
        (newline)
        (unless (string=? parent "NONE")
          (loop parent)))))

;;; status
(define (cmd-status)
  (define index (read-index))
  (displayln "Staged files:")
  (if (null? index)
      (displayln "(none)")
      (for-each displayln index))
  (exit 0))

;;; diff <commit1> <commit2>
(define (cmd-diff hash1 hash2)
  (define path1 (build-path (commits-dir) hash1))
  (define path2 (build-path (commits-dir) hash2))
  (unless (file-exists? path1)
    (displayln "Invalid commit")
    (exit 1))
  (unless (file-exists? path2)
    (displayln "Invalid commit")
    (exit 1))
  (define-values (_p1 _t1 _m1 files1) (parse-commit-full hash1))
  (define-values (_p2 _t2 _m2 files2) (parse-commit-full hash2))
  (define ht1 (make-hash))
  (for-each (lambda (pair) (hash-set! ht1 (car pair) (cdr pair))) files1)
  (define ht2 (make-hash))
  (for-each (lambda (pair) (hash-set! ht2 (car pair) (cdr pair))) files2)
  (define all-files
    (sort (remove-duplicates (append (map car files1) (map car files2))) string<?))
  (for-each (lambda (f)
              (define in1 (hash-ref ht1 f #f))
              (define in2 (hash-ref ht2 f #f))
              (cond
                [(and (not in1) in2)
                 (displayln (string-append "Added: " f))]
                [(and in1 (not in2))
                 (displayln (string-append "Removed: " f))]
                [(and in1 in2 (not (string=? in1 in2)))
                 (displayln (string-append "Modified: " f))]))
            all-files)
  (exit 0))

;;; checkout <commit_hash>
(define (cmd-checkout hash)
  (define path (build-path (commits-dir) hash))
  (unless (file-exists? path)
    (displayln "Invalid commit")
    (exit 1))
  (define-values (_p _t _m files) (parse-commit-full hash))
  (for-each (lambda (pair)
              (define filename (car pair))
              (define blobhash (cdr pair))
              (define blob-path (build-path (objects-dir) blobhash))
              (define data (file->bytes blob-path))
              (with-output-to-file filename
                (lambda () (write-bytes data))
                #:exists 'replace))
            files)
  (with-output-to-file (head-file)
    (lambda () (display hash))
    #:exists 'replace)
  (with-output-to-file (index-file)
    (lambda () (display ""))
    #:exists 'replace)
  (displayln (string-append "Checked out " hash))
  (exit 0))

;;; reset <commit_hash>
(define (cmd-reset hash)
  (define path (build-path (commits-dir) hash))
  (unless (file-exists? path)
    (displayln "Invalid commit")
    (exit 1))
  (with-output-to-file (head-file)
    (lambda () (display hash))
    #:exists 'replace)
  (with-output-to-file (index-file)
    (lambda () (display ""))
    #:exists 'replace)
  (displayln (string-append "Reset to " hash))
  (exit 0))

;;; rm <file>
(define (cmd-rm filename)
  (define index (read-index))
  (unless (member filename index)
    (displayln "File not in index")
    (exit 1))
  (define new-index (filter (lambda (f) (not (string=? f filename))) index))
  (with-output-to-file (index-file)
    (lambda ()
      (for-each displayln new-index))
    #:exists 'replace)
  (exit 0))

;;; show <commit_hash>
(define (cmd-show hash)
  (define path (build-path (commits-dir) hash))
  (unless (file-exists? path)
    (displayln "Invalid commit")
    (exit 1))
  (define-values (_p timestamp message files) (parse-commit-full hash))
  (displayln (string-append "commit " hash))
  (displayln (string-append "Date: " timestamp))
  (displayln (string-append "Message: " message))
  (displayln "Files:")
  (for-each (lambda (pair)
              (displayln (string-append "  " (car pair) " " (cdr pair))))
            (sort files (lambda (a b) (string<? (car a) (car b)))))
  (exit 0))

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
    [(string=? cmd "status")
     (cmd-status)]
    [(string=? cmd "diff")
     (when (< (vector-length args) 3)
       (displayln "Usage: minigit diff <commit1> <commit2>" (current-error-port))
       (exit 1))
     (cmd-diff (vector-ref args 1) (vector-ref args 2))]
    [(string=? cmd "checkout")
     (when (< (vector-length args) 2)
       (displayln "Usage: minigit checkout <commit_hash>" (current-error-port))
       (exit 1))
     (cmd-checkout (vector-ref args 1))]
    [(string=? cmd "reset")
     (when (< (vector-length args) 2)
       (displayln "Usage: minigit reset <commit_hash>" (current-error-port))
       (exit 1))
     (cmd-reset (vector-ref args 1))]
    [(string=? cmd "rm")
     (when (< (vector-length args) 2)
       (displayln "Usage: minigit rm <file>" (current-error-port))
       (exit 1))
     (cmd-rm (vector-ref args 1))]
    [(string=? cmd "show")
     (when (< (vector-length args) 2)
       (displayln "Usage: minigit show <commit_hash>" (current-error-port))
       (exit 1))
     (cmd-show (vector-ref args 1))]
    [else
     (displayln (string-append "Unknown command: " cmd) (current-error-port))
     (exit 1)]))

(main)
