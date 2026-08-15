TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpideyBattery
SpideyBattery_FILES = Tweak.x
SpideyBattery_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
