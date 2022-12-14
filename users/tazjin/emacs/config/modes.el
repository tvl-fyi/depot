;; Initializes modes I use.

(add-hook 'prog-mode-hook 'esk-add-watchwords)
(add-hook 'prog-mode-hook 'hl-line-mode)

;; Use auto-complete as completion at point
(defun set-auto-complete-as-completion-at-point-function ()
  (setq completion-at-point-functions '(auto-complete)))

(add-hook 'auto-complete-mode-hook
          'set-auto-complete-as-completion-at-point-function)

;; Enable rainbow-delimiters for all things programming
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; Enable Paredit & Company in Emacs Lisp mode
(add-hook 'emacs-lisp-mode-hook 'company-mode)

;; Always highlight matching brackets
(show-paren-mode 1)

;; Always auto-close parantheses and other pairs
(electric-pair-mode)

;; Keep track of recent files
(recentf-mode)

;; Easily navigate sillycased words
(global-subword-mode 1)

;; Transparently open compressed files
(auto-compression-mode t)

;; Configure go-mode for Go2 Alpha
(add-to-list 'auto-mode-alist '("\\.go2$" . go-mode))

(provide 'modes)
