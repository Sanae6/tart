enum Memtype : u32{
EfiReservedMemoryType,
EfiLoaderCode,
EfiLoaderData,
EfiBootServicesCode,
EfiBootServicesData,
EfiRuntimeServicesCode,
EfiRuntimeServicesData,
EfiConventionalMemory,
EfiUnusableMemory,
EfiACPIReclaimMemory,
EfiACPIMemoryNVS,
EfiMemoryMappedIO,
EfiMemoryMappedIOPortSpace,
EfiPalCode,
EfiPersistentMemory,
EfiUnacceptedMemoryType,
EfiMaxMemoryType
};
struct Memdesc {
    Memtype type;
    padding[4];
    u64 phyStart;
    u64 virtStart;
    u64 pageCount;
    u64 attribute;
    padding[8];
};
Memdesc descs[89] @ 0;