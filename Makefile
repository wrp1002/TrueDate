THEOS_DEVICE_IP = 10.0.0.225
GO_EASY_ON_ME = 1

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TrueDate

TrueDate_FILES = Tweak.x
TrueDate_CFLAGS = -fobjc-arc
TrueDate_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += TrueDatePrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
