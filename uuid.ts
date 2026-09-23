let regex = /(0x[\d\w]{8}),\s*(0x[\d\w]{4}),\s*(0x[\d\w]{4}),.+{((?:0x[\d\w]{2},?){8})/;
let data = regex.exec(process.argv[2]);

if (data == null) {
  throw new Error("");
}

console.log(`  dd ${data[1]}\n  dw ${data[2]}\n  dw ${data[3]}\n  db ${data[4]}`)
