.PHONY: clean dialyzer checks test
all: clean checks test
clean:
	mix clean
checks:
	mix format --check-formatted
	mix dialyzer --format dialyxir
test:
	mix coveralls.html
