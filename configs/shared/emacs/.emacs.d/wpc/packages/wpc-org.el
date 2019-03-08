;;; org.el --- My org preferences -*- lexical-binding: t -*-
;; Author: William Carroll <wpcarro@gmail.com>

;;; Commentary:
;; Hosts my org mode preferences

;;; Code:

;; TODO: figure out how to nest this in (use-package org ...)
(setq org-capture-templates
      (quote (

("w" "work" entry (file+headline "~/Documents/org/work.org" "Tasks")
 "* TODO %?")

("p" "personal" entry (file+headline "~/Documents/org/personal.org" "Tasks")
 "* TODO %? ")

)))
(evil-set-initial-state 'org-mode 'insert)

(use-package org
  :preface
  (defconst wpc-org-directory
    "~/Documents/org")
  :config
  ; (general-add-hook org-mode-hook (disable linum-mode))
  (general-define-key :prefix "C-c"
           "l" #'org-store-link
           "a" #'org-agenda
           "c" #'org-capture)
  (setq org-default-notes-file (wpc/org-file "notes"))
  (setq org-log-done 'time)
  (setq org-agenda-files (list (wpc/org-file "work")
                               (wpc/org-file "personal"))))

(use-package org-bullets
  :after (org)
  :config
  (general-add-hook 'org-mode-hook (enable org-bullets-mode)))

;; i3, `org-mode' integration
;; Heavily influenced by: https://somethingsomething.us/post/i3_and_orgmode/
(defadvice org-switch-to-buffer-other-window
    (after supress-window-splitting activate)
  "Delete the extra window if we're in a capture frame."
  (if (equal "org-protocol-capture" (wpc/frame-name))
      (delete-other-windows)))

(add-hook 'org-capture-after-finalize-hook
          (lambda ()
            (when (equal "org-protocol-capture" (wpc/frame-name))
                (delete-frame))))

(provide 'wpc-org)
;;; wpc-org.el ends here
