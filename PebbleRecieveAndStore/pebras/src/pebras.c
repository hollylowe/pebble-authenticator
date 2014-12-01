#include <pebble.h>
#include "SHA1.h"
static Window *window;
static TextLayer *account_one_name_layer;
static TextLayer *account_one_code_layer;
static TextLayer *account_two_name_layer;
static TextLayer *account_two_code_layer;
static TextLayer *account_three_name_layer;
static TextLayer *account_three_code_layer;

static AppSync sync;
static uint8_t sync_buffer[256];

// Each key is 32 chars
#define ACCOUNT_KEY_LENGTH 33 // 33 for null character
#define MAX_ACCOUNT_NAME_LENGTH 20
#define MAX_ACCOUNT_CODE_LENGTH 20

#define ACCOUNT_ONE 1
#define ACCOUNT_TWO 2
#define ACCOUNT_THREE 3
#define NO_ACCOUNT 4

char account_one_key[ACCOUNT_KEY_LENGTH];
char account_one_name[MAX_ACCOUNT_NAME_LENGTH];
char account_one_code[MAX_ACCOUNT_CODE_LENGTH];

char account_two_key[ACCOUNT_KEY_LENGTH];
char account_two_name[MAX_ACCOUNT_NAME_LENGTH];
char account_two_code[MAX_ACCOUNT_CODE_LENGTH];

char account_three_key[ACCOUNT_KEY_LENGTH];
char account_three_name[MAX_ACCOUNT_NAME_LENGTH];
char account_three_code[MAX_ACCOUNT_CODE_LENGTH];

enum DictionaryIndices {
  ACCOUNT_NAME_INDEX = 0, // TUPLE_CSTRING
  ACCOUNT_TIME_BASED_KEY_INDEX = 1  // TUPLE_CSTRING
};

void printHash(uint8_t* hash, char *str) {
    int i;
    printf("First: %d\n", hash[0]);
    for (i=0; i<20; i++) {
        printf("%02x", hash[i]);
    }
    printf("\n");
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


int intervals(void) {
    //printf("%d\n", (int)time(NULL));
    return (int)time(NULL) / 30;
}

static void sync_error_callback(DictionaryResult dict_error, AppMessageResult app_message_error, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "App Message Sync Error: %d", app_message_error);
}

int get_next_available_account() {
  if (account_one_key[0] == 0) {
    return ACCOUNT_ONE;
  } else if (account_two_key[0] == 0) {
    return ACCOUNT_TWO;
  } else if (account_three_key[0] == 0) {
    return ACCOUNT_THREE;
  } else {
    return NO_ACCOUNT;
  }

}

void set_next_account_name(const char* name) {
  int next_account = get_next_available_account();

  if (next_account == ACCOUNT_ONE) {
    strcpy(account_one_name, name);
    text_layer_set_text(account_one_name_layer, account_one_name);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Set account one name.");

  } else if (next_account == ACCOUNT_TWO) {
    strcpy(account_two_name, name);
    text_layer_set_text(account_two_name_layer, account_two_name);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Set account two name.");

  } else if (next_account == ACCOUNT_THREE) {
    strcpy(account_three_name, name);
    text_layer_set_text(account_three_name_layer, account_three_name);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Set account three name.");
  } else {
    // No account 
  }
}

void updateCodeWithKey(char* code, char* key) {


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
  strcpy(code, tokenText);

}

void updateCodes() {
  // char new_code[MAX_ACCOUNT_CODE_LENGTH];

  // Check every account for a key
  if (account_one_key[0] != 0) {
    updateCodeWithKey(account_one_code, account_one_key);
  } 

  if (account_two_key[0] != 0) {
    updateCodeWithKey(account_two_code, account_two_key);
  } 

  if (account_three_key[0] != 0) {
    updateCodeWithKey(account_three_code, account_three_key);
  } 
}

void set_next_account_key(const char* key) {
  int next_account = get_next_available_account();
  // char* test = "test";

  if (next_account == ACCOUNT_ONE) {
    strcpy(account_one_key, key);
    updateCodes();
    text_layer_set_text(account_one_code_layer, account_one_code);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Set account one key and code.");

  } else if (next_account == ACCOUNT_TWO) {
    strcpy(account_two_key, key);
    updateCodes();
    text_layer_set_text(account_two_code_layer, account_two_code);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Set account two key and code.");

  } else if (next_account == ACCOUNT_THREE) {
    strcpy(account_three_key, key);
    updateCodes();
    text_layer_set_text(account_three_code_layer, account_three_code);
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Set account three key and code.");

  } else {
    // No account 
  }
}

// Required to recieve stuff
static void sync_tuple_changed_callback(const uint32_t key, const Tuple* new_tuple, const Tuple* old_tuple, void* context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "value: %s", new_tuple->value->cstring);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "key: %d", (uint8_t) key);

  switch (key) {
    case ACCOUNT_NAME_INDEX:
        // Data for Edit and Create command
        if (strlen(new_tuple->value->cstring) > 0) {
          set_next_account_name(new_tuple->value->cstring);
        }
        break;
    case ACCOUNT_TIME_BASED_KEY_INDEX:
        // Data for Edit and Create command
        // text_layer_set_text(third_text_layer, new_tuple->value->cstring);
        if (strlen(new_tuple->value->cstring) > 0) {
          set_next_account_key(new_tuple->value->cstring);
        }

        break;
  }
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  // Setting up the text layer
  account_one_name_layer = text_layer_create(GRect(0, 0, 144, 168));
  text_layer_set_text(account_one_name_layer, "");
  text_layer_set_font(account_one_name_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text_alignment(account_one_name_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(account_one_name_layer, GTextOverflowModeWordWrap);

  account_one_code_layer = text_layer_create(GRect(0, 25, 144, 168));
  text_layer_set_text(account_one_code_layer, "");
  text_layer_set_font(account_one_code_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text_alignment(account_one_code_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(account_one_code_layer, GTextOverflowModeWordWrap);

  account_two_name_layer = text_layer_create(GRect(0, 50, 144, 168));
  text_layer_set_font(account_two_name_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text(account_two_name_layer, "");
  text_layer_set_text_alignment(account_two_name_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(account_two_name_layer, GTextOverflowModeWordWrap);

  account_two_code_layer = text_layer_create(GRect(0, 75, 144, 168));
  text_layer_set_text(account_two_code_layer, "");
  text_layer_set_font(account_two_code_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text_alignment(account_two_code_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(account_two_code_layer, GTextOverflowModeWordWrap);

  account_three_name_layer = text_layer_create(GRect(0, 100, 144, 168));
  text_layer_set_font(account_three_name_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text(account_three_name_layer, "");
  text_layer_set_text_alignment(account_three_name_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(account_three_name_layer, GTextOverflowModeWordWrap);

  account_three_code_layer = text_layer_create(GRect(0, 125, 144, 168));
  text_layer_set_font(account_three_code_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text(account_three_code_layer, "");
  text_layer_set_text_alignment(account_three_code_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(account_three_code_layer, GTextOverflowModeWordWrap);

  // This is required to recieve stuff 
  Tuplet initial_values[] = {
        TupletCString(ACCOUNT_NAME_INDEX, ""),
        TupletCString(ACCOUNT_TIME_BASED_KEY_INDEX, "")
    };
  app_sync_init(&sync, sync_buffer, sizeof(sync_buffer), initial_values, ARRAY_LENGTH(initial_values),
        sync_tuple_changed_callback, sync_error_callback, NULL);

  layer_add_child(window_layer, text_layer_get_layer(account_one_name_layer));
  layer_add_child(window_layer, text_layer_get_layer(account_one_code_layer));
  layer_add_child(window_layer, text_layer_get_layer(account_two_name_layer));
  layer_add_child(window_layer, text_layer_get_layer(account_two_code_layer));
  layer_add_child(window_layer, text_layer_get_layer(account_three_name_layer));
  layer_add_child(window_layer, text_layer_get_layer(account_three_code_layer));

}

static void window_unload(Window *window) {
  app_sync_deinit(&sync); 

  text_layer_destroy(account_one_name_layer);
  text_layer_destroy(account_one_code_layer);
  text_layer_destroy(account_two_name_layer);
  text_layer_destroy(account_two_code_layer);
  text_layer_destroy(account_three_name_layer);
  text_layer_destroy(account_three_code_layer);

}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  // text_layer_set_text(text_layer, "Select");
}

static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  // text_layer_set_text(text_layer, "Up");
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  // text_layer_set_text(text_layer, "Down");
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void init(void) {
  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
    printf("here");
  // Required to recieve stuff
  const int inbound_size = app_message_inbox_size_maximum();
  const int outbound_size = app_message_outbox_size_maximum();
  app_message_open(inbound_size, outbound_size);
    printf("here2");
  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  // Null out the keys
  account_one_key[0] = 0;
  account_two_key[0] = 0;
  account_three_key[0] = 0;

  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
