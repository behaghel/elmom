;;; elmom.el --- Emacs Line Management with Org Mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Hubert Behaghel

;; Author: Hubert Behaghel <behaghel@gmail.com>
;; Version: 0.1
;; Package-Requires: ((mustache.el "0.24"))
;; Keywords: tools, convenience
;; URL: https://github.com/behaghel/elmom

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A package to support line managers with 360 feedback collection.

;;; Code:

;; XXX technically auto-insert could potentially avoid this external
;; dependency
(require 'mustache)

(setq reviews (make-hash-table :test 'equal))

(setq feedback-message "
Hi {{firstname}},

You have been working with my team, more specifically:
{{#reviewees}}
- {{firstname}} {{lastname}}{{#comment}}:{{comment}}{{/comment}}
{{/reviewees}}

I would like to ask you to share some feedback to support their
development. It's very important that you do.

I know you're busy so let me help you do it efficiently:
- you're extremely time poor or fear you won't get back to it: click
  reply and just input a number between 0 (under performer of the
  year) to 10 (role model). I may get in touch for a quick chat to
  collect more if I need.
- you are normally busy or not particularly inspired: name only one
  strength and only one weakness and send it to me.
- you really care for this colleague of ours: give me facts and
  stories trying to target what I may not know. Try to balance praises
  with growth opportunities.

Thank you,
")

;; TODO: retrieve these info from lm.org file
(setq newbie-comment "he has just joined but what a better time to start receiving feebdack?")
(setq team (list
             (list "Sam Christy" (list "Paul Dasan-Cutting" "Daniel Himsworth" "Steven Gonsalves") newbie-comment)
             (list "Amit Vij" (list "Daniel Louden" "Sam Barnes" "Michael George" "Kajal Padaria" "Jonathan Davies") newbie-comment)
             (list "Sam Barnes" (list "Karen Douglas" "Janos Nagy" "Christopher Mitchelmore" "Zak Finn" "Paul Hunter" "Oleg Narea") "Supporting our engineering communities is a new role both for Sam and M&S")
             (list "Stevie Gonsalves" (list "Christopher Mitchelmore" "Steven Warren" "Saurabh Sengupta" "Pradeep Venkata Krishnan" "David Han" "Kevin McGrane" "Tanya Odonovan" "Nick Barnes") nil)
             (list "Christopher Tomlinson" (list "Kirk Northrop" "Catherine Mullen" "Daniel Louden" "Steven Gonsalves" "Matteo Tomassetti" "Kevin McGrane") nil)
             (list "Christopher Mitchelmore" (list "Nick Barnes" "David Gillard" "Frank Long" "Sam Barnes" "Dilesh Mistry") nil)
             (list "Tim Searle" (list "Tom Moat" "Sebastien Thibert" "Ryan Mason-Davies" "Sam Sibbert" "Steven Gonsalves") "what development focus would you advise? More potential towards technical leadership? or people leadership?")
             (list "Steven Warren" (list "Peter Rostron" "Simon Reeves" "Tanya Odonovan" "Sam Barnes" "Simon Thornton" "Ginal Patel" "Colin Rogers" "Shiv Patel" "Aravind Rajaveeraswamy" "Siddarth Sharma" "Maheshkumar Pattusalli Janakiraman" "Levi Strange" "Jo Lacy" "Elaine Hawthorn" "Himanshu Khanna" "Laura Rogers" "Negar Farokhpey Tripepi") nil)
             ))

(defun first-name (name)
  (car (split-string name)))
(defun last-name (name)
  (mapconcat 'identity (cdr (split-string name)) " "))

(defun make-person-hash (fullname)
  (let ((ht (make-hash-table :test 'equal)))
    (puthash "firstname" (first-name fullname) ht)
    (puthash "lastname" (last-name fullname) ht)
    ht))

(defun make-reviewee-hash (fullname &optional comment)
  (let ((ht (make-person-hash fullname)))
    (puthash "comment" comment ht)
    ht))

(defun append-to-list-hashvalue (key value table)
  (puthash key (cons value (gethash-or-create key table (lambda () ()))) table))

(defun gethash-or-create (key table make-default)
  (let ((val (gethash key table)))
    (if (null val)
        (progn
          (puthash key (funcall make-default) table)
          (gethash key table))
      val)))

;; (json-read-from-string (json-encode reviews))

(defun compose-message (context to subject body)
  (let ((mu4e-compose-context-policy nil)
        (org-msg-greeting-fmt nil))
    (mu4e-context-switch t context)
    (compose-mail to subject)
    (org-msg-goto-body)
    (insert body)
    (message-goto-to)))

(defun populate-reviewers (reviewees)
  (dolist (mate-record reviewees)
    (let ((mate-name (car mate-record))
          (mate-reviewers (cadr mate-record))
          (mate-comment (caddr mate-record)))
      (dolist (reviewer mate-reviewers)
        (let ((reviewer-ht (gethash-or-create reviewer reviews
                                              (lambda () (make-person-hash reviewer)))))
          (append-to-list-hashvalue "reviewees" (make-reviewee-hash mate-name mate-comment) reviewer-ht))))))

(defun email-feedback (requests)
  (let ((compose (lambda (key value)
                   (compose-message "mns" key "Request for Feedback"
                                    (mustache-render feedback-message value)))))
    (maphash compose requests)))

;;;###autoload
(defun request-feedback ()
  (interactive)
  (email-feedback (populate-reviewers team)))

(provide 'elmom)
;;; elmom.el ends here