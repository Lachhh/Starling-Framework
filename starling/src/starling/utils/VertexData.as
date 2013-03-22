// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/** The VertexData class manages a raw list of vertex information, allowing direct upload
	 *  to Stage3D vertex buffers. <em>You only have to work with this class if you create display 
	 *  objects with a custom render function. If you don't plan to do that, you can safely 
	 *  ignore it.</em>
	 * 
	 *  <p>To render objects with Stage3D, you have to organize vertex data in so-called
	 *  vertex buffers. Those buffers reside in graphics memory and can be accessed very 
	 *  efficiently by the GPU. Before you can move data into vertex buffers, you have to 
	 *  set it up in conventional memory - that is, in a Vector object. The vector contains
	 *  all vertex information (the coordinates, color, and texture coordinates) - one
	 *  vertex after the other.</p>
	 *  
	 *  <p>To simplify creating and working with such a bulky list, the VertexData class was 
	 *  created. It contains methods to specify and modify vertex data. The raw Vector managed 
	 *  by the class can then easily be uploaded to a vertex buffer.</p>
	 * 
	 *  <strong>Premultiplied Alpha</strong>
	 *  
	 *  <p>The color values of the "BitmapData" object contain premultiplied alpha values, which 
	 *  means that the <code>rgb</code> values were multiplied with the <code>alpha</code> value 
	 *  before saving them. Since textures are created from bitmap data, they contain the values in 
	 *  the same style. On rendering, it makes a difference in which way the alpha value is saved; 
	 *  for that reason, the VertexData class mimics this behavior. You can choose how the alpha 
	 *  values should be handled via the <code>premultipliedAlpha</code> property.</p>
	 * 
	 */ 
	public class VertexData 
	{
		/** The total number of elements (Numbers) stored per vertex. */
		public static const ELEMENTS_PER_VERTEX:int = 2;
		public static const ELEMENTS_PER_COLOR_VERTEX:int = 4;
		public static const ELEMENTS_PER_TEXTURE_VERTEX:int = 2;
		
		/** The offset of position data (x, y) within a vertex. */
		public static const POSITION_OFFSET:int = 0;
		
		/** The offset of color data (r, g, b, a) within a vertex. */ 
		public static const COLOR_OFFSET:int = 0;
		
		/** The offset of texture coordinate (u, v) within a vertex. */
		public static const TEXCOORD_OFFSET:int = 0;
		
		private var mRawDataPosition	:Vector.<Number>;
		private var mRawDataTexture		:Vector.<Number>;
		private var mRawDataColor		:Vector.<Number>;
		
		private var mPremultipliedAlpha:Boolean;
		private var mNumVertices:int;
		
		/** Helper object. */
		private static var sHelperPoint:Point = new Point();
		
		/** Create a new VertexData object with a specified number of vertices. */
		public function VertexData(numVertices:int, premultipliedAlpha:Boolean=false)
		{
			mRawDataPosition = new <Number>[];
			mRawDataColor = new <Number>[];
			mRawDataTexture = new <Number>[];
			mPremultipliedAlpha = premultipliedAlpha;
			this.numVertices = numVertices;
		}
		
		/** Creates a duplicate of either the complete vertex data object, or of a subset. 
		 *  To clone all vertices, set 'numVertices' to '-1'. */
		public function clone(vertexID:int=0, numVertices:int=-1):VertexData
		{
			if (numVertices < 0 || vertexID + numVertices > mNumVertices)
				numVertices = mNumVertices - vertexID;
			
			var clone:VertexData = new VertexData(0, mPremultipliedAlpha);
			clone.mNumVertices = numVertices; 
			clone.mRawDataPosition = mRawDataPosition.slice(vertexID * ELEMENTS_PER_VERTEX, 
				numVertices * ELEMENTS_PER_VERTEX); 
			clone.mRawDataPosition.fixed = true;
			
			clone.mRawDataColor = mRawDataColor.slice(vertexID * ELEMENTS_PER_COLOR_VERTEX, 
				numVertices * ELEMENTS_PER_COLOR_VERTEX); 
			clone.mRawDataColor.fixed = true;
			
			clone.mRawDataTexture = mRawDataTexture.slice(vertexID * ELEMENTS_PER_TEXTURE_VERTEX, 
				numVertices * ELEMENTS_PER_TEXTURE_VERTEX); 
			clone.mRawDataTexture.fixed = true;
			
			return clone;
		}
		
		/** Copies the vertex data 
		 *  of this instance to another vertex data object, starting at a certain index. 
		 * 
		 *  @see copyRangeTo to copy a range of it, defined by 'vertexID' and 'numVertices')
		 * */
		public function copyToAndTransformVertex(targetData:VertexData, targetVertexID, matrix:Matrix):void
		{
			var targetIndex:int;
			var dataLenght : int = mNumVertices * ELEMENTS_PER_VERTEX;
			targetIndex = targetVertexID * ELEMENTS_PER_VERTEX;
			
			var x:Number;
			var y:Number;
			
			for (var i : int; i < dataLenght; i+=2) {
				targetData.mRawDataTexture[int(targetIndex)] = mRawDataTexture[i];
				targetData.mRawDataTexture[int(targetIndex + 1)] = mRawDataTexture[int(i+1)];
				
				x = mRawDataPosition[i];
				y = mRawDataPosition[int(i + 1)];
				targetData.mRawDataPosition[int(targetIndex++)] = matrix.a * x + matrix.c * y + matrix.tx;
				targetData.mRawDataPosition[int(targetIndex++)] = matrix.d * y + matrix.b * x + matrix.ty;
			}
			
			if (targetData.copyColorData) {
				
				targetIndex = targetVertexID * ELEMENTS_PER_COLOR_VERTEX;
				dataLenght = mNumVertices * ELEMENTS_PER_COLOR_VERTEX;
				for (i = 0; i < dataLenght; i++) {
					targetData.mRawDataColor[int(targetIndex++)] = mRawDataColor[i];
				}
			}
		}
		
		
		
		
		/** Copies the vertex data 
		 *  of this instance to another vertex data object, starting at a certain index. 
		 * 
		 *  @see copyRangeTo to copy a range of it, defined by 'vertexID' and 'numVertices')
		 * */
		public function copyTo(targetData:VertexData, targetVertexID:int=0):void
		{
			var targetIndex:int;
			var dataLenght : int = mNumVertices * ELEMENTS_PER_VERTEX;
			targetIndex = targetVertexID * ELEMENTS_PER_VERTEX;
			
			for (var i : int; i < dataLenght; i++) {
				targetData.mRawDataTexture[int(targetIndex)] = mRawDataTexture[i];
				targetData.mRawDataPosition[int(targetIndex++)] = mRawDataPosition[i];
			}
			
			if (targetData.copyColorData) {
				
				targetIndex = targetVertexID * ELEMENTS_PER_COLOR_VERTEX;
				dataLenght = mNumVertices * ELEMENTS_PER_COLOR_VERTEX;
				for (i = 0; i < dataLenght; i++) {
					targetData.mRawDataColor[int(targetIndex++)] = mRawDataColor[i];
				}
			}
		}
		
		/** Copies the vertex data (or a range of it, defined by 'vertexID' and 'numVertices') 
		 *  of this instance to another vertex data object, starting at a certain index. */
		public function copyRangeTo(targetData:VertexData, targetVertexID:int,
									vertexID:int, numVertices:int):void
		{
			if (numVertices < 0 || vertexID + numVertices > mNumVertices) //{
				numVertices = mNumVertices - vertexID;
			
			var targetRawData:Vector.<Number> = targetRawData = targetData.mRawDataPosition;
			var targetIndex:int = targetVertexID * ELEMENTS_PER_VERTEX;
			var sourceIndex:int = vertexID * ELEMENTS_PER_VERTEX;
			var dataLength:int = numVertices * (ELEMENTS_PER_VERTEX);
			
			for (var i:int=sourceIndex; i<dataLength; ++i) {
				targetData.mRawDataTexture[targetIndex] = mRawDataTexture[i];
				targetRawData[int(targetIndex++)] = mRawDataPosition[i];
			}
			
			if (targetData.copyColorData) {
				sourceIndex = vertexID * ELEMENTS_PER_VERTEX;
				dataLength = numVertices * (ELEMENTS_PER_VERTEX);
				
				targetRawData = targetData.mRawDataColor;
				targetIndex = targetVertexID * ELEMENTS_PER_COLOR_VERTEX;
				sourceIndex = vertexID * ELEMENTS_PER_COLOR_VERTEX;
				dataLength = numVertices * (ELEMENTS_PER_COLOR_VERTEX);
				
				for (i=sourceIndex; i<dataLength; ++i) {
					targetRawData[int(targetIndex++)] = mRawDataColor[i];
				}
			}
		}
		
		public var copyColorData : Boolean = true;
		
		/** Appends the vertices from another VertexData object. */
		public function append(data:VertexData):void
		{
			mRawDataTexture.fixed = false;
			mRawDataPosition.fixed = false;
			mRawDataColor.fixed = false;
			
			var targetIndex		:int = mRawDataPosition.length;
			var rawData			:Vector.<Number> = data.mRawDataPosition;
			var rawDataLength	:int = rawData.length;
			
			for (var i:int=0; i<rawDataLength; ++i) {
				mRawDataTexture[targetIndex] = data.mRawDataTexture[i];
				mRawDataPosition[int(targetIndex++)] = rawData[i];
			}
			
			targetIndex		= mRawDataColor.length;
			rawData			= data.mRawDataColor;
			rawDataLength	= rawData.length;
			for (i=0; i<rawDataLength; ++i)
				mRawDataColor[int(targetIndex++)] = rawData[i];
			
			mNumVertices += data.numVertices;
			mRawDataPosition.fixed = true;
			mRawDataTexture.fixed = true;
			mRawDataColor.fixed = true;
		}
		
		// functions
		
		/** Updates the position values of a vertex. */
		public function setPosition(vertexID:int, x:Number, y:Number):void
		{
			var offset:int = getPositionOffset(vertexID);
			mRawDataPosition[offset] = x;
			mRawDataPosition[int(offset+1)] = y;
		}
		
		/** Returns the position of a vertex. */
		public function getPosition(vertexID:int, position:Point):void
		{
			var offset:int = getPositionOffset(vertexID);
			position.x = mRawDataPosition[offset];
			position.y = mRawDataPosition[int(offset+1)];
		}
		
		/** Updates the RGB color values of a vertex. */ 
		public function setColor(vertexID:int, color:uint):void
		{   
			var offset:int = getColorOffset(vertexID);
			var multiplier:Number = mPremultipliedAlpha ? mRawDataColor[int(offset+3)] : 1.0;
			mRawDataColor[offset]        = ((color >> 16) & 0xff) / 255.0 * multiplier;
			mRawDataColor[int(offset+1)] = ((color >>  8) & 0xff) / 255.0 * multiplier;
			mRawDataColor[int(offset+2)] = ( color        & 0xff) / 255.0 * multiplier;
		}
		
		/** Returns the RGB color of a vertex (no alpha). */
		public function getColor(vertexID:int):uint
		{
			var offset:int = getColorOffset(vertexID);
			var divisor:Number = mPremultipliedAlpha ? mRawDataColor[int(offset+3)] : 1.0;
			
			if (divisor == 0) return 0;
			else
			{
				var red:Number   = mRawDataColor[offset]        / divisor;
				var green:Number = mRawDataColor[int(offset+1)] / divisor;
				var blue:Number  = mRawDataColor[int(offset+2)] / divisor;
				
				return (int(red*255) << 16) | (int(green*255) << 8) | int(blue*255);
			}
		}
		
		/** Updates the alpha value of a vertex (range 0-1). */
		public function setAlpha(vertexID:int, alpha:Number):void
		{
			var offset:int = getColorOffset(vertexID) + 3;
			
			if (mPremultipliedAlpha)
			{
				if (alpha < 0.001) alpha = 0.001; // zero alpha would wipe out all color data
				var color:uint = getColor(vertexID);
				mRawDataColor[offset] = alpha;
				setColor(vertexID, color);
			}
			else
			{
				mRawDataColor[offset] = alpha;
			}
		}
		
		/** Returns the alpha value of a vertex in the range 0-1. */
		public function getAlpha(vertexID:int):Number
		{
			var offset:int = getColorOffset(vertexID) + 3;
			return mRawDataColor[offset];
		}
		
		/** Updates the texture coordinates of a vertex (range 0-1). */
		public function setTexCoords(vertexID:int, u:Number, v:Number):void
		{
			var offset:int = getPositionOffset(vertexID);
			mRawDataTexture[offset]        = u;
			mRawDataTexture[int(offset + 1)] = v;
		}
		
		/** Returns the texture coordinates of a vertex in the range 0-1. */
		public function getTexCoords(vertexID:int, texCoords:Point):void
		{
			var offset:int = getPositionOffset(vertexID);
			texCoords.x = mRawDataTexture[offset];
			texCoords.y = mRawDataTexture[int(offset+1)];
		}
		
		// utility functions
		
		/** Translate the position of a vertex by a certain offset. */
		public function translateVertex(vertexID:int, deltaX:Number, deltaY:Number):void
		{
			var offset:int = getPositionOffset(vertexID);
			mRawDataPosition[offset]        += deltaX;
			mRawDataPosition[int(offset+1)] += deltaY;
		}
		
		/** Transforms the position of subsequent vertices by multiplication with a 
		 *  transformation matrix. */
		public function transformVertex(vertexID:int, matrix:Matrix, numVertices:int=1):void
		{
			var offset:int = getPositionOffset(vertexID);
			
			for (var i:int=0; i<numVertices; ++i)
			{
				var x:Number = mRawDataPosition[i];
				var y:Number = mRawDataPosition[int(i+1)];
				
				mRawDataPosition[i]        = matrix.a * x + matrix.c * y + matrix.tx;
				mRawDataPosition[int(i+1)] = matrix.d * y + matrix.b * x + matrix.ty;
				
				offset += ELEMENTS_PER_VERTEX;
			}
		}
		
		/** Sets all vertices of the object to the same color values. */
		public function setUniformColor(color:uint):void
		{
			for (var i:int=0; i<mNumVertices; ++i)
				setColor(i, color);
		}
		
		/** Sets all vertices of the object to the same alpha values. */
		public function setUniformAlpha(alpha:Number):void
		{
			for (var i:int=0; i<mNumVertices; ++i)
				setAlpha(i, alpha);
		}
		
		/** Multiplies the alpha value of subsequent vertices with a certain delta. */
		public function scaleAlpha(vertexID:int, alpha:Number, numVertices:int=1):void
		{
			if (alpha == 1.0) return;
			if (numVertices < 0 || vertexID + numVertices > mNumVertices)
				numVertices = mNumVertices - vertexID;
			
			var i:int;
			
			if (mPremultipliedAlpha)
			{
				for (i=0; i<numVertices; ++i)
					setAlpha(vertexID+i, getAlpha(vertexID+i) * alpha);
			}
			else
			{
				var offset:int = getColorOffset(vertexID) + 3;
				for (i=0; i<numVertices; ++i)
					mRawDataColor[int(offset + i*ELEMENTS_PER_COLOR_VERTEX)] *= alpha;
			}
		}
		
		private function getPositionOffset(vertexID:int):int
		{
			return vertexID * ELEMENTS_PER_VERTEX;
		}
		private function getColorOffset(vertexID:int):int
		{
			return vertexID * ELEMENTS_PER_COLOR_VERTEX;
		}
		
		/** Calculates the bounds of the vertices, which are optionally transformed by a matrix. 
		 *  If you pass a 'resultRect', the result will be stored in this rectangle 
		 *  instead of creating a new object. To use all vertices for the calculation, set
		 *  'numVertices' to '-1'. */
		public function getBounds(transformationMatrix:Matrix=null, 
								  vertexID:int=0, numVertices:int=-1,
								  resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			if (numVertices < 0 || vertexID + numVertices > mNumVertices)
				numVertices = mNumVertices - vertexID;
			
			var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
			var offset:int = getPositionOffset(vertexID);
			var x:Number, y:Number, i:int;
			
			if (transformationMatrix == null)
			{
				for (i=vertexID; i<numVertices; ++i)
				{
					x = mRawDataPosition[offset];
					y = mRawDataPosition[int(offset+1)];
					offset += ELEMENTS_PER_VERTEX;
					
					minX = minX < x ? minX : x;
					maxX = maxX > x ? maxX : x;
					minY = minY < y ? minY : y;
					maxY = maxY > y ? maxY : y;
				}
			}
			else
			{
				for (i=vertexID; i<numVertices; ++i)
				{
					x = mRawDataPosition[offset];
					y = mRawDataPosition[int(offset+1)];
					offset += ELEMENTS_PER_VERTEX;
					
					MatrixUtil.transformCoords(transformationMatrix, x, y, sHelperPoint);
					minX = minX < sHelperPoint.x ? minX : sHelperPoint.x;
					maxX = maxX > sHelperPoint.x ? maxX : sHelperPoint.x;
					minY = minY < sHelperPoint.y ? minY : sHelperPoint.y;
					maxY = maxY > sHelperPoint.y ? maxY : sHelperPoint.y;
				}
			}
			
			resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
			return resultRect;
		}
		
		// properties
		
		/** Indicates if any vertices have a non-white color or are not fully opaque. */
		public function get tinted():Boolean
		{
			//var offset:int = COLOR_OFFSET;
			var dataLenght : int = mNumVertices * ELEMENTS_PER_COLOR_VERTEX; 
			
			for (var i:int=0; i<dataLenght; ++i)
			{
				if (mRawDataColor[i] != 1.0) return true;
			}
			
			return false;
		}
		
		/** Changes the way alpha and color values are stored. Updates all exisiting vertices. */
		public function setPremultipliedAlpha(value:Boolean, updateData:Boolean=true):void
		{
			if (value == mPremultipliedAlpha) return;
			
			if (updateData)
			{
				var dataLength:int = mNumVertices * ELEMENTS_PER_COLOR_VERTEX;
				
				for (var i:int=0; i<dataLength; i += ELEMENTS_PER_COLOR_VERTEX)
				{
					var alpha:Number = mRawDataColor[int(i+3)];
					var divisor:Number = mPremultipliedAlpha ? alpha : 1.0;
					var multiplier:Number = value ? alpha : 1.0;
					
					if (divisor != 0)
					{
						mRawDataColor[i]        = mRawDataColor[i]        / divisor * multiplier;
						mRawDataColor[int(i+1)] = mRawDataColor[int(i+1)] / divisor * multiplier;
						mRawDataColor[int(i+2)] = mRawDataColor[int(i+2)] / divisor * multiplier;
					}
				}
			}
			
			mPremultipliedAlpha = value;
		}
		
		/** Indicates if the rgb values are stored premultiplied with the alpha value. */
		public function get premultipliedAlpha():Boolean { return mPremultipliedAlpha; }
		
		/** The total number of vertices. */
		public function get numVertices():int { return mNumVertices; }
		public function set numVertices(value:int):void
		{
			mRawDataTexture.fixed = false;
			mRawDataPosition.fixed = false;
			
			var i:int;
			var delta:int = value - mNumVertices;
			
			for (i=0; i<delta; ++i) {
				mRawDataTexture.push(0,0); //  u, v
				mRawDataPosition.push(0, 0); // x,y
			}
			
			for (i=0; i<-(delta*ELEMENTS_PER_VERTEX); ++i) {
				mRawDataTexture.pop();
				mRawDataPosition.pop();
			}
			
			mNumVertices = value;
			mRawDataPosition.fixed = true;
			mRawDataTexture.fixed = true;
			
			// color
			mRawDataColor.fixed = false;
			
			
			for (i=0; i<delta; ++i)
				mRawDataColor.push(0, 0,  0, 1); // R,G,B,A alpha should be '1' per default
			
			for (i=0; i<-(delta*ELEMENTS_PER_VERTEX); ++i)
				mRawDataColor.pop();
			
			mRawDataColor.fixed = true;
		}
		
		/** The raw vertex data; not a copy! */
		public function get rawTextureData():Vector.<Number> { return mRawDataTexture; }
		public function get rawPostionData():Vector.<Number> { return mRawDataPosition; }
		public function get rawColorData():Vector.<Number> { return mRawDataColor; }
	}
}