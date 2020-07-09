TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TrueDatePrefs

TrueDatePrefs_FILES = XXXRootListController.m
TrueDatePrefs_FRAMEWORKS = UIKit
TrueDatePrefs_PRIVATE_FRAMEWORKS = Preferences
TrueDatePrefs_INSTALL_PATH = /Library/PreferenceBundles
TrueDatePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
