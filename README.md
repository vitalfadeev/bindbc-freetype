# bindbc-freetype
This project provides both static and dynamic bindings to [the FreeType library](https://www.freetype.org/). They are `@nogc` and `nothrow` compatible can be compiled for compatibility with `-betterC`. This package is intended as a replacement of [DerelictFT](https://github.com/DerelictOrg/DerelictFT), which is not compatible with `@nogc`,  `nothrow`, or `-betterC`.

## Usage
By default, `bindbc-freetype` is configured to compile as a dynamic binding that is not `-betterC` compatible. The dynamic binding has no link-time dependency on the FreeType library, so the FreeType shared library must be manually loaded at  run time. When configured as a static binding, there is a link-time dependency on the FreeType library&mdash;either the static library or the appropriate file for linking with shared libraries on your platform (see below).

When using DUB to manage your project, the static binding can be enabled via a DUB `subConfiguration` statement in your project's package file. `-betterC` compatibility is also enabled via subconfigurations.

To use FreeType, add `bindbc-freetype` as a dependency to your project's package config file. For example, the following is configured to compile `bindbc-freeType` as a dynamic binding that is not `-betterC` compatible:

__dub.json__
```
dependencies {
    "bindbc-freetype": "~>1.0.0",
}
```

__dub.sdl__
```
dependency "bindbc-freetypee" version="~>1.0.0"
```

### The dynamic binding
The dynamic binding requires no special configuration when using DUB to manage your project. There is no link-time dependency. At  run time, the FreeType shared library is required to be on the shared library search path of the user's system. On Windows, this is typically handled by distributing the FreeType DLL with your program. On other systems, it usually means the user must install the FreeType shared library through a package manager.

To load the shared library, you need to call the `loadFreeType` function. This returns a member of the `FTSupport` enumeration (see [the README for `bindbc.loader`](https://github.com/BindBC/bindbc-loader/blob/master/README.md) for the error handling API):

* `FTSupport.noLibrary` indicating that the library failed to load (it couldn't be found)
* `FTSupport.badLibrary` indicating that one or more symbols in the library failed to load
* a member of `FTSupport` indicating a version number that matches the version of FreeType that `bindbc-freetype` was configured at compile time to load. By default, that is `FTSupport.ft26`, but can be configured via a version identifier (see below). This value will match the global manifest constant, `ftSupport`.

```d
import bindbc.freetype;

/*
This version attempts to load the FreeType shared library using well-known variations
of the library name for the host system.
*/
FTSupport ret = loadFreeType();
if(ret != ftSupport) {

    // Handle error. For most use cases, its reasonable to use the the error handling API in
    // bindbc-loader to retrieve error messages for logging and then abort. If necessary, it's
    // possible to determine the root cause via the return value:

    if(ret == FTSupport.noLibrary) {
        // FreeType shared library failed to load
    }
    else if(FTSupport.badLibrary) {
        // One or more symbols failed to load. The likely cause is that the
        // shared library is for a lower version than bindbc-freetype was configured
        // to load (via FT_26, FT_27, etc.)
    }
}
/*
This version attempts to load the FreeType library using a user-supplied file name.
Usually, the name and/or path used will be platform specific, as in this example
which attempts to load `freetype.dll` from the `libs` subdirectory, relative
to the executable, only on Windows.
*/
// version(Windows) loadFreeType("libs/freetype.dll")
```
By default, the `bindbc-freetype` binding is configured to load FreeType 2.6. This ensures the widest level of compatibility at run time. This behavior can be overridden via the `-version` compiler switch or the `versions` DUB directive with the desired FreeType version number. It is recommended that you always select the minimum version you require _and no higher_.

In this example, the FreeType dynamic binding is compiled to support FreeType 2.7:

__dub.json__
```
"dependencies": {
    "bindbc-freetype": "~>1.0.0"
},
"versions": ["FT_27"]
```

__dub.sdl__
```
dependency "bindbc-freetype" version="~>1.0.0"
versions "FT_27"
```

With this example configuration, `ftSupport == FTSupport.ft27` after a successful load. If FreeType 2.7 or later is installed on the user's system, `loadFreeType` will return `FTSupport.ft27`. If FreeType 2.6 is installed, `loadFreeType` will return `FTSupport.badLibrary`. In this scenario, calling `loadedFreeTypeVersion()` will return a `FTSupport` member indicating which version of FreeType, if any, actually loaded. If a lower version was loaded, it's still possible to call functions from that version of FreeType, but any calls to functions from higher versions will result in a null pointer access. For this reason, it's recommended to always specify your required version of the FreeType library at compile time and abort when you receive a `FTSupport.badLibrary` return value from `loadFreeType`.

No matter which version was configured, the successfully loaded version can be obtained via a call to `loadedFreeTypeVersion`. It returns one of the following:

* `FTSupport.noLibrary` if `loadFreeType` returned `FTSupport.noLibrary`
* `FTSupport.badLibrary` if `loadFreeType` returned `FTSupport.badLibrary` and no version of FreeType successfully loaded
* a member of `FTSupport` indicating the version of FreeType that successfully loaded. When `loadFreeType` returns `FTSupport.badLibrary`, this will be a version number lower than that configured at compile time. Otherwise, it will be the same as the manifest constant `ftSupport`.

The function `isFreeTypeLoaded` returns `true` if any version of FreeType was successfully loaded and `false` otherwise.

Following are the supported versions of FreeType, the corresponding version IDs to pass to the compiler, and the corresponding `FTSupport` members.

| Library & Version  | Version ID       | `FTSupport` Member |
|--------------------|------------------|--------------------|
|FreeType 2.6.x      | Default          | `FTSupport.ft26`   |
|FreeType 2.7.x      | FT_27            | `FTSupport.ft27`   |
|FreeType 2.8.x      | FT_28            | `FTSupport.ft28`   |
|FreeType 2.9.x      | FT_29            | `FTSupport.ft29`   |
|FreeType 2.10.x     | FT_210           | `FTSupport.ft210`  |
|FreeType 2.11.x     | FT_211           | `FTSupport.ft211`  |

## The static binding
The static binding has a link-time dependency on either the shared or the static FreeType library. On Windows, you can link with the static library or, to use the shared library (`freetype.dll`), you can link with the import library. On other systems, you can link with either the static library or directly with the shared library. This requires the FreeType development package be installed on your system at compile time, either by compiling the FreeType source yourself, downloading the FreeType precompiled binaries for Windows, or installing via a system package manager. [See the FreeType download page](https://www.freetype.org/download.html) for details.

When linking with the static library, there is no run-time dependency on FreeType. When linking with the shared library (or the import library on Windows), the run-time dependency is the same as that of the dynamic binding, the difference being that the shared library is no longer loaded manually&mdash;loading is handled automatically by the system when the program is launched.

Enabling the static binding can be done in two ways.

### Via the compiler's `-version` switch or DUB's `versions` directive
Pass the `BindFT_Static` version to the compiler and link with the appropriate library.

When using the compiler command line or a build system that doesn't support DUB, this is the only choice. The `-version=BindFT_Static` option should be passed to the compiler when building your program. All of the required C libraries, as well as the `bindbc-freetype` and `bindbc-loader` static libraries must also be passed to the compiler on the command line or via your build system's configuration.

When using DUB, set the `BindFT_Static` version via its `versions` directive. For example:

__dub.json__
```
"dependencies": {
    "bindbc-freetype": "~>1.0.0"
},
"versions": ["BindFT_Static"],
"libs": ["freetype"]
```

__dub.sdl__
```
dependency "bindbc-freetype" version="~>1.0.0"
versions "BindFT_Static"
libs "freetype"
```

When using multiple BindBC packages, the `BindBC_Static` version will enable the static binding for all that support it.

### Via DUB subconfigurations
Instead of using DUB's `versions` directive, a `subConfiguration` can be used. To enable the `static` subconfiguration for the `bindbc-freetype` dependency:

__dub.json__
```
"dependencies": {
    "bindbc-freetype": "~>1.0.0"
},
"subConfigurations": {
    "bindbc-freetype": "static"
},
"libs": ["freetype"]
```

__dub.sdl__
```
dependency "bindbc-freetype" version="~>1.0.0"
subConfiguration "bindbc-freetype" "static"
libs "freetype"
```

This has the benefit that it completely excludes from the build any source modules related to the dynamic binding, i.e., they will never be passed to the compiler.

## `betterC` support

`betterC` support is enabled via the `dynamicBC` and `staticBC` subconfigurations, for dynamic and static bindings respectively. To enable the dynamic binding with `-betterC` support:

__dub.json__
```
"dependencies": {
    "bindbc-freetype": "~>1.0.0"
},
"subConfigurations": {
    "bindbc-freetype": "dynamicBC"
},
"libs": ["freetype"]
```

__dub.sdl__
```
dependency "bindbc-freetype" version="~>1.0.0"
subConfiguration "bindbc-freetype" "dynamicBC"
libs "freetype"
```

When not using DUB to manage your project, first use DUB to compile the BindBC libraries with the `dynamicBC` or `staticBC` configuration, then pass `-betterC` to the compiler when building your project.