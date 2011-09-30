#!/usr/bin/newlisp

(load-unittest)
(load-abc-gtk)

(context 'Gtk)

(define-test (test_apply-actions)
  (local (func1 func2 func3)
    (setq func1 (fn (x) (string x)))
    (setq func2 (fn () (join (map string (args)) " ")))
    (setq func3 (fn (x y) (+ x y)))

    (assert= 22
             (apply-actions 1 '((func1 10)
                                (func2 "a" "b" "c")
                                (func3 21))))
    (assert= "10 a b c"
             (apply-actions 10 '((func1 10)
                                 (func3 20)
                                 (func2 "a" "b" "c"))))
    (assert= "10"
             (apply-actions 10 '((func1 10))))
    ))

(define-test (test_repeat)
  (assert= '(1 1 1) (repeat 1 3))
  (assert= '("a" "a" "a" "a") (repeat "a" 4)))

(define-test (test_fill)
  (assert= '(1 1 1 1 1) (fill '() 1 5))
  (assert= '(1 " " " " " " " ") (fill '(1) " " 5))
  )

(define-test (test_type)
  (Gtk:type "a" "10")
  (assert= "10" (Gtk:type "a")))

(UnitTest:run-all 'Gtk)

(context 'MAIN)
(exit)
