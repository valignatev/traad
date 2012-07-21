;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; traad.el --- emacs interface to the traad xmlrpc refactoring server.
;;
;; Author: Austin Bingham <austin.bingham@gmail.com>
;; Version: 0.1
;; URL: https://github.com/abingham/traad
;;
;; This file is not part of GNU Emacs.
;;
;; Copyright (c) 2012 Austin Bingham
;;
;; Description:
;;
;; traad is an xmlrpc server built around the rope refactoring library. This
;; file provides an API for talking to that server - and thus to rope - from
;; emacs lisp. Or, put another way, it's another way to use rope from emacs.
;;
;; For more details, see the project page at
;; https://github.com/abingham/traad.
;;
;; Installation:
;;
;; Make sure xml-rpc.el is in your load path. Check the emacswiki for more info:
;;
;;    http://www.emacswiki.org/emacs/XmlRpc
;;
;; Copy traad.el to some location in your emacs load path. Then add
;; "(require 'traad)" to your emacs initialization (.emacs,
;; init.el, or something). 
;; 
;; Example config:
;; 
;;   (require 'traad)
;;
;; License:
;;
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

(require 'xml-rpc)

(defvar traad-host "localhost.localdomain"
  "The host on which the traad server is running.")

(defvar traad-port 6942
  "The port on which the traad server is listening.")

(defun traad-get-all-resources ()
  (traad-call 'get_all_resources))

(defun traad-get-children (path)
  (traad-call 'get_children ""))

;(defmacro for (var from init to final do &rest body)
;       "Execute a simple for loop: (for i from 1 to 10 do (print i))."
;       `(let ((,var ,init)
;              (max ,final))
;          (while (<= ,var max)
;            ,@body
;            (inc ,var))))

(defmacro traad-call (func &rest args)
  `(xml-rpc-method-call (concat "http://" ,traad-host ":" (number-to-string ,traad-port))
			func ,@args))
;  (let* 
;   ((x (list xml-rpc-method-call
;	     (concat traad-host ":" (number-to-string traad-port))
;	     func))
;    (y (append x args)))
;   (print y)
;   (y)))

(provide 'traad)