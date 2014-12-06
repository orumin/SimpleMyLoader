#include<efi.h>
#include<efilib.h>

EFI_STATUS
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    EFI_DEVICE_PATH *Path;
    EFI_LOADED_IMAGE *LoadedImageParent;
    EFI_LOADED_IMAGE *LoadedImage;
    EFI_HANDLE *Image;
    CHAR16 *Options = L"root=/dev/sda2 rootfstype=btrfs rw quiet splash";
    EFI_STATUS Status=EFI_SUCCESS;

    InitializeLib(ImageHandle, SystemTable);
    Print(L"Hello, EFI!\n");

    Status = uefi_call_wrapper(BS->OpenProtocol, 6, ImageHandle, &LoadedImageProtocol, &LoadedImageParent, ImageHandle, NULL, EFI_OPEN_PROTOCOL_GET_PROTOCOL);
    if (EFI_ERROR(Status)) {
        Print(L"Could not get LoadedImageProtocol handler %r\n", Status);
        return Status;
    }

    Path = FileDevicePath(LoadedImageParent->DeviceHandle, L"\\vmlinuz");
    if (Path == NULL) {
        Print(L"Could not get device path.");
        return EFI_INVALID_PARAMETER;
    }
    
    Status = uefi_call_wrapper(BS->LoadImage, 6, FALSE, ImageHandle, Path, NULL, 0, &Image);
    if (EFI_ERROR(Status)) {
        Print(L"Could not load %r", Status);
        FreePool(Path);
        return Status;
    }

    Status = uefi_call_wrapper(BS->OpenProtocol, 6, Image, &LoadedImageProtocol, &LoadedImage, ImageHandle, NULL, EFI_OPEN_PROTOCOL_GET_PROTOCOL);
    if (EFI_ERROR(Status)) {
        Print(L"Could not get LoadedImageProtocol handler %r\n", Status);
        uefi_call_wrapper(BS->UnloadImage, 1, Image);
        FreePool(Path);
        return Status;
    }
    LoadedImage->LoadOptions = Options;
    LoadedImage->LoadOptionsSize = (StrLen(LoadedImage->LoadOptions)+1) * sizeof(CHAR16);

    Status = uefi_call_wrapper(BS->StartImage, 3, Image, NULL, NULL);
    uefi_call_wrapper(BS->UnloadImage, 1, Image);
    FreePool(Path);

    return EFI_SUCCESS;
}
