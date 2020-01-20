module evael.lib.image.image;

import std.string : format, toStringz;
import std.exception : enforce;

public 
{
    import std.typecons : Flag, Yes, No;
}

import evael.lib.memory;

import bindbc.freeimage;

/**
 * Image loading using FreeImage.
 */
class Image : NoGCClass
{
    private FIBITMAP* m_bitmap, m_bitmap32;

	private ubyte* m_bytes;

    private uint m_bitsPerPixel;
	private uint m_width;
	private uint m_height;

    /**
     * Image constructor.
     */
    @nogc
    public this()
    {

    }

    /**
     * Image destructor.
     */
    @nogc
    public ~this()
    {
		FreeImage_Unload(this.m_bitmap32);
	
		// If we had to do a conversion to 32-bit colour, then unload the original
		// non-32-bit-colour version of the image data too.
		if (this.m_bitsPerPixel != 32)
		{
			FreeImage_Unload(this.m_bitmap);
		}
    }
    
    /**
     * Loads an image.
     * Params:
     *      file : file name
     *      flipImage : indicates if image need to be flipped vertically
     */
    public static Image fromFile(in string file, Flag!"flipImage" flipImage = No.flipImage)
    {
    	immutable fileName = file.toStringz();

		FREE_IMAGE_FORMAT imageFormat = FreeImage_GetFileType(fileName , 0);
	
		// Image not found
		enforce(imageFormat != -1, new Exception("File \"%s\" must exists.".format(file)));

		if (imageFormat == FIF_UNKNOWN)
		{
			imageFormat = FreeImage_GetFIFFromFilename(fileName);
	
			enforce(FreeImage_FIFSupportsReading(imageFormat), new Exception("File \"%s\" cannot be read.".format(file)));
		}
	
        auto image = MemoryHelper.create!Image();
		image.m_bitmap = FreeImage_Load(imageFormat, fileName);
	
		if (flipImage)
		{
			FreeImage_FlipVertical(image.m_bitmap);
		}

		image.m_bitsPerPixel = FreeImage_GetBPP(image.m_bitmap);
	
		// Convert our image up to 32 bits (8 bits per channel, Red/Green/Blue/Alpha) -
		// but only if the image is not already 32 bits (i.e. 8 bits per channel).
		// Note: ConvertTo32Bits returns a CLONE of the image data - so if we
		// allocate this back to itself without using our bitmap32 intermediate
		// we will LEAK the original bitmap data
		if (image.m_bitsPerPixel == 32)
		{
			image.m_bitmap32 = image.m_bitmap;
		}
		else
		{
			image.m_bitmap32 = FreeImage_ConvertTo32Bits(image.m_bitmap);
		}
	
		image.m_width = FreeImage_GetWidth(image.m_bitmap32);
		image.m_height = FreeImage_GetHeight(image.m_bitmap32);
		image.m_bytes = FreeImage_GetBits(image.m_bitmap32);

        return image;
	}

	@nogc
	@property nothrow
	{
		public uint width() const
		{
			return this.m_width;
		}

		public uint height() const
		{
			return this.m_height;
		}

		public const(ubyte*) bytes() const
		{
			return this.m_bytes;
		}
	}
}