CR_FILES := $(wildcard src/*.cr) $(wildcard src/**/*.cr)

crforth: $(CR_FILES)
	crystal build -o $@ src/main.cr

run:
	crystal src/main.cr

clean:
	rm -f crforth
