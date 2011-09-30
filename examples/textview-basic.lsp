#!/usr/bin/newlisp

(load "../nl-abc-gtk.lsp")

(context 'TextViewBasic)

(setq win nil
      vbox nil
      buff nil)

(define (create-main-window)
  (setq win (Gtk:window-new GtkWindow:TOPLEVEL))
  (Gtk:apply-actions
   win '((title "TextView Basic Demonstration")
         (size-request 600 450)
         (border-width 3)
         (position 1))
   )
  )

(define (create-box)
  (setq vbox (Gtk:vbox-new nil 0))
  )

(define (create-text-view)
  (setq view (Gtk:textview-new))
  (setq buff (Gtk:get-buffer view))
  )

(define (create-styles , iter)
  (Gtk:create-tag buff "gap" "pixels_above_lines" 15)
  (Gtk:create-tag buff "lmarg" "left_margin" 5)
  (Gtk:create-tag buff "gray_bg" "background" "gray")
  (Gtk:create-tag buff "blue_fg" "foreground" "blue")
  (Gtk:create-tag buff "italic" "style" Pango:STYLE_ITALIC)
  (Gtk:create-tag buff "bold" "weight" Pango:WEIGHT_BOLD)
  )

(define (insert-text , iter)
  (setq iter (Gtk:get-iter-at-offset buff 0))
  (Gtk:insert-text buff iter "Plain text\\n" -1)
  (Gtk:insert-text buff iter "Left margin\\n" -1
                   "gap" "lmarg")
  (Gtk:insert-text buff iter "Look at these colors\\n" -1
                   "gray_bg" "lmarg" "blue_fg")
  (Gtk:insert-text buff iter "Styles\\n" -1
                   "italic" "gap" "bold")
  )

(define (pack-widgets)
  (Gtk:add-widget win vbox)
  (Gtk:pack-start vbox view true true 0)
  )

(define (main-loop , g-signal)
  (setq g-signal 0)
  (while (!= g-signal win)
    (setq g-signal (Gtk:get-signal)))
  ;; (Gtk:clean-up)
  (Gtk:server-exit)
  )

(Gtk:start-ipc)
(Gtk:init)

(create-main-window)
(create-text-view)
(create-box)
(create-styles)
(insert-text)
(pack-widgets)
(Gtk:show-all win)
(main-loop)

(context 'MAIN)
(exit)
