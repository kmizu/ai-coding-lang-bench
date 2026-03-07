#lang racket

;;; MiniHash: FNV-1a variant, 64-bit
(define MASK64 (- (expt 2 64) 1))
(define FNV-PRIME 1099511628211)
(define FNV-INIT  1469598103934665603)

(define (pad-hex s)
  (let ([n (- 16 (string-length s))])
    (if (<= n 0) s (string-append (make-string n #\0) s))))

(define (minihash bytes)
  (let loop ([i 0] [h FNV-INIT])
    (if (= i (bytes-length bytes))
        (pad-hex (number->string h 16))
        (let* ([b (bytes-ref bytes i)]
               [h2 (bitwise-xor h b)]
               [h3 (bitwise-and (* h2 FNV-PRIME) MASK64)])
          (loop (+ i 1) h3)))))

;;; Path helpers
(define (minigit-dir) ".minigit")
(define (objects-dir) (build-path (minigit-dir) "objects"))
(define (commits-dir) (build-path (minigit-dir) "commits"))
(define (index-path) (build-path (minigit-dir) "index"))
(define (head-path)  (build-path (minigit-dir) "HEAD"))

;;; Read HEAD (returns hash string or #f)
(define (read-head)
  (let ([p (head-path)])
    (if (file-exists? p)
        (let ([s (string-trim (file->string p))])
          (if (string=? s "") #f s))
        #f)))

;;; Read index (list of filenames)
(define (read-index)
  (let ([p (index-path)])
    (if (file-exists? p)
        (filter (lambda (s) (not (string=? s "")))
                (string-split (file->string p) "\n"))
        '())))

;;; Write index
(define (write-index lines)
  (display-to-file (string-join lines "\n")
                   (index-path) #:exists 'replace))

;;; Parse commit file: returns alist with 'parent, 'timestamp, 'message, 'files
(define (parse-commit content)
  (let* ([lines (string-split content "\n")]
         [get-field
          (lambda (prefix)
            (let ([line (findf (lambda (l) (string-prefix? l prefix)) lines)])
              (if line (substring line (string-length prefix)) "")))]
         [parent-val  (get-field "parent: ")]
         [timestamp   (get-field "timestamp: ")]
         [message     (get-field "message: ")]
         ;; files section: lines after "files:"
         [files-idx   (let loop ([i 0] [ls lines])
                        (cond [(null? ls) #f]
                              [(string=? (car ls) "files:") i]
                              [else (loop (+ i 1) (cdr ls))]))]
         [file-lines  (if files-idx
                          (filter (lambda (l) (not (string=? l "")))
                                  (list-tail lines (+ files-idx 1)))
                          '())]
         [files       (map (lambda (l)
                             (let ([parts (string-split l " ")])
                               (cons (car parts) (cadr parts))))
                           file-lines)])
    (list (cons 'parent    (if (string=? parent-val "NONE") #f parent-val))
          (cons 'timestamp timestamp)
          (cons 'message   message)
          (cons 'files     files))))

(define (commit-field commit key)
  (let ([pair (assq key commit)])
    (if pair (cdr pair) #f)))

;;; Load a commit by hash; returns parsed commit or #f
(define (load-commit hash)
  (let ([p (build-path (commits-dir) hash)])
    (if (file-exists? p)
        (parse-commit (file->string p))
        #f)))

;;; Command: init
(define (cmd-init)
  (if (directory-exists? (minigit-dir))
      (displayln "Repository already initialized")
      (begin
        (make-directory* (objects-dir))
        (make-directory* (commits-dir))
        (display-to-file "" (index-path) #:exists 'replace)
        (display-to-file "" (head-path)  #:exists 'replace)))
  (exit 0))

;;; Command: add <file>
(define (cmd-add filename)
  (unless (file-exists? filename)
    (displayln "File not found")
    (exit 1))
  (let* ([content (file->bytes filename)]
         [hash    (minihash content)]
         [obj-path (build-path (objects-dir) hash)])
    ;; Store blob
    (unless (file-exists? obj-path)
      (display-to-file content obj-path #:exists 'replace))
    ;; Update index (no duplicates)
    (let ([staged (read-index)])
      (unless (member filename staged)
        (write-index (append staged (list filename))))))
  (exit 0))

;;; Command: commit -m <message>
(define (cmd-commit message)
  (let ([staged (read-index)])
    (when (null? staged)
      (displayln "Nothing to commit")
      (exit 1))
    ;; Build file list: filename -> blob hash, sorted
    (let* ([sorted-files (sort staged string<?)]
           [file-hashes
            (map (lambda (f)
                   (cons f (minihash (file->bytes f))))
                 sorted-files)]
           [parent (or (read-head) "NONE")]
           [timestamp (number->string (current-seconds))]
           [files-str
            (string-join
             (map (lambda (pair)
                    (string-append (car pair) " " (cdr pair)))
                  file-hashes)
             "\n")]
           [commit-content
            (string-append
             "parent: " parent "\n"
             "timestamp: " timestamp "\n"
             "message: " message "\n"
             "files:\n"
             files-str "\n")]
           [commit-hash (minihash (string->bytes/utf-8 commit-content))]
           [commit-path (build-path (commits-dir) commit-hash)])
      ;; Write commit file
      (display-to-file commit-content commit-path #:exists 'replace)
      ;; Update HEAD
      (display-to-file commit-hash (head-path) #:exists 'replace)
      ;; Clear index
      (write-index '())
      (displayln (string-append "Committed " commit-hash))))
  (exit 0))

;;; Command: status
(define (cmd-status)
  (let ([staged (read-index)])
    (displayln "Staged files:")
    (if (null? staged)
        (displayln "(none)")
        (for-each displayln staged)))
  (exit 0))

;;; Command: log
(define (cmd-log)
  (let ([head (read-head)])
    (if (not head)
        (displayln "No commits")
        (let loop ([hash head])
          (when hash
            (let* ([commit (load-commit hash)]
                   [timestamp  (commit-field commit 'timestamp)]
                   [message    (commit-field commit 'message)]
                   [parent-val (commit-field commit 'parent)])
              (displayln (string-append "commit " hash))
              (displayln (string-append "Date: " timestamp))
              (displayln (string-append "Message: " message))
              (displayln "")
              (loop parent-val))))))
  (exit 0))

;;; Command: diff <commit1> <commit2>
(define (cmd-diff hash1 hash2)
  (let ([c1 (load-commit hash1)]
        [c2 (load-commit hash2)])
    (unless c1
      (displayln "Invalid commit")
      (exit 1))
    (unless c2
      (displayln "Invalid commit")
      (exit 1))
    (let* ([files1 (commit-field c1 'files)]  ; list of (name . blob)
           [files2 (commit-field c2 'files)]
           [names1 (map car files1)]
           [names2 (map car files2)]
           [all-names (sort (remove-duplicates (append names1 names2)) string<?)])
      (for-each
       (lambda (name)
         (let ([blob1 (assoc name files1)]
               [blob2 (assoc name files2)])
           (cond
             [(and (not blob1) blob2)
              (displayln (string-append "Added: " name))]
             [(and blob1 (not blob2))
              (displayln (string-append "Removed: " name))]
             [(and blob1 blob2 (not (string=? (cdr blob1) (cdr blob2))))
              (displayln (string-append "Modified: " name))])))
       all-names)))
  (exit 0))

;;; Command: checkout <commit_hash>
(define (cmd-checkout hash)
  (let ([commit (load-commit hash)])
    (unless commit
      (displayln "Invalid commit")
      (exit 1))
    (let ([files (commit-field commit 'files)])
      (for-each
       (lambda (pair)
         (let* ([filename (car pair)]
                [blob-hash (cdr pair)]
                [obj-path (build-path (objects-dir) blob-hash)]
                [content (file->bytes obj-path)])
           (display-to-file content filename #:exists 'replace)))
       files))
    ;; Update HEAD
    (display-to-file hash (head-path) #:exists 'replace)
    ;; Clear index
    (write-index '())
    (displayln (string-append "Checked out " hash)))
  (exit 0))

;;; Command: reset <commit_hash>
(define (cmd-reset hash)
  (let ([commit (load-commit hash)])
    (unless commit
      (displayln "Invalid commit")
      (exit 1))
    ;; Update HEAD only, do NOT touch working directory
    (display-to-file hash (head-path) #:exists 'replace)
    ;; Clear index
    (write-index '())
    (displayln (string-append "Reset to " hash)))
  (exit 0))

;;; Command: rm <file>
(define (cmd-rm filename)
  (let ([staged (read-index)])
    (unless (member filename staged)
      (displayln "File not in index")
      (exit 1))
    (write-index (filter (lambda (f) (not (string=? f filename))) staged)))
  (exit 0))

;;; Command: show <commit_hash>
(define (cmd-show hash)
  (let ([commit (load-commit hash)])
    (unless commit
      (displayln "Invalid commit")
      (exit 1))
    (let ([timestamp (commit-field commit 'timestamp)]
          [message   (commit-field commit 'message)]
          [files     (commit-field commit 'files)])
      (displayln (string-append "commit " hash))
      (displayln (string-append "Date: " timestamp))
      (displayln (string-append "Message: " message))
      (displayln "Files:")
      (for-each
       (lambda (pair)
         (displayln (string-append "  " (car pair) " " (cdr pair))))
       (sort files (lambda (a b) (string<? (car a) (car b)))))))
  (exit 0))

;;; Entry point
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
