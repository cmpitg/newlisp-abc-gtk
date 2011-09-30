#!/usr/bin/newlisp

(context 'GtkVerySimple)

(load "../nl-abc-gtk.lsp")

(Gtk:start-ipc)
(Gtk:init)

(setq main-win (Gtk:window-new GtkWindow:TOPLEVEL))
(Gtk:show-all main-win)
(Gtk:title main-win "Hello world")
(Gtk:size-request main-win 500 350)

;;; mainloop
(setq gtk-signal 0)
(while (!= gtk-signal main-win)
  (setq gtk-signal (Gtk:get-signal))
  (println "Caught: " gtk-signal))

(Gtk:server-exit)

(context 'MAIN)
(exit)
