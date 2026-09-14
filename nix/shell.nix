{
  mkShell,
  rust-bin,
  pkg-config,
  zig,
  writeShellScriptBin,
}:

let

  glibcTargetVersion = "2.36";
  zigTarget = "x86_64-linux-gnu.${glibcTargetVersion}";
  zigCC = writeShellScriptBin "zig-cc-x86_64-unknown-linux-gnu" ''
    exec ${zig}/bin/zig cc "$@" -target ${zigTarget}
  '';
  zigAR = writeShellScriptBin "zig-ar-x86_64-unknown-linux-gnu" ''
    exec ${zig}/bin/zig ar "$@"
  '';
  crossCC = "${zigCC}/bin/zig-cc-x86_64-unknown-linux-gnu";
  crossAR = "${zigAR}/bin/zig-ar-x86_64-unknown-linux-gnu";

  rust-toolchain = rust-bin.stable.latest.default.override {
    targets = [ "x86_64-unknown-linux-gnu" ];
  };

in
mkShell {

  # rustic's native dependencies (aws-lc-sys, zstd-sys) build via their `cc`
  # fallback rather than cmake for every target here, so plain CC/AR/linker
  # env vars are enough - no cmake or system TLS/crypto libs required.
  env = {
    CC_x86_64_unknown_linux_gnu = crossCC;
    AR_x86_64_unknown_linux_gnu = crossAR;
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = crossCC;
  };

  nativeBuildInputs = [
    rust-toolchain
    pkg-config
    zigCC
    zigAR
  ];
}
