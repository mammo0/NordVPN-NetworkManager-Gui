# global variables
BASE = $(shell pwd)
SCRIPT = ${BASE}/nord_nm_gui.py
DYNAMIC_BIN = ${BASE}/dist/nord_nm_gui
STATIC_BIN = ${BASE}/bin/nord_nm_gui
SPEC_FILE = ${BASE}/nord_nm_gui.spec
INIT_FILE = ${BASE}/.init

PYTHON_VERSION = $(shell cat ${BASE}/.python-version)


# look for the pipenv executable
PIPENV = $(shell command -v pipenv 2> /dev/null)
ifeq ($(strip $(PIPENV)),)
$(error "Error: pipenv is not installed!")
endif
PIPENV := PIPENV_DONT_USE_PYENV=true ${PIPENV}

# look for the pyenv executable
PYENV = $(shell command -v pyenv 2> /dev/null)
ifeq ($(strip $(PYENV)),)
$(error "Error: pyenv is not installed!")
endif


build: ${STATIC_BIN}

run: prepare
	${PIPENV} run python ${SCRIPT}

install:
	${BASE}/install.sh

uninstall:
	${BASE}/uninstall.sh

clean:
	rm -rf ${BASE}/build || true
	rm -rf ${BASE}/dist || true
	rm -rf ${BASE}/bin || true

dist-clean: clean
	${PIPENV} --rm || true
	${PYENV} uninstall -f ${PYTHON_VERSION} || true
	rm ${INIT_FILE} || true


${DYNAMIC_BIN}: ${SCRIPT} ${SPEC_FILE} prepare
	${PIPENV} run pyinstaller ${SPEC_FILE}

${STATIC_BIN}: ${DYNAMIC_BIN}
	mkdir -p ${BASE}/bin
	${PIPENV} run staticx ${DYNAMIC_BIN} $@

${INIT_FILE}:
	PYTHON_CONFIGURE_OPTS="--enable-shared" ${PYENV} install -f ${PYTHON_VERSION}
	python_path=$$(${PYENV} which python); \
		${PIPENV} install --python $$python_path
	touch $@

prepare: ${INIT_FILE}
	init_content=$$(cat ${INIT_FILE}); \
	if [ "$$init_content" = "" ] && ([ "${MAKECMDGOALS}" = "build" ] || [ "${MAKECMDGOALS}" = "" ]); then \
		${PIPENV} sync --dev; \
		echo "DEV" > ${INIT_FILE}; \
	elif [ "$$init_content" = "DEV" ] && [ "${MAKECMDGOALS}" = "run" ]; then \
		echo "" > ${INIT_FILE}; \
		${PIPENV} run pip freeze | grep pyinstaller && \
			${PIPENV} uninstall --all || true; \
		${PIPENV} sync; \
	fi
