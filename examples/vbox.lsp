#!/usr/bin/newlisp

(context 'GtkWithVBox)

(load "../nl-abc-gtk.lsp")

(Gtk:start-ipc)
(Gtk:init)

;;; widgets

(setq win (Gtk:window-new GtkWindow:TOPLEVEL))
(Gtk:apply-actions win
                   '((title "Window with a vbox")
                     (size-request 500 350)
                     (border-width 5)
                     (position GtkWindow:POS_CENTER)))

(setq vbox (Gtk:vbox-new nil 3))

(setq hello-button (Gtk:button-new "Say _Hello!"))
(setq quit-button (Gtk:button-new "_Quit"))

;;; packing

(Gtk:add-widget win vbox)
(Gtk:pack-start-defaults vbox hello-button quit-button)

;;; show and do main loop

(Gtk:show-all win)

(setq g-signal 0)
(while (!= g-signal win)
  (setq g-signal (Gtk:get-signal))
  (if (= g-signal hello-button) (println "Hello, world!")
      (= g-signal quit-button) (setq g-signal win)))

(Gtk:server-exit)

(context 'MAIN)
(exit)
