;;; wrapper of gtk-server for newlisp

;;; list of all widgets
(new Tree 'GtkWidgetList)
(global 'GtkWidgetList)

(context 'Gtk)

;;;
;;; constants
;;;

;;; Gtk in general

(define *max-tags* 8)

(define Gtk:EXPAND                      (<< 1 0))
(define Gtk:SHRINK                      (<< 1 1))
(define Gtk:FILL                        (<< 1 2))

(define Gtk:MESSAGE_INFO                0)
(define Gtk:MESSAGE_WARNING             1)
(define Gtk:MESSAGE_QUESTION            2)
(define Gtk:MESSAGE_ERROR               3)
(define Gtk:MESSAGE_OTHER               4)

(define Gtk:BUTTONS_NONE                0)
(define Gtk:BUTTONS_OK                  1)
(define Gtk:BUTTONS_CLOSE               2)
(define Gtk:BUTTONS_CANCEL              3)
(define Gtk:BUTTONS_YES_NO              4)
(define Gtk:BUTTONS_OK_CANCEL           5)

;;; GtkWindow

(define GtkWindow:TOPLEVEL              0)

(define GtkWindow:POS_NONE              0)
(define GtkWindow:POS_CENTER            1)
(define GtkWindow:POS_MOUSE             2)
(define GtkWindow:POS_CENTER_ALWAYS     3)
(define GtkWindow:POS_CENTER_ON_PARENT  4)

;;; Pango

(define Pango:STYLE_NORMAL              0)
(define Pango:STYLE_OBLIQUE             1)
(define Pango:STYLE_ITALIC              2)

(define Pango:WEIGHT_THIN               100)
(define Pango:WEIGHT_ULTRALIGHT         200)
(define Pango:WEIGHT_LIGHT              300)
(define Pango:WEIGHT_BOOK               380)
(define Pango:WEIGHT_NORMAL             400)
(define Pango:WEIGHT_MEDIUM             500)
(define Pango:WEIGHT_SEMIBOLD           600)
(define Pango:WEIGHT_BOLD               700)
(define Pango:WEIGHT_ULTRABOLD          800)
(define Pango:WEIGHT_HEAVY              900)
(define Pango:WEIGHT_ULTRAHEAVY         1000)

;;;
;;; high level manipulations
;;;

;;; apply a list of actions using just one functions
(define (apply-actions obj actions (cont "")  obj-bak name arguments)
  (setq obj-bak obj)
  (dolist (pair actions)
    (setq obj obj-bak)
    ;; (println "Function: " (sym (append cont (term (pair 0))))
    ;;          " -> " (cons obj (map eval (1 pair))))
    ;; (println (eval 'Gtk:title))
    (setq name (eval (sym (append cont (term (pair 0))))))
    (setq arguments (cons obj (map eval (1 pair))))
    ;; (println "Gonna do: " name " " arguments)
    (apply name arguments)))

;;;
;;; initialization
;;;

(define (start-ipc)
  (! "gtk-server -ipc=1 -detach"))

;;; low level calling for gtk-server
(define (gtk)
  (letn ((ensure-args (map (fn (x)
                             (if (= true x) "1"
                                 (= nil x) "0"
                                 (string x))) (args)))
         (msg (append "gtk-server msg=1,\""
                      (join ensure-args " ") "\"")))
    ;; uncomment ONE following line for debugging purpose
    (println ">> sending: " msg)

    (catch (exec msg) 'obj)
    (if obj (first obj) '())))

(define (init)
  (gtk "gtk_init NULL NULL"))

(define (server-exit)
  (clean-up)
  (gtk "gtk_server_exit"))

;;; determine widget type based on its initialization
(define (type widget new-type)
  (println "-- type: " widget " -> " new-type)
  (if new-type (GtkWidgetList (string widget) new-type)
      (GtkWidgetList (string widget))))

;;; register a signal with gtk-server; whenever the mainloop emits
;;; this signal, you would receive your predefined string as the id.
(define (reg-signal widget signal-name str-id)
  (println (append "gtk_server_connect" widget signal-name str-id))
  (gtk "gtk_server_connect" widget signal-name str-id))

;;; get the emitted signal as a string
(define (get-signal (arg "WAIT"))
  (gtk "gtk_server_callback" arg))

;;;
;;; helpers
;;;

(define (repeat value number)
  (if (string? value) (flat (dup (list value) number))
      (dup value number)))

(define (fill the-array with-value til-length , remain)
  (setq remain (- til-length (length the-array)))
  (append the-array (repeat with-value remain)))

(define (quote-string s)
  (if s (append "'" s "'")
      "0"))

;;;
;;; gtk-server intenals, use this with care
;;;

(define (opaque , obj)
  (setq obj (gtk "gtk_server_opaque"))
  (setq obj (obj 0))
  (type obj "gtk_server_opaque")
  obj)

(define (free obj)
  (gtk "g_free" obj))

(define (clean-up , saved)
  (setq saved (filter (fn (x)
                        (= "gtk_server_opaque" (x 1)))
                      (GtkWidgetList)))
  (setq saved (map first saved))
  (map (fn (x)
         (println ">> debug => clean-up => cleaning " x)
         (free x)
         (GtkWidgetList x nil)) saved))

;;;
;;; Objects
;;;

;;;
;;; GtkWidget
;;;

(define (show-all widget)
  (gtk "gtk_widget_show_all" widget))

(define (size-request widget (width 500) (height 400))
  (gtk "gtk_widget_set_size_request" widget
       (string width) (string height)))

(define (Gtk:destroy widget , ret)
  (setq ret (gtk "gtk_widget_destroy" widget))
  (GtkWidgetList widget nil))

(define Gtk:widget-destroy Gtk:destroy)

;;;
;;; GtkContainer
;;;

(define (border-width widget border)
  (if border (gtk "gtk_container_set_border_width" widget border)
      (gtk "gtk_container_get_border_width" widget)))

(define (add-widget parent child)
  (gtk "gtk_container_add" parent child))

(define Gtk:add add-widget)

;;;
;;; GtkBox
;;;

(define (vbox-new homogeneous spacing)
  (gtk "gtk_vbox_new" homogeneous spacing))

(define (hbox-new homogeneous spacing)
  (gtk "gtk_hbox_new" homogeneous spacing))

(define (pack-start box child (expand? true) (fill? true) (padding 0))
  (gtk "gtk_box_pack_start" box child expand? fill? padding))

(define (pack-end box child (expand? true) (fill? true) (padding 0))
  (gtk "gtk_box_pack_end" box child expand? fill? padding))

(define (pack-start-defaults box)
  (dolist (child (args))
    (gtk "gtk_box_pack_start_defaults" box child)))

(define (pack-end-defaults box)
  (dolist (child (args))
    (gtk "gtk_box_pack_end_defaults" box child)))

;;;
;;; GtkTable
;;;

(define (table-new rows cols (homogeneous true) , table)
  (setq table (gtk "gtk_table_new" rows cols homogeneous))
  (type table "gtk_table")
  table)

(define (row-spacings table (new-value 3))
  (gtk "gtk_table_set_row_spacings" new-value))

(define (col-spacings table (new-value 3))
  (gtk "gtk_table_set_col_spacings" new-value))

(define (attach table child left right top bottom
                x-opts y-opts x-padding y-padding)
  (gtk "gtk_table_attach" table child left right top bottom
       x-opts y-opts x-padding y-padding))

(define (attach-defaults table child left right top bottom)
  (attach table child left right top bottom
          (| Gtk:FILL Gtk:EXPAND) (| Gtk:FILL Gtk:EXPAND) 0 0))

;;;
;;; GtkWindow
;;;

(define (window-new (arg 0) , window)
  (setq window (gtk "gtk_window_new" (string arg)))
  (type window "gtk_window")
  window)

;;; get and set title
(define (title widget new-title , widget-type)
  (setq widget-type (type widget))
  (if (= widget-type "gtk_message_dialog") (setq widget-type "gtk_window"))

  (if new-title (gtk (append widget-type "_set_title") widget
                     (quote-string new-title))
      (gtk (append widget-type "_get_title") widget)))

(define (position widget pos)
  (if pos (gtk "gtk_window_set_position" widget pos)
      (gtk "gtk_window_get_position" widget)))

;;;
;;; GtkButton
;;;

(define (button-new mnemonic , button)
  (if mnemonic (setq button (gtk "gtk_button_new_with_mnemonic" mnemonic))
      (setq button (gtk "gtk_button_new")))
  (type button "gtk_button")
  button)

(define (button-new-with-label label , button)
  (setq button (gtk "gtk_button_new_with_label" label))
  (type button "gtk_button")
  button)

;;;
;;; GtkDialog
;;;

(define (dialog-run dialog)
  (gtk "gtk_dialog_run" dialog))

;;;
;;; GtkMessageDialog
;;;

(define (message-dialog-new parent flags type buttons msg (arg ""))
  (local (widget)
    (setq widget (gtk "gtk_message_dialog_new" parent flags type buttons
                   (quote-string msg) (quote-string arg)))
    (GtkWidgetList widget "gtk_message_dialog")
    (type widget "gtk_message_dialog")  # WHAT'S WRONG?????
    widget))

;;;
;;; GtkTextBuffer
;;;

(define (create-tag buffer name key value null , ret)
  ;; the tricky part is when your value is STRING, not INT (by
  ;; default); so we have to redefine the function
  (if (string? value)
      (begin
        (setq value (quote-string value))
        (gtk "gtk_server_redefine"
             "gtk_text_buffer_create_tag NONE WIDGET 5 WIDGET STRING STRING STRING NULL")))
  (setq ret (gtk "gtk_text_buffer_create_tag"
                 buffer name key value null))
  (gtk "gtk_server_redefine"
       "gtk_text_buffer_create_tag NONE WIDGET 5 WIDGET STRING STRING INT NULL")
  ret)

(define (insert-text buffer iter text (len -1))
  (setq text (quote-string text))
  ;; maximum tags allow: 3
  (let ((tags "")
        (widget-type (type buffer)))

    ;; if insert text with tags, fill the rest with the first tag and
    ;; end them with nil
    (when (args)
      (setq tags (fill (args) ((args) 0) *max-tags*))
      (push "0" tags -1)
      (setq tags (join (map quote-string tags) " ")))
    ;; (println "-- debug: insert-text => tags: " tags)

    (if (= nil iter)
        ;; insert at current cursor
        (gtk (append widget-type "_insert_at_cursor")
             buffer text len)

        (zero? (length (args)))
        ;; no styles
        (gtk (append widget-type "_insert")
             buffer iter text len)

        ;; with styles/tags
        (gtk (append widget-type "_insert_with_tags_by_name")
             buffer iter text len tags))))

;;;
;;; GtkTextIter
;;;

(define (get-iter-at-offset buffer offset , iter)
  (setq iter (opaque))
  (println "-- debug: [iter] " iter)
  (gtk (append (type buffer) "_get_iter_at_offset")
       buffer iter offset)
  iter)

;;;
;;; GtkTextView
;;;

(define (textview-new , view)
  (setq view (gtk "gtk_text_view_new"))
  (type view "gtk_text_view")
  view)

(define (get-buffer obj , buffer)
  (setq buffer (gtk (append (type obj) "_get_buffer") obj))
  (type buffer "gtk_text_buffer")
  buffer)

(context 'MAIN)
