#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>

#define MAX_CORES 128
#define BUF_SIZE 1024

// Structure to hold previous CPU ticks for calculation
typedef struct {
    unsigned long long total;
    unsigned long long idle;
    char temp_path[256]; // Store the path to this core's temp file
} CoreData;

CoreData core_data[MAX_CORES];
char hwmon_path[256] = "";

// Helper: Find the hwmon directory for "coretemp" (Intel driver)
void find_coretemp_path() {
    DIR *d;
    struct dirent *dir;
    char path[256], content[256];
    FILE *f;

    d = opendir("/sys/class/hwmon");
    if (!d) return;

    while ((dir = readdir(d)) != NULL) {
        if (strncmp(dir->d_name, "hwmon", 5) == 0) {
            snprintf(path, sizeof(path), "/sys/class/hwmon/%s/name", dir->d_name);
            f = fopen(path, "r");
            if (f) {
                if (fgets(content, sizeof(content), f)) {
                    if (strncmp(content, "coretemp", 8) == 0) {
                        snprintf(hwmon_path, sizeof(hwmon_path), "/sys/class/hwmon/%s", dir->d_name);
                        fclose(f);
                        break;
                    }
                }
                fclose(f);
            }
        }
    }
    closedir(d);
}

// Helper: Get physical core ID for a logical CPU (to match temp file)
int get_physical_core_id(int cpu_id) {
    char path[256];
    int phy_id = 0;
    snprintf(path, sizeof(path), "/sys/devices/system/cpu/cpu%d/topology/core_id", cpu_id);
    FILE *f = fopen(path, "r");
    if (f) {
        fscanf(f, "%d", &phy_id);
        fclose(f);
    }
    return phy_id;
}

// Helper: Setup paths for each CPU
void init_core_metadata() {
    find_coretemp_path();
    if (strlen(hwmon_path) == 0) return; // Driver not found

    for (int i = 0; i < MAX_CORES; i++) {
        // Map Logical CPU (0,1,2,3) -> Physical Core (0,1)
        int phy_core = get_physical_core_id(i);
        
        // Construct path: tempX_input. 
        // Usually Package=temp1, Core0=temp2, Core1=temp3... so offset is +2
        snprintf(core_data[i].temp_path, sizeof(core_data[i].temp_path), 
                 "%s/temp%d_input", hwmon_path, phy_core + 2);
    }
}

// Helper: Read temp from pre-calculated path
int read_temp(int cpu_id) {
    if (strlen(core_data[cpu_id].temp_path) == 0) return 0;
    
    FILE *f = fopen(core_data[cpu_id].temp_path, "r");
    int temp = 0;
    if (f) {
        fscanf(f, "%d", &temp);
        fclose(f);
    } else {
        // Fallback: Try Package Temp (temp1_input) if core temp is missing
        char fallback[256];
        snprintf(fallback, sizeof(fallback), "%s/temp1_input", hwmon_path);
        f = fopen(fallback, "r");
        if (f) {
            fscanf(f, "%d", &temp);
            fclose(f);
        }
    }
    return temp / 1000; // Convert millidegrees to degrees
}

int main() {
    FILE *fp;
    char buffer[BUF_SIZE];
    unsigned long long user, nice, system, idle, iowait, irq, softirq, steal;
    unsigned long long current_total, current_idle, diff_total, diff_idle;
    int core_id;
    int first_run = 1;

    // Zero out struct and setup temps
    memset(core_data, 0, sizeof(core_data));
    init_core_metadata();

    while (1) {
        fp = fopen("/proc/stat", "r");
        if (fp == NULL) {
            perror("Error opening /proc/stat");
            return 1;
        }

        printf("[CPU]");

        while (fgets(buffer, BUF_SIZE, fp) != NULL) {
            if (strncmp(buffer, "cpu", 3) == 0 && buffer[3] >= '0' && buffer[3] <= '9') {
                
                sscanf(buffer, "cpu%d %llu %llu %llu %llu %llu %llu %llu %llu", 
                       &core_id, &user, &nice, &system, &idle, &iowait, &irq, &softirq, &steal);

                if (core_id >= MAX_CORES) continue;

                current_idle = idle + iowait;
                current_total = user + nice + system + idle + iowait + irq + softirq + steal;

                diff_total = current_total - core_data[core_id].total;
                diff_idle = current_idle - core_data[core_id].idle;
                
                double usage = 0.0;
                if (diff_total != 0) {
                    usage = (double)(diff_total - diff_idle) / diff_total * 100.0;
                }

                if (!first_run) {
                    // Get Temp for this specific core
                    int temp = read_temp(core_id);
                    // Print format: " 12% 45°C"
                    printf(" %3.0f%% %d°C", usage, temp);
                }

                core_data[core_id].total = current_total;
                core_data[core_id].idle = current_idle;
            }
        }

        printf("\n");
        fflush(stdout);
        fclose(fp);
        
        first_run = 0;
        usleep(500000); // Updated to 500ms (reading temps is slower than just /proc/stat)
    }

    return 0;
}
