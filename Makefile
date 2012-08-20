TARGET = bin/hello

# C library
CC = cc
AR = ar cqs
CLIB = bin/libhello.a
CFLAGS = -Wall -D_REENTRANT -fPIC
CSRC = $(wildcard src/*.c)
COBJS = $(patsubst src/%.c, obj/%.o, $(CSRC))

# C# application
CSHARPC = dmcs
CSHARPEXECUTABLE = bin/Hello.exe
CSHARPREFERENCES = /r:System.dll
CSHARPFLAGS = /nologo /warn:4 /optimize+ /codepage:utf8 /t:exe
CHARPSRC = $(wildcard src/*.cs)

# mkbundle
GENERATEDSRC = obj/hello-gen.c
BUNDLEOBJS = obj/hello-bundles.o

$(TARGET): $(CSHARPEXECUTABLE) $(CLIB)
	mkbundle -c -o $(GENERATEDSRC) -oo $(BUNDLEOBJS) $(CSHARPEXECUTABLE)
	$(CC) -o $(TARGET) $(CFLAGS) $(GENERATEDSRC) \
		`pkg-config --cflags --libs mono-2` \
		$(CLIB) \
		$(BUNDLEOBJS)

obj/%.o: src/%.c
	$(CC) -c $(CFLAGS) -o $@ $<

$(CLIB): $(COBJS)
	$(AR) $(CLIB) $(COBJS)

$(CSHARPEXECUTABLE): $(CHARPSRC)
	$(CSHARPC) "/out:$(CSHARPEXECUTABLE)" \
		$(CSHARPREFERENCES) $(CSHARPFLAGS) $(CHARPSRC)

clean:
	rm -f $(CSHARPEXECUTABLE) \
		$(BUNDLEOBJS) $(GENERATEDSRC) \
		$(CLIB) $(COBJS) \
		$(TARGET) 
