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

;;; Command: log
(define (cmd-log)
  (let ([head (read-head)])
    (if (not head)
        (displayln "No commits")
        (let loop ([hash head])
          (when hash
            (let* ([commit-path (build-path (commits-dir) hash)]
                   [content (file->string commit-path)]
                   [lines (string-split content "\n")]
                   ;; Parse fields
                   [get-field
                    (lambda (prefix)
                      (let ([line (findf (lambda (l) (string-prefix? l prefix)) lines)])
                        (if line
                            (substring line (string-length prefix))
                            "")))]
                   [timestamp (get-field "timestamp: ")]
                   [message   (get-field "message: ")]
                   [parent-val (get-field "parent: ")])
              (displayln (string-append "commit " hash))
              (displayln (string-append "Date: " timestamp))
              (displayln (string-append "Message: " message))
              (displayln "")
              (loop (if (string=? parent-val "NONE") #f parent-val)))))))
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
        [(string=? cmd "log")
         (cmd-log)]
        [else
         (displayln (string-append "Unknown command: " cmd))
         (exit 1)]))))

(main)
