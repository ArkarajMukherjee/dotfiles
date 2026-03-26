#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main() {
    FILE *fp;
    int capacity;
    char status[32];
    char path_cap[64] = "/sys/class/power_supply/BAT0/capacity";
    char path_stat[64] = "/sys/class/power_supply/BAT0/status";

    // Auto-detect: If BAT0 doesn't exist, switch to BAT1
    if (access(path_cap, F_OK) == -1) {
        strcpy(path_cap, "/sys/class/power_supply/BAT1/capacity");
        strcpy(path_stat, "/sys/class/power_supply/BAT1/status");
    }

    while (1) {
        // 1. Read Capacity
        fp = fopen(path_cap, "r");
        if (fp == NULL) { sleep(1); continue; }
        fscanf(fp, "%d", &capacity);
        fclose(fp);

        // 2. Read Status
        // Status can be: "Charging", "Discharging", "Full", "Not charging", "Unknown"
        fp = fopen(path_stat, "r");
        status[0] = '\0'; 
        if (fp != NULL) {
            fscanf(fp, "%s", status);
            fclose(fp);
        }

        // 3. Logic
        // If status is ANYTHING other than "Discharging", we assume plugged in.
        if (strcmp(status, "Discharging") != 0) {
             // PLUGGED IN (Charging or Full)
             printf("[BAT]  %d%%\n", capacity);
        } else {
             // BATTERY ONLY (No icon)
             printf("[BAT] %d%%\n", capacity);
        }

        fflush(stdout);
        sleep(1);
    }
    return 0;
}
