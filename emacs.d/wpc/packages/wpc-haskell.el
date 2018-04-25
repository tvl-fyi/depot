;;; haskell.el --- My Haskell preferences -*- lexical-binding: t -*-
;; Author: William Carroll <wpcarro@gmail.com>

;;; Commentary:
;; Hosts my Haskell development preferences

;;; Code:

;; Haskell support
(use-package intero
  :config
  (intero-global-mode 1))

;; text objects for Haskell
(quelpa '(evil-text-objects-haskell
          :fetcher github
          :repo "urbint/evil-text-objects-haskell"))
(require 'evil-text-objects-haskell)

(use-package haskell-mode
  :gfhook #'evil-text-objects-haskell/install
  :after (intero evil-text-objects-haskell)
  :config
  (flycheck-add-next-checker 'intero 'haskell-hlint)
  (let ((m-symbols
         '(("`mappend`" . "⊕")
           ("<>"        . "⊕"))))
    (dolist (item m-symbols) (add-to-list 'haskell-font-lock-symbols-alist item)))
  (setq haskell-font-lock-symbols t))

(provide 'wpc-haskell)
;;; haskell.el ends here
