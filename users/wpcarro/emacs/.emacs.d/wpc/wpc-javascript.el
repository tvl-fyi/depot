;;; wpc-javascript.el --- My Javascript preferences -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "24"))

;;; Commentary:
;; This module hosts my Javascript tooling preferences.  This also includes
;; tooling for TypeScript and other frontend tooling.  Perhaps this module will
;; change names to more accurately reflect that.
;;
;; Depends
;; - yarn global add prettier

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'general)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constants
(defconst wpc-javascript--js-hooks
  '(js-mode-hook
    web-mode-hook
    typescript-mode-hook
    js2-mode-hook
    rjsx-mode-hook)
  "All of the commonly used hooks for Javascript buffers.")

(defconst wpc-javascript--frontend-hooks
  (-insert-at 0 'css-mode-hook wpc-javascript--js-hooks)
  "All of the commonly user hooks for frontend development.")

;; frontend indentation settings
(setq typescript-indent-level 2
      js-indent-level 2
      css-indent-offset 2)

(use-package web-mode
  :mode "\\.html\\'"
  :config
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2))

;; JSX highlighting
(use-package rjsx-mode
  :config
  (general-unbind rjsx-mode-map "<" ">" "C-d")
  (general-nmap
    :keymaps 'rjsx-mode-map
    "K" #'flow-minor-type-at-pos)
  (setq js2-mode-show-parse-errors nil
        js2-mode-show-strict-warnings nil))

(progn
  (defun wpc-javascript-tide-setup ()
    (interactive)
    (tide-setup)
    (flycheck-mode 1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode 1)
    (tide-hl-identifier-mode 1)
    (company-mode 1))
  (use-package tide
    :config
    (add-hook 'typescript-mode-hook #'wpc-javascript-tide-setup))
  (require 'web-mode)
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (f-ext buffer-file-name))
                (wpc-javascript-tide-setup))))
  (flycheck-add-mode 'typescript-tslint 'web-mode))

;; JS autoformatting
(use-package prettier-js
  :config
  (general-add-hook wpc-javascript--frontend-hooks #'prettier-js-mode))

;; Support Elm
(use-package elm-mode
  :config
  (add-hook 'elm-mode-hook #'elm-format-on-save-mode))

(provide 'wpc-javascript)
;;; wpc-javascript.el ends here
