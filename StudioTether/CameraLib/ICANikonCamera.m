//
//  ICANikonCamera.m
//  StudioTether
//
//  Created by drake on 24/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ICANikonCamera.h"


static NSNumber *readCameraDataType( uint8_t **p, uint16_t type );


@implementation ICANikonCamera



- (id)init:(ICAObject)dev withDict:(NSDictionary *)dict notify:(id)d
{
	id retVal = nil;
	if( [super init: dev withDict: dict notify: d] )
	{
		bzero( &self->pendingDownload, sizeof( self->pendingDownload ) );
		self->sdram = FALSE;
		self->pendingFile = nil;
		self->pendingFilename = nil;
		self->liveViewEnabled = FALSE;
		self->liveViewReady = FALSE;
		
		// were going to need a polling loop to get nikon events
		self->eventTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
															target: self
														  selector: @selector( nikonEventTimer: )
														  userInfo: NULL
														   repeats: YES];
		retVal = ( self->eventTimer != nil ) ? self: nil;
		
	} // if
	return( retVal );
	
} // init:withDict:notify 



- (void)shutdown
{
	if( self->pendingFile != nil )
	{
		fclose( self->pendingFile );
		
	} // if
	[self->pendingFilename release];
	[self setSDRAMCapture: FALSE]; 
	[self->eventTimer invalidate];	
	[self->downloadTimer invalidate];
	[self->liveViewTimer invalidate];
	self->liveViewTimer = nil;
	
} // shutdown



- (BOOL)setSDRAMCapture:(BOOL)on
{
	BOOL retVal = FALSE;
	PTPPassThroughPB pb = {0};
	
	NSLog( @"Nikon camera: stick it into SDRAM mode" );
	
	pb.commandCode		 = kSetDeviceProp;
	pb.numOfInputParams	 = 1;
	pb.numOfOutputParams = 0;
	pb.params[ 0 ]		 = kCameraProperty_NikonRecordingMedia;
	pb.dataUsageMode	 = kPTPPassThruSend;
	pb.dataSize			 = 1;
	pb.data[ 0 ]		 = on ? kCameraPropertyValue_NikonRecordingMedia_SDRAM: kCameraPropertyValue_NikonRecordingMedia_CFCard;
	if(    ( [self passthrough: &pb size: sizeof( PTPPassThroughPB )] == TRUE )
	   && ( pb.resultCode == kCameraError_NikonOK ) )
	{
		self->sdram = on;
		retVal = TRUE;
		
	} // if
	else
	{
		NSLog( @"Unable to enable SDRAM capture" );
		
	} // if
	return( retVal );
	
} // setSDRAMCapture



- (BOOL)setLiveViewMode:(BOOL)on
{
	BOOL retVal = FALSE;
	PTPPassThroughPB pb = {0};
	if( on )
	{
		NSLog( @"start liveview mode" );
		pb.commandCode = kCameraProperty_NikonStartLiveView;
		
	}
	else
	{
		// closed
		NSLog( @"stop liveview" );
		pb.commandCode = kCameraProperty_NikonEndLiveView;
		[self->liveViewTimer invalidate];
		self->liveViewTimer = nil;
		
	} // if
	pb.numOfInputParams	 = 0;
	pb.numOfOutputParams = 0;
	pb.dataUsageMode	 = kPTPPassThruNotUsed;
	pb.dataSize			 = 0;
	if(    ( [self passthrough: &pb size: sizeof( pb )] == TRUE )
 	    && ( pb.resultCode == kCameraError_NikonOK ) )
	{
		// setup liveview timer
		self->liveViewEnabled = on;
		self->liveViewReady = FALSE;
		if( on )
		{
			self->liveViewTimer = [NSTimer scheduledTimerWithTimeInterval: 0.06 // 15fps - 0.06; 60fps - 0.016
																   target: self
																 selector: @selector( nikonLiveViewTimer: )
																 userInfo: NULL
																  repeats: YES];		
			if( self->liveViewTimer != nil )
			{		
				retVal = TRUE;

			} // if		
		}
		else
		{
			retVal = TRUE;
			
		} // if
	}
	else
	{
		NSLog( @"failed running liveview: %x", pb.resultCode );
			  
	} // if
	return( retVal );
	
} // setLiveViewMode



- (BOOL)shutterRelease
{
	BOOL retVal = FALSE;
	
	if( self->sdram == TRUE )
	{
		// capture to SDRAM
		PTPPassThroughPB pb = {0};
		pb.commandCode		 = kCameraCommand_NikonInitiateCaptureRecInSdram;
		pb.numOfInputParams	 = 1;
		pb.numOfOutputParams = 0;
		pb.params[ 0 ]		 = kCameraProperty_NikonCaptureSort_Release;
		pb.dataUsageMode	 = kPTPPassThruNotUsed;
		pb.dataSize			 = 0;
		if(    ( [self passthrough: &pb size: sizeof( PTPPassThroughPB )] == TRUE )
		    && ( pb.resultCode == kCameraError_NikonOK ) )
		{
			retVal = TRUE;
			
		} // if
	}
	else
	{
		retVal = [super shutterRelease];
	
	} // if	
	return( retVal );
	
} // shutterRelease


- (BOOL)downloadObject:(NSDictionary *)obj toFolder:(NSString *)folder
{
	BOOL retVal = FALSE;
	if( self->sdram == TRUE )
	{
		char buf[ sizeof( PTPPassThroughPB ) + sizeof( ObjectInfoDataset ) - 1 ] = {0};
		PTPPassThroughPB *pb = ( PTPPassThroughPB * ) buf;
		
		self->pendingDownloadObj = [[obj objectForKey: ( NSString * ) kICANotificationICAObjectKey] unsignedLongValue];
		
		NSLog( @"imageDownload begin: %@", [obj objectForKey: ( NSString * ) kICANotificationICAObjectKey]);
		pb->commandCode		  = kGetObjectInfo;
		pb->numOfInputParams  = 1;
		pb->params[ 0 ]		  = self->pendingDownloadObj;
		pb->numOfOutputParams = 0;
		pb->dataUsageMode	  = kPTPPassThruReceive;
		pb->dataSize		  = sizeof( ObjectInfoDataset );
		if(    ( [self passthrough: pb size: sizeof( buf )] )
		   && ( pb->resultCode == kCameraError_NikonOK ) )
		{
			char *ext = nil;
			memmove( &self->pendingDownload, ( buf + sizeof( PTPPassThroughPB ) - 4 ), sizeof( self->pendingDownload ) );
			
			NSLog( @"filename: %S", self->pendingDownload.fileName );
			switch( self->pendingDownload.objFmtCode )
			{
				case( kFmtCodeExif_JPEG ):
				case( kFmtCodeJFIF ):
					ext = "JPG";
					break;
					
				case( kFmtCodeUndefined ):
				case( kFmtCodeUndefined2 ):
					ext = "NEF";
					break;
					
				case( kFmtCodeTIFF ):
					ext = "TIF";
					break;
					
			} // switch		
			
			if(    ( self->pendingDownload.compressedSize > 0 ) 
				&& ( ext != nil ) )
			{
				self->pendingFilename = [self generateFilename: folder ext: ext file: &self->pendingFile];
				if( self->pendingFilename != nil )
				{
					self->pendingDownloadSize = self->pendingDownload.compressedSize;
					self->downloadTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0
																		   target: self
																		 selector: @selector( nikonDownloadTimer: )
																		 userInfo: NULL
																		  repeats: YES];				 
					if( self->downloadTimer != nil )
					{
						if( self->liveViewEnabled == TRUE )
						{
							[self->liveViewTimer invalidate]; // stop the liveview whilst we download the image
							self->liveViewTimer = nil;
							
						} // if			
						retVal = TRUE;
						
					} // if		 
				} // if
			} // if
		} // if
	}
	else
	{
		retVal = [super downloadObject: obj toFolder: folder];
		
	} // if
	return( retVal );
	
} // downloadObject



- (NSDictionary *)getDevicePropDesc:(unsigned long)property
{	
	NSMutableDictionary *retVal = nil;
	char data[ sizeof( PTPPassThroughPB ) + 4096 ] = {0};
	PTPPassThroughPB *pb  = ( PTPPassThroughPB * ) data;
	pb->commandCode		  = kCameraCommand_NikonGetDevicePropDesc;
	pb->numOfInputParams  = 1;
	pb->numOfOutputParams = 0;
	pb->params[ 0 ]		  = property;
	pb->dataUsageMode	  = kPTPPassThruReceive;
	pb->dataSize		  = sizeof( data ) - sizeof( PTPPassThroughPB );
	if(    ( [self passthrough: pb size: sizeof( data )] == TRUE )
	   && ( pb->resultCode == kCameraError_NikonOK ) )
	{
		NikonObjectPropDesc *prop = ( NikonObjectPropDesc * ) pb->data;
		retVal = [NSMutableDictionary dictionaryWithCapacity: 5];
		if( retVal != nil )
		{
			NSLog( @"property: %x, propertytype: %x, getSet: %x", prop->objectPropertyCode, prop->dataType, prop->getSet );
			[retVal setObject: [NSNumber numberWithBool: ( !prop->getSet )] forKey: @"readonly"];
			
			uint8_t *p = prop->other;
			[retVal setObject: readCameraDataType( &p, prop->dataType ) forKey: @"factoryDefaultValue"];
			[retVal setObject: readCameraDataType( &p, prop->dataType ) forKey: @"currentValue"];
			if( *p == 1 )
			{
				// range
				p++;
				
				NSLog( @"range" );
				NSMutableDictionary *rangeValues = [NSMutableDictionary dictionaryWithCapacity: 3];
				[rangeValues setObject: readCameraDataType( &p, prop->dataType ) forKey: @"min"];
				[rangeValues setObject: readCameraDataType( &p, prop->dataType ) forKey: @"max"];
				[rangeValues setObject: readCameraDataType( &p, prop->dataType ) forKey: @"step"];
				[retVal setObject: rangeValues forKey: @"range"]; 
				
			}
			else if( *p == 2 )
			{
				// enum
				p++;
				
				NSLog( @"enum" );
				NSMutableArray *obj = [NSMutableArray arrayWithCapacity: 10];
				CameraDataType_Enum *enumValues = ( CameraDataType_Enum * ) p;
				
				p = enumValues->values;
				while( enumValues->count > 0 )
				{
					[obj addObject: readCameraDataType( &p, prop->dataType )];
					enumValues->count--;
					
				} // while				
				[retVal setObject: obj forKey: @"enum"]; 
				
			} // if
		} // if		
	} // if
	return( retVal );
	
} // getDevicePropDesc



- (BOOL)setDeviceProp:(unsigned long)property withData:(char *)val length:(unsigned long)len
{
	BOOL retVal = FALSE;
	char data[ sizeof( PTPPassThroughPB ) + 4096 ] = {0};
	PTPPassThroughPB *pb  = ( PTPPassThroughPB * ) data;
	pb->commandCode		  = kCameraCommand_NikonSetDeviceProp;
	pb->numOfInputParams  = 1;
	pb->numOfOutputParams = 0;
	pb->params[ 0 ]		  = property;
	pb->dataUsageMode	  = kPTPPassThruSend;
	pb->dataSize		  = len;
	memmove( pb->data, val, len );
	if(    ( [self passthrough: pb size: sizeof( PTPPassThroughPB ) + len - 1 ] == TRUE )
	   && ( pb->resultCode == kCameraError_NikonOK ) )
	{
		retVal = TRUE;
		
	} // if
	return( retVal );
	
} // setDeviceProp:toValue:size



- (void)nikonEventTimer:(NSTimer *)t
{
	NikonEvent event = {0};
	
	// check for new events
	while( [self getNikonEvent: &event ] == TRUE )
	{
		// check the event
		NSLog( @"event: %x, %x", event.code, event.parameter );
		if( event.code == kCameraEvent_NikonObjectAddedInSdram ) 
		{
			NSLog( @"event - image added to sdram" );
			if( event.parameter == 0 )
			{
				// its a D70/D80 and doesn't supply the value as its always
				event.parameter = kCameraProperty_NikonD80SDRAMImage_ObjectHandle;
				
			} // if
			[self->delegate imageDownloadBegin: [NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedLong: event.parameter] 
																			forKey: ( NSString * ) kICANotificationICAObjectKey]];
			
		}
		else if( event.code == kCameraEvent_NikonDevicePropChanged ) 
		{
			[self->delegate cameraPropertyChanged: event.parameter];
				
		} // if
	} // while
} // nikonEventTimer



- (void)nikonDownloadTimer:(NSTimer *)t
{
	// process image downloads
	if( self->pendingDownload.compressedSize > 0 )
	{
		// we have a file to download & data to download
		char data[ 0xFFFFF + sizeof( PTPPassThroughPB ) ] = {0};
		PTPPassThroughPB *pb  = ( PTPPassThroughPB * ) data;
		
		NSLog( @"download: %x, %x", self->pendingDownloadSize - self->pendingDownload.compressedSize, self->pendingDownloadSize );
		
		unsigned long sizeToDownload = MIN( sizeof( data ) - sizeof( PTPPassThroughPB ), 
										    self->pendingDownload.compressedSize ); // amount to read - we need to know when were at the end?
		pb->commandCode	      = kGetPartialObject;
		pb->numOfInputParams  = 3;
		pb->numOfOutputParams = 0;
		pb->params[ 0 ]		  = self->pendingDownloadObj;
		pb->params[ 1 ]		  = self->pendingDownloadSize - self->pendingDownload.compressedSize;
		pb->params[ 2 ]		  = sizeToDownload;
		pb->dataUsageMode	  = kPTPPassThruReceive;
		pb->dataSize		  = pb->params[ 2 ];
		if(    ( [self passthrough: pb size:sizeof( data )] == TRUE ) 
		   && ( pb->resultCode == kCameraError_NikonOK ) )
		{
			if( fwrite( pb->data, pb->params[ 2 ], 1, self->pendingFile ) == sizeToDownload )
			{
				NSLog( @"fwrite failed, requested: %x", sizeToDownload );
				
			} // if
			self->pendingDownload.compressedSize -= pb->params[ 2 ];

		}
		else
		{
			self->pendingDownload.compressedSize = 0; // stop downloading
			[self->downloadTimer invalidate];
			self->downloadTimer = nil;

			fclose( self->pendingFile );
			self->pendingFile = nil;

			[self->delegate imageDownloadFailed];
			[self->pendingFilename release];
			self->pendingFilename = nil;
			
			if( self->liveViewEnabled == TRUE )
			{				
				sleep( 1 );
				[self setLiveViewMode: YES]; // if need be restart liveview
				
			} // if
		} // if
		
		if( self->pendingDownload.compressedSize == 0 )
		{
			// download complete
			NSLog( @"Image download complete" );
			[self->downloadTimer invalidate];
			self->downloadTimer = nil;
			
			fclose( self->pendingFile );
			self->pendingFile = nil;
			
			[self->delegate imageDownloadComplete: self->pendingFilename];
			[self->pendingFilename release];
			self->pendingFilename = nil;
			
			if( self->liveViewEnabled == TRUE )
			{				
				sleep( 1 );
				[self setLiveViewMode: YES]; // if need be restart liveview
				
			} // if
		} // if
	} // if
} // nikonDownloadTimer



- (void)nikonLiveViewTimer:(NSTimer *)t
{
	if( self->liveViewReady == FALSE )
	{
		PTPPassThroughPB pb = {0};
		pb.commandCode		 = kCameraCommand_NikonDeviceReady;
		pb.numOfInputParams  = 0;
		pb.numOfOutputParams = 0;
		pb.dataUsageMode	 = kPTPPassThruNotUsed;
		pb.dataSize		     = 0;
		if(    ( [self passthrough: &pb size: sizeof( pb )] == TRUE )
		   && ( pb.resultCode == kCameraError_NikonOK ) )
		{
			self->liveViewReady = TRUE;
			
		} // if
	}
	else
	{
		// were ready
		char buf[ sizeof( PTPPassThroughPB ) + sizeof( NikonLiveViewObject ) - 1 ] = {0};
		PTPPassThroughPB *pass = ( PTPPassThroughPB * ) buf;
		
		pass->commandCode		= kCameraCommand_NikonGetLiveViewImage;
		pass->numOfInputParams	= 0;
		pass->numOfOutputParams = 0;
		pass->dataUsageMode	    = kPTPPassThruReceive;
		pass->dataSize			= sizeof( NikonLiveViewObject );
		if( [self passthrough: pass size: sizeof( buf )] == TRUE )
		{
			NikonLiveViewObject *data = ( NikonLiveViewObject * ) pass->data;
			[self->delegate imageLiveViewImageData: [NSData dataWithBytes: data->previewImage length: sizeof( data->previewImage )]];

		} // if
	} // if	
} // nikonLiveViewTimer



// get the next event from the camera
- (BOOL)getNikonEvent:(NikonEvent *)event
{
	BOOL retVal = FALSE;
	static char buf[ sizeof( PTPPassThroughPB ) + sizeof( NikonEventStream ) - 1 ] = {0}; // PTPPassThroughPB has 1 byte of data
	NikonEventStream *events = ( NikonEventStream * ) ( buf + sizeof( PTPPassThroughPB ) - 4 ); // - 4 is actually - 1 but the struct isn't packed
	
	if( events->count == 0 )
	{
		// get a load of new events
		PTPPassThroughPB *pb = ( PTPPassThroughPB * ) buf;
		pb->commandCode		  = kCameraCommand_NikonGetEvent;
		pb->numOfInputParams  = 0;
		pb->numOfOutputParams = 0;
		pb->dataUsageMode	  = kPTPPassThruReceive;
		pb->dataSize		  = sizeof( NikonEventStream );
		if(    ( [self passthrough: ( PTPPassThroughPB * ) buf size: sizeof( buf )] == FALSE )
		   || ( pb->resultCode != kCameraError_NikonOK ) )
		{
			NSLog( @"unable to retrieve nikon event list" );
			
		} // if
	} // if
	
	if( events->count > 0 )
	{
		// return first event
		event->code = events->events[ 0 ].code;
		event->parameter = events->events[ 0 ].parameter;
		
		events->count--;
		memmove( &events->events[ 0 ], &events->events[ 1 ], events->count * sizeof( NikonEvent ) );
		retVal = TRUE;
		
	} // if	
	return( retVal );
	
} // getNikonEvent



- (NSString *)generateFilename:(NSString *)folder ext:(char *)ext file:(FILE **)f
{
	static unsigned long no = 0;
	NSString *retVal = nil;	
	do
	{
		[retVal release];
		retVal = [[NSString alloc] initWithFormat: @"%@/img_%04u.%s", folder, no++, ext];
		*f = fopen( [retVal cStringUsingEncoding: NSASCIIStringEncoding], "wb" );
		
	} while(    ( *f == NULL ) 
			 && ( no < 10000 ) );
	
	if( no >= 10000 )
	{
		NSLog( @"oops exceeded the mo of files in a directory" );
		[retVal release];
		
	} // if
	return( retVal );
	
} // generateFilename:ext:file:



@end



static NSNumber *readCameraDataType( uint8_t **p, uint16_t type )
{
	NSNumber *retVal = nil;
	switch( type )
	{
		case( kCameraDataTypeCode_uint32 ):
			retVal = [NSNumber numberWithUnsignedLong: *( ( uint32_t * ) *p )];
			*p += sizeof( uint32_t );
			break;
	
		case( kCameraDataTypeCode_uint16 ):
			retVal = [NSNumber numberWithUnsignedInt: *( ( uint16_t * ) *p )];
			*p += sizeof( uint16_t );
			break;
			
		case( kCameraDataTypeCode_uint8 ):
			retVal = [NSNumber numberWithUnsignedInt: *( ( uint8_t * ) *p )];
			*p += sizeof( uint8_t );
			break;
			
		case( kCameraDataTypeCode_int8 ):
		case( kCameraDataTypeCode_int16 ):
		case( kCameraDataTypeCode_int32 ):
		case( kCameraDataTypeCode_int64 ):
		case( kCameraDataTypeCode_uint64 ):
		case( kCameraDataTypeCode_int128 ):
		case( kCameraDataTypeCode_uint128 ):
			
		case( kCameraDataTypeCode_int8Array ):
		case( kCameraDataTypeCode_uint8Array ):
		case( kCameraDataTypeCode_int16Array ):
		case( kCameraDataTypeCode_uint16Array ):
		case( kCameraDataTypeCode_int32Array ):
		case( kCameraDataTypeCode_uint32Array ):
		case( kCameraDataTypeCode_int64Array ):
		case( kCameraDataTypeCode_uint64Array ):
		case( kCameraDataTypeCode_int128Array ):
		case( kCameraDataTypeCode_uint128Array ):
			
		case( kCameraDataTypeCode_string ):
			
		default:
			NSLog( @"readCameraDataType: unhandled datatype" );
			break;
			
	} // switch
	return( retVal );
	
} // readCameraDataType

