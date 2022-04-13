;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'display)
(require 'window-manager)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Monitor Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display-register primary
                  :output "HDMI-1"
                  :primary t
                  :coords (0 0)
                  :size (2560 1440)
                  :rate 30.0
                  :dpi 96
                  :rotate normal)

(display-register secondary
                  :output "HDMI-2"
                  :primary nil
                  :coords (2561 0)
                  :size (2560 1440)
                  :rate 30.0
                  :dpi 96
                  :rotate normal)

(display-arrangement main :displays (primary secondary))

(setq window-manager-named-workspaces
      (list (make-window-manager-named-workspace
             :label "Web Browsing"
             :kbd "c"
             :display display-secondary)
            (make-window-manager-named-workspace
             :label "Coding"
             :kbd "d"
             :display display-primary)
            (make-window-manager-named-workspace
             :label "Chatting"
             :kbd "h"
             :display display-secondary)))

(window-manager-init :init-hook #'display-arrange-main)
