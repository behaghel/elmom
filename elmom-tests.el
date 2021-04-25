;;; elmom-tests.el ---Emacs Line Management with Org Mode tests  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Hubert Behaghel

;; Author: Hubert Behaghel <hubert.behaghel@marks-and-spencer.com>
;; Keywords:

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

;; Testing is doubting.

;;; Code:

(require 'ert)
(require 'elmom)

(ert-deftest first-name-test ()
  (should (equal (first-name "John Doe") "John")))

(provide 'elmom-tests)
;;; elmom-tests.el ends here
