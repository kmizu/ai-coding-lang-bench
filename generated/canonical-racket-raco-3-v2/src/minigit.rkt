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

;; Split line on last space: returns (cons before-last-space after-last-space)
(define (split-on-last-space line)
  (let loop ([i (- (string-length line) 1)])
    (cond
      [(< i 0) (cons line "")]
      [(char=? (string-ref line i) #\space)
       (cons (substring line 0 i) (substring line (+ i 1)))]
      [else (loop (- i 1))])))

;; Parse a commit file into an alist with keys: parent, timestamp, message, files
;; files is a list of (filename . blobhash) pairs
(define (parse-commit hash)
  (let* ([path (build-path (commits-dir) hash)])
    (unless (file-exists? path)
      (displayln "Invalid commit")
      (exit 1))
    (let* ([content (file->string path)]
           [lines (string-split content "\n")])
      (define parent "")
      (define timestamp "")
      (define message "")
      (define files '())
      (define in-files #f)
      (for ([line lines])
        (cond
          [in-files
           (when (not (string=? line ""))
             (let ([p (split-on-last-space line)])
               (set! files (append files (list (cons (car p) (cdr p)))))))]
          [(string-prefix? line "parent: ")
           (set! parent (substring line 8))]
          [(string-prefix? line "timestamp: ")
           (set! timestamp (substring line 11))]
          [(string-prefix? line "message: ")
           (set! message (substring line 9))]
          [(string=? line "files:")
           (set! in-files #t)]))
      (list
       (cons 'parent parent)
       (cons 'timestamp timestamp)
       (cons 'message message)
       (cons 'files files)))))

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

;; cmd: status
(define (cmd-status)
  (let ([index (read-index)])
    (displayln "Staged files:")
    (if (null? index)
        (displayln "(none)")
        (for ([f index])
          (displayln f)))))

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

;; cmd: diff <commit1> <commit2>
(define (cmd-diff commit1 commit2)
  (unless (file-exists? (build-path (commits-dir) commit1))
    (displayln "Invalid commit")
    (exit 1))
  (unless (file-exists? (build-path (commits-dir) commit2))
    (displayln "Invalid commit")
    (exit 1))
  (let* ([files1 (cdr (assoc 'files (parse-commit commit1)))]
         [files2 (cdr (assoc 'files (parse-commit commit2)))])
    ;; Added: in commit2 but not commit1
    (for ([f files2])
      (unless (assoc (car f) files1)
        (displayln (string-append "Added: " (car f)))))
    ;; Removed: in commit1 but not commit2
    (for ([f files1])
      (unless (assoc (car f) files2)
        (displayln (string-append "Removed: " (car f)))))
    ;; Modified: in both but different hash
    (for ([f files1])
      (let ([f2 (assoc (car f) files2)])
        (when (and f2 (not (string=? (cdr f) (cdr f2))))
          (displayln (string-append "Modified: " (car f))))))))

;; cmd: checkout <commit_hash>
(define (cmd-checkout commit-hash)
  (unless (file-exists? (build-path (commits-dir) commit-hash))
    (displayln "Invalid commit")
    (exit 1))
  (let ([files (cdr (assoc 'files (parse-commit commit-hash)))])
    (for ([f files])
      (let* ([filename (car f)]
             [blobhash (cdr f)]
             [obj-path (build-path (objects-dir) blobhash)]
             [content (file->bytes obj-path)])
        (display-to-file content filename #:exists 'replace)))
    (write-head commit-hash)
    (write-index '())
    (displayln (string-append "Checked out " commit-hash))))

;; cmd: reset <commit_hash>
(define (cmd-reset commit-hash)
  (unless (file-exists? (build-path (commits-dir) commit-hash))
    (displayln "Invalid commit")
    (exit 1))
  (write-head commit-hash)
  (write-index '())
  (displayln (string-append "Reset to " commit-hash)))

;; cmd: rm <file>
(define (cmd-rm filename)
  (let ([index (read-index)])
    (unless (member filename index)
      (displayln "File not in index")
      (exit 1))
    (write-index (filter (lambda (f) (not (string=? f filename))) index))))

;; cmd: show <commit_hash>
(define (cmd-show commit-hash)
  (unless (file-exists? (build-path (commits-dir) commit-hash))
    (displayln "Invalid commit")
    (exit 1))
  (let ([info (parse-commit commit-hash)])
    (displayln (string-append "commit " commit-hash))
    (displayln (string-append "Date: " (cdr (assoc 'timestamp info))))
    (displayln (string-append "Message: " (cdr (assoc 'message info))))
    (displayln "Files:")
    (for ([f (sort (cdr (assoc 'files info))
                   (lambda (a b) (string<? (car a) (car b))))])
      (displayln (string-append "  " (car f) " " (cdr f))))))

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
        [(string=? cmd "status")
         (cmd-status)]
        [(string=? cmd "log")
         (cmd-log)]
        [(string=? cmd "diff")
         (when (< (vector-length args) 3)
           (displayln "Usage: minigit diff <commit1> <commit2>")
           (exit 1))
         (cmd-diff (vector-ref args 1) (vector-ref args 2))]
        [(string=? cmd "checkout")
         (when (< (vector-length args) 2)
           (displayln "Usage: minigit checkout <commit_hash>")
           (exit 1))
         (cmd-checkout (vector-ref args 1))]
        [(string=? cmd "reset")
         (when (< (vector-length args) 2)
           (displayln "Usage: minigit reset <commit_hash>")
           (exit 1))
         (cmd-reset (vector-ref args 1))]
        [(string=? cmd "rm")
         (when (< (vector-length args) 2)
           (displayln "Usage: minigit rm <file>")
           (exit 1))
         (cmd-rm (vector-ref args 1))]
        [(string=? cmd "show")
         (when (< (vector-length args) 2)
           (displayln "Usage: minigit show <commit_hash>")
           (exit 1))
         (cmd-show (vector-ref args 1))]
        [else
         (displayln (string-append "Unknown command: " cmd))
         (exit 1)]))))

(main)
