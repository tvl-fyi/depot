;;;  package.lisp --- backtracking parser package definition

;;;  Copyright (C) 2003-2006, 2009 by Walter C. Pelissero

;;;  Author: Walter C. Pelissero <walter@pelissero.de>
;;;  Project: NPG a Naive Parser Generator

#+cmu (ext:file-comment "$Module: package.lisp $")

;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public License
;;; as published by the Free Software Foundation; either version 2.1
;;; of the License, or (at your option) any later version.
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Lesser General Public License for more details.
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this library; if not, write to the Free
;;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
;;; 02111-1307 USA

(in-package :cl-user)

(defpackage :naive-parser-generator
  (:nicknames :npg)
  (:use :common-lisp)
  (:export
   #:parse				; The Parser
   #:reset-grammar
   #:generate-grammar
   #:print-grammar-figures
   #:grammar-keyword-p
   #:keyword
   #:grammar
   #:make-token
   #:token-value
   #:token-type
   #:token-position
   #:later-position
   #:defrule				; to define grammars
   #:deftoken				; to define a lexer
   #:input-cursor-mixin
   #:copy-input-cursor-slots
   #:dup-input-cursor
   #:read-next-tokens
   #:end-of-input
   #:? #:+ #:* #:or
   #:$vars #:$all #:$alist
   #:$1 #:$2 #:$3 #:$4 #:$5 #:$6 #:$7 #:$8 #:$9 #:$10))
