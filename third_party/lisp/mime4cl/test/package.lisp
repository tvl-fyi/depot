;;;  package.lisp --- package description for the regression tests

;;;  Copyright (C) 2006, 2009 by Walter C. Pelissero
;;;  Copyright (C) 2022 by The TVL Authors

;;;  Author: Walter C. Pelissero <walter@pelissero.de>
;;;  Project: mime4cl

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

(cl:in-package :common-lisp)

(defpackage :mime4cl-tests
  (:use :common-lisp
        :rtest :mime4cl :mime4cl-ex-sclf)
  (:export))
