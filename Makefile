SRCS := src/Extensions.cpp src/Group.cpp src/Networking.cpp src/Hub.cpp src/Node.cpp src/WebSocket.cpp src/HTTPSocket.cpp src/Socket.cpp src/Epoll.cpp
OBJS := src/Extensions.o src/Group.o src/Networking.o src/Hub.o src/Node.o src/WebSocket.o src/HTTPSocket.o src/Socket.o src/Epoll.o
CPP_SHARED := -std=c++11 -O3 -I src -shared -fPIC $(SRCS)
CPP_OPENSSL_OSX := -L/usr/local/opt/openssl/lib -I/usr/local/opt/openssl/include
CPP_OSX := -stdlib=libc++ -mmacosx-version-min=10.7 -undefined dynamic_lookup $(CPP_OPENSSL_OSX)

CPPFLAGS += -std=c++11 -O3 -I src -shared -fPIC -Wall

ifdef CROSS
CXX = $(CROSS)g++ 
AR = $(CROSS)ar
endif


default:
	$(MAKE) `(uname -s)`
Linux:
	# $(CXX) $(CPPFLAGS) $(CFLAGS) $(CPP_SHARED) -s -o libuWS.so
	$(MAKE) uWebSocket.a
	cp uWebSocket.a ..

uWebSocket.a:$(OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(OBJS):%.o:%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

Darwin:
	$(CXX) $(CPPFLAGS) $(CFLAGS) $(CPP_SHARED) $(CPP_OSX) -o libuWS.dylib
.PHONY: install
install:
	make install`(uname -s)`
.PHONY: installLinux
installLinux:
	$(eval PREFIX ?= /usr)
	if [ -d "/usr/lib64" ]; then mkdir -p $(PREFIX)/lib64 && cp libuWS.so $(PREFIX)/lib64/; else mkdir -p $(PREFIX)/lib && cp libuWS.so $(PREFIX)/lib/; fi
	mkdir -p $(PREFIX)/include/uWS
	cp src/*.h $(PREFIX)/include/uWS/
.PHONY: installDarwin
installDarwin:
	$(eval PREFIX ?= /usr/local)
	mkdir -p $(PREFIX)/lib
	cp libuWS.dylib $(PREFIX)/lib/
	mkdir -p $(PREFIX)/include/uWS
	cp src/*.h $(PREFIX)/include/uWS/
.PHONY: clean
clean:
	rm -f *.a
	rm -f src/*.o
	@ #rm -f testsBin onconnect
.PHONY: tests 
tests:
	$(CXX) $(CPP_OPENSSL_OSX) -std=c++11 -O3 tests/main.cpp -Isrc -o testsBin -lpthread -L. -luWS -lssl -lcrypto -lz -luv
onconnect:
	$(CXX) $(CPP_OPENSSL_OSX) -std=c++11 -O3 tests/connect.cpp -Isrc -o onconnect -lpthread -L. -luWS -lssl -lcrypto -lz -luv
