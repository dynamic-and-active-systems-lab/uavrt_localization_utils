all:
	rm -f bearing
	rm -f *.o
	rm -f codegen/exe/beraring/*.o
	make -f matlab-coder-utils/Makefile PRODUCT_NAME=bearing -j4
