;;; -*- lexical-binding: t; -*-

(require 'erc)
(require 'alert)

(defvar irc-servers
  '("hackint"
    "libera"))

(defun irc-connect (server)
  (interactive
   (list (ivy-read "Server: " irc-servers)))
  (let ((pw (s-trim (shell-command-to-string
                     (format "pass irccloud/%s" server))))
        (gnutls-verify-error nil))
    (erc-tls :server "bnc.irccloud.com"
             :port 6697
             :nick "grfn"
             :password (concat "bnc@"
                               (s-trim (shell-command-to-string "hostname"))
                               ":"
                               pw))))


(defgroup erc-alert nil
  "Alert me using alert.el for important ERC messages"
  :group 'erc)

(defcustom erc-noise-regexp
  "\\(Logging in:\\|Signing off\\|You're now away\\|Welcome back\\)"
  "This regexp matches unwanted noise."
  :type 'regexp
  :group 'erc)

(setq tvl-enabled? t)

(defun disable-tvl-notifications ()
  (interactive)
  (setq tvl-enabled? nil))

(defun enable-tvl-notifications ()
  (interactive)
  (setq tvl-enabled? t))

(defun erc-alert-important-p (info)
  (let ((message (plist-get info :message))
        (erc-message (-> info (plist-get :data) (plist-get :message)))
        (erc-channel (-> info (plist-get :data) (plist-get :channel))))
    (and erc-message
         (not (or (string-match "^\\** *Users on #" message)
                  (string-match erc-noise-regexp
                                message)))
         (or (and tvl-enabled?
                  (string-equal erc-channel "#tvl"))
             (string-match "grfn" message)))))

(comment
 last-info
 erc-noise-regexp
 (setq tvl-enabled? nil)
 )

(defun my-erc-hook (&optional match-type nick message)
  "Shows a notification, when user's nick was mentioned.
If the buffer is currently not visible, makes it sticky."
  (setq last-message message)
  (if (or (null match-type) (not (eq match-type 'fool)))
      (let (alert-log-messages)
        (alert (or message (buffer-string))
               :severity (if (string-match "grfn" (or message ""))
                             'high 'low)
               :title (or nick (buffer-name))
               :data `(:message ,(or message (buffer-string))
                                :channel ,(or nick (buffer-name)))))))

(add-hook 'erc-text-matched-hook 'my-erc-hook)
(add-hook 'erc-insert-modify-hook 'my-erc-hook)

(defun my-erc-define-alerts (&rest ignore)
  ;; Unless the user has recently typed in the ERC buffer, highlight the fringe
  (alert-add-rule
   :status   '(buried visible idle)
   :severity '(moderate high urgent)
   :mode     'erc-mode
   :predicate
   #'(lambda (info)
       (and (not (eq (current-buffer) (plist-get info :buffer)))
            (string-match "grfn:" (plist-get info :message))))
   :persistent
   #'(lambda (info)
       ;; If the buffer is buried, or the user has been idle for
       ;; `alert-reveal-idle-time' seconds, make this alert
       ;; persistent.  Normally, alerts become persistent after
       ;; `alert-persist-idle-time' seconds.
       (memq (plist-get info :status) '(buried idle)))
   :style 'message
   :continue t)

  (alert-add-rule
   :status 'buried
   :mode   'erc-mode
   :predicate #'erc-alert-important-p
   :style 'libnotify
   :append t)

  (alert-add-rule
   :status 'buried
   :mode   'erc-mode
   :predicate #'erc-alert-important-p
   :style 'message
   :append t)

  (alert-add-rule
   :mode 'erc-mode
   :predicate #'erc-alert-important-p
   :style 'log
   :append t)

  (alert-add-rule :mode 'erc-mode :style 'ignore :append t))

(add-hook 'erc-connect-pre-hook 'my-erc-define-alerts)

(defun fix-irc-message (msg)
  (let ((msg (s-trim msg)))
    (if (string-equal msg ":q") "" msg)))

(advice-add #'erc-user-input :filter-return #'fix-irc-message)

(comment
 (my-erc-define-alerts)
 )
