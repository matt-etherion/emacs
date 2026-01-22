;; Basic init
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(show-paren-mode 1)
(setq line-number-display-limit nil)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)
(setq byte-compile-warnings nil)
(setq display-line-numbers-width 3)
(setq display-line-numbers-grow-only t)
(add-hook 'display-line-numbers-mode-hook
          (lambda ()
            (setq display-line-numbers-width 3)))

;; Core settings
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default standard-indent 2)
(electric-pair-mode 1)
(setq scroll-margin 3
  scroll-conservatively 101)

(when (member "Iosevka Nerd Font Mono" (font-family-list))
  (set-frame-font "Iosevka Nerd Font Mono 24" nil t))
(set-language-environment "UTF-8")

;; Package system
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(defvar my/packages-refreshed nil)

(defun ensure (pkg)
  (unless (package-installed-p pkg)
    (unless my/packages-refreshed
      (package-refresh-contents)
      (setq my/packages-refreshed t))
    (package-install pkg)))

;; Essentials
(ensure 'gruber-darker-theme)
(load-theme 'gruber-darker)
(ensure 'marginalia)
(ensure 'vertico)
(ensure 'orderless)
(ensure 'consult)
(ensure 'vterm)
(ensure 'move-text)

(vertico-mode 1)
(marginalia-mode 1)

(setq completion-styles '(orderless basic))

(setq whitespace-style '(face spaces tabs space-mark tabs tab-mark))
(add-hook 'prog-mode-hook #'whitespace-mode)

;; Utilities
(ensure 'multiple-cursors)
(ensure 'magit)

;; Custom Functions
(defun my/dired()
  "Open Dired in current dir fullscreened"
  (interactive)
  (dired default-directory))
(setq dired-listing-switches "-alh --group-directories-first")
(setq dired-kill-when-opening-new-dired-buffer t)
(put 'dired-find-alternative-file 'disabled nil)
(defun my/exec-in-term ()
  "Run the current executable in a bottom split using term-mode."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (unless (file-executable-p file)
      (error "%s is not executable" file))
    (let* ((buf-name (format "*term-%s*" (file-name-nondirectory file)))
           (win (split-window-vertically -15))
           (buf (get-buffer-create buf-name)))
      (set-window-buffer win buf)
      (with-selected-window win
        (term file)))))
(defun my/kill-function ()
  "Kill all buffers except the current one."
  (interactive)
  (mapc (lambda (buf)
          (unless (eq buf (current-buffer))
            (kill-buffer buf)))
        (buffer-list)))


;; Keybinds
(global-set-key (kbd "C-c d") #'my/dired)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c r") #'my/exec-in-term)
  (define-key dired-mode-map (kbd ".") #'dired-create-empty-file))
(global-set-key (kbd "C-c t") #'vterm)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)
(global-set-key (kbd "C-c c") #'compile)
(global-set-key (kbd "C-c f") #'consult-fd)
(global-set-key (kbd "C-c e") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c a") 'mc/mark-all-like-this)
(global-set-key (kbd "C-c k") #'my/kill-function)

(provide 'init)
