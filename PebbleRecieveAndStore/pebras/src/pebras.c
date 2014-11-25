#include <pebble.h>
static Window *window;
static TextLayer *text_layer;
static TextLayer *second_text_layer;
static TextLayer *third_text_layer;
static TextLayer *fourth_text_layer;
static TextLayer *fifth_text_layer;

static AppSync sync;
static uint8_t sync_buffer[256];

enum DictionaryIndices {
  ACCOUNT_UNIQUE_ID_INDEX = 0,
  ACCOUNT_NAME_INDEX = 1,
  ACCOUNT_TIME_BASED_KEY_INDEX = 2,
  ACCOUNT_DELETE_INDEX = 4,
  EPOCH_TIME_STAMP_GMT_INDEX = 9      // TUPLE_CSTRING
};

static void sync_error_callback(DictionaryResult dict_error, AppMessageResult app_message_error, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "App Message Sync Error: %d", app_message_error);
}

// Required to recieve stuff
static void sync_tuple_changed_callback(const uint32_t key, const Tuple* new_tuple, const Tuple* old_tuple, void* context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "value: %s", new_tuple->value->cstring);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "key: %d", (uint8_t) key);

  switch (key) {
    case ACCOUNT_UNIQUE_ID_INDEX: 
        // Check if account has been saved to internal storage 
        // If so, then this is an Edit command, and update it with 
        // a new name and key
        // If not, then this is a Create command, so save it to storage
        text_layer_set_text(text_layer, new_tuple->value->cstring);
        break;
    case ACCOUNT_NAME_INDEX:
        // Data for Edit and Create command
        text_layer_set_text(second_text_layer, new_tuple->value->cstring);
        break;
    case ACCOUNT_TIME_BASED_KEY_INDEX:
        // Data for Edit and Create command
        text_layer_set_text(third_text_layer, new_tuple->value->cstring);
        break;
    case ACCOUNT_DELETE_INDEX: 
        // If this is true, delete the given account from 
        // persistent storage.
        text_layer_set_text(fourth_text_layer, new_tuple->value->cstring);
        break;
    case EPOCH_TIME_STAMP_GMT_INDEX:
        // This is always sent with the dictionary.
        text_layer_set_text(fifth_text_layer, new_tuple->value->cstring);

        break;
  }
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  // Setting up the text layer
  text_layer = text_layer_create(GRect(0, 0, 144, 168));
  text_layer_set_text(text_layer, "Recieved items go here");
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(text_layer, GTextOverflowModeWordWrap);

  second_text_layer = text_layer_create(GRect(0, 20, 144, 168));
  text_layer_set_text(second_text_layer, "Recieved items go here");
  text_layer_set_text_alignment(second_text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(second_text_layer, GTextOverflowModeWordWrap);

  third_text_layer = text_layer_create(GRect(0, 40, 144, 168));
  text_layer_set_text(third_text_layer, "Recieved items go here");
  text_layer_set_text_alignment(third_text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(third_text_layer, GTextOverflowModeWordWrap);

  fourth_text_layer = text_layer_create(GRect(0, 60, 144, 168));
  text_layer_set_text(fourth_text_layer, "Recieved items go here");
  text_layer_set_text_alignment(fourth_text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(fourth_text_layer, GTextOverflowModeWordWrap);

  fifth_text_layer = text_layer_create(GRect(0, 80, 144, 168));
  text_layer_set_text(fifth_text_layer, "Recieved items go here");
  text_layer_set_text_alignment(fifth_text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(fifth_text_layer, GTextOverflowModeWordWrap);

  // This is required to recieve stuff 
  Tuplet initial_values[] = {
        TupletCString(ACCOUNT_UNIQUE_ID_INDEX, "accountID"),
        TupletCString(ACCOUNT_NAME_INDEX, "accountName"),
        TupletCString(ACCOUNT_TIME_BASED_KEY_INDEX, "accountKey"),
        TupletCString(ACCOUNT_DELETE_INDEX, "accountDelete"),
        TupletCString(EPOCH_TIME_STAMP_GMT_INDEX, "epoch")
    };
  app_sync_init(&sync, sync_buffer, sizeof(sync_buffer), initial_values, ARRAY_LENGTH(initial_values),
        sync_tuple_changed_callback, sync_error_callback, NULL);

  layer_add_child(window_layer, text_layer_get_layer(text_layer));
  layer_add_child(window_layer, text_layer_get_layer(second_text_layer));
  layer_add_child(window_layer, text_layer_get_layer(third_text_layer));
  layer_add_child(window_layer, text_layer_get_layer(fourth_text_layer));
  layer_add_child(window_layer, text_layer_get_layer(fifth_text_layer));

}

static void window_unload(Window *window) {
  app_sync_deinit(&sync); 

  text_layer_destroy(text_layer);
  text_layer_destroy(second_text_layer);
  text_layer_destroy(third_text_layer);
  text_layer_destroy(fourth_text_layer);
  text_layer_destroy(fifth_text_layer);

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

  // Required to recieve stuff
  const int inbound_size = app_message_inbox_size_maximum();
  const int outbound_size = app_message_outbox_size_maximum();
  app_message_open(inbound_size, outbound_size);

  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
