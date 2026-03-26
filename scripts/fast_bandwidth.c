#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BUF_SIZE 1024
#define UPDATE_INTERVAL_MS 1000 // 1 second update rate

// Nerd Font Icons 
#define ICON_UP ""   
#define ICON_DOWN "" 

typedef struct {
    unsigned long long rx_bytes;
    unsigned long long tx_bytes;
} NetStats;

void format_speed(double speed_bps, char *buffer) {
    if (speed_bps >= 1024 * 1024) {
        sprintf(buffer, "%.1fMB/s", speed_bps / (1024 * 1024));
    } else if (speed_bps >= 1024) {
        sprintf(buffer, "%.1fKB/s", speed_bps / 1024);
    } else {
        sprintf(buffer, "%.0fB/s", speed_bps);
    }
}

NetStats get_network_stats() {
    FILE *fp = fopen("/proc/net/dev", "r");
    char buffer[BUF_SIZE];
    NetStats stats = {0, 0};
    
    if (fp == NULL) return stats;

    fgets(buffer, BUF_SIZE, fp);
    fgets(buffer, BUF_SIZE, fp);

    while (fgets(buffer, BUF_SIZE, fp) != NULL) {
        char *iface = buffer;
        while (*iface == ' ') iface++;
        char *colon = strchr(iface, ':');
        if (!colon) continue;
        if (strncmp(iface, "lo", 2) == 0) continue;

        unsigned long long rx, tx, junk;
        // Parse RX (col 1) and TX (col 9)
        sscanf(colon + 1, "%llu %llu %llu %llu %llu %llu %llu %llu %llu", 
               &rx, &junk, &junk, &junk, &junk, &junk, &junk, &junk, &tx);
        
        stats.rx_bytes += rx;
        stats.tx_bytes += tx;
    }
    
    fclose(fp);
    return stats;
}

int main() {
    NetStats prev = {0, 0};
    NetStats current;
    char rx_str[16], tx_str[16];

    prev = get_network_stats();

    while (1) {
        usleep(UPDATE_INTERVAL_MS * 1000); 
        
        current = get_network_stats();

        double time_factor = 1000.0 / UPDATE_INTERVAL_MS;
        double rx_speed = (double)(current.rx_bytes - prev.rx_bytes) * time_factor;
        double tx_speed = (double)(current.tx_bytes - prev.tx_bytes) * time_factor;

        format_speed(rx_speed, rx_str);
        format_speed(tx_speed, tx_str);

        // Updated Format: Right Aligned (%8s) with Icons after numbers
        printf("[BAND] %8s %s %8s %s\n", tx_str, ICON_UP, rx_str, ICON_DOWN);
        fflush(stdout);

        prev = current;
    }
    return 0;
}
