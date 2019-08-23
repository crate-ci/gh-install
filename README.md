> gh-install: Install pre-built binaries from github

[![Build Status](https://dev.azure.com/crate-ci/crate-ci/_apis/build/status/gh-install%20v1?branchName=master)](https://dev.azure.com/crate-ci/crate-ci/_build/latest?definitionId=8&branchName=master)

## Getting Started

# Usage

Download the script for your platform:
- [bash](v1/install.sh)
- [powershell](v1/install.ps1)

And run it:
```
$ ./install.sh --git <org>/<repo>
# Or
PS install.ps1 -git <org>/<repo>
```
and the binary will be installed to `$HOME/.cargo/bin` unless `--path` is specified

Or use the [Azure Pipeline template](v1/azdo-step.yml) ([example](v1/azure-pipelines.yml)).

# Creating compatible artifacts

The filename must be of the form `<crate>-<tag>-<target>.<format>`
- `<crate>`: If it does not match `<repo>`, users will need to pass in the `--crate <crate>` flag
- `<tag>`: Must be the tag the artifact is associated with. `install.*` can
  automatically use the latest tag if it starts with a `v` and looks like a
  version.
- `<target>`: The [target triplet](https://wiki.osdev.org/Target_Triplet). If rust is installed, it will be inferred from that.
- `<format>`: Must be `zip` for Windows and `tar.gz` for Linux/Mac.

All binaries in the root of the artifact will be copied to the `--path`.

For an Azure Pipelines example, see [`committed`](https://github.com/crate-ci/committed/blob/master/azure-pipelines.yml).

## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.

Thanks for [japaric/trust](https://github.com/japaric/trust) for the original `install.sh`.
