BINDIR = bin
TARGET = $(BINDIR)/hello

# C library
CC = cc
AR = ar cqs
CLIB = $(BINDIR)/libhello.a
CFLAGS = -Wall -s -O2 -Wl,-O1 # -D_REENTRANT
CSRC = $(wildcard src/*.c)
OBJDIR = obj
COBJS = $(patsubst src/%.c, $(OBJDIR)/%.o, $(CSRC))
LIBFLAGS = -L$(BINDIR) -lhello

# C# application
CSHARPC = dmcs
CSHARPEXECUTABLE = $(BINDIR)/Hello.exe
CSHARPREFERENCES = /r:System.dll
CSHARPFLAGS = /nologo /warn:4 /optimize+ /codepage:utf8 /t:exe
CHARPSRC = $(wildcard src/*.cs)

# mkbundle
GENERATEDSRC = $(OBJDIR)/hello-gen.c
BUNDLEOBJS = $(OBJDIR)/hello-bundles.o

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

$(GENERATEDSRC): $(CSHARPEXECUTABLE) | $(OBJDIR)
	mkbundle -c -o $(GENERATEDSRC) -oo $(BUNDLEOBJS) $(CSHARPEXECUTABLE)

$(CSHARPEXECUTABLE): $(CHARPSRC) | $(BINDIR)
	$(CSHARPC) "/out:$(CSHARPEXECUTABLE)" \
		$(CSHARPREFERENCES) $(CSHARPFLAGS) $(CHARPSRC)

$(CLIB): $(COBJS)
	$(AR) $(CLIB) $(COBJS)

$(OBJDIR)/%.o: src/%.c
	$(CC) -c -o $@ $(CFLAGS) $<

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

clean:
	rm -rf $(OBJDIR) $(BINDIR)

bin/dlopen-self: src/dlopen-self/dlopen-self.c | $(BINDIR)
	$(CC) -o $@ $(CFLAGS) -rdynamic $< -ldl
