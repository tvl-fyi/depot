;; wpc-javascript.el --- My Javascript preferences -*- lexical-binding: t -*-
;; Author: William Carroll <wpcarro@gmail.com>

;;; Commentary:
;; This module hosts my Javascript tooling preferences

;;; Code:

;; Constants
(defconst wpc/js-hooks
  '(js-mode-hook js2-mode-hook rjsx-mode-hook)
  "All of the commonly used hooks for Javascript buffers.")

(defconst wpc/frontend-hooks
  (-insert-at 0 'css-mode-hook wpc/js-hooks)
  "All of the commonly user hooks for frontend development.")


;; Helper functions
(defun wpc/insert-flow-annotation ()
  "Insert a flow type annotation to the beginning of a buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (insert "// @flow\n")))

;; frontend indentation settings
(setq js-indent-level 2
      css-indent-offset 2)

;; ;; javascript
;; (evil-leader/set-key-for-mode 'rjsx-mode "t" #'wpc/toggle-between-js-test-and-module)
;; (evil-leader/set-key-for-mode 'rjsx-mode "x" #'wpc/toggle-between-js-component-and-store)
;; (evil-leader/set-key-for-mode 'rjsx-mode "u" #'wpc/jump-to-parent-file)

;; Flow for Javascript
(use-package add-node-modules-path
  :config
  (general-add-hook wpc/js-hooks #'add-node-modules-path))

(use-package flow-minor-mode
  :requires evil-leader
  :config
  (general-add-hook wpc/js-hooks #'flow-minor-mode)
  (evil-leader/set-key-for-mode 'rjsx-mode "F" #'wpc/insert-flow-annotation))

(use-package web-mode
  :mode "\\.html\\'"
  :config
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2))

;; Shouldn't need this once LSP is setup properly
;; (use-package company-flow
;;   :after (company)
;;   :config
;;   (add-to-list 'company-flow-modes 'rjsx-mode)
;;   (add-to-list 'company-backends 'company-flow))

;; Shouldn't need this once LSP is setup properly
;; (use-package flycheck-flow
;;   :after (flycheck)
;;   :config
;;   (flycheck-add-mode 'javascript-flow 'rjsx-mode)
;;   (flycheck-add-mode 'javascript-flow 'flow-minor-mode)
;;   (flycheck-add-mode 'javascript-eslint 'flow-minor-mode)
;;   (flycheck-add-next-checker 'javascript-flow 'javascript-eslint))

;; JSX highlighting
(use-package rjsx-mode
  :mode "\\.js\\'"
  :config
  (general-unbind rjsx-mode-map "<" ">" "C-d")
  (general-nmap
    :keymaps 'rjsx-mode-map
    "K" #'flow-minor-type-at-pos)
  (setq js2-mode-show-parse-errors nil
        js2-mode-show-strict-warnings nil))

;; JS autoformatting
(use-package prettier-js
  :after (rjsx-mode)
  :config
  (general-add-hook wpc/frontend-hooks #'prettier-js-mode))

(provide 'wpc-javascript)
;;; wpc-javascript.el ends here
