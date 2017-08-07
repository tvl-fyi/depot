;;; William Carroll's Emacs configuration


;; From `https://github.com/melpa/melpa`
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#1B2229" "#ff6c6b" "#98be65" "#ECBE7B" "#51afef" "#c678dd" "#46D9FF" "#DFDFDF"])
 '(column-number-mode t)
 '(custom-enabled-themes (quote (sanityinc-tomorrow-eighties)))
 '(custom-safe-themes
   (quote
    ("c50a672a129e71b9362b209c63d4e203ccc88a388c370411535b8b54ecc878bc" "5310b88333fc64c0cb34a27f42fa55ce371438a55f02ac7a4b93519d148bd03d" "f67652440b66223b66a4d3e9c0ddeddbf4a6560182fa38693bdc4d940ce43a2e" "0f0022c8091326c9894b707df2ae58dd51527b0cf7abcb0a310fb1e7bda78cd2" "8d737627879eff1bbc7e3ef1e9adc657207d9bf74f9abb6e0e53a6541c5f2e88" "5c9bd73de767fa0d0ea71ee2f3ca6fe77261d931c3d4f7cca0734e2a3282f439" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "398e6465d45d5af4cbf94f8ebfb24deb71249f28cdfb4b0fa7197354ee0c9802" "db34c17b9a7810856352a341e15d701696fb4710fe7e0dab57b8268515c2b082" "ee93cac221c92b580bde1326209e1a327287cd49931ba319a9af7a7af201967c" "68f66d916f4e90f11f2dc815e9580c1aaf9e9c75eeee3fbd8b663d706e121a1a" "c158c2a9f1c5fcf27598d313eec9f9dceadf131ccd10abc6448004b14984767c" "cc0dbb53a10215b696d391a90de635ba1699072745bf653b53774706999208e3" "3e335d794ed3030fefd0dbd7ff2d3555e29481fe4bbb0106ea11c660d6001767" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "20e23cba00cf376ea6f20049022241c02a315547fc86df007544852c94ab44cb" "60d4556ebff0dc94849f177b85dcb6956fe9bd394c18a37e339c0fcd7c83e4a9" "707227acad0cf8d4db55dcf1e574b3644b68eab8aca4a8ce6635c8830bc72144" "1c656eb3f6ae6c84ced46282cb4ed697bffe2f6c764bb5a737ed7ca6d068f798" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "9f3181dc1fabe5d58bbbda8c48ef7ece59b01bed606cfb868dd147e8b36af97c" "ad1c2abad40e11d22156fe3987fd9b74b9e1c822264a07dacb24e0b3133aaed1" "945fe66fbc30a7cbe0ed3e970195a7ee79ee34f49a86bc96d02662ab449b8134" "0f0db69b7a75a7466ef2c093e127a3fe3213ce79b87c95d39ed1eccd6fe69f74" "08b8807d23c290c840bbb14614a83878529359eaba1805618b3be7d61b0b0a32" "9d91458c4ad7c74cf946bd97ad085c0f6a40c370ac0a1cbeb2e3879f15b40553" "6254372d3ffe543979f21c4a4179cd819b808e5dd0f1787e2a2a647f5759c1d1" "8ec2e01474ad56ee33bc0534bdbe7842eea74dccfb576e09f99ef89a705f5501" "5b24babd20e58465e070a8d7850ec573fe30aca66c8383a62a5e7a3588db830b" "eb0a314ac9f75a2bf6ed53563b5d28b563eeba938f8433f6d1db781a47da1366" "3d47d88c86c30150c9a993cc14c808c769dad2d4e9d0388a24fee1fbf61f0971" default)))
 '(evil-shift-width 2)
 '(fci-rule-color "#5B6268")
 '(flycheck-color-mode-line-face-to-color (quote mode-line-buffer-id))
 '(jdee-db-active-breakpoint-face-colors (cons "#1B2229" "#51afef"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#1B2229" "#98be65"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#1B2229" "#3f444a"))
 '(mouse-wheel-mode nil)
 '(neo-window-fixed-size nil)
 '(neo-window-width 35)
 '(org-ellipsis "  ")
 '(org-fontify-done-headline t)
 '(org-fontify-quote-and-verse-blocks t)
 '(org-fontify-whole-heading-line t)
 '(package-selected-packages
   (quote
    (undo-tree solaire-mode smart-mode-line memoize async json-mode toml-mode git-timemachine rainbow-mode company-shell swiper ivy nlinum tabbar rainbow-delimiters s font-lock+ f diminish dash avy all-the-icons dired+ linum-off git markdown-mode yaml-mode haskell-mode color-theme-sanityinc-tomorrow graphql-mode flycheck-elm popup-kill-ring green-phosphor-theme green-screen-theme minimal-theme creamsody-theme autothemer solarized-theme avk-emacs-themes github-theme all-the-icons-dired ace-window yasnippet chess synonyms powerline doom-neotree doom-themes persp-mode use-package helm-projectile persp-projectile perspective projectile with-editor helm-core company helm-ag evil-leader flycheck-mix flycheck-elixir evil-matchit typescript-mode evil-surround erlang elixir-mode golden-ratio flycheck-credo flycheck command-log-mode atom-one-dark-theme exec-path-from-shell clues-theme gotham-theme dracula-theme zenburn-theme fill-column-indicator neotree evil vimrc-mode helm-ispell transpose-frame helm-ack nyan-mode alchemist helm dockerfile-mode elm-mode ack)))
 '(popwin-mode t)
 '(popwin:popup-window-height 25)
 '(popwin:special-display-config
   (quote
    (help-mode
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm-.+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("^*helm .+*$" :regexp t)
     ("*Miniedit Help*" :noselect t)
     (completion-list-mode :noselect t)
     (compilation-mode :noselect t)
     (grep-mode :noselect t)
     (occur-mode :noselect t)
     ("*Pp Macroexpand Output*" :noselect t)
     "*Shell Command Output*" "*vc-diff*" "*vc-change-log*"
     (" *undo-tree*" :width 60 :position right)
     ("^\\*anything.*\\*$" :regexp t)
     "*slime-apropos*" "*slime-macroexpansion*" "*slime-description*"
     ("*slime-compilation*" :noselect t)
     "*slime-xref*"
     (sldb-mode :stick t)
     slime-repl-mode slime-connection-list-mode)))
 '(tool-bar-mode nil)
 '(vc-annotate-background "#1B2229")
 '(vc-annotate-color-map
   (list
    (cons 20 "#98be65")
    (cons 40 "#b4be6c")
    (cons 60 "#d0be73")
    (cons 80 "#ECBE7B")
    (cons 100 "#e6ab6a")
    (cons 120 "#e09859")
    (cons 140 "#da8548")
    (cons 160 "#d38079")
    (cons 180 "#cc7cab")
    (cons 200 "#c678dd")
    (cons 220 "#d974b7")
    (cons 240 "#ec7091")
    (cons 260 "#ff6c6b")
    (cons 280 "#cf6162")
    (cons 300 "#9f585a")
    (cons 320 "#6f4e52")
    (cons 340 "#5B6268")
    (cons 360 "#5B6268")))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(hl-line ((t (:inherit nil)))))


;; Avoid re-read from disk prompt after switching git branches
(global-auto-revert-mode t)


;; server stuff
(server-start)


;; File extensions and their associated major modes
(add-to-list 'auto-mode-alist '("\\.zsh_profile\\'" . shell-script-mode))


;; Turn off line-wrapping (default)
(set-default 'truncate-lines t)
(setq truncate-partial-width-windows nil)


;; Window Auto-Balancing
(defadvice split-window-below (after restore-balanace-below activate)
  (balance-windows))

(defadvice split-window-right (after restore-balance-right activate)
  (balance-windows))

(defadvice delete-window (after restore-balance activate)
  (balance-windows))


;; Extend load-path
(add-to-list 'load-path "~/.emacs.d/wc-downloads")


;; Basic functions used within configuration
(load "~/.emacs.d/wc-helper-functions.el")


;; Extend linum to highlight current line numbers
(use-package hlinum
  :ensure t
  :config
  (hlinum-activate))


;; Extend linum to highlight current line numbers
(use-package git-timemachine
  :ensure t
  :config
  (require 'evil)
  (evil-make-overriding-map git-timemachine-mode-map 'normal t)
  (add-hook 'git-timemachine-mode-hook #'evil-normalize-keymaps))


;; Tabbed buffer support
(use-package tabbar
  :ensure t
  :init
  (load "~/.emacs.d/wc-tabbar-functions.el")
  :config
  (setq tabbar-hide-header-button t)
  (setq tabbar-use-images nil)

  (defun wc/conditionally-activate-tabbar ()
    (if (and (derived-mode-p 'prog-mode)
             (not (string-match-p "*" (buffer-name))))
        (tabbar-local-mode -1)
      (tabbar-local-mode 1)))

  (add-hook 'emacs-startup-hook #'wc/conditionally-activate-tabbar)
  (add-hook 'after-change-major-mode-hook #'wc/conditionally-activate-tabbar)

  (tabbar-mode))


;; Smart Mode Line
(use-package smart-mode-line
  :ensure t
  :config
  (display-time)
  (load-theme 'smart-mode-line-respectful)
  (smart-mode-line-enable))


;; Aesthetic tweaks
(use-package solaire-mode
  :ensure t
  :config
  (add-hook 'after-change-major-mode-hook #'turn-on-solaire-mode)
  (add-hook 'after-revert-hook #'turn-on-solaire-mode)
  (add-hook 'minibuffer-setup-hook #'solaire-mode-in-minibuffer)
  (add-hook 'dired-mode-hook #'solaire-mode))


;; Colorized delimiters
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))


;; Colorize Hex codes
(use-package rainbow-mode
  :ensure t
  :config
  (add-hook 'css-mode-hook 'rainbow-mode))


;; Colorscheme
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold nil
        doom-themes-enable-italic nil)
  (load-theme 'doom-one)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (load "~/.emacs.d/wc-doom-functions.el"))


;; Nyan cat
(use-package nyan-mode
  :ensure t
  :config
  (nyan-mode t))


;; Man page viewing
(use-package man
  :bind (:map Man-mode-map
              ("j" . next-line)
              ("k" . previous-line)
              ("h" . backward-char)
              ("l" . forward-char)
              ("g" . beginning-of-buffer)
              ("G" . end-of-buffer)))


;; ERC configuration (IRC in Emacs)
(use-package erc
  :ensure t
  :init
  (setq erc-autojoin-channels-alist '(("freenode.net" "#emacs" "#elixir"))))


;; Disable fringes in Emacs
(fringe-mode 0)


;; Linum
(use-package linum
  :init
  (setq linum-disabled-modes-list '(term-mode dired-mode Man-mode org-mode emacs-pager-mode))
  :config
  (require 'evil)

  (defun linum-on ()
    (if (or (memq major-mode linum-disabled-modes-list)
            (minibufferp)
            (and (string-match-p "*" (buffer-name))
                 (not (string-match-p "*scratch*" (buffer-name)))))
        (linum-mode -1)
      (progn
        (linum-mode nil)
        (evil-local-mode))))
  (setq linum-format " %d  ")
  (global-linum-mode t))


;; Command Log Mode
(use-package command-log-mode
  :ensure t
  :config
  (setq-default command-log-mode-window-font-size 1)
  (setq-default command-log-mode-window-size 40))


;; Ace Window
(use-package ace-window
  :ensure t
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))


;; All-the-fonts
(use-package all-the-icons
  :ensure t
  :config
  ;; (all-the-icons-install-fonts)
  )


;; Thesaurus
(use-package synonyms
  :ensure t)


;; View stream of Emacs commands
(use-package command-log-mode
  :ensure t
  :commands (global-command-log-mode))


;; Flycheck Settings
(use-package flycheck
  :ensure t
  :config
  (setq flycheck-display-errors-delay 0.0))


(defadvice term-sentinel (around my-advice-term-sentinel (proc msg))
  (if (memq (process-status proc) '(signal exit))
      (let ((buffer (process-buffer proc)))
        ad-do-it
        (kill-buffer-and-window))
    ad-do-it))
(ad-activate 'term-sentinel)


;; Ansi-Term
(use-package term
  :ensure t
  :init
  (setq explicit-shell-file-name "/bin/zsh")
  :config
  (add-hook 'term-mode-hook 'wc/bootstrap-ansi-term))


;; Projectile Settings
(use-package projectile
  :ensure t
  :commands (projectile-mode))


;; Dired Settings
(use-package dired
  :init
  (load "~/.emacs.d/wc-dired-functions.el")
  :bind (:map dired-mode-map
              ("C-p" . helm-ag-neotree-node)
              ("e" . wdired-change-to-wdired-mode)
              ("c" . find-file)
              ("RET" . dired-find-alternate-file)
              ("^" . wc/dired-up-directory))
  :config
  (setq wdired-allow-to-change-permissions t))


;; Dired-plus
(use-package dired+
  :ensure t
  :init
  (setq diredp-hide-details-initially-flag nil)
  :config
  ;; remove bindings that interfere with globally-set windmove bindings
  (define-key dired-mode-map (kbd "C-h") nil)
  (define-key dired-mode-map (kbd "C-j") nil)
  (define-key dired-mode-map (kbd "C-k") nil)
  (define-key dired-mode-map (kbd "C-l") nil))


(defun wc/evil-window-split-down ()
  "Convenience function that does 3 things: 1. creates a horizontal split (downward),2. Center both the previous window and the newly created window,3. Moves (downward) to the newly created window."
  (interactive)
  (evil-window-split-down)
  (call-interactively 'evil-window-up)
  (call-interactively 'evil-scroll-line-to-center)
  (call-interactively 'evil-window-down)
  (call-interactively 'evil-scroll-line-to-center))


(defun wc/evil-window-split ()
  "Convenience function that does 3 things: 1. creates a horizontal split (upward),2. Center both the previous window and the newly created window,3. Moves (upward) to the newly created window."
  (interactive)
  (evil-window-split)
  (call-interactively 'evil-scroll-line-to-center)
  (call-interactively 'evil-window-down)
  (call-interactively 'evil-scroll-line-to-center)
  (call-interactively 'evil-window-up))


;; Evil Settings
(use-package evil
  :ensure t
  :commands (evil-mode local-evil-mode)
  :bind (:map evil-visual-state-map
              ("H" . evil-first-non-blank)
              ("L" . evil-end-of-visual-line)

              :map evil-motion-state-map
              ("<return>" . nil)
              ([tab] . nil)
              ("SPC" . nil)
              ("M-." . nil)

              :map evil-insert-state-map
              ("C-k" . nil)
              ("C-p" . nil)
              ("C-n" . nil)
              ("C-r" . nil)
              ("C-t" . nil)
              ("C-e" . nil)
              ("C-a" . nil)
              ("C-h" . evil-window-left)
              ("C-l" . evil-window-right)
              ("C-k" . evil-window-up)
              ("C-j" . evil-window-down)
              ("C-c" . term-interrupt-subjob)

              :map evil-normal-state-map
              ("<return>" . nil)
              ([tab] . tabbar-forward-tab)
              ([backtab] . tabbar-backward-tab)
              ("K" . nil)
              ("M-." . nil)
              ("s" . nil)
              ("C-p" . nil)
              ("g c" . comment-or-uncomment-region)
              ("s h" . evil-window-vsplit)
              ("s l" . evil-window-vsplit-right)
              ("s k" . wc/evil-window-split)
              ("s j" . wc/evil-window-split-down)
              ("H" . evil-first-non-blank)
              ("L" . evil-end-of-line)
              ("<S-left>" . evil-window-increase-width)
              ("<S-right>" . evil-window-decrease-width)
              ("<S-up>" . evil-window-decrease-height)
              ("<S-down>" . evil-window-increase-height)

              :map evil-ex-map
              ("tb" . alchemist-test-this-buffer)
              ("tap" . alchemist-test-at-point)
              ("lt" . alchemist-mix-rerun-last-test))
  :init
  (global-evil-matchit-mode t)
  (global-evil-surround-mode t)
  (global-evil-leader-mode t)
  :config

  (defadvice evil-write (around force-evil-write activate)
    (set-buffer-modified-p t)
    (save-buffer))

  (setq evil-emacs-state-cursor '("VioletRed3" box))
  (setq evil-normal-state-cursor '("DeepSkyBlue2" box))
  (setq evil-visual-state-cursor '("orange" box))
  (setq evil-insert-state-cursor '("VioletRed3" bar))
  (setq evil-replace-state-cursor '("VioletRed3" bar))
  (setq evil-operator-state-cursor '("VioletRed3" hollow))
  (evil-ex-define-cmd (kbd "qb") 'kill-this-buffer)

  ;; center search results
  (defadvice evil-search-next
      (after center-evil-search-next activate)
    (call-interactively 'evil-scroll-line-to-center))

  (defadvice evil-search-previous
      (after center-evil-search-previous activate)
    (call-interactively 'evil-scroll-line-to-center))

  (add-hook 'org-mode-hook 'evil-local-mode))


;; Hack at the moment for extending the behavior of the jump to mark command
(evil-define-command evil-goto-mark-line (char)
  "Go to line of marker denoted by CHAR."
  :keep-visual t
  :repeat nil
  :type line
  (interactive (list (read-char)))
  (evil-goto-mark char)
  (evil-first-non-blank)
  (call-interactively 'evil-scroll-line-to-center))


(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")


;; Evil Leader Settings
(use-package evil-leader
  :ensure t
  :commands (global-evil-leader-mode)
  :config
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "[" 'flycheck-previous-error
    "]" 'flycheck-next-error
    "w" 'toggle-truncate-lines
    "x" 'helm-M-x
    "<SPC>" 'wc/switch-to-mru-buffer
    "a" 'ace-delete-window
    "l" 'global-linum-mode
    "s" 'ace-swap-window
    "n" 'neotree-toggle-project-dir
    "N" 'neotree-reveal-current-buffer
    "t" 'alchemist-project-toggle-file-and-tests
    "f" 'helm-projectile
    "p" 'helm-projectile-ag
    "d" 'dired-jump
    "D" 'projectile-dired
    "q" 'kill-this-buffer
    "h" 'help
    "i" 'helm-semantic-or-imenu
    "b" 'helm-mini
    "T" 'alchemist-mix-test-at-point
    "B" 'alchemist-mix-test-this-buffer
    "L" 'alchemist-mix-rerun-last-test
    "z" 'wc/projectile-shell-pop
    "g" 'git-timemachine
    ))


;; Evil Match-it
(use-package evil-matchit
  :ensure t
  :commands (global-evil-matchit-mode))


;; Evil Surround
(use-package evil-surround
  :ensure t
  :commands (global-evil-surround-mode))


;; Flycheck Mix Settings
(use-package flycheck-mix
  :ensure t
  :init
  (flycheck-mix-setup))


;; Flycheck
(use-package flycheck
  :ensure t
  :config)
  ;; (setq flycheck-display-errors-function 'ignore))


;; Flycheck Credo Settings
(use-package flycheck-credo
  :ensure t
  :init
  (flycheck-credo-setup))


;; Popwin Settings
(use-package popwin
  :ensure t
  :config
  (setq display-buffer-function 'popwin:display-buffer)
  (setq helm-split-window-preferred-function 'ignore)
  (push '("^\*helm-.+\*$" :regexp t) popwin:special-display-config))


;; Alchemist Settings
(use-package alchemist
  :ensure t
  :config
  (setq alchemist-mix-env "prod")
  (setq alchemist-goto-elixir-source-dir "~/source_code/elixir/")
  (setq alchemist-goto-erlang-source-dir "~/source_code/otp/"))


(add-hook 'erlang-mode-hook 'wc/custom-erlang-mode-hook)


;; NeoTree Settings
(use-package neotree
  :ensure t
  :bind (:map neotree-mode-map
              ("j" . next-line)
              ("k" . previous-line)
              ("g" . beginning-of-buffer)
              ("G" . end-of-buffer)
              ("<return>" . neotree-enter)
              ([tab] . neotree-enter)
              ("D" . neotree-delete-node)
              ("R" . neotree-rename-node)
              ("c" . neotree-create-node)
              ("C-p" . helm-ag-neotree-node))
  :init
  (hl-line-mode)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (setq-default neo-show-hidden-files t))


;; Whitespace Settings
(use-package whitespace
  :ensure t
  :commands (whitespace-mode)
  :config
  (setq whitespace-line-column 100)
  (setq whitespace-style '(face lines-tail)))


;; Helm Settings
(use-package helm
  :ensure t
  :commands (helm-mode)
  :bind (("M-x" . helm-M-x)
         ("M-y" . helm-show-kill-ring)
         ("C-x b" . helm-mini)
         ("C-x f" . helm-projectile-switch-project)
         ("C-x p" . helm-projectile-ag)
         ("C-x C-f" . helm-find-files)

         :map helm-map
         ("C-j" . helm-next-line)
         ("C-k" . helm-previous-line)
         ("C-z" . helm-select-action)

         :term-raw-map
         ("M-x" . helm-M-x))
  :init
  (setq helm-buffers-fuzzy-matching t)
  (setq helm-recentf-fuzzy-match t)
  (setq helm-semantic-fuzzy-match t)
  (setq helm-imenu-fuzzy-match t)
  (setq helm-locate-fuzzy-match t)
  :config
  (load "~/.emacs.d/wc-helm-functions.el"))


;; Helm Projectile Settings
(use-package helm-projectile
  :ensure t)


;; Elm Mode
(use-package elm-mode
  :config
  (add-to-list 'company-backends 'company-elm))


;; Company Settings
(use-package company
  :bind (
         ("C-j" . company-select-next)
         ("C-k" . company-select-previous))
  :config
  (setq company-idle-delay 0))


(add-hook 'after-init-hook 'global-whitespace-mode)
(add-hook 'after-init-hook 'global-hl-line-mode)
(add-hook 'after-init-hook 'global-flycheck-mode)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'after-init-hook 'projectile-mode)
(add-hook 'after-init-hook 'helm-mode)
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; Scrolling Settings
(setq scroll-step 1)
(setq scroll-conservatively 10000)


;; Properly configure GUI Emacs to use $PATH values
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))


;; Emacs autosave, backup, interlocking files
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq create-lockfiles nil)


;; Automatically follow symlinks
(setq vc-follow-symlinks t)


;; Commenting / Uncommenting
(global-set-key (kbd "C-x C-;") 'comment-or-uncomment-region)


;; Window movements
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-l") 'windmove-right)
(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-j") 'windmove-down)


;; Fullscreen settings
(setq ns-use-native-fullscreen nil)
(global-set-key (kbd "<s-return>") 'toggle-frame-fullscreen)


;; General Settings
;; Hide the menu-bar
(if (string-equal system-type "gnu/linux") (menu-bar-mode -1)
  (if (string-equal system-type "darwin") (setq ns-auto-hide-menu-bar t)))


;; Native App Settings
(tool-bar-mode -1)

;; Disable GUI scrollbars
(when (display-graphic-p)
  (scroll-bar-mode -1))

;; Use spaces instead of tabs
(setq-default indent-tabs-mode nil)


;; Change font settings
(if (string-equal system-type "gnu/linux")
    (add-to-list 'default-frame-alist '(font . "Hack 9"))
  (if (string-equal system-type "darwin")
      (add-to-list 'default-frame-alist '(font . "Menlo 12"))))


;; Line Height
(setq-default line-spacing 4)


;; Default spaces indentation
(setq css-indent-offset 2)
(setq js-indent-level 2)
(setq sh-basic-offset 2)


;; Disable startup screen
(setq inhibit-startup-screen t)


;; Add transparency
(set-frame-parameter (selected-frame) 'alpha '(100 . 100))
(add-to-list 'default-frame-alist '(alpha . (100 . 100)))
(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)
