#include <pebble.h>
#include <stdio.h>
#include <stdlib.h>
#include "SHA1.h"
  
#define TIME_ZONE_OFFSET -8
#define TEST_KEY "ylxxyp6aho7w7txfa662xcjdahvmctli"

Window *window;
TextLayer *text_layer;

void handle_init(char *str) {
    // Create a window and text layer
    window = window_create();
    text_layer = text_layer_create(GRect(0, 0, 144, 154));
    
    // Set the text, font, and text alignment
    text_layer_set_text(text_layer, str);
    text_layer_set_font(text_layer, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
    text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
    
    // Add the text layer to the window
    layer_add_child(window_get_root_layer(window), text_layer_get_layer(text_layer));

    // Push the window
    window_stack_push(window, true);
    
    // App Logging!
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Just pushed a window!");
}

void handle_deinit(void) {
    // Destroy the text layer
    text_layer_destroy(text_layer);
    
    // Destroy the window
    window_destroy(window);
}


void decToHex(uint8_t *hash, char *str) {
    int i = 0;
    int temp = 0;
    int quo = 0;
    int num = 0;
    for (i = 0; i < 20; i++) {
      printf("%d", hash[i]);
      num = (int)hash[i];
      quo = num;
      while (quo) {
        temp = quo % 16;
        if (temp < 10) {
          temp += 48;
        }
        else {
          temp += 55;
        }
        str[i] = temp;
        quo /= 16;
      }
    }
}

/* NEED TO ADJUST FOR TIMEZONE! */
int intervals(void) {
    //printf("%d\n", (int)time(NULL));
    return (int)time(NULL) / 30;
}


/*************************************/
int main(void) {
	const unsigned char sha1_key[] = {
	'H', 'e', 'l', 'l', 'o', '!', 0xDE, 0xAD, 0xBE, 0xEF
	};

    static char tokenText[] = "TESTIN";

    char *str = (char *)malloc(42);
    sha1nfo s;
    uint8_t *hash;
    int time;
    char sha1_time[8] = {0,0,0,0,0,0,0,0};
    uint8_t ofs;
    uint32_t otp;


    time = intervals();
    printf("Time: %d\n", time);
    sha1_time[4] = (time >> 24) & 0xFF;
    sha1_time[5] = (time >> 16) & 0xFF;
    sha1_time[6] = (time >> 8) & 0XFF;
    sha1_time[7] = time & 0xFF;
    printf("sha1_time: %s\n", sha1_time);
    int i;
    for (i = 0; i < 8; i++) {
        printf("%d ", sha1_time[i]);
    }    


    sha1_initHmac(&s, sha1_key, 10);
    sha1_write(&s, sha1_time, 8);
    hash = sha1_resultHmac(&s);
    printHash(hash, str);

    ofs = s.state.b[19] & 0xf;
    otp = 0;
otp = ((s.state.b[ofs] & 0x7f) << 24) |
		((s.state.b[ofs + 1] & 0xff) << 16) |
		((s.state.b[ofs + 2] & 0xff) << 8) |
		(s.state.b[ofs + 3] & 0xff);
	otp %= DIGITS_TRUNCATE;
	
	// Convert result into a string.  Sure wish we had working snprintf...
	for(i = 0; i < 6; i++) {
		tokenText[5-i] = 0x30 + (otp % 10);
		otp /= 10;
	}
	tokenText[6]=0;

    printf("Result: %c%c%c%c%c%c\n", 
        tokenText[0],
        tokenText[1],
        tokenText[2],
        tokenText[3],
        tokenText[4],
        tokenText[5]);

     
 
    handle_init(tokenText);
    app_event_loop();
    handle_deinit();
}

