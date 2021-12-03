;;; tvl.el --- description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Griffin Smith
;; Copyright (C) 2020 The TVL Contributors
;;
;; Author: Griffin Smith <grfn@gws.fyi>
;; Version: 0.0.1
;; Package-Requires: (s dash magit)
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; This file provides shared utilities for interacting with the TVL monorepo
;;
;;; Code:

(require 'magit)
(require 's)

(defgroup tvl nil
  "Customisation options for TVL functionality.")

(defcustom tvl-gerrit-remote "origin"
  "Name of the git remote for gerrit"
  :type '(string)
  :group 'tvl)

(defcustom tvl-depot-path "/depot"
  "Location at which the TVL depot is checked out."
  :type '(string)
  :group 'tvl)

(defcustom tvl-target-branch "canon"
  "Branch to use to target CLs"
  :group 'tvl
  :type '(string)
  :safe (lambda (_) t))

(defun tvl--gerrit-ref (target-branch &optional flags)
  (let ((flag-suffix (if flags (format "%%l=%s" (s-join "," flags))
                       "")))
    (format "HEAD:refs/for/%s%s" target-branch flag-suffix)))

(transient-define-suffix magit-gerrit-push-for-review ()
  "Push to Gerrit for review."
  (interactive)
  (magit-push-refspecs tvl-gerrit-remote
                       (tvl--gerrit-ref tvl-target-branch)
                       nil))

(transient-append-suffix
  #'magit-push ["r"]
  (list "R" "push to Gerrit for review" #'magit-gerrit-push-for-review))

(transient-define-suffix magit-gerrit-push-wip ()
  "Push to Gerrit as a work-in-progress."
  (interactive)
  (magit-push-refspecs tvl-gerrit-remote
                       (concat (tvl--gerrit-ref tvl-target-branch) "%wip")
                       nil))

(transient-append-suffix
  #'magit-push ["r"]
  (list "W" "push to Gerrit as a work-in-progress" #'magit-gerrit-push-wip))

(transient-define-suffix magit-gerrit-submit ()
  "Push to Gerrit for review."
  (interactive)
  (magit-push-refspecs tvl-gerrit-remote
                       (tvl--gerrit-ref tvl-target-branch '("submit"))
                       nil))

(transient-append-suffix
  #'magit-push ["r"]
  (list "S" "push to Gerrit to submit" #'magit-gerrit-submit))


(transient-define-suffix magit-gerrit-rubberstamp ()
  "Push, automatically approve and submit to Gerrit. This
rubberstamp operation is dangerous and should only be used in
`//users'."
  (interactive)
  (magit-push-refspecs tvl-gerrit-remote
                       (tvl--gerrit-ref tvl-target-branch
                                        '("Code-Review+2" "publish-comments"))
                       nil))

(transient-append-suffix
  #'magit-push ["r"]
  (list "P" "push & rubberstamp to Gerrit" #'magit-gerrit-rubberstamp))

(defvar magit-cl-history nil)
(defun magit-read-cl (remote)
  (let* ((refs (prog2 (message "Determining available refs...")
                   (magit-remote-list-refs remote)
                 (message "Determining available refs...done")))
         (change-refs (-filter
                       (apply-partially #'string-prefix-p "refs/changes/")
                       refs))
         (cl-number-to-refs
          (-group-by
           (lambda (change-ref)
             ;; refs/changes/34/1234/1
             ;; ^    ^       ^  ^    ^
             ;; 1    2       3  4    5
             ;;                 ^-- this one
             (cadddr
              (split-string change-ref (rx "/"))))
           change-refs))
         (cl-numbers
          (-map
           (lambda (cl-to-refs)
             (let ((latest-patchset-ref
                    (-max-by
                     (-on #'> (lambda (ref)
                                (string-to-number
                                 (fifth (split-string ref (rx "/"))))))
                     (-remove
                      (apply-partially #'s-ends-with-p "meta")
                      (cdr cl-to-refs)))))
               (propertize (car cl-to-refs) 'ref latest-patchset-ref)))
           cl-number-to-refs)))
    (get-text-property
     0
     'ref
     (magit-completing-read
      "Checkout CL" cl-numbers nil t nil 'magit-cl-history))))

(transient-define-suffix magit-gerrit-checkout (remote cl-refspec)
  "Prompt for a CL number and checkout the latest patchset of that CL with
  detached HEAD"
  (interactive
   (let* ((remote tvl-gerrit-remote)
          (cl (magit-read-cl remote)))
     (list remote cl)))
  (magit-fetch-refspec remote cl-refspec (magit-fetch-arguments))
  ;; That runs async, so wait for it to finish (this is how magit does it)
  (while (and magit-this-process
              (eq (process-status magit-this-process) 'run))
    (sleep-for 0.005))
  (magit-checkout "FETCH_HEAD" (magit-branch-arguments))
  (message "HEAD detached at %s" cl-refspec))

(transient-append-suffix
  #'magit-branch ["l"]
  (list "g" "gerrit CL" #'magit-gerrit-checkout))

(defun tvl-depot-status ()
  "Open the TVL monorepo in magit."
  (interactive)
  (magit-status-setup-buffer tvl-depot-path))

(provide 'tvl)
;;; tvl.el ends here
