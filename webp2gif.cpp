#include "gif.h"
#include <cstdint>
#include <cstring>
#include <iostream>
#include <fstream>
#include <cassert>
#include <vector>
#include <filesystem>
#include "webp/demux.h"
#include <tbb/tbb.h>

using namespace std;
using namespace tbb;

namespace fs = filesystem;

bool webp2gif(string webp_name, string gif_name){
	printf("%s\n", webp_name.c_str());
	ifstream webpfile;
	ios_base::iostate exceptionMask = webpfile.exceptions() | std::ios::failbit;
	webpfile.exceptions(exceptionMask);
	try{
		webpfile.open(webp_name.c_str(), ios::binary | ios::in | ios::ate);
	}
	catch (ios_base::failure &e){
		cerr << e.what() << endl;
		cerr << strerror(errno) << endl;
		return false;
	}

	//Initialize Anim WebP Decoder Options

	WebPAnimDecoderOptions webp_dec_options;
	WebPAnimDecoderOptionsInit(&webp_dec_options);
	webp_dec_options.color_mode = MODE_RGBA;
	webp_dec_options.use_threads = true;

	//Read WebP File to webp_data's buffer
	WebPData webp_data;

	webp_data.size = webpfile.tellg();
	webp_data.bytes = new uint8_t[webp_data.size];
	webpfile.seekg(0, ios::beg);
	webpfile.read((char*)webp_data.bytes, webp_data.size);
	webpfile.close();

	//Initialize Anim WebP Decoder
	WebPAnimDecoder* webp_dec = WebPAnimDecoderNew(&webp_data, &webp_dec_options);
	
	//Get Anim WebP Info
	WebPAnimInfo webp_anim_info;
	WebPAnimDecoderGetInfo(webp_dec, &webp_anim_info);

	//Initialize Gif Writer
	GifWriter gif_file;
	GifBegin(&gif_file, gif_name.c_str(), webp_anim_info.canvas_width, webp_anim_info.canvas_height, 1, 8, false);

	int curr_timestamp = 0;
       	int prev_timestamp = 0;

	//Cycle through WebP and Write Gif
	while(WebPAnimDecoderHasMoreFrames(webp_dec)){
		uint8_t* rgba_buffer;
		WebPAnimDecoderGetNext(webp_dec, &rgba_buffer, &curr_timestamp);
		GifWriteFrame(&gif_file, rgba_buffer, webp_anim_info.canvas_width, webp_anim_info.canvas_height, curr_timestamp/10 - prev_timestamp/10, 8, false);	//WebPAnimDecoder uses 1/1000 sec to delay but GifWriteFrame uses 1/100 sec to delay so divide by 10
		prev_timestamp = curr_timestamp;
	}

	//Cleanup
	WebPAnimDecoderReset(webp_dec);
	WebPAnimDecoderDelete(webp_dec);

	GifEnd(&gif_file);

	WebPDataClear(&webp_data);
	return true;
}

int main(int argc, char **argv){

	parallel_for(blocked_range<size_t>(1, argc, (argc-1)/4),
		[argv](const blocked_range<size_t> &r){
			for(size_t i = r.begin(); i != r.end(); ++i){
				fs::path webp_name (argv[i]);
				if(webp_name.extension() != ".webp")
					continue;
				fs::path gif_name = webp_name;
				gif_name.replace_extension(".gif");
				webp2gif(webp_name.string(), gif_name.string());
			}
		}
	);
	return 0;
}
