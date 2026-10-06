package main

import (
	"fmt"
	"os"
	"os/user"
	"strconv"
	"strings"

	"github.com/elastic/go-sysinfo"
	"github.com/jaypipes/ghw"
	cpu2 "github.com/shirou/gopsutil/v4/cpu"
	"github.com/shirou/gopsutil/v4/disk"
)

func HexColor(hex string) string {
	hex = strings.TrimPrefix(hex, "#")

	r, _ := strconv.ParseUint(hex[0:2], 16, 8)
	g, _ := strconv.ParseUint(hex[2:4], 16, 8)
	b, _ := strconv.ParseUint(hex[4:6], 16, 8)

	return fmt.Sprintf("\033[38;2;%d;%d;%dm", r, g, b)
}

const ColorReset = "\033[0m"

var (
	ColorLogo = HexColor("#5E81AC")
	ColorKey  = HexColor("#A3BE8C")
	ColorVal  = HexColor("#D8DEE9")
)

func main() {
	currentUser, err := user.Current()
	username := "unknown"
	if err == nil {
		username = currentUser.Username
	}

	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	host, err := sysinfo.Host()
	if err != nil {
		fmt.Println("Fehler beim Abrufen der Systeminfos:", err)
		return
	}
	info := host.Info()

	memory, err := host.Memory()
	var ramStr string
	if err == nil {
		used := (memory.Total - memory.Available) / 1024 / 1024
		total := memory.Total / 1024 / 1024
		ramStr = fmt.Sprintf("%d MB / %d MB", used, total)
	} else {
		ramStr = "N/A"
	}

	cpu, err := cpu2.Info()
	if err != nil {
		fmt.Println("Fehler beim Abrufen der Systeminfos:", err)
		return
	}

	gpu, err := ghw.GPU()
	if err != nil {
		fmt.Println("Fehler beim Abrufen der Systeminfos:", err)
		return
	}

	internalDisk, err := disk.Usage("/")
	if err != nil {
		fmt.Println("Fehler beim Abrufen der Systeminfos:", err)
		return
	}

	uptimeDuration := info.Uptime()
	hours := int(uptimeDuration.Hours())
	minutes := int(uptimeDuration.Minutes()) % 60
	uptimeStr := fmt.Sprintf("%dh %dm", hours, minutes)
	cpuStr := fmt.Sprintf("%s CPU", cpu[0].ModelName)
	diskStr := fmt.Sprintf("%d GB / %d GB (%.1f%%)", internalDisk.Used/1024/1024/1024, internalDisk.Total/1024/1024/1024, internalDisk.UsedPercent)

	osName := info.OS.Name
	if info.OS.Version != "" {
		osName = fmt.Sprintf("%s %s", info.OS.Name, info.OS.Version)
	}

	fmt.Println()
	fmt.Printf(ColorLogo+" ________  _________  _______   ________ ________  ________         "+ColorKey+"%s"+ColorVal+"@"+ColorKey+"%s\n", username, hostname)
	fmt.Printf(ColorLogo + "|\\   ____\\|\\___   ___\\\\  ___ \\ |\\  _____\\\\   __  \\|\\   ___  \\       " + ColorReset + "---------------------\n")
	fmt.Printf(ColorLogo+"\\ \\  \\___|\\|___ \\  \\_\\ \\   __/|\\ \\  \\__/\\ \\  \\|\\  \\ \\  \\\\ \\  \\      "+ColorKey+"OS:       "+ColorVal+"%s\n", osName)
	fmt.Printf(ColorLogo+" \\ \\_____  \\   \\ \\  \\ \\ \\  \\_|/_\\ \\   __\\\\ \\   __  \\ \\  \\\\ \\  \\     "+ColorKey+"Kernel:   "+ColorVal+"%s\n", info.KernelVersion)
	fmt.Printf(ColorLogo+"  \\|____|\\  \\   \\ \\  \\ \\ \\  \\_|\\ \\ \\  \\_| \\ \\  \\ \\  \\ \\  \\\\ \\  \\    "+ColorKey+"Arch:     "+ColorVal+"%s\n", info.Architecture)
	fmt.Printf(ColorLogo+"    ____\\_\\  \\   \\ \\__\\ \\ \\_______\\ \\__\\   \\ \\__\\ \\__\\ \\__\\\\ \\__\\   "+ColorKey+"Uptime:   "+ColorVal+"%s\n", uptimeStr)
	fmt.Printf(ColorLogo+"   |\\_________\\   \\|__|  \\|_______|\\|__|    \\|__|\\|__|\\|__| \\|__|   "+ColorKey+"RAM:      "+ColorVal+"%s\n", ramStr)
	fmt.Printf(ColorLogo+"   \\|_________|                                                     "+ColorKey+"CPU:      "+ColorVal+"%s\n", cpuStr)
	for i, gpu := range gpu.GraphicsCards {
		fmt.Printf("                                                                    "+ColorKey+"GPU%d:     "+ColorVal+"%s\n", i, gpu.DeviceInfo.Product.Name)
	}
	fmt.Printf("                                                                    "+ColorKey+"Disk:     "+ColorVal+"%s\n", diskStr)
	fmt.Println(ColorReset)
}
