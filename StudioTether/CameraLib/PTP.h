/*
    Description:  PTP pass-through test application

	Copyright:    © Copyright 2001-2005 Apple Computer, Inc. All rights reserved.
	
	Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
				("Apple") in consideration of your agreement to the following terms, and your
				use, installation, modification or redistribution of this Apple software
				constitutes acceptance of these terms.  If you do not agree with these terms,
				please do not use, install, modify or redistribute this Apple software.

				In consideration of your agreement to abide by the following terms, and subject
				to these terms, Apple grants you a personal, non-exclusive license, under Apple’s
				copyrights in this original Apple software (the "Apple Software"), to use,
				reproduce, modify and redistribute the Apple Software, with or without
				modifications, in source and/or binary forms; provided that if you redistribute
				the Apple Software in its entirety and without modifications, you must retain
				this notice and the following text and disclaimers in all such redistributions of
				the Apple Software.  Neither the name, trademarks, service marks or logos of
				Apple Computer, Inc. may be used to endorse or promote products derived from the
				Apple Software without specific prior written permission from Apple.  Except as
				expressly stated in this notice, no other rights or licenses, express or implied,
				are granted by Apple herein, including but not limited to any patent rights that
				may be infringed by your derivative works or by other works in which the Apple
				Software may be incorporated.

				The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
				WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
				WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
				PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
				COMBINATION WITH YOUR PRODUCTS.

				IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
				CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
				GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
				ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
				OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
				(INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
				ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//————————————————————————————————————————————————————————————————————————————————————————————————

#pragma once

//————————————————————————————————————————————————————————————————————————————————————————————————

// all datacodes should have the msn ( most significant nibble ) set as one of the
// following:
typedef enum {
	kStdOpCodeMask					= 0x1000,
	kStdResponseCodeMask			= 0x2000,
	kStdObjFmtCodeMask				= 0x3000,
	kStdEventCodeMask				= 0x4000,
	kStdPropertyCodeMask			= 0x5000,
	kVendorDefOpCodeMask			= 0x9000,
	kVendorDefResponseCodeMask		= 0xA000,
	kVendorDefObjFmtCodeMask		= 0xB000,
	kVendorDefEventCodeMask			= 0xC000,
	kVendorDefPropertyCodeMask		= 0xD000
} DataCodeMasks;

//	Command Codes
typedef enum {
	kUndefined		 				= 0x1000,
	kGetDeviceInfo					= 0x1001,
	kOpenSession					= 0x1002,
	kCloseSession					= 0x1003,
	kGetStorageIDs					= 0x1004,
	kGetStorageInfo					= 0x1005,
	kGetNumObjects					= 0x1006,
	kGetObjectHandles				= 0x1007,
	kGetObjectInfo					= 0x1008,
	kGetObject						= 0x1009,
	kGetThumb						= 0x100A,
	kDeleteObject					= 0x100B,
	kSendObjectInfo					= 0x100C,
	kSendObject						= 0x100D,
	kInitiateCapture				= 0x100E,
	kFormatStore					= 0x100F,
	kResetDevice					= 0x1010,
	kSelfTest						= 0x1011,
	kSetObjectProtection			= 0x1012,
	kPowerDown						= 0x1013,
	kGetDevicePropInfo				= 0x1014,
	kGetDeviceProp					= 0x1015,
	kSetDeviceProp					= 0x1016,
	kResetDeviceProp				= 0x1017,
	kTerminateCapture				= 0x1018,
	kMoveObject						= 0x1019,
	kCopyObject						= 0x101A,
	kGetPartialObject				= 0x101B
} PTPCommands;

//	Response Codes
typedef enum {
	kRspCodeUndefined				= 0x2000,
	kRspCodeOK						= 0x2001,
	kRspCodeGenErr					= 0x2002,
	kRspCodeSessNotOpen				= 0x2003,
	kRspCodeInvalTranID				= 0x2004,
	kRspCodeOpNotSupport			= 0x2005,
	kRspCodeParamNotSupport			= 0x2006,
	kRspCodeIncompleteTransfer		= 0x2007,
	kRspCodeInvalStorageID			= 0x2008,
	kRspCodeInvalObjHandle			= 0x2009,
	kRspCodePropNotSupport			= 0x200A,
	kRspCodeInvalObjFmtCode			= 0x200B,
	kRspCodeStoreFull				= 0x200C,
	kRspCodeObjWriteProtected		= 0x200D,
	kRspCodeStoreReadOnly			= 0x200E,
	kRspCodeAccessDenied			= 0x200F,
	kRspCodeNoThumb					= 0x2010,
	kRspCodeSelfTestFailed			= 0x2011,
	kRspCodePartialDeletion			= 0x2012,
	kRspCodeStoreNotAvail			= 0x2013,
	kRspCodeNotSpecByFmt			= 0x2014,
	kRspCodeNoValidObjInfo			= 0x2015,
	kRspCodeInvalCodeFmt			= 0x2016,
	kRspCodeUnknownVendorCode		= 0x2017,
	kRspCodeCaptureTerminated		= 0x2018,
	kRspCodeDeviceBusy				= 0x2019,
	kRspCodeInvalParentObj			= 0x201A,
	kRspCodeInvalPropFmt			= 0x201B,
	kRspCodeInvalPropValue			= 0x201C,
	kRspCodeInvalParam				= 0x201D,
	kRspCodeSessionAlreadyOpen		= 0x201E
} ResponseCodes;

//	Object Format Codes
typedef enum {
	kFmtCodeUndefined				= 0x3000,
	kFmtCodeAssociation				= 0x3001,
	kFmtCodeScript					= 0x3002,
	kFmtCodeExecutable				= 0x3003,
	kFmtCodeText					= 0x3004,
	kFmtCodeHTML					= 0x3005,
	kFmtCodeDPOF					= 0x3006,
	kFmtCodeAIFF					= 0x3007,
	kFmtCodeWAV						= 0x3008,
	kFmtCodeMP3						= 0x3009,
	kFmtCodeAVI						= 0x300A,
	kFmtCodeMPEG					= 0x300B,
    kFmtCodeMOV						= 0x300D,
	kFmtCodeUndefined2				= 0x3800,
	kFmtCodeExif_JPEG				= 0x3801,
	kFmtCodeTIFF_EP					= 0x3802,
	kFmtCodeFlashPix				= 0x3803,
	kFmtCodeBMP						= 0x3804,
	kFmtCodeCIFF					= 0x3805,
	kFmtCodeUndefined3				= 0x3806,
	kFmtCodeGIF						= 0x3807,
	kFmtCodeJFIF					= 0x3808,
	kFmtCodePCD						= 0x3809,
	kFmtCodePICT					= 0x380A,
	kFmtCodePNG						= 0x380B,
	kFmtCodeUndefined4				= 0x380C,
	kFmtCodeTIFF					= 0x380D,
	kFmtCodeTIFF_IT					= 0x380E,
	kFmtCodeJP2						= 0x380F,
	kFmtCodeJPX						= 0x3810
} ObjFmtCodes;

//	Event Codes
typedef enum {
	kEvtCodeUndefined				= 0x4000,
	kEvtCodeCancelTransaction		= 0x4001,
	kEvtCodeObjectAdded				= 0x4002,
	kEvtCodeObjectRemoved			= 0x4003,
	kEvtCodeStoreAdded				= 0x4004,
	kEvtCodeStoreRemoved			= 0x4005,
	kEvtCodeDevPropChanged			= 0x4006,
	kEvtCodeObjInfoChanged			= 0x4007,
	kEvtCodeDevInfoChanged			= 0x4008,
	kEvtCodeRequestObjTransfer		= 0x4009,
	kEvtCodeStoreFull				= 0x400A,
	kEvtCodeDeviceReset				= 0x400B,
    kEvtCodeStorageInfoChanged		= 0x400C,
    kEvtCodeCaptureComplete			= 0x400D,
    kEvtCodeUnreportedStatus		= 0x400E
} EventCodes;

//	Property Codes
typedef enum {
	kpropCodeUndefined				= 0x5000,
	kpropCodeBatteryLevel			= 0x5001,
	kpropCodeFunctMode				= 0x5002,
	kpropCodeImageSize				= 0x5003,
	kpropCodeCommpressionSize		= 0x5004,
	kpropCodeWhiteBalance			= 0x5005,
	kpropCodeRGBGain				= 0x5006,
	kpropCodeFNumber				= 0x5007,
	kpropCodeFocalLength			= 0x5008,
	kpropCodeFocalDist				= 0x5009,
	kpropCodeFocusMode				= 0x500A,
	kpropCodeExpMeterMode			= 0x500B,
	kpropCodeFlashMode				= 0x500C,
	kpropCodeExpTime				= 0x500D,
	kpropCodeExpProgramMode			= 0x500E,
	kpropCodeExpIndex				= 0x500F,
	kpropCodeExpBiasCompensation	= 0x5010,
	kpropCodeDateTime				= 0x5011,
	kpropCodeCaptureDelay			= 0x5012,
	kpropCodeStillCaptureMode		= 0x5013,
	kpropCodeContrast				= 0x5014,
	kpropCodeSharpness				= 0x5015,
	kpropCodeDigitalZoom			= 0x5016,
	kpropCodeEffectMode				= 0x5017,
	kpropCodeBurstNumber			= 0x5018,
	kpropCodeBurstInterval			= 0x5019,
	kpropCodeTimelapseNumber		= 0x501A,
	kpropCodeTimelapseInterval		= 0x501B,
	kpropCodeFocusMeterMode			= 0x501C
} PropertyCodes;

// Object Format Codes
typedef enum {
	kNonImgUndefined				= 0x3000,
	kNonImgAssociation				= 0x3001,
	kNonImgScript					= 0x3002,
	kNonImgExecutable				= 0x3003,
	kNonImgText						= 0x3004,
	kNonImgHTML						= 0x3005,
	kNonImgDPOF						= 0x3006,
	kNonImgAIFF						= 0x3007,
	kNonImgWAV						= 0x3008,
	kNonImgMP3						= 0x3009,
	kNonImgAVI						= 0x300A,
	kNonImgMPEG						= 0x300B,
	kNonImgMOV						= 0x300D,
	kImgUndefined					= 0x3800,
	kImgEXIF_JPEG					= 0x3801,
	kImgTIFF_EP						= 0x3802,
	kImgFlashPix					= 0x3803,
	kImgBMP							= 0x3804,
	kImgCIFF						= 0x3805,
	kImgUndefined2					= 0x3806,
	kImgGIF							= 0x3807,
	kImgJFIF						= 0x3808,
	kImgPCD							= 0x3809,
	kImgPICT						= 0x380A,
	kImgPNG							= 0x380B,
	kImgUndefined3					= 0x380C,
	kImgTIFF						= 0x380D,
	kImgTIFF_IT						= 0x380E,
	kImgJP2							= 0x380F,
	kImgJPX							= 0x3810
} ObjectFormatCodes;

typedef enum
{
	kUndefinedType					= 0x0000,
	kCommandType					= 0x0001,
	kDataType						= 0x0002,
	kResponseType					= 0x0003
} ContainerTypes;

//	PTP related data structures

typedef Str63 VariableLenString;		// this field might take up to 63 bytes

typedef struct
{
	UInt32				containerLen;
	UInt16				containerType;	// 0 - undefined, 1 - Command, 2 - Data, 3 - Response
	UInt16				code;			// either command code or reponse code
	UInt32				transactionID;
	UInt32				params[0];		// params start here, # of params = (containerLen-12)/4
} PTPContainer;

// used in StorageInfo dataset
typedef enum
{
	kFixedROM						= 0x0001,
	kRemovableROM					= 0x0002,
	kFixedRAM						= 0x0003,
    kRemovableRAM					= 0x0004,
} StorageTypes;

// used in StorageInfo dataset
typedef enum
{
	kGenericFlat					= 0x0001,
	kGenericHierarchical			= 0x0002,
	kDCF							= 0x0003,
} FileSymTypes;

// used in StorageInfo dataset
typedef enum
{
    kReadWrite						= 0x0000,
	kReadOnlyNoDelete				= 0x0001,
	kReadOnlyWithDelete				= 0x0002,
} AccessCapabilityTypes;

typedef struct
{
	UInt16				storageType;
    UInt16				fileSymType;		// file system type
    UInt16				accessCapability;
    UInt64				maxCapacity;
    UInt64				freeSpaceInBytes;
    UInt32				freeSpaceInImages;
    VariableLenString	storageDescription;
    VariableLenString	volumeLabel;
} StorageInfoDataset;

typedef struct
{
	UInt32				storageID;
    StorageInfoDataset	storageInfo;
} ExtendedStorageInfoDataSet;

typedef struct
{
	UInt32				storageID;
	UInt16				objFmtCode;
	UInt16				protectionStatus;
	UInt32				compressedSize;
	UInt16				thumbFmtCode;
	UInt32				thumbCompressedSize;
	UInt32				thumbPixWidth;
	UInt32				thumbPixHeight;
	UInt32				imagePixWidth;
	UInt32				imagePixHeight;
	UInt32				imageBitDepth;
	UInt32				parentObject;
	UInt16				assocType;			// association type
	UInt32				assocDesc;			// association description
	UInt32				seqNum;				// sequence number
	VariableLenString	fileName;
	VariableLenString	captureDateStr;
	VariableLenString	modDataStr;
	VariableLenString	keywordsStr;
} ObjectInfoDataset;

typedef struct
{
    UInt32				dataLength;
    UInt16				containerType;		// should be 0x0004 for event
    UInt16				eventCode;
    UInt32				transactionID;
    UInt32				params[3];			// up to 3 params. # of params = (dataLength - 12)/4
} EventDataset;

//————————————————————————————————————————————————————————————————————————————————————————————————

// *** Pass through command related declarations.  Should be moved to PTP portion of ICA SDK eventually.

/*enum {
	kICAMessageCameraPassThrough	= 'pass',
};
*/
enum {
	kPTPPassThruSend				= 0,
    kPTPPassThruReceive				= 1,
    kPTPPassThruNotUsed				= 2,
};

enum
{
    kPTPOpenSession  = 0x00000001,
    kPTPCloseSession = 0x00000002
};

typedef struct PTPPassThroughPB
{
    UInt32	commandCode;		// <--	PTP command code (including vendor specific)
    UInt32	resultCode;			// -->	PTP response code
    UInt32	numOfInputParams;	// <--	number of valid parameters to be sent to device
    UInt32	numOfOutputParams;	// <--	number of valid parameters expected from device
    UInt32	params[4];			// <->	PTP parameters (command specific / optional)
    UInt32	dataUsageMode;		// <--	send / receive / not used
    UInt32	flags;				// <--	use open/close session..., not used currently
    UInt32	dataSize;			// <->	size of data block
    UInt8	data[1];			// <->	data block
} PTPPassThroughPB;

// *** End of Pass through command related declarations.

//————————————————————————————————————————————————————————————————————————————————————————————————
