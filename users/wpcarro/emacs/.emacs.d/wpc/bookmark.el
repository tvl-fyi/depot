;;; bookmark.el --- Saved files and directories on my filesystem -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.3"))

;;; Commentary:
;; After enjoying and relying on Emacs's builtin `jump-to-register' command, I'd
;; like to recreate this functionality with a few extensions.
;;
;; Everything herein will mimmick my previous KBDs for `jump-to-register', which
;; were <leader>-j-<register-kbd>.  If the `bookmark-path' is a file, Emacs will
;; open a buffer with that file.  If the `bookmark-path' is a directory, Emacs
;; will open an ivy window searching that directory.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'f)
(require 'buffer)
(require 'dash)
(require 'string)
(require 'set)
(require 'constants)
(require 'general)
(require 'tvl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(cl-defstruct bookmark label path kbd)

(defun bookmark-handle-directory-dwim (path)
  "Open PATH as either a project directory or a regular directory."
  (with-temp-buffer
    (cd path)
    (call-interactively #'project-find-file)))

(defconst bookmark-handle-directory #'bookmark-handle-directory-dwim
  "Function to call when a bookmark points to a directory.")

(defconst bookmark-handle-file #'counsel-find-file-action
  "Function to call when a bookmark points to a file.")

(defconst bookmark-whitelist
  (list
   (make-bookmark :label "depot"
                  :path tvl-depot-path
                  :kbd "d"))
  "List of registered bookmarks.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bookmark-open (b)
  "Open bookmark, B, in a new buffer or an ivy minibuffer."
  (let ((path (bookmark-path b)))
    (cond
     ((f-directory? path)
      (funcall bookmark-handle-directory path))
     ((f-file? path)
      (funcall bookmark-handle-file path)))))

(defun bookmark-install-kbd (b)
  "Define two functions to explore B and assign them to keybindings."
  (eval `(defun ,(intern (format "bookmark-visit-%s" (bookmark-label b))) ()
           (interactive)
           (find-file ,(bookmark-path b))))
  (eval `(defun ,(intern (format "bookmark-browse-%s" (bookmark-label b))) ()
           (interactive)
           (bookmark-open ,b)))
  (general-define-key
   :prefix "<SPC>"
   :states '(motion)
   (format "J%s" (bookmark-kbd b)) `,(intern (format "bookmark-visit-%s" (bookmark-label b)))
   (format "j%s" (bookmark-kbd b)) `,(intern (format "bookmark-browse-%s" (bookmark-label b)))))

(defun bookmark-install-kbd (x)
  "Install the keybindings for a bookmark, X."
  (general-define-key
    :prefix "<SPC>"
    :states '(normal)
    (format "J%s" (bookmark-kbd x)) (lambda () (interactive) (find-file (bookmark-path x)))
    (format "j%s" (bookmark-kbd x)) (lambda () (interactive) (bookmark-open (bookmark-path x)))))

(defun bookmark-install-kbds ()
  "Install the keybindings defined herein."
  (->> bookmark-whitelist
       (-map #'bookmark-install-kbd)))

(provide 'bookmark)
;;; bookmark.el ends here
