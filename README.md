# package-hhvm

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
