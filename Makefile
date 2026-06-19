PYTHON := python3
JULIA  := julia

.PHONY: all build run-python run-fortran run-julia animation clean clean-output clean-figure

all: build

build:
	$(MAKE) -C src/fortran

run-python:
	$(PYTHON) src/python/run_1d.py
	$(PYTHON) src/python/run_2d.py

run-fortran: build
	./bin/heat_1d output/fortran/1d
	./bin/heat_2d output/fortran/2d

run-julia:
	$(JULIA) src/julia/run_1d.jl output/julia/1d

animation:
	$(PYTHON) scripts/animate_heat_1d.py --input-dir output/python/1d --frames-dir figure/frames_python_1d --output figure/python_heat_1d
	$(PYTHON) scripts/animate_heat_2d.py --input-dir output/python/2d --frames-dir figure/frames_python_2d --output figure/python_heat_2d
	$(PYTHON) scripts/animate_heat_1d.py --input-dir output/fortran/1d --frames-dir figure/frames_fortran_1d --output figure/fortran_heat_1d
	$(PYTHON) scripts/animate_heat_2d.py --input-dir output/fortran/2d --frames-dir figure/frames_fortran_2d --output figure/fortran_heat_2d

clean-output:
	rm -rf output

clean-figure:
	rm -rf figure

clean: clean-output clean-figure
	$(MAKE) -C src/fortran clean
