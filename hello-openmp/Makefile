CC=cc
CFLAGS=-O2 -fopenmp

hello-openmp: hello-openmp.c
	$(CC) -o $@ $< $(CFLAGS)

.PHONY: clean

clean:
	rm hello-openmp


