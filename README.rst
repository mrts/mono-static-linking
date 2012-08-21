Static linking with Mono
========================

Minimal example that demonstrates how to statically link a C library into a
Mono application bundle. Tested on Ubuntu 12.04.

Instructions
------------

- Use `ordinary P/Invoke declarations`_ for the library functions, but use
  ``"__Internal"`` instead of the library name in the ``DllImport()``
  attribute. Mono P/Invoke implementation uses ``dlopen`` for accessing
  unmanaged libraries and ``"__Internal"`` will cause a "`dlopen self`_" - the
  application executable image itself is dlopened. **Note that Windows (and
  possibly other platforms) does not support this**.

- The declared symbols need to be available for ``dlsym`` in the application
  executable image. However, the linker does not detect during link time that
  the symbols are used as they are not referenced directly and does not include
  them in the output by default. Therefore the linker needs to be `forced to
  include the library`_ with the ``-Wl,-whole-archive`` flag and add all
  symbols to the dynamic symbol table with the ``-rdynamic`` flag.  Don't
  forget to use ``-Wl,-no-whole-archive`` after your list of libraries, because
  ``gcc`` will add its own list of libraries to your link and you may not want
  this flag to affect those as well.

- If you get the ``System.EntryPointNotFoundException: {{symbol name}}``
  exception, then the ``{{symbol name}}`` symbol is missing from the
  binary. You can list the symbols included in the binary with ``nm
  {{binary}} | grep {{symbol name}}`` (C++ symbols need demangling as well).

.. _`ordinary P/Invoke declarations`: https://github.com/mrts/mono-static-linking/blob/master/src/Main.cs
.. _`dlopen self`: https://github.com/mrts/mono-static-linking/blob/master/src/dlopen-self/dlopen-self.c
.. _`forced to include the library`: http://github.com/mrts/mono-static-linking/blob/master/Makefile

Mac
+++

On Mac, use ``-force_load`` instead of ``-whole-archive``::

 $(TARGET): $(GENERATEDSRC) $(CLIB)
         $(CC) -o $(TARGET) $(CFLAGS) $(GENERATEDSRC) \
                 `pkg-config --cflags --libs mono-2` \
                 $(LIBFLAGS) \
                 -force_load $(CLIB) \
                 $(BUNDLEOBJS)

See https://developer.apple.com/library/mac/#qa/qa2006/qa1490.html and
http://docs.xamarin.com/ios/advanced_topics/linking_native_libraries.

Sources and further information
-------------------------------

- http://www.mono-project.com/Mono:Runtime#Ahead-of-time_compilation
- http://www.mono-project.com/AOT
- http://www.mono-project.com/Guide:Running_Mono_Applications#Bundles
- ``man mkbundle``

Information on reducing the size of binaries:

- http://www.mono-project.com/Small_footprint
- http://www.mono-project.com/Embedding_Mono
- ``man mono-cil-strip``
- ``man monolinker``

Thanks
------

Thanks to `Jonathan Pryor`_ for help on #mono IRC and for explaining dlopen self
in http://lists.ximian.com/pipermail/mono-devel-list/2012-April/038771.html

.. _`Jonathan Pryor`: https://github.com/jonpryor
