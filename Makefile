.PHONY: dialyzer checks test
all: checks test
checks:
	mix format --check-formatted
	mix dialyzer --format dialyxir
test:
	mix coveralls.html
