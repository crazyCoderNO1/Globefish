#ifndef AFCompatibilityMacros_h
#define AFCompatibilityMacros_h
#ifdef API_UNAVAILABLE
    #define AF_API_UNAVAILABLE(x) API_UNAVAILABLE(x)
#else
    #define AF_API_UNAVAILABLE(x)
#endif 
#if __has_warning("-Wunguarded-availability-new")
    #define AF_CAN_USE_AT_AVAILABLE 1
#else
    #define AF_CAN_USE_AT_AVAILABLE 0
#endif
#endif 
