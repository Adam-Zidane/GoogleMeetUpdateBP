THEOS ?= $(HOME)/theos
TARGET := iphone:clang:latest:14.0
ARCHS = arm64
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GoogleMeetUpdateBP
GoogleMeetUpdateBP_FILES = Tweak.xm
GoogleMeetUpdateBP_CFLAGS = -fobjc-arc
GoogleMeetUpdateBP_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
