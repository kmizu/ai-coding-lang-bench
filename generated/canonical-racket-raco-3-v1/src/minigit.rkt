#lang racket

;; MiniHash: FNV-1a variant, 64-bit
(define FNV-OFFSET 1469598103934665603)
(define FNV-PRIME 1099511628211)
(define MOD64 (expt 2 64))

(define (mini-hash bytes)
  (let loop ([i 0] [h FNV-OFFSET])
    (if (= i (bytes-length bytes))
        (let* ([val (bitwise-and h (- MOD64 1))]
               [hex (number->string val 16)]
               [padded (string-append (make-string (max 0 (- 16 (string-length hex))) #\0) hex)])
          padded)
        (let* ([b (bytes-ref bytes i)]
               [h2 (bitwise-xor h b)]
               [h3 (remainder (* h2 FNV-PRIME) MOD64)])
          (loop (+ i 1) h3)))))

;; Paths
(define (minigit-dir) ".minigit")
(define (objects-dir) (build-path (minigit-dir) "objects"))
(define (commits-dir) (build-path (minigit-dir) "commits"))
(define (index-file) (build-path (minigit-dir) "index"))
(define (head-file) (build-path (minigit-dir) "HEAD"))

;; Read HEAD (returns empty string if no commits)
(define (read-head)
  (if (file-exists? (head-file))
      (string-trim (file->string (head-file)))
      ""))

;; Write HEAD
(define (write-head hash)
  (display-to-file hash (head-file) #:exists 'replace))

;; Read index (list of filenames)
(define (read-index)
  (if (file-exists? (index-file))
      (let ([content (string-trim (file->string (index-file)))])
        (if (string=? content "")
            '()
            (string-split content "\n")))
      '()))

;; Write index
(define (write-index entries)
  (display-to-file (string-join entries "\n") (index-file) #:exists 'replace))

;; cmd: init
(define (cmd-init)
  (if (directory-exists? (minigit-dir))
      (displayln "Repository already initialized")
      (begin
        (make-directory (minigit-dir))
        (make-directory (objects-dir))
        (make-directory (commits-dir))
        (display-to-file "" (index-file) #:exists 'replace)
        (display-to-file "" (head-file) #:exists 'replace)
        (displayln "Initialized empty repository"))))

;; cmd: add <file>
(define (cmd-add filename)
  (unless (file-exists? filename)
    (displayln "File not found")
    (exit 1))
  (let* ([content (file->bytes filename)]
         [hash (mini-hash content)]
         [obj-path (build-path (objects-dir) hash)])
    (display-to-file content obj-path #:exists 'replace)
    (let ([index (read-index)])
      (unless (member filename index)
        (write-index (append index (list filename)))))))

;; cmd: commit -m <message>
(define (cmd-commit message)
  (let ([index (read-index)])
    (when (null? index)
      (displayln "Nothing to commit")
      (exit 1))
    (let* ([parent (let ([h (read-head)]) (if (string=? h "") "NONE" h))]
           [timestamp (number->string (current-seconds))]
           [sorted-files (sort index string<?)]
           [file-lines
            (map (lambda (f)
                   (let* ([content (file->bytes f)]
                          [hash (mini-hash content)])
                     (string-append f " " hash)))
                 sorted-files)]
           [commit-content
            (string-append
             "parent: " parent "\n"
             "timestamp: " timestamp "\n"
             "message: " message "\n"
             "files:\n"
             (string-join file-lines "\n")
             "\n")]
           [commit-hash (mini-hash (string->bytes/utf-8 commit-content))]
           [commit-path (build-path (commits-dir) commit-hash)])
      (display-to-file commit-content commit-path #:exists 'replace)
      (write-head commit-hash)
      (write-index '())
      (displayln (string-append "Committed " commit-hash)))))

;; Parse a commit file into an alist
(define (parse-commit hash)
  (let* ([path (build-path (commits-dir) hash)]
         [content (file->string path)]
         [lines (string-split content "\n")])
    (define (get-field prefix)
      (let ([line (findf (lambda (l) (string-prefix? l prefix)) lines)])
        (if line (substring line (string-length prefix)) "")))
    (list
     (cons 'parent (get-field "parent: "))
     (cons 'timestamp (get-field "timestamp: "))
     (cons 'message (get-field "message: ")))))

;; cmd: log
(define (cmd-log)
  (let ([head (read-head)])
    (if (string=? head "")
        (displayln "No commits")
        (let loop ([hash head])
          (when (and (not (string=? hash "")) (not (string=? hash "NONE")))
            (let ([info (parse-commit hash)])
              (displayln (string-append "commit " hash))
              (displayln (string-append "Date: " (cdr (assoc 'timestamp info))))
              (displayln (string-append "Message: " (cdr (assoc 'message info))))
              (displayln "")
              (let ([parent (cdr (assoc 'parent info))])
                (unless (string=? parent "NONE")
                  (loop parent)))))))))

;; Main
(define (main)
  (let ([args (current-command-line-arguments)])
    (when (= (vector-length args) 0)
      (displayln "Usage: minigit <command> [args]")
      (exit 1))
    (let ([cmd (vector-ref args 0)])
      (cond
        [(string=? cmd "init")
         (cmd-init)]
        [(string=? cmd "add")
         (when (< (vector-length args) 2)
           (displayln "Usage: minigit add <file>")
           (exit 1))
         (cmd-add (vector-ref args 1))]
        [(string=? cmd "commit")
         (when (or (< (vector-length args) 3)
                   (not (string=? (vector-ref args 1) "-m")))
           (displayln "Usage: minigit commit -m <message>")
           (exit 1))
         (cmd-commit (vector-ref args 2))]
        [(string=? cmd "log")
         (cmd-log)]
        [else
         (displayln (string-append "Unknown command: " cmd))
         (exit 1)]))))

(main)
