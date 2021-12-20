;;; wpc-nix.el --- Nix support -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1"))
;; Homepage: https://user.git.corp.google.com/wpcarro/briefcase

;;; Commentary:
;; Configuration to support working with Nix.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'device)
(require 'constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Library
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package nix-mode
  :mode "\\.nix\\'")

;; TODO(wpcarro): Ensure the sub-process can resolve <briefcase>.
(defun wpc-nix-rebuild-emacs ()
  "Use nix-env to rebuild wpcarros-emacs."
  (interactive)
  (let* ((pname (format "nix-build <briefcase/emacs.nixos>"))
         (bname (format "*%s*" pname)))
    (start-process pname bname
                   "nix-env"
                   "-I" (format "briefcase=%s" constants-briefcase)
                   "-f" "<briefcase>" "-iA" "emacs.nixos")
    (display-buffer bname)))

(defun wpc-nix-sly-from-briefcase (attr)
  "Start a Sly REPL configured using the derivation pointed at by ATTR.

  The derivation invokes nix.buildLisp.sbclWith and is built asynchronously.
  The build output is included in the error thrown on build failures."
  (interactive "sAttribute: ")
  (lexical-let* ((outbuf (get-buffer-create (format "*briefcase-out/%s*" attr)))
         (errbuf (get-buffer-create (format "*briefcase-errors/%s*" attr)))
         (expression (format "let briefcase = import <briefcase> {}; in briefcase.third_party.depot.nix.buildLisp.sbclWith [ briefcase.%s ]" attr))
         (command (list "nix-build" "-E" expression)))
    (message "Acquiring Lisp for <briefcase>.%s" attr)
    (make-process :name (format "nix-build/%s" attr)
                  :buffer outbuf
                  :stderr errbuf
                  :command command
                  :sentinel
                  (lambda (process event)
                    (unwind-protect
                        (pcase event
                          ("finished\n"
                           (let* ((outpath (s-trim (with-current-buffer outbuf
                                                     (buffer-string))))
                                  (lisp-path (s-concat outpath "/bin/sbcl")))
                             (message "Acquired Lisp for <briefcase>.%s at %s"
                                      attr lisp-path)
                             (sly lisp-path)))
                          (_ (with-current-buffer errbuf
                               (error "Failed to build '%s':\n%s" attr
                                      (buffer-string)))))
                      (kill-buffer outbuf)
                      (kill-buffer errbuf))))))

(provide 'wpc-nix)
;;; wpc-nix.el ends here