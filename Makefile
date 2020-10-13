# global variables
BASE = $(shell pwd)
SCRIPT = ${BASE}/nord_nm_gui.py
DYNAMIC_BIN = ${BASE}/dist/nord_nm_gui
STATIC_BIN = ${BASE}/bin/nord_nm_gui
SPEC_FILE = ${BASE}/nord_nm_gui.spec
INIT_FILE = ${BASE}/.init

# look for the pipenv executable
PIPENV = $(shell command -v pipenv 2> /dev/null)
ifeq ($(strip $(PIPENV)),)
$(error "Error: pipenv is not installed!")
endif


build: ${STATIC_BIN}

run: prepare
	${PIPENV} run python ${SCRIPT}

install: build
	$(shell ${BASE}/install.sh)

uninstall:
	$(shell ${BASE}/uninstall.sh)

clean:
	${PIPENV} --rm
	rm ${INIT_FILE}
	rm -rf ${BASE}/build || true
	rm -rf ${BASE}/dist || true
	rm -rf ${BASE}/bin || true


${DYNAMIC_BIN}: ${SCRIPT} ${SPEC_FILE} prepare
	${PIPENV} run pyinstaller ${SPEC_FILE}

${STATIC_BIN}: ${DYNAMIC_BIN}
	mkdir -p ${BASE}/bin
	${PIPENV} run staticx ${DYNAMIC_BIN} $@

${INIT_FILE}:
	${PIPENV} sync
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
