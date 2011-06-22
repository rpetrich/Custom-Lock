GO_EASY_ON_ME=1
SYSROOT=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.3.sdk
include theos/makefiles/common.mk

TWEAK_NAME = customlock
customlock_FILES = Tweak.xm
customlock_FRAMEWORKS=UIKit Foundation
include $(THEOS_MAKE_PATH)/tweak.mk
