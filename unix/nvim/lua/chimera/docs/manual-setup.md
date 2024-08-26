# Dependencies

Ada beberapa dependensi yang dibutuhkan untuk memenuhi beberapa error.

## Telescope

```
sudo apt install fd ripgrep
```

# Troubleshoot

## Luacheck

### Error

Akan ada error luacheck tidak bisa di pasang karena error

```
Warning: Failed searching manifest: Failed downloading https://luarocks.org/manifest-5.1 - timeout
Warning: Failed searching manifest: Failed downloading https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/manifest-5.1 - Operation already in progress
Warning: Failed searching manifest: Failed downloading https://luafr.org/luarocks/manifest-5.1 - timeout
Warning: falling back to wget - install luasec to get native HTTPS support
```

### Solution

```
sudo luarocks install luarocks
```
