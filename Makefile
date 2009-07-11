#### Blackthorn -- Lisp Game Engine
####
#### Copyright (c) 2007-2009, Elliott Slaughter <elliottslaughter@gmail.com>
####
#### Permission is hereby granted, free of charge, to any person
#### obtaining a copy of this software and associated documentation
#### files (the "Software"), to deal in the Software without
#### restriction, including without limitation the rights to use, copy,
#### modify, merge, publish, distribute, sublicense, and/or sell copies
#### of the Software, and to permit persons to whom the Software is
#### furnished to do so, subject to the following conditions:
####
#### Except as contained in this notice, the name(s) of the above
#### copyright holders shall not be used in advertising or otherwise to
#### promote the sale, use or other dealings in this Software without
#### prior written authorization.
####
#### The above copyright notice and this permission notice shall be
#### included in all copies or substantial portions of the Software.
####
#### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#### EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#### MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#### NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#### HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#### WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#### OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#### DEALINGS IN THE SOFTWARE.
####

# Search PATH for a Lisp compiler.
ifneq ($(shell which alisp),)
	cl := allegro
else
ifneq ($(shell which sbcl),)
	cl := sbcl
else
ifneq ($(shell which clisp),)
	cl := clisp
else
ifneq ($(shell which ecl),)
	cl := ecl
else
ifneq ($(shell which ccl),)
	cl := clozure
else
	$(error No Lisp compiler found.)
endif
endif
endif
endif
endif

# Use no DB by default. (Valid options are store.)
db := store

# Which ASDF system to load:
system := blackthorn

# Stardard drivers:
prop := property.lisp
load := load.lisp
dist := dist.lisp
prof := profile.lisp
atdoc := atdoc.lisp

# Select which driver to run (load by default).
driver := ${load}

# Specify which game file to load (none by default).

mode := save
file := game.btg

# Specify the run command for the installer.
ifeq (${cl}, allegro)
	command := \\\"\\x24INSTDIR\\\\main.exe\\\"
else
	command := \\\"\\x24INSTDIR\\\\chp\\\\chp.exe\\\" \\\"\\x24INSTDIR\\\\main.exe\\\"
endif

# A temporary file for passing values around.
tempfile := .tmp

# A command which can be used to get an ASDF system property.
ifeq (${cl}, allegro)
	get-property = $(shell alisp +B +s ${prop} -e "(defparameter *driver-system* '|${system}|)" -e "(defparameter *output-file* \"${tempfile}\")" -e "(defparameter *output-expression* '$(1))")
else
ifeq (${cl}, sbcl)
	get-property = $(shell sbcl --eval "(defparameter *driver-system* \"${system}\")" --eval "(defparameter *output-file* \"${tempfile}\")" --eval "(defparameter *output-expression* '$(1))" --load ${prop})
else
ifeq (${cl}, clisp)
	get-property = $(shell clisp -x "(defparameter *driver-system* \"${system}\")" -x "(defparameter *output-file* \"${tempfile}\")" -x "(defparameter *output-expression* '$(1))" -x "(load \"${prop}\")")
else
ifeq (${cl}, ecl)
	get-property = $(shell ecl -eval "(defparameter *driver-system* \"${system}\")" -eval "(defparameter *output-file* \"${tempfile}\")" -eval "(defparameter *output-expression* '$(1))" -load ${prop})
else
ifeq (${cl}, clozure)
	get-property = $(shell ccl --eval "(defparameter *driver-system* \"${system}\")" --eval "(defparameter *output-file* \"${tempfile}\")" --eval "(defparameter *output-expression* '$(1))" --load ${prop})
endif
endif
endif
endif
endif

# Get ASDF system properties for the specified system.
define get-properties
	$(eval temp := $$(call get-property,(asdf:component-name *system*)))
	$(eval name := $$(shell cat $${tempfile}))
	$(eval temp := $$(call get-property,(or (asdf:component-property *system* :long-name) (asdf:component-name *system*))))
	$(eval longname := $$(shell cat $${tempfile}))
	$(eval temp := $$(call get-property,(asdf:component-version *system*)))
	$(eval version := $$(shell cat $${tempfile}))
	$(eval temp := $$(call get-property,(asdf:system-description *system*)))
	$(eval description := $$(shell cat $${tempfile}))
	$(eval temp := $$(call get-property,(asdf:component-property *system* :url)))
	$(eval url := $$(shell cat $${tempfile}))
endef

export cl, db, system, driver, name, longname, version, description, url, command

.PHONY: new
new:
	$(MAKE) clean
	$(MAKE) load

.PHONY: load
load:
	$(MAKE) load-${cl}

.PHONY: load-allegro
load-allegro:
	alisp +B +s ${driver} -e "(pushnew :bt-${db} cl:*features*)" -e "(defparameter *driver-system* '|${system}|)" -- -${mode} ${file}

.PHONY: load-sbcl
load-sbcl:
	sbcl --eval "(pushnew :bt-${db} cl:*features*)" --eval "(defparameter *driver-system* \"${system}\")" --load ${driver} -- -${mode} ${file}

.PHONY: load-clisp
load-clisp:
	clisp -x "(pushnew :bt-${db} cl:*features*)" -x "(defparameter *driver-system* \"${system}\")" -x "(load \"${driver}\")" -- -${mode} ${file}

.PHONY: load-ecl
load-ecl:
	ecl -eval "(pushnew :bt-${db} cl:*features*)" -eval "(defparameter *driver-system* \"${system}\")" -load ${driver} -- -${mode} ${file}

.PHONY: load-clozure
load-clozure:
	ccl --eval "(pushnew :bt-${db} cl:*features*)" --eval "(defparameter *driver-system* \"${system}\")" --load ${driver} -- -${mode} ${file}

.PHONY: test
test:
	$(MAKE) new

.PHONY: prof
prof:
	$(MAKE) driver="${prof}" new

.PHONY: dist
dist:
	rm -rf bin
	mkdir bin
	cp -r $(wildcard lib/*) disp bin
	$(MAKE) driver="${dist}" new

.PHONY: doc
doc:
	$(MAKE) docclean
	$(MAKE) README
	$(MAKE) atdoc

.PHONY: README
README:
	pdflatex README.latex
	pdflatex README.latex
	hevea -o README.html README.latex
	hevea -o README.html README.latex

.PHONY: atdoc
atdoc:
	$(MAKE) driver="${atdoc}" new

.PHONY: install-w32
install-w32:
	-$(call get-properties)
	$(MAKE) dist
	cp -r w32/bt.ico w32/chp w32/is_user_admin.nsh COPYRIGHT bin
	awk "{gsub(/@NAME@/, \"${name}\");print}" w32/install.nsi | awk "{gsub(/@LONGNAME@/, \"${longname}\");print}" | awk "{gsub(/@VERSION@/, \"${version}\");print}" | awk "{gsub(/@DESCRIPTION@/, \"${description}\");print}" | awk "{gsub(/@URL@/, \"${url}\");print}" | awk "{gsub(/@COMMAND@/, \"${command}\");print}" > bin/install.nsi
	makensis bin/install.nsi
	mv bin/*-install.exe .

.PHONY: install-unix
install-unix:
	-$(call get-properties)
	$(MAKE) dist
	cp unix/run.sh bin
	mv bin ${name}
	tar cfz ${name}-${version}-linux.tar.gz ${name}
	mv ${name} bin

.PHONY: install-mac
install-mac:
	-$(call get-properties)
	rm -rf "${longname}.app"
	$(MAKE) dist
	mkdir "${longname}.app" "${longname}.app/Contents" "${longname}.app/Contents/MacOS" "${longname}.app/Contents/Frameworks" "${longname}.app/Contents/Resources"
	awk "{gsub(/@NAME@/, \"${name}\");print}" macos/Info.plist | awk "{gsub(/@LONGNAME@/, \"${longname}\");print}" | awk "{gsub(/@VERSION@/, \"${version}\");print}" | awk "{gsub(/@DESCRIPTION@/, \"${description}\");print}" | awk "{gsub(/@URL@/, \"${url}\");print}" > "${longname}.app/Contents/Info.plist"
	cp -r $(wildcard lib/*.framework) "${longname}.app/Contents/Frameworks"
	cp -r disp "${longname}.app/Contents/Resources"
	cp bin/main "${longname}.app/Contents/MacOS"
	cp macos/PkgInfo COPYRIGHT "${longname}.app/Contents"
	tar cfz "${name}-${version}-macos.tar.gz" "${longname}.app"

.PHONY: clean
clean:
	rm -rf $(wildcard */*/*.o */*/*.fas */*/*.lib */*/*.fasl */*/*.wx32fsl *.db ${tempfile})

.PHONY: distclean
distclean:
	$(MAKE) clean docclean
	rm -rf $(wildcard build.in build.out bin *-install.exe)

.PHONY: docclean
docclean:
	rm -rf atdoc README.aux README.haux README.htoc README.html README.log README.out README.pdf README.toc
