#!/usr/bin/newlisp

(context 'WindowWithButton)

(load "../nl-abc-gtk.lsp")

(Gtk:start-ipc)
(Gtk:init)

(setq main-win (Gtk:window-new GtkWindow:TOPLEVEL))
(Gtk:title main-win "Window With One Button")
(Gtk:size-request main-win 500 350)
(Gtk:border-width main-win 5)
(println "Main window's border width: " (Gtk:border-width main-win))
(Gtk:position main-win GtkWindow:POS_CENTER)

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