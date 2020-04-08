src_cpp = $(wildcard *.cpp)
src_cu = $(wildcard *.cu)
path_obj = obj
obj = $(src_cpp:%.cpp=${path_obj}/%.o) $(src_cu:%.cu=${path_obj}/%.o)

inc_c = -I tclap/include/ -I tools/src/
lib_c = -Ltools -ltools 

test: $(obj)
	nvcc -o $@ $^  ${lib_c}

${path_obj}/%.o: %.cpp |${path_obj}
	nvcc -c -o $@ $^ ${inc_c}

${path_obj}/%.o: %.cu |${path_obj}
	nvcc -c -o $@ $^

${path_obj}:
	mkdir -p $@
	
clear:
	rm -rf ${path_obj} test