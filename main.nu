const root_dir = path self .
const build_dir = path self build

def main [] {
  try {
    let files = glob src/**/*.s;
    let objects = $files | each {|file| {source: $file, object: ([$build_dir ($file | path relative-to $root_dir | str replace ".s" ".o") ] | path join) } }

    mkdir $build_dir
    $objects | each {|artifact|
      mkdir ($artifact.object | path dirname)
      print ($artifact.source | path basename)
      # clang -x assembler-with-cpp -c $artifact.source -I src -target x86_64-unknown-windows -masm=intel -ffreestanding -fshort-wchar -mno-red-zone -std=c23 -nostdlib -o $artifact.object
      fasm $artifact.source $artifact.object
    }

    clang -target x86_64-unknown-windows ...($objects | get object) -fuse-ld=lld -Wl,-entry:efi_main -Wl,-subsystem:efi_application -nodefaultlibs -dll -nostdlib -o ($build_dir)/BOOTX64.EFI
    # fasm src/main.s ($build_dir)/BOOTX64.EFI
    print compiled
    dd if=/dev/zero of=build/fat.img bs=1k count=1440
    mformat -i build/fat.img -f 1440 ::
    mmd -i build/fat.img ::/EFI
    mmd -i build/fat.img ::/EFI/BOOT
    mcopy -i build/fat.img build/BOOTX64.EFI ::/EFI/BOOT
    mkdir build/iso
    cp build/fat.img build/iso
    xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o build/cdimage.iso ./build/iso 
  } catch { exit 1 }
}

def "main run" [-g] {
  main
  let nographic = if $g { [] } else { [-display none] }
  (qemu-system-x86_64 
    -L OVMF_dir/ -pflash OVMF.fd
    ...($nographic)
    -M q35
    -cdrom build/cdimage.iso
    -device virtio-serial-pci
    -device virtconsole,chardev=serial0
    -serial mon:stdio)
}
