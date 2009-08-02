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

(in-package :blackthorn-physics)

(defclass game ()
  ((root
    :accessor game-root
    :initform nil)
   (view
    :accessor game-view
    :initform nil)
   (key-subscription
    :accessor key-subscription
    :initform (make-instance 'event-subscription))))

(defvar *game*)

(defgeneric init-game (game))
(defgeneric load-game (game))
(defgeneric save-game (game))

(defmethod init-game :after ((game game))
  (if (game-view game)
      (window (size (game-view game)))
      (warn "No view object for game ~a: Unable to initialize window.~%" game)))

(defmethod render ((game game))
  (with-slots (offset size) (game-view game)
    (gl:with-pushed-matrix
      (gl:ortho 0 (x size) (y size) 0 -1 1)
      (gl:translate (x offset) (y offset) 0)
      (render (game-root game)))))

(defgeneric update (object))

(defmethod update ((game game))
  (update (game-root game)))

(defmethod event-update ((game game))
  (event-update (game-root game)))

(defmethod handle-key-down ((game game) &rest initargs)
  (push-event (key-subscription game)
              (apply #'make-instance 'key-event :type 'key-down initargs)))

(defmethod handle-key-up ((game game) &rest initargs)
  (push-event (key-subscription game)
              (apply #'make-instance 'key-event  :type 'key-up initargs)))