;;; maybe.el --- Library for dealing with nil values -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "24"))

;;; Commentary:
;; Inspired by Elm's Maybe library.
;;
;; For now, a Nothing value will be defined exclusively as a nil value.  I'm
;; uninterested in supported falsiness in this module even at risk of going
;; against the LISP grain.
;;
;; I'm avoiding introducing a struct to handle the creation of Just and Nothing
;; variants of Maybe.  Perhaps this is a mistake in which case this file would
;; be more aptly named nil.el.  I may change that.  Because of this limitation,
;; functions in Elm's Maybe library like andThen, which is the monadic bind for
;; the Maybe type, doesn't have a home here since we cannot compose multiple
;; Nothing or Just values without a struct or some other construct.
;;
;; Possible names for the variants of a Maybe.
;; None    | Some
;; Nothing | Something
;; None    | Just
;; Nil     | Set
;;
;; NOTE: In Elisp, values like '() (i.e. the empty list) are aliases for nil.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Library
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun maybe-nil? (x)
  "Return t if X is nil."
  (null x))

(defun maybe-some? (x)
  "Return t when X is non-nil."
  (not (maybe-nil? x)))

(defun maybe-default (default x)
  "Return DEFAULT when X is nil."
  (if (maybe-nil? x) default x))

(defun maybe-map (f x)
  "Apply F to X if X is not nil."
  (if (maybe-some? x)
      (funcall f x)
    x))

(provide 'maybe)
;;; maybe.el ends here
