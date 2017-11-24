# package-hhvm

> **NOTE:** I don't use HHVM anymore — especially since they shifted their focus from PHP 7.x to Hacklang — so I will no longe r be maintaining this package. It's _mostly_ there, but since newer versions of HHVM source require a newer version of GCC than what comes with CentOS 7, I'm not enough of a C/C++ developer to fix the compilation issues I'm running into. If someone wants to provide a patch for the `Makefile`, I'd be happy to rebuild an RPM.

HHVM is an alternative PHP runtime developed by Facebook which aims to speed-up runtime performance, and implements a few new features. <https://hhvm.com>

See <https://github.com/facebook/hhvm/releases> for releases.

## Generating the RPM package

Edit the `Makefile` to ensure that you are setting the intended version, then run `make`.

```bash
make
```

## Dynamic Extensions

See <https://docs.hhvm.com/hhvm/extensions/introduction#dynamically-loaded-extensions> for a complete list.

The following dynamic extensions have been compiled and are available in this package, but you need to update your HHVM configuration to include them.

* [dBase](https://github.com/skyfms/hhvm-ext_dbase)
* [GeoIP](https://github.com/vipsoft/hhvm-ext-geoip)
* [MessagePack](https://github.com/reeze/msgpack-hhvm)
* [UUID](https://github.com/vipsoft/hhvm-ext-uuid)

Extensions are installed in `/usr/local/lib64/hhvm/extensions/20150212`.
