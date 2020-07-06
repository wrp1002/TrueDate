THEOS_DEVICE_IP = 10.0.0.225
GO_EASY_ON_ME = 1

TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = test1

test1_FILES = Tweak.x
test1_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"