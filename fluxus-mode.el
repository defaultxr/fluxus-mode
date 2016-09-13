(require 'osc)

(defvar osc-host "127.0.0.1")
(defvar osc-port 34343)

(setf fluxus-client (osc-make-client osc-host osc-port))
(set-process-query-on-exit-flag fluxus-client nil)

(defvar fluxus-process nil
  "The Fluxus process.")

(with-eval-after-load "smartparens" ;; FIX
  ;; (sp-local-pair 'fluxus-mode "'" nil :actions :rem)
  ;; (sp-local-pair 'fluxus-mode "`" nil :actions :rem)
  )

(defun fluxus-start ()
  "Starts or restarts Fluxus."
  (interactive)
  (fluxus-stop)
  ;; (with-current-buffer (get-buffer-create "*Fluxus*")
  ;;   (erase-buffer))
  ;; (get-buffer-create "*Fluxus*")
  (setq fluxus-process (start-process "fluxus" "*Fluxus*" "/usr/bin/fluxus"))
  (with-current-buffer "*Fluxus*"
    (let ((window (display-buffer (current-buffer))))
      (goto-char (point-max))
      (save-selected-window
        (set-window-point window (point-max))
        ;; (set (make-local-variable 'scroll-conservatively) 1000) ;; FIX: this doesn't work for some reason.
        ))))
;; (fluxus-show)

(defun fluxus-stop ()
  "Stops Fluxus."
  (interactive)
  (when (process-live-p fluxus-process)
    (interrupt-process fluxus-process)
    (setq fluxus-process nil)
    (sit-for 0.5)))

(defun fluxus-show ()
  "Displays the Fluxus buffer."
  (interactive)
  (with-current-buffer "*Fluxus*"
    (let ((window (display-buffer (current-buffer))))
        (goto-char (point-max)))))

(defun fluxus-send (text)
  (osc-send-message fluxus-client "/code" text))

(defun current-task ()
  (car (split-string (buffer-name) "\\.")))
    
(defun fluxus-spawn-task ()
  "spawn the task named as the filename"
  (interactive)
  (osc-send-message fluxus-client "/spawn-task" (current-task)))

(defun fluxus-rm-task ()
  "remove the current task"
  (interactive)
  (osc-send-message fluxus-client "/rm-task" (current-task)))

(defun fluxus-rm-all-tasks ()
  "remove all tasks"
  (interactive)
  (osc-send-message fluxus-client "/rm-all-tasks" ""))     
    
(defun fluxus-send-region ()
  "Send a region to Fluxus."
  (interactive)
  (fluxus-send (buffer-substring-no-properties (region-beginning) (region-end))))

(defun fluxus-send-buffer ()
  "Send the current buffer to Fluxus."
  (interactive)
  (fluxus-send (buffer-substring-no-properties (point-min) (point-max))))

(defun fluxus-send-defun ()
  "Sends the current top-level form to Fluxus."
  (fluxus-send (buffer-substring-no-properties
                (save-excursion (forward-char) (beginning-of-defun) (point))
                (save-excursion (end-of-defun) (point)))))

(defun fluxus-send-dwim ()
  "Send the region to Fluxus. If the region isn't active, send the whole buffer."
  (interactive)
  (if (region-active-p)
      (fluxus-send-region)
    (fluxus-send-defun)))

(defun fluxus-load ()
  "loads the current file"
  (interactive)
  (osc-send-message fluxus-client "/load" buffer-file-name))

(defun fluxus-load-and-spawn ()
  "loads and spawns current file"
  (interactive)
  (fluxus-load)
  (fluxus-spawn-task))

(defun fluxus-send-via-shell (start end)
  (shell-command-on-region start end
                           (append "sendOSC -h " osc-host " " (number-to-string osc-port) " /code ")))

(defun osc-make-client (host port)
  (make-network-process
   :name "OSC client"
   :host host
   :service port
   :type 'datagram
   :family 'ipv4))

(defconst fluxus-keywords
  (regexp-opt
   '("start-audio" "colour" "vector" "gh" "gain"
     "build-cube" "build-sphere" "build-plane" "every-frame"
     "scale" "translate" "rotate" "with-state" "clear"
     "destroy" "with-primitive" "parent" "time" "delta"
     "texture" "opacity" "pdata-map!" "pdata-index-map!" "build-torus"
     "build-seg-plane" "build-cylinder" "build-polygons")
   'symbols))

(defvar fluxus-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<f5>") 'fluxus-load)
    (define-key map (kbd "<f6>") 'fluxus-spawn-task)
    (define-key map (kbd "<f7>") 'fluxus-rm-task)
    (define-key map (kbd "<f8>") 'fluxus-rm-all-tasks)
    (define-key map (kbd "<f10>") 'fluxus-send-region)
    (define-key map (kbd "C-c C-c") 'fluxus-send-dwim)
    (define-key map (kbd "C-c C-f") 'fluxus-send-buffer)
    (define-key map (kbd "C-c C-o") 'fluxus-start)
    (define-key map (kbd "C-c >") 'fluxus-show)
    map)
  "keymap for fluxus-mode")

(define-derived-mode fluxus-mode scheme-mode
  "Fluxus"
  "Fluxus mode."
  (font-lock-add-keywords nil `((,fluxus-keywords . 'font-lock-function-name-face))))
(add-to-list 'auto-mode-alist '("\\.flx\\'" . fluxus-mode))

(provide 'fluxus-mode)
