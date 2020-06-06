# this is faster than github's release page
URL := https://raw.githubusercontent.com/crazyboycjr/deps/master/build
WGET ?= wget

PROTOBUF := $(DEPS_PATH)/include/google/protobuf/message.h
$(PROTOBUF):
	$(eval FILE=protobuf-cpp-3.6.1.tar.gz)
	$(eval DIR=protobuf-3.6.1)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar --no-same-owner -zxf $(FILE)
	cd $(DIR) && ./configure --prefix=$(DEPS_PATH) && $(MAKE) && $(MAKE) install
	rm -rf $(FILE) $(DIR)

BOOST_PT_TREE := $(DEPS_PATH)/include/boost/property_tree/
$(BOOST_PT_TREE):
	$(eval FILE=boost-property_tree-1.70.0.tar.gz)
	$(eval DIR=property_tree)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar --no-same-owner -zxf $(FILE) && cp -r $(DIR)/* $(DEPS_PATH)/include
	rm -rf $(FILE) $(DIR)

BOOST_COROUTINE := $(DEPS_PATH)/include/boost/coroutine/
$(BOOST_COROUTINE):
	$(eval FILE=boost-coroutine-1.70.0.tar.gz)
	$(eval DIR=boost-coroutine-1.70.0)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar --no-same-owner -zxf $(FILE) && cd $(DIR) && ./bootstrap.sh --with-libraries=coroutine && ./b2 --prefix=$(DEPS_PATH) --build-type=minimal variant=release link=static debug-symbols=on coroutine install -j 4
	rm -rf $(FILE) $(DIR)

MVAPICH := $(DEPS_PATH)/include/mpi.h
$(MVAPICH):
	$(eval FILE=mvapich2-2.3.tar.gz)
	$(eval PATCH_FILE=mvapich2-2.3.patch)
	$(eval DIR=mvapich2-2.3)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar xzf $(FILE) && $(WGET) $(URL)/$(PATCH_FILE)
	# give a patch to mvapich
	patch -p0 < $(PATCH_FILE)
	cd $(DIR) && ./configure --disable-fortran --disable-mcast --enable-error-messages=all --with-cma --prefix=$(DEPS_PATH) && $(MAKE) && $(MAKE) install
	rm -rf $(FILE) $(DIR) $(PATCH_FILE)

RESTBED := $(DEPS_PATH)/include/restbed
$(RESTBED):
	$(eval FILE=restbed-bf61912.tar.gz)
	$(eval DIR=restbed)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar --no-same-owner -zxf $(FILE)
	sed -i 's/ssl_LIBRARY_STATIC AND ssl_LIBRARY_SHARED AND crypto_LIBRARY_STATIC AND crypto_LIBRARY_SHARED/(ssl_LIBRARY_STATIC OR ssl_LIBRARY_SHARED) AND (crypto_LIBRARY_STATIC OR crypto_LIBRARY_SHARED)/' $(DIR)/cmake/Findopenssl.cmake
	cd $(DIR)/dependency/openssl && ./config no-shared --prefix=$(DEPS_PATH) && $(MAKE) all && $(MAKE) install_dev
	cd $(DIR) && mkdir build && cd build && cmake -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$(DEPS_PATH) -DCMAKE_INSTALL_LIBDIR=$(DEPS_PATH)/lib .. && $(MAKE) && $(MAKE) install
	rm -rf $(FILE) $(DIR)

GOOGLE_BENCHMARK := $(DEPS_PATH)/include/benchmark/benchmark.h
$(GOOGLE_BENCHMARK):
	$(eval FILE=google-benchmark-1.5.0.tar.gz)
	$(eval DIR=benchmark-1.5.0)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar --no-same-owner -zxf $(FILE)
	cd $(DIR) && mkdir -p build && cd build && cmake -DBENCHMARK_ENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(DEPS_PATH) ../ && $(MAKE) && $(MAKE) install
	rm -rf $(FILE) $(DIR)


GRPC := $(DEPS_PATH)/include/grpcpp/grpcpp.h
$(GRPC):
	$(eval FILE=grpc-v1.29.1.tar.gz)
	$(eval DIR=grpc-v1.29.1)
	rm -rf $(FILE) $(DIR)
	$(WGET) $(URL)/$(FILE) && tar --no-same-owner -zxf $(FILE)
	cd $(DIR) && mkdir -p cmake/build && cd cmake/build
	cmake -DgRPC_INSTALL=ON -DCMAKE_BUILD_TYPE=Release -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF -DCMAKE_INSTALL_PREFIX=$(DEPS_PATH) ../.. && $(make) && $(make) install
	rm -rf $(FILE) $(DIR)
