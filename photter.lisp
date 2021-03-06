;;;; Name:    Photter IRC bot
;;;; Author:  Tamas Molnar - tmolnar0831@gmail.com
;;;; License: MIT

(defpackage :photter
  (:use "COMMON-LISP"
        "WEATHER-CHECKER"
        "API-KEY")
  (:export "MAIN"))
(in-package :photter)

(defparameter *version* "0.0.1")
(defvar *nick* "photter")
(defvar *server* "irc.freenode.net")
(defvar *channel* "#iron-bottest-room")
(defvar *connection*)

(defparameter about-text
  (format nil "IRC BOT ~A, maintained by st_iron." *nick*))

(defparameter help-text
    "Available commands: .weather <city>,[<ISO 3166 country code>]")

(defun say-to-channel (say)
  (irc:privmsg *connection* *channel* (princ-to-string say)))

(defun process-message-params (message)
  (split-sequence:split-sequence #\Space (first message)))

(defun issued-command (message)
  (first message))

(defun argument-vector (message)
  (rest message))

(defun msg-hook (message)
  (let ((arguments (last (irc:arguments message))))
    (handler-case
        (cond ((string-equal (issued-command (process-message-params arguments)) ".weather")
               (say-to-channel (return-answer (get-processed-output (first (argument-vector (process-message-params arguments)))))))
              ((string-equal (issued-command (process-message-params arguments)) ".help")
               (say-to-channel help-text))
              ((string-equal (issued-command (process-message-params arguments)) ".about")
               (say-to-channel about-text)))
      (error (err)
        (say-to-channel (format nil "Sorry, I got an error: ~A" err))))))

(defun main (&key ((:nick *nick*) *nick*))
  (setf *api-key* (load-api-key "openweathermap"))
  (setf *connection* (irc:connect :nickname *nick* :server *server*))
  (unwind-protect (progn
                    (irc:join *connection* *channel*)
                    (irc:add-hook *connection* 'irc:irc-privmsg-message 'msg-hook)
                    (irc:read-message-loop *connection*))
    (irc:quit *connection*)))

