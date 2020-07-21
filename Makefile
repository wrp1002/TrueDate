THEOS_DEVICE_IP = 10.0.0.225
GO_EASY_ON_ME = 1


PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = armv7 arm64 arm64e
#SDKVERSION = 11.2
#SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TrueDate

TrueDate_FILES = Tweak.x
TrueDate_CFLAGS = -fobjc-arc
TrueDate_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += TrueDatePrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
