PRODUCT_VERSION_MAJOR = 9
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE := 0

ifeq ($(TARGET_VENDOR_SHOW_MAINTENANCE_VERSION),true)
    EXTHM_VERSION_MAINTENANCE := $(PRODUCT_VERSION_MAINTENANCE)
else
    EXTHM_VERSION_MAINTENANCE := 0
endif

# Set EXTHM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef EXTHM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "EXTHM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^exTHm_||g')
        EXTHM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter OFFICIAL,$(EXTHM_COMPILERTYPE)),)
    EXTHM_COMPILERTYPE :=
endif

# Filter out random types, so it'll reset to UNKNOWN
ifeq ($(filter RELEASE RC BETA ALPHA EXPERIMENTAL,$(EXTHM_BUILDTYPE)),)
    EXTHM_BUILDTYPE :=
endif

ifdef EXTHM_BUILDTYPE
    ifneq ($(EXTHM_BUILDTYPE), ALPHA)
        ifdef EXTHM_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            EXTHM_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from EXTHM_EXTRAVERSION
            EXTHM_EXTRAVERSION := $(shell echo $(EXTHM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to EXTHM_EXTRAVERSION
            EXTHM_EXTRAVERSION := -$(EXTHM_EXTRAVERSION)
        endif
    else
        ifndef EXTHM_EXTRAVERSION
            # Force build type to EXPERIMENTAL mandates a tag
            EXTHM_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from EXTHM_EXTRAVERSION
            EXTHM_EXTRAVERSION := $(shell echo $(EXTHM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to EXTHM_EXTRAVERSION
            EXTHM_EXTRAVERSION := -$(EXTHM_EXTRAVERSION)
        endif
    endif
else
    # If EXTHM_COMPILERTYPE is not defined, set to UNOFFICIAL
    EXTHM_COMPILERTYPE := UNOFFICIAL
endif

ifeq ($(EXTHM_COMPILERTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        EXTHM_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(EXTHM_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(EXTHM_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            ifeq ($(EXTHM_VERSION_MAINTENANCE),0)
                EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(EXTHM_BUILD)
            else
                EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(EXTHM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(EXTHM_BUILD)
            endif
        else
            EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(EXTHM_BUILD)
        endif
    endif
else
    ifeq ($(EXTHM_VERSION_MAINTENANCE),0)
        ifeq ($(EXTHM_VERSION_APPEND_TIME_OF_DAY),true)
            EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d_%H%M%S)-$(EXTHM_COMPILERTYPE)-$(EXTHM_BUILDTYPE)$(EXTHM_EXTRAVERSION)-$(EXTHM_BUILD)
        else
            EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(EXTHM_COMPILERTYPE)-$(EXTHM_BUILDTYPE)$(EXTHM_EXTRAVERSION)-$(EXTHM_BUILD)
        endif
    else
        ifeq ($(EXTHM_VERSION_APPEND_TIME_OF_DAY),true)
            EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(EXTHM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d_%H%M%S)-$(EXTHM_COMPILERTYPE)-$(EXTHM_BUILDTYPE)$(EXTHM_EXTRAVERSION)-$(EXTHM_BUILD)
        else
            EXTHM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(EXTHM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d)-$(EXTHM_COMPILERTYPE)-$(EXTHM_BUILDTYPE)$(EXTHM_EXTRAVERSION)-$(EXTHM_BUILD)
        endif
    endif
endif

ifdef EXTHM_ADDITIONAL_DETIALS
    EXTHM_VERSION += -$(EXTHM_ADDITIONAL_DETIALS)
endif

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/lineage/build/target/product/security/lineage

-include vendor/lineage-priv/keys/keys.mk

EXTHM_DISPLAY_VERSION := $(EXTHM_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
    ifneq ($(EXTHM_BUILDTYPE), UNOFFICIAL)
        ifndef TARGET_VENDOR_RELEASE_BUILD_ID
            ifneq ($(EXTHM_EXTRAVERSION),)
                # Remove leading dash from EXTHM_EXTRAVERSION
                EXTHM_EXTRAVERSION := $(shell echo $(EXTHM_EXTRAVERSION) | sed 's/-//')
                TARGET_VENDOR_RELEASE_BUILD_ID := $(EXTHM_EXTRAVERSION)
            else
                TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
            endif
        else
            TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
        endif
        ifeq ($(EXTHM_VERSION_MAINTENANCE),0)
            EXTHM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(EXTHM_BUILD)
        else
            EXTHM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(EXTHM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(EXTHM_BUILD)
        endif
    endif
endif
endif

