TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = truedateprefs

truedateprefs_FILES = XXXRootListController.m
truedateprefs_FRAMEWORKS = UIKit
truedateprefs_PRIVATE_FRAMEWORKS = Preferences
truedateprefs_INSTALL_PATH = /Library/PreferenceBundles
truedateprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
