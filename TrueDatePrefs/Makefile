GO_EASY_ON_ME = 1

TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TrueDatePrefs

ARCHS = armv7 arm64 arm64e
#SDKVERSION = 11.4
#SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk

TrueDatePrefs_FILES = TRDRootListController.m
TrueDatePrefs_FRAMEWORKS = UIKit
TrueDatePrefs_PRIVATE_FRAMEWORKS = Preferences
TrueDatePrefs_INSTALL_PATH = /Library/PreferenceBundles
TrueDatePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
