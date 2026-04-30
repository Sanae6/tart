def main [] {
  try {
    let files = glob src/**/*.s;
    const root_dir = path self .
    const build_dir = path self build
    let objects = $files | each {|file| {source: $file, object: ([$build_dir ($file | path relative-to $root_dir | str replace ".s" ".o") ] | path join) } }

    mkdir $build_dir
    $objects | each {|artifact|
      mkdir ($artifact.object | path dirname)
      clang -x assembler-with-cpp -c $artifact.source -I src -target riscv32-unknown-none -march=rv32im -std=c23 -nostdlib -o $artifact.object
    }

    ld.lld -T src/link.ld ...($objects | get object) -nostdlib -o ($build_dir)/build.elf
  } catch { exit 1 }
  # print compiled
}

def "main run" [] {
  main
  # print starting
  qemu-system-riscv32 -nographic -machine virt -bios none -kernel build/build.elf
}
