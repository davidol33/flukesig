#define sigArraySize 16
#define isigArrayLast 15
#define indexArraySize 5
#define iIndexArrayLast 4

int calculateFlukeSig(unsigned int startAddress, unsigned int cb)
{
	unsigned char i;
	unsigned char sigArray[sigArraySize];
	unsigned char indexArray[indexArraySize];
	unsigned char *pb = (unsigned char *)(startAddress);
	unsigned int count;
	int sig = 0;
	unsigned char b;

	for(i = 0; i <= isigArrayLast; ++i)
		sigArray[i] = 0;

	indexArray[0] = 6;
	indexArray[1] = 8;
	indexArray[2] = 11;
	indexArray[3] = 15;
	indexArray[4] = 0;


	for(count = 0; count < cb; ++count)
	{
		b = *pb++;

	    for (i = 0; i <= iIndexArrayLast; ++i)
		{
			unsigned char index = indexArray[i];

			if (i == iIndexArrayLast)
				sigArray[index] = b; 
			else
				b = sigArray[index] ^ b;

			if(index == 0)
				index = isigArrayLast;
			else
				--index;

			indexArray[i] = index;
		} 
		
	}

	for (i = 0; i < sigArraySize; ++i)
	{
		b = sigArray[i];

		for (count = 0; count < 8; ++count)
		{
			sig = (sig << 1) | ((b ^ ((sig >> 6) ^ (sig >> 8) ^ (sig >> 11) ^ (sig >> 15))) & 1);
			b = b >> 1;
		}
	}
	
	sig = sig & 0xFFFF;
	return sig;
}
