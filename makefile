src_cpp = $(wildcard *.cpp)
src_cu = $(wildcard *.cu)
path_obj = obj
obj = $(src_cpp:%.cpp=${path_obj}/%.o) $(src_cu:%.cu=${path_obj}/%.o)

test: $(obj)
	nvcc -o $@ $^

${path_obj}/%.o: %.cpp |${path_obj}
	nvcc -c -o $@ $^

${path_obj}/%.o: %.cu |${path_obj}
	nvcc -c -o $@ $^

${path_obj}:
	mkdir -p $@
	
clear:
	rm -rf ${path_obj} test