#!/usr/bin/newlisp

(context 'WindowWithButton)

(load "../nl-abc-gtk.lsp")

(Gtk:start-ipc)
(Gtk:init)

(setq main-win (Gtk:window-new GtkWindow:TOPLEVEL))
(Gtk:apply-actions main-win
                   '((title "Window With One Button")
                     (size-request 500 350)
                     (border-width 5)
                     (position GtkWindow:POS_CENTER)))

(setq button (Gtk:button-new "_Say \"Hello world!\""))
(Gtk:reg-signal button "enter" "button-enter")

(Gtk:add-widget main-win button)
(Gtk:show-all main-win)

;;; mainloop
(setq g-signal 0)
(while (!= g-signal main-win)
  (setq g-signal (Gtk:get-signal))
  (if (= g-signal button) (println "Hello, world!")
      (println "Caught: " g-signal)))

(Gtk:server-exit)

(context 'MAIN)
(exit)
