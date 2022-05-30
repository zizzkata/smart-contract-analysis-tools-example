CMPLR = kompile
RNR = krun

SRCS = $(wildcard *.k)
TSTS = $(wildcard *.test)

.PHONY = build clean testAll

build: ${SRCS}
	${CMPLR} ${SRCS}

testAll: build ${TSTS}

%.test: FORCE
	${RNR} $@

FORCE: ;

clean:
	rm -r *-kompiled