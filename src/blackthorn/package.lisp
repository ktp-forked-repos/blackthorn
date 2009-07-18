;;;; Blackthorn -- Lisp Game Engine
;;;;
;;;; Copyright (c) 2007-2009, Elliott Slaughter <elliottslaughter@gmail.com>
;;;;
;;;; Permission is hereby granted, free of charge, to any person
;;;; obtaining a copy of this software and associated documentation
;;;; files (the "Software"), to deal in the Software without
;;;; restriction, including without limitation the rights to use, copy,
;;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;;; of the Software, and to permit persons to whom the Software is
;;;; furnished to do so, subject to the following conditions:
;;;;
;;;; Except as contained in this notice, the name(s) of the above
;;;; copyright holders shall not be used in advertising or otherwise to
;;;; promote the sale, use or other dealings in this Software without
;;;; prior written authorization.
;;;;
;;;; The above copyright notice and this permission notice shall be
;;;; included in all copies or substantial portions of the Software.
;;;;
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;;; NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;;; DEALINGS IN THE SOFTWARE.
;;;;

#+allegro (require :foreign)
#+allegro (require :osi)

;;;
;;; Package definitions
;;;

(in-package :cl-user)

(defpackage :blackthorn-graphics
  (:nicknames :blt-gfx)
  (:use :cl)
  (:export

   ;; graphics.lisp
   :image
   :size
   :x
   :y
   :render
   :unload-graphics
   :window

   ))

(defpackage :blackthorn-physics
  (:nicknames :blt-phys)
  (:use :cl :blt-gfx)
  (:export

   ;; game.lisp
   :game
   :game-root
   :game-view
   :init-game
   :load-game
   :save-game
   :*game*

   ;; component.lisp
   :component
   :offset
   :depth
   :size
   :parent
   :children
   :attach
   :dettach
   :render
   :sprite
   :image

   ))

(defpackage :blackthorn-user
  (:nicknames :blt-user)
  (:use :cl :blt-gfx :blt-phys)
  (:shadow :room)
  #+allegro (:import-from :cl-user :exit)
  (:export

   ;; main.lisp
   :main

   ))

#-allegro
(eval-when (:compile-toplevel :load-toplevel)
  (setf (symbol-function 'blt-user::exit) #'quit))