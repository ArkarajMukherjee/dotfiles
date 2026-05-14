#include <stdio.h>
#include <string.h>
#include <pulse/pulseaudio.h>

// This callback runs whenever the server info (volume) changes
void sink_info_callback(pa_context *c, const pa_sink_info *i, int eol, void *userdata) {
    if (eol < 0) return; // Error
    if (eol > 0) return; // End of list

    // Calculate volume percentage (avg of all channels)
    float volume_percent = (float)pa_cvolume_avg(&i->volume) / PA_VOLUME_NORM * 100.0f;
    
    // Check if muted
    int muted = i->mute;

    // Check if an external audio device is connected 
    // (Bluetooth, USB, Headphones, Headset, or HDMI)
    int connected = 0;
    if (strstr(i->name, "bluez_sink") != NULL || strstr(i->name, "usb") != NULL) {
        connected = 1;
    } else if (i->active_port) {
        if (strstr(i->active_port->name, "headphone") != NULL ||
            strstr(i->active_port->name, "headset") != NULL ||
            strstr(i->active_port->name, "hdmi") != NULL) {
            connected = 1;
        }
    }

    // Build the status flags (M for Muted, A for Audio device connected)
    char flags[4] = "";
    if (muted || connected) {
        strcat(flags, " ");
        if (muted) strcat(flags, "M");
        if (connected) strcat(flags, "A");
    }

    // CHANGE IS HERE:
    // If muted and connected: returns " MA" -> [VOL MA]
    // If muted only: returns " M"          -> [VOL M]
    // If connected only: returns " A"      -> [VOL A]
    // If neither: returns "" (Empty)       -> [VOL]
    printf("VOL%s %.0f%%\n", flags, volume_percent);
    
    fflush(stdout); // Crucial for Polybar!
}

// This runs when an event (like volume change) happens
void subscribe_callback(pa_context *c, pa_subscription_event_type_t t, uint32_t idx, void *userdata) {
    if ((t & PA_SUBSCRIPTION_EVENT_FACILITY_MASK) == PA_SUBSCRIPTION_EVENT_SINK) {
        pa_context_get_sink_info_by_name(c, "@DEFAULT_SINK@", sink_info_callback, NULL);
    }
}

void context_state_callback(pa_context *c, void *userdata) {
    switch (pa_context_get_state(c)) {
        case PA_CONTEXT_READY:
            pa_context_subscribe(c, PA_SUBSCRIPTION_MASK_SINK, NULL, NULL);
            pa_context_set_subscribe_callback(c, subscribe_callback, NULL);
            pa_context_get_sink_info_by_name(c, "@DEFAULT_SINK@", sink_info_callback, NULL);
            break;
        case PA_CONTEXT_FAILED:
        case PA_CONTEXT_TERMINATED:
            *(int*)userdata = 1; 
            break;
        default:
            break;
    }
}

int main() {
    pa_mainloop *m = pa_mainloop_new();
    pa_mainloop_api *api = pa_mainloop_get_api(m);
    int ret = 0;

    pa_context *c = pa_context_new(api, "Polybar Volume Script");

    pa_context_set_state_callback(c, context_state_callback, &ret);
    pa_context_connect(c, NULL, 0, NULL);

    if (pa_mainloop_run(m, &ret) < 0) {
        printf("VOL ERR\n");
        return 1;
    }

    return ret;
}
