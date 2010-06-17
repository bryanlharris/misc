
;;; This is for GNU Emacs 22
(defun terminal-init-screen ()
  "Terminal initialization function for screen."
  ;; Use the xterm color initialization code.
  (load "term/xterm")
  (xterm-register-default-colors)
  (tty-set-up-initial-frame-faces))

;; (require 'auto-complete)
;; (require 'ispell)

;; (defvar ac-ispell-modes
;;   '(text-mode))

;; (defun ac-ispell-candidate ()
;; (if (memq major-mode ac-ispell-modes)
;; (let ((word (ispell-get-word nil "\\*")))
;;      (setq word (car word))
;;      (lookup-words (concat word "*") ispell-complete-word-dict))))

;; (defvar ac-source-ispell
;;   '((candidates . ac-ispell-candidate)
;;     (requires . 3))
;;   "Source for ispell.")

;; (provide 'auto-complete-ispell)

;; (add-to-list 'vc-handled-backends 'Git)
(setq load-path
      (append (list nil "~/.emacs.d/site-lisp")
              (list nil "/usr/local/share/emacs/site-lisp")
      load-path))

;;(require 'magit)
;; (require 'cssh)
;;(require 'dired-extension)
;;(setq ansi-term-color-vector [unspecified "black" "red3" "lime" "green" "yellow3" "DeepSkyBlue3" "magenta3" "cyan3" "white"])
;;(setq ansi-term-color-vector ["" "" "" "" "" "" "" "" ""])
;;[unspecified "#000000" "#963F3C" "#5FFB65" "#FFFD65"
;;"#0082FF" "#FF2180" "#57DCDB" "#FFFFFF"])
;; (setq
;;  ansi-term-color-vector [unspecified "black"
;;                                      "red"
;;                                      "green"
;;                                      "yellow"
;;                                      "blue"
;;                                      "magenta"
;;                                      "cyan"
;;                                      "white"]
;;  term-bold-attribute '(:weight normal)
;;  term-term-name "xterm")
(setq ansi-color-names-vector ; better contrast colors
      ["black" "red4" "green4" "yellow4"
       "blue3" "magenta4" "cyan4" "white"])

(defun refresh-file ()
  (interactive)
  (revert-buffer t t t)
  )
(defun open-terminal ()
  (interactive)
  (ansi-term "/bin/bash" "Terminal"))
(global-set-key [f5] 'refresh-file)
(global-set-key [f6] 'toggle-truncate-lines)
(global-set-key [f9] 'open-terminal)

(load "tail")

;(add-to-list 'load-path "~/.emacs.d/site-lisp")
;(load "ssh")

;;(defvar smart-tab-using-hippie-expand t)
;;(defun smart-tab (prefix)
;;  (interactive "P")
;;   (labels ((smart-tab-must-expand (&optional prefix)
;;                                   (unless (or (consp prefix)
;;                                               mark-active)
;;                                     (looking-at "\\_>"))))
;;           (cond ((minibufferp)
;;                  (minibuffer-complete))
;;                 ((smart-tab-must-expand prefix)
;;                  (if smart-tab-using-hippie-expand
;;                      (hippie-expand nil)
;;                    (dabbrev-expand nil)))
;;                 ((smart-indent)))))
;; (defun smart-indent ()
;;   (interactive)
;;   (if mark-active
;;       (indent-region (region-beginning)
;;                      (region-end))
;;     (indent-for-tab-command)))
;; (provide 'smart-tab)

;; Frame title bar formatting to show full path of file
(setq-default
 frame-title-format
 (list '((buffer-file-name " %f" (dired-directory 
	 			  dired-directory
				  (revert-buffer-function " %b"
				  ("%b - Dir:  " default-directory)))))))

(defun reload-dot-emacs ()
  (interactive)
  (let ((dot-emacs "~/.emacs"))
    (and (get-file-buffer dot-emacs)
         (save-buffer (get-file-buffer dot-emacs)))
    (load-file dot-emacs))
  (message "Done!"))

(require 'ido)
(ido-mode t)

(setq ido-execute-command-cache nil)
(defun ido-execute-command ()
  (interactive)
  (call-interactively
   (intern
    (ido-completing-read
     "M-x "
     (progn
       (unless ido-execute-command-cache
         (mapatoms (lambda (s)
                     (when (commandp s)
                       (setq ido-execute-command-cache
                             (cons (format "%S" s) ido-execute-command-cache))))))
       ido-execute-command-cache)))))
(add-hook 'ido-setup-hook
          (lambda ()
            (setq ido-enable-flex-matching t)
            (global-set-key "\M-x" 'ido-execute-command)))

(setq x-select-enable-clipboard t)
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
;; To tabify do this:
;; C-x h
;; M-x indent-region

(setq org-agenda-window-setup 'current-window)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

(defun wicked/org-update-checkbox-count (&optional all)
  "Update the checkbox statistics in the current section.
This will find all statistic cookies like [57%] and [6/12] and update
them with the current numbers.  With optional prefix argument ALL,
do this for the whole buffer."
  (interactive "P")
  (save-excursion
    (let* ((buffer-invisibility-spec (org-inhibit-invisibility))
           (beg (condition-case nil
                    (progn (outline-back-to-heading) (point))
                  (error (point-min))))
           (end (move-marker
                 (make-marker)
                 (progn (or (outline-get-next-sibling) ;; (1)
                            (goto-char (point-max)))
                        (point))))
           (re "\\(\\[[0-9]*%\\]\\)\\|\\(\\[[0-9]*/[0-9]*\\]\\)")
           (re-box
            "^[ \t]*\\(*+\\|[-+*]\\|[0-9]+[.)]\\) +\\(\\[[- X]\\]\\)")
           b1 e1 f1 c-on c-off lim (cstat 0))
      (when all
        (goto-char (point-min))
        (or (outline-get-next-sibling) (goto-char (point-max))) ;; (2)
        (setq beg (point) end (point-max)))
      (goto-char beg)
      (while (re-search-forward re end t)
        (setq cstat (1+ cstat)
              b1 (match-beginning 0)
              e1 (match-end 0)
              f1 (match-beginning 1)
              lim (cond
                   ((org-on-heading-p)
                    (or (outline-get-next-sibling) ;; (3)
                        (goto-char (point-max)))
                    (point))
                   ((org-at-item-p) (org-end-of-item) (point))
                   (t nil))
              c-on 0 c-off 0)
        (goto-char e1)
        (when lim
          (while (re-search-forward re-box lim t)
            (if (member (match-string 2) '("[ ]" "[-]"))
                (setq c-off (1+ c-off))
              (setq c-on (1+ c-on))))
          (goto-char b1)
          (insert (if f1
                      (format "[%d%%]" (/ (* 100 c-on)
                                          (max 1 (+ c-on c-off))))
                    (format "[%d/%d]" c-on (+ c-on c-off))))
          (and (looking-at "\\[.*?\\]")
               (replace-match ""))))
      (when (interactive-p)
        (message "Checkbox statistics updated %s (%d places)"
                 (if all "in entire file" "in current outline entry")
                 cstat)))))
(defadvice org-update-checkbox-count (around wicked activate)
  "Fix the built-in checkbox count to understand headlines."
  (setq ad-return-value
        (wicked/org-update-checkbox-count (ad-get-arg 1))))
(defvar count-words-buffer
  nil
  "*Number of words in the buffer.")
(defun wicked/update-wc ()
  (interactive)
  (setq count-words-buffer (number-to-string (count-words-buffer)))
  (force-mode-line-update))
                                        ; only setup timer once
(unless count-words-buffer
  ;; seed count-words-paragraph
  ;; create timer to keep count-words-paragraph updated
  (run-with-idle-timer 1 t 'wicked/update-wc))
;; add count words paragraph the mode line
(unless (memq 'count-words-buffer global-mode-string)
  (add-to-list 'global-mode-string "words: " t)
  (add-to-list 'global-mode-string 'count-words-buffer t))
;; count number of words in current paragraph
(defun count-words-buffer ()
  "Count the number of words in the current paragraph."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((count 0))
      (while (not (eobp))
        (forward-word 1)
        (setq count (1+ count)))
      count)))
(setq org-agenda-exporter-settings
      '((ps-number-of-columns 2)
        (ps-landscape-mode t)
        (org-agenda-add-entry-text-maxlines 5)
        (htmlize-output-type 'css)))

(defvar find-file-sqltest-prefix "/sudo:sqltest@localhost:")
(defvar find-file-sqltest-history nil)
(defvar find-file-sqltest-hook nil)
(defun find-file-sqltest ()
  (interactive)
  (require 'tramp)
  (let* ((file-name-history find-file-sqltest-history)
         (name (or buffer-file-name default-directory))
         (tramp (and (tramp-tramp-file-p name)
                     (tramp-dissect-file-name name)))
         path dir file)
    (when tramp
      (setq path (tramp-file-name-path tramp)
            dir (file-name-directory path)))
    (when (setq file (read-file-name "Find file (sqltest): " dir path))
      (find-file (concat find-file-sqltest-prefix file))
      (setq find-file-sqltest-history file-name-history)
      (run-hooks 'find-file-sqltest-hook))))
(global-set-key [(control x) (control r)] 'find-file-sqltest)

(transient-mark-mode 1)
(setq next-screen-context-lines 35)
(setq woman-use-own-frame nil)
(setq comint-completion-autolist nil)
(setq backup-inhibited t)
(setq auto-save-default nil)
(set-default 'truncate-lines t)
(setq scroll-step 1)
(global-unset-key "\C-z")
(blink-cursor-mode -1)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(setq initial-frame-alist
      (cons '(cursor-type . bar)
            (copy-alist initial-frame-alist)
            )
      )
(setq default-frame-alist
      (cons '(cursor-type . bar)
            (copy-alist default-frame-alist)
            )
      )
(custom-set-faces
 '(default ((t (:stipple nil :background "black" :foreground "grey90" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :family "adobe-courier")))))
(setq default-frame-alist
      (cons
       '(cursor-color      . "grey90")
       default-frame-alist))


(standard-display-ascii ?\200 [15])
(standard-display-ascii ?\201 [21])
(standard-display-ascii ?\202 [24])
(standard-display-ascii ?\203 [13])
(standard-display-ascii ?\204 [22])
(standard-display-ascii ?\205 [25])
(standard-display-ascii ?\206 [12])
(standard-display-ascii ?\210 [23])
(standard-display-ascii ?\211 [14])
(standard-display-ascii ?\212 [18])
(standard-display-ascii ?\214 [11])
(standard-display-ascii ?\222 [?\'])
(standard-display-ascii ?\223 [?\"])
(standard-display-ascii ?\224 [?\"])
(standard-display-ascii ?\227 " -- ")

(set-default-font "-adobe-courier-medium-r-normal--18-180-75-75-m-110-iso10646-1")

(put 'narrow-to-region 'disabled nil)
