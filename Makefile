TARGET = bin/hello

# C library
CC = cc
AR = ar cqs
CLIB = bin/libhello.a
CFLAGS = -Wall -s -O2 -Wl,-O1 # -D_REENTRANT
CSRC = $(wildcard src/*.c)
COBJS = $(patsubst src/%.c, obj/%.o, $(CSRC))
LIBFLAGS = -Lbin -lhello

# C# application
CSHARPC = dmcs
CSHARPEXECUTABLE = bin/Hello.exe
CSHARPREFERENCES = /r:System.dll
CSHARPFLAGS = /nologo /warn:4 /optimize+ /codepage:utf8 /t:exe
CHARPSRC = $(wildcard src/*.cs)

# mkbundle
GENERATEDSRC = obj/hello-gen.c
BUNDLEOBJS = obj/hello-bundles.o

all: $(TARGET)

# use -force_load on Mac instead of -whole-archive, see README.rst
$(TARGET): $(GENERATEDSRC) $(CLIB)
	$(CC) -o $(TARGET) $(CFLAGS) $(GENERATEDSRC) \
		`pkg-config --cflags --libs mono-2` \
		-rdynamic \
		-Wl,-whole-archive \
		$(LIBFLAGS) \
		-Wl,-no-whole-archive \
		$(BUNDLEOBJS)

$(GENERATEDSRC): $(CSHARPEXECUTABLE)
	mkbundle -c -o $(GENERATEDSRC) -oo $(BUNDLEOBJS) $(CSHARPEXECUTABLE)

$(CSHARPEXECUTABLE): $(CHARPSRC)
	$(CSHARPC) "/out:$(CSHARPEXECUTABLE)" \
		$(CSHARPREFERENCES) $(CSHARPFLAGS) $(CHARPSRC)

$(CLIB): $(COBJS)
	$(AR) $(CLIB) $(COBJS)

obj/%.o: src/%.c
	$(CC) -c -o $@ $(CFLAGS) $<


clean:
	rm -f bin/* obj/*

bin/dlopen-self: src/dlopen-self/dlopen-self.c
	$(CC) -o $@ $(CFLAGS) -rdynamic $< -ldl
