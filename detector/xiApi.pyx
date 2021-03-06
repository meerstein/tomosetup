from cxiapi cimport *

error_codes = { XI_OK: "Function call succeeded",
                XI_INVALID_HANDLE: "Invalid handle",
                XI_READREG: "Register read error",
                XI_WRITEREG: "Register write error",
                XI_FREE_RESOURCES: "Freeing resiurces error",
                XI_FREE_CHANNEL: "Freeing channel error",
                XI_FREE_BANDWIDTH: "Freeing bandwith error",
                XI_READBLK: "Read block error",
                XI_WRITEBLK: "Write block error",
                XI_NO_IMAGE: "No image",
                XI_TIMEOUT: "Timeout",
                XI_INVALID_ARG: "Invalid arguments supplied",
                XI_NOT_SUPPORTED: "Not supported",
                XI_ISOCH_ATTACH_BUFFERS: "Attach buffers error",
                XI_GET_OVERLAPPED_RESULT: "Overlapped result",
                XI_MEMORY_ALLOCATION: "Memory allocation error",
                XI_DLLCONTEXTISNULL: "DLL context is NULL",
                XI_DLLCONTEXTISNONZERO: "DLL context is non zero",
                XI_DLLCONTEXTEXIST: "DLL context exists",
                XI_TOOMANYDEVICES: "Too many devices connected",
                XI_ERRORCAMCONTEXT: "Camera context error",
                XI_UNKNOWN_HARDWARE: "Unknown hardware",
                XI_INVALID_TM_FILE: "Invalid TM file",
                XI_INVALID_TM_TAG: "Invalid TM tag",
                XI_INCOMPLETE_TM: "Incomplete TM",
                XI_BUS_RESET_FAILED: "Bus reset error",
                XI_NOT_IMPLEMENTED: "Not implemented",
                XI_SHADING_TOOBRIGHT: "Shading too bright",
                XI_SHADING_TOODARK: "Shading too dark",
                XI_TOO_LOW_GAIN: "Gain is too low",
                XI_INVALID_BPL: "Invalid bad pixel list",
                XI_BPL_REALLOC: "Bad pixel list realloc error",
                XI_INVALID_PIXEL_LIST: "Invalid pixel list",
                XI_INVALID_FFS: "Invalid Flash File System",
                XI_INVALID_PROFILE: "Invalid profile",
                XI_INVALID_CALIBRATION: "Invalid calibration",
                XI_INVALID_BUFFER: "Invalid buffer",
                XI_INVALID_DATA: "Invalid data",
                XI_TGBUSY: "Timing generator is busy",
                XI_IO_WRONG: "Wrong operation open/write/read/close",
                XI_ACQUISITION_ALREADY_UP: "Acquisition already started",
                XI_OLD_DRIVER_VERSION: "Old version of device driver installed to the system.",
                XI_GET_LAST_ERROR: "To get error code please call GetLastError function.",
                XI_CANT_PROCESS: "Data can't be processed",
                XI_ACQUISITION_STOPED: "Acquisition has been stopped. It should be started before GetImage.",
                XI_ACQUISITION_STOPED_WERR: "Acquisition has been stoped with error.",
                XI_INVALID_INPUT_ICC_PROFILE: "Input ICC profile missed or corrupted",
                XI_INVALID_OUTPUT_ICC_PROFILE: "Output ICC profile missed or corrupted",
                XI_DEVICE_NOT_READY: "Device not ready to operate",
                XI_SHADING_TOOCONTRAST: "Shading too contrast",
                XI_ALREADY_INITIALIZED: "Module already initialized",
                XI_NOT_ENOUGH_PRIVILEGES: "Application doesn't enough privileges(one or more app",
                XI_NOT_COMPATIBLE_DRIVER: "Installed driver not compatible with current software",
                XI_TM_INVALID_RESOURCE: "TM file was not loaded successfully from resources",
                XI_DEVICE_HAS_BEEN_RESETED: "Device has been reseted, abnormal initial state",
                XI_NO_DEVICES_FOUND: "No Devices Found",
                XI_RESOURCE_OR_FUNCTION_LOCKED: "Resource(device) or function locked by mutex",
                XI_BUFFER_SIZE_TOO_SMALL: "Buffer provided by user is too small",
                XI_COULDNT_INIT_PROCESSOR: "Couldn't initialize processor.",
                XI_NOT_INITIALIZED: "The object/module/procedure/process being referred to has not been started.",
                XI_UNKNOWN_PARAM: "Unknown parameter",
                XI_WRONG_PARAM_VALUE: "Wrong parameter value",
                XI_WRONG_PARAM_TYPE: "Wrong parameter type",
                XI_WRONG_PARAM_SIZE: "Wrong parameter size",
                XI_BUFFER_TOO_SMALL: "Input buffer too small",
                XI_NOT_SUPPORTED_PARAM: "Parameter info not supported",
                XI_NOT_SUPPORTED_PARAM_INFO: "Parameter info not supported",
                XI_NOT_SUPPORTED_DATA_FORMAT: "Data format not supported",
                XI_READ_ONLY_PARAM: "Read only parameter",
                XI_BANDWIDTH_NOT_SUPPORTED: "This camera does not support currently available bandwidth",
                XI_INVALID_FFS_FILE_NAME: "FFS file selector is invalid or NULL",
                XI_FFS_FILE_NOT_FOUND: "FFS file not found",
                XI_PROC_OTHER_ERROR: "Processing error - other",
                XI_PROC_PROCESSING_ERROR: "Error while image processing.",
                XI_PROC_INPUT_FORMAT_UNSUPPORTED: "Input format is not supported for processing.",
                XI_PROC_OUTPUT_FORMAT_UNSUPPORTED: "Output format is not supported for processing." }


cdef void create_exception(return_code, func_name) except *:
    reason = "Detector_LibraryError"
    desc = error_codes[return_code]
    origin = func_name
    print(reason, desc, origin)

cdef void handle_error(return_code, func_name) except *:
    if return_code != XI_OK:
        create_exception(return_code, func_name)
        print "Detector. Error occurred: {}".format(return_code)


cdef class Detector:

    cdef HANDLE handle
    TIMEOUT = 10000 # in ms
    def __cinit__(self):
        cdef DWORD a

        e = xiGetNumberDevices(&a)
        handle_error(e, "Detector.__cinit__()")
        print "Number of devices: {}".format(a)

        e = xiOpenDevice(0, &self.handle)
        handle_error(e, "Detector.__cinit__()")

        e = xiSetParamInt(self.handle, XI_PRM_IMAGE_DATA_FORMAT, XI_MONO16)
        handle_error(e, "Detector.__cinit__()")

    def set_exposure(self, exposure):
        e = xiSetParamInt(self.handle, XI_PRM_EXPOSURE, exposure * 1000)
        handle_error(e, "Detector.set_exposure()")

    def get_exposure(self):
        cdef int exposure_in_us
        e = xiGetParamInt(self.handle, XI_PRM_EXPOSURE, &exposure_in_us)
        handle_error(e, "Detector.get_exposure()")
        return round(exposure_in_us / 1000)

    def get_image(self):
        cdef XI_IMG image
        e = xiStartAcquisition(self.handle)
        handle_error(e, "Detector.get_image().xiStartAcquisition()")
        e = xiGetImage(self.handle, Detector.TIMEOUT, &image)
        handle_error(e, "Detector.get_image().xiGetImage()")
        #return image.height, image.width, image.bp
        return image.bp[0]

    def enable_cooling(self):
        e = xiSetParamInt(self.handle, XI_PRM_COOLING, XI_ON)
        handle_error(e, "Detector.enable_cooling()")

    def disable_cooling(self):
        e = xiSetParamInt(self.handle, XI_PRM_COOLING, XI_OFF)
        handle_error(e, "Detector.disable_cooling()")

    def __dealloc__(self):
        e = xiCloseDevice(self.handle)
        handle_error(e, "Detector.__dealloc__()")
        print('DEBUG: Detector dealloc')