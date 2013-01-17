//
//  ICANikonCamera.h
//  StudioTether
//
//  Created by drake on 24/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ICACamera.h"





enum 
{
	kCameraVendor_Nikon = 1200,
	
	kCameraProperty_NikonRecordingMedia = 0xD10B,
	kCameraPropertyValue_NikonRecordingMedia_CFCard = 0,
	kCameraPropertyValue_NikonRecordingMedia_SDRAM = 1,
	
	kCameraProperty_NikonStartLiveView = 0x9201,
	kCameraProperty_NikonEndLiveView = 0x9202,
	kCameraCommand_NikonGetLiveViewImage = 0x9203,
	
	kCameraCommand_NikonInitiateCaptureRecInSdram = 0x90C0,
	kCameraProperty_NikonCaptureSort_Release = 0xFFFFFFFF,
	
	kCameraCommand_NikonGetEvent = 0x90C7,
	kCameraEvent_NikonObjectAddedInSdram = 0xC101,
	kCameraEvent_NikonPreviewImageAdded = 0xC104,
	kCameraEvent_NikonDevicePropChanged = 0x4006,
	
	kCameraCommand_NikonDeviceReady = 0x90C8,
	kCameraCommand_NikonChangeCameraMode = 0x90C2,
	
	kCameraProperty_NikonD80SDRAMImage_ObjectHandle = 0xffff0001,
	
	kCameraCommand_NikonGetDevicePropDesc = 0x1014,
	kCameraCommand_NikonSetDeviceProp = 0x1016,
	
	kCameraProperty_NikonShutterSpeed = 0xD100,
	kCameraProperty_NikonFNumber = 0x5007,
	kCameraProperty_NikonExposureIndex = 0x500F,
	kCameraProperty_NikonLiveViewImageZoomRatio = 0xD1A3,
	kCameraProperty_NikonLiveViewMode = 0xD1A0,
	kCameraProperty_NikonOrientation = 0xD10E,
	kCameraProperty_NikonExposureProgram = 0x500E,
	
	kCameraError_NikonOK = 0x2001,
	
	kCameraProperty_NikonOrientation_Widthwise = 0,
	kCameraProperty_NikonOrientation_LengthwiseGripup = 1,
	kCameraProperty_NikonOrientation_LengthwiseGripdown = 2,
	kCameraProperty_NikonOrientation_WidthwiseUpsidedown = 3
	
};


enum
{	
	kCameraDataTypeCode_int8 = 0x0001,
	kCameraDataTypeCode_uint8 = 0x0002,
	kCameraDataTypeCode_int16 = 0x0003,
	kCameraDataTypeCode_uint16 = 0x0004,
	kCameraDataTypeCode_int32 = 0x0005,
	kCameraDataTypeCode_uint32 = 0x0006,
	kCameraDataTypeCode_int64 = 0x0007,
	kCameraDataTypeCode_uint64 = 0x0008,
	kCameraDataTypeCode_int128 = 0x0009,
	kCameraDataTypeCode_uint128 = 0x000A,
	
	kCameraDataTypeCode_int8Array = 0x4001,
	kCameraDataTypeCode_uint8Array = 0x4002,
	kCameraDataTypeCode_int16Array = 0x4003,
	kCameraDataTypeCode_uint16Array = 0x4004,
	kCameraDataTypeCode_int32Array = 0x4005,
	kCameraDataTypeCode_uint32Array = 0x4006,
	kCameraDataTypeCode_int64Array = 0x4007,
	kCameraDataTypeCode_uint64Array = 0x4008,
	kCameraDataTypeCode_int128Array = 0x4009,
	kCameraDataTypeCode_uint128Array = 0x400A,

	kCameraDataTypeCode_string = 0xFFFF
	
};


#pragma pack( 1 )
// an event from the camera
typedef struct __NikonEvent
{
	uint16_t code;
	uint32_t parameter;
	
} NikonEvent; // __NikonEvent( struct )



// an event from the camera
typedef struct __NikonEventStream
{
	uint16_t count;
	NikonEvent events[ 100 ];
	
} NikonEventStream; // __NikonEventStream( struct )



//	nikon image dimensions
typedef struct __NikonDimensions
{
	uint16_t horizontalSize;
	uint16_t verticalSize;
	
} NikonDimensions; // __NikonDimensions( struct )



// Nikon live view display info
typedef struct __NikonLiveViewDisplayInfo	
{
	NikonDimensions attachedJPEGImageSize;
	NikonDimensions wholeSize;
	NikonDimensions displayAreaSize;
	NikonDimensions displayCenterCoordinates;
	NikonDimensions afFrameSize;
	NikonDimensions afFrameCenterCoordinates;
	uint32_t reserved;
	uint8_t selectedFocusArea;
	uint8_t rotationDirection;
	uint8_t focusDrivingStatus;
	uint8_t reserved1;
	uint32_t shutterSpeed;
	uint16_t aperatureValue;
	uint16_t countdownTimer;
	uint8_t focusingJudgementResult;
	uint8_t afDrivingEnabledStatus;
	uint8_t reserved2[ 22 ];
	
} NikonLiveViewDisplayInfo; // __NikonLiveViewDisplayInfo( struct )



// live view frame
typedef struct __NikonLiveViewObject
{
	NikonLiveViewDisplayInfo displayInfo;
	char previewImage[ 921600 ];
	
} NikonLiveViewObject; // __NikonLiveViewObject( struct )



// property values
typedef struct  __NikonObjectPropDesc
{
	uint16_t	objectPropertyCode;
	uint16_t	dataType;
	uint8_t		getSet;
	uint8_t		other[ 0 ];
	
} NikonObjectPropDesc; // __NikonObjectPropDesc( struct )



typedef struct  __CameraDataType_Array
{
	uint32_t	count;
	uint8_t		values[ 0 ];
	
} CameraDataType_Array; // __CameraDataType_Array( struct )



typedef struct  __CameraDataType_Enum
{
	uint16_t	count;
	uint8_t		values[ 0 ];
	
} CameraDataType_Enum; // CameraDataType_Enum( struct )
#pragma options align=reset



@interface ICANikonCamera : ICACamera
{
	NSTimer *eventTimer;
	
	NSTimer *downloadTimer;
	uint32_t pendingDownloadObj;
	ObjectInfoDataset pendingDownload;
	unsigned long pendingDownloadSize;
	FILE *pendingFile;
	NSString *pendingFilename;
	
	BOOL liveViewReady;
	BOOL liveViewEnabled;
	NSTimer *liveViewTimer;	
	BOOL sdram;
}


- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict notify:(id)delegate;
- (void)shutdown;

- (BOOL)setSDRAMCapture:(BOOL)on;
- (BOOL)setLiveViewMode:(BOOL)on;
- (BOOL)shutterRelease;
- (BOOL)downloadObject:(NSDictionary *)obj toFolder:(NSString *)folder;
- (NSDictionary *)getDevicePropDesc:(unsigned long)property;
- (BOOL)setDeviceProp:(unsigned long)property withData:(char *)val length:(unsigned long)len;

- (void)nikonEventTimer:(NSTimer *)t;
- (void)nikonDownloadTimer:(NSTimer *)t;
- (void)nikonLiveViewTimer:(NSTimer *)t;

- (BOOL)getNikonEvent:(NikonEvent *)event;

- (NSString *)generateFilename:(NSString *)folder ext:(char *)ext file:(FILE **)f;

@end
