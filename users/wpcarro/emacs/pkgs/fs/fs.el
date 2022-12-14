;;; fs.el --- Make working with the filesystem easier -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.1"))

;;; Commentary:
;; Ergonomic alternatives for working with the filesystem.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'dash)
(require 'f)
(require 's)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Library
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fs-ensure-file (path)
  "Ensure that a file and its directories in `PATH' exist.
Will error for inputs with a trailing slash."
  (when (s-ends-with? "/" path)
    (error (format "Input path has trailing slash: %s" path)))
  (->> path
       f-dirname
       fs-ensure-dir)
  (f-touch path))

(defun fs-ensure-dir (path)
  "Ensure that a directory and its ancestor directories in `PATH' exist."
  (->> path
       f-split
       (apply #'f-mkdir)))

(defun fs-ls (dir &optional full-path?)
  "List the files in `DIR' one-level deep.
Should behave similarly in spirit to the Unix command, ls.
If `FULL-PATH?' is set, return the full-path of the files."
  (-drop 2 (directory-files dir full-path?)))

(provide 'fs)
;;; fs.el ends here
