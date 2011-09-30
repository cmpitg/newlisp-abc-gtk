#!/usr/bin/newlisp

(load "../nl-abc-gtk.lsp")

(context 'Dialogs)

(define (main)
  (Gtk:start-ipc)
  (Gtk:init)

  (create-widgets)
  (pack-widgets)
  (signals-register)
  (show-widgets)

  (main-loop))

;;;
;;; define some widgets
;;;

(setq win nil
      tab nil
      info-button nil
      warn-button nil
      err-button nil
      ques-button nil)

(define (create-widgets)
  (create-window)
  (create-table)
  (create-buttons))

(define (create-window)
  (setq win (Gtk:window-new GtkWindow:TOPLEVEL))
  (Gtk:apply-actions
      win '((title "Dialogs Demonstration")
            (size-request 400 350)
            (border-width 3)
            (position GtkWindow:POS_CENTER))))

(define (create-table)
  (setq tab (Gtk:table-new 2 2 true))
  (Gtk:apply-actions
      tab '((row-spacings 2)
            (col-spacings 2))))

(define (create-buttons)
  (setq info (Gtk:button-new "_Information")
        warn (Gtk:button-new "_Warn")
        ques (Gtk:button-new "_Question")
        err  (Gtk:button-new "_Error")))

(define (show-widgets)
  (Gtk:show-all win))

(define (pack-widgets)
  (Gtk:add win tab)

  (Gtk:attach tab info 0 1 0 1 Gtk:FILL Gtk:FILL 3 3)
  (Gtk:attach tab warn 1 2 0 1 Gtk:FILL Gtk:FILL 3 3)
  (Gtk:attach tab ques 0 1 1 2 Gtk:FILL Gtk:FILL 3 3)
  (Gtk:attach tab err  1 2 1 2 Gtk:FILL Gtk:FILL 3 3))

(define (signals-register)
  _)

(define (show-info , dialog)
  (setq dialog
        (Gtk:message-dialog-new win
                                GtkDialog:DESTROY_WITH_PARENT
                                Gtk:MESSAGE_INFO Gtk:BUTTONS_OK
                                "Download Completed"))
  (process-dialog dialog "Information"))

(define (show-warn , dialog)
  (setq dialog
        (Gtk:message-dialog-new win
                                GtkDialog:DESTROY_WITH_PARENT
                                Gtk:MESSAGE_WARNING Gtk:BUTTONS_OK
                                "Warning!"))
  (process-dialog dialog "Warning"))

(define (show-ques , dialog)
  (setq dialog
        (Gtk:message-dialog-new win
                                GtkDialog:DESTROY_WITH_PARENT
                                Gtk:MESSAGE_QUESTION Gtk:BUTTONS_YES_NO
                                "Are you sure you want to continue?"))
  (println "Received: " (process-dialog dialog "Question")))

(define (show-err , dialog)
  (setq dialog
        (Gtk:message-dialog-new win
                                GtkDialog:DESTROY_WITH_PARENT
                                Gtk:MESSAGE_ERROR Gtk:BUTTONS_CLOSE
                                "An unexpected error has occurred!!!"))
  (process-dialog dialog "Error"))

(define (process-dialog dialog title , res)
  (Gtk:title dialog title)
  (setq res (Gtk:dialog-run dialog))
  (Gtk:destroy dialog)
  res)

(define (main-loop , g-signal)
  (setq g-signal 0)
  (while (!= g-signal win)
    (setq g-signal (Gtk:get-signal))

    (if (= g-signal info) (show-info)
        (= g-signal warn) (show-warn)
        (= g-signal ques) (show-ques)
        (= g-signal err)  (show-err)
        )
    )
  (Gtk:server-exit)
  )

;;;
;;; main program
;;;

(main)

(context 'MAIN)
(exit)
