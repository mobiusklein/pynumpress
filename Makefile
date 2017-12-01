

all: clean build install test


test:
	pytest pynumpress


build:
	python setup.py build sdist bdist_wheel


install: build
	python setup.py install


clean:
	python setup.py clean --all
	rm -rf build/
