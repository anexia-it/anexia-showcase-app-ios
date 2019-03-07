/*******************************************************************************
 Copyright (C) 2017 Philips Lighting Holding B.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHSBridgeConnection.h"
#import "PHSBridgeConnectionOptions.h"
#import "PHSBridgeConnectionProvider.h"
#import "PHSBridgeConnectionType.h"
#import "PHSBridgeBuilder.h"
#import "PHSBridgeDiscovery.h"
#import "PHSBridgeDiscoveryResult.h"
#import "PHSBridgeProvider.h"
#import "PHSBridgeResponseCompletionHandler.h"
#import "PHSClipError.h"
#import "PHSClipResponse.h"
#import "PHSColor.h"
#import "PHSDeviceInfo.h"
#import "PHSDeviceSearchStatus.h"
#import "PHSDomainObject.h"
#import "PHSError.h"
#import "PHSGamut.h"
#import "PHSGamutColor.h"
#import "PHSHeartbeatManager.h"
#import "PHSHttpError.h"
#import "PHSHttpRequest.h"
#import "PHSHttpRequestError.h"
#import "PHSHttpResponse.h"
#import "PHSKnownBridge.h"
#import "PHSKnownBridges.h"
#import "PHSImage.h"
#import "PHSImagesKnowledgeBase.h"
#import "PHSKnowledgeBaseLibrary.h"
#import "PHSKnowledgeBaseType.h"
#import "PHSLightInfo.h"
#import "PHSLightsKnowledgeBase.h"
#import "PHSLocalBridgeConnection.h"
#import "PHSLocalBridgeConnectionOptions.h"
#import "PHSLog.h"
#import "PHSManufacturer.h"
#import "PHSManufacturersKnowledgeBase.h"
#import "PHSParameterRange.h"
#import "PHSPersistence.h"
#import "PHSPortalConnectionError.h"
#import "PHSPortalConnectionErrorCode.h"
#import "PHSQueueOptions.h"
#import "PHSRemoteBridgeConnection.h"
#import "PHSRemoteBridgeConnectionOptions.h"
#import "PHSReturnCode.h"
#import "PHSSDK.h"

// Types
#import "PHSAlertMode.h"
#import "PHSButtonEvent.h"
#import "PHSClipErrorType.h"
#import "PHSColor.h"
#import "PHSColorHSL.h"
#import "PHSColorHSV.h"
#import "PHSColorRGB.h"
#import "PHSColorXY.h"
#import "PHSDomainType.h"
#import "PHSGroupType.h"
#import "PHSLightMode.h"
#import "PHSProxyMode.h"
#import "PHSLightColorMode.h"
#import "PHSLightEffectMode.h"
#import "PHSNumberPair.h"
#import "PHSClipAttribute.h"


// Devices
#import "PHSBridge.h"
#import "PHSBridgeConfiguration.h"
#import "PHSBridgeNetworkConfiguration.h"
#import "PHSBridgePortalConfiguration.h"
#import "PHSBridgePortalState.h"
#import "PHSBridgeState.h"
#import "PHSBridgeStateCacheType.h"
#import "PHSBridgeTimeConfiguration.h"
#import "PHSBridgeVersion.h"
#import "PHSBridgeBackup.h"
#import "PHSBridgeBackupErrorCode.h"
#import "PHSBridgeBackupStatus.h"
#import "PHSCompoundDevice.h"
#import "PHSCompoundSensor.h"
#import "PHSDaylightSensor.h"
#import "PHSDaylightSensorConfiguration.h"
#import "PHSDaylightSensorState.h"
#import "PHSDevice.h"
#import "PHSDeviceConfiguration.h"
#import "PHSDeviceState.h"
#import "PHSDigestFunction.h"
#import "PHSFindNewDevicesCallback.h"
#import "PHSGenericFlagSensor.h"
#import "PHSGenericFlagSensorConfiguration.h"
#import "PHSGenericFlagSensorState.h"
#import "PHSGenericStatusSensor.h"
#import "PHSGenericStatusSensorConfiguration.h"
#import "PHSGenericStatusSensorState.h"
#import "PHSGeofenceSensor.h"
#import "PHSGeofenceSensorConfiguration.h"
#import "PHSGeofenceSensorState.h"
#import "PHSHumiditySensor.h"
#import "PHSHumiditySensorConfiguration.h"
#import "PHSHumiditySensorState.h"
#import "PHSLightConfiguration.h"
#import "PHSLightLevelSensor.h"
#import "PHSLightLevelSensorConfiguration.h"
#import "PHSLightLevelSensorState.h"
#import "PHSLightPoint.h"
#import "PHSLightSource.h"
#import "PHSLightState.h"
#import "PHSMultiSourceLuminaire.h"
#import "PHSOpenCloseSensor.h"
#import "PHSOpenCloseSensorConfiguration.h"
#import "PHSOpenCloseSensorState.h"
#import "PHSPortalConnectionState.h"
#import "PHSPresenceSensor.h"
#import "PHSPresenceSensorConfiguration.h"
#import "PHSPresenceSensorState.h"
#import "PHSSwitch.h"
#import "PHSSwitchConfiguration.h"
#import "PHSSwitchState.h"
#import "PHSTemperatureSensor.h"
#import "PHSTemperatureSensorConfiguration.h"
#import "PHSTemperatureSensorState.h"

// Resources
#import "PHSAbsoluteTimePattern.h"
#import "PHSBridgeResource.h"
#import "PHSBridgeCapabilities.h"
#import "PHSClipAction.h"
#import "PHSClipCondition.h"
#import "PHSClipConditionAttribute.h"
#import "PHSDayIntervalPattern.h"
#import "PHSGroup.h"
#import "PHSOAuthTokenPair.h"
#import "PHSRandomizedTimePattern.h"
#import "PHSRandomizedTimerPattern.h"
#import "PHSRecurringDays.h"
#import "PHSRecurringRandomizedTimePattern.h"
#import "PHSRecurringRandomizedTimerPattern.h"
#import "PHSRecurringTimeIntervalPattern.h"
#import "PHSRecurringTimePattern.h"
#import "PHSRecurringTimerPattern.h"
#import "PHSResourceLink.h"
#import "PHSRule.h"
#import "PHSScene.h"
#import "PHSSchedule.h"
#import "PHSTimeIntervalPattern.h"
#import "PHSTimePattern.h"
#import "PHSTimePatternFactory.h"
#import "PHSTimer.h"
#import "PHSTimerPattern.h"
#import "PHSTimeZones.h"
#import "PHSTruncatedTimePattern.h"
#import "PHSWhitelistEntry.h"
#import "PHSResourceLinkBuilder.h"
#import "PHSBridgeRuleCapabilities.h"
#import "PHSBridgeSceneCapabilities.h"
#import "PHSBridgeSensorCapabilities.h"
#import "PHSSDKError.h"
#import "PHSSupportedFeature.h"

// Builder
#import "PHSBridge+Builder.h"
#import "PHSResourceLink+Builder.h"

// Sw update
#import "PHSDeviceSoftwareUpdate.h"
#import "PHSDeviceSoftwareUpdateState.h"
#import "PHSSystemSoftwareUpdate.h"
#import "PHSSystemSoftwareUpdateAutoInstall.h"
#import "PHSSystemSoftwareUpdateState.h"
#import "PHSSystemSoftwareUpdateVersion.h"
