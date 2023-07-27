# Benchmarking PGO performance

In order to build a re-usable container for our experiments, run the following command 

```
podman build -t pgo .
```

Then, run a specific benchmark like so:

```
podman run -it --rm pgo amalgamation
podman run -it --rm pgo compile-clang-source
podman run -it --rm pgo llvm-test-suite
```