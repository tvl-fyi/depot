;;; ssh.el --- When working remotely -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "24"))

;;; Commentary:
;; Configuration to make remote work easier.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'tramp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: Is "ssh" preferable to "scp"?
(setq tramp-default-method "ssh")

;; Taken from: https://superuser.com/questions/179313/tramp-waiting-for-prompts-from-remote-shell
(setq tramp-shell-prompt-pattern "^[^$>\n]*[#$%>] *\\(\[[0-9;]*[a-zA-Z] *\\)*")

;; Sets the value of the TERM variable to "dumb" when logging into the remote
;; host. This allows me to check for the value of "dumb" in my shell's init file
;; and control the startup accordingly. You can see in the (shamefully large)
;; commit, 0b4ef0e, that I added a check like this to my ~/.zshrc. I've since
;; switched from z-shell to fish. I don't currently have this check in
;; config.fish, but I may need to add it one day soon.
(setq tramp-terminal-type "dumb")

;; Maximizes the tramp debugging noisiness while I'm still learning about tramp.
(setq tramp-verbose 10)

;; As confusing as this may seem, this forces Tramp to use *my* .ssh/config
;; options, which enable ControlMaster. In other words, disabling this actually
;; enables ControlMaster.
(setq tramp-use-ssh-controlmaster-options nil)

(defcustom ssh-hosts '("wpcarro@wpcarro.dev"
                       "foundation"
                       "edge")
  "List of hosts to which I commonly connect.")

(defun ssh-sudo-buffer ()
  "Open the current buffer with sudo rights."
  (interactive)
  (with-current-buffer (current-buffer)
    (if (s-starts-with? "/ssh:" buffer-file-name)
        (pcase (s-split ":" buffer-file-name)
          (`(,one ,two ,three) (find-file (format "/ssh:%s|sudo:%s:%s" two two three))))
        (find-file
         (s-join ":" (-insert-at 2 "|sudo" (s-split ":" buffer-file-name))))
      (find-file (format "/sudo::%s" buffer-file-name)))))

(defun ssh-cd-home ()
  "Prompt for an SSH host and open a dired buffer for wpcarro on that machine."
  (interactive)
  (let ((machine (completing-read "Machine: " ssh-hosts)))
    (find-file (format "/ssh:%s:~" machine))))

(provide 'ssh)
;;; ssh.el ends here
