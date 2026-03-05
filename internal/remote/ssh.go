package remote

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// Config holds remote SSH connection configuration.
type Config struct {
	Host     string
	User     string
	Password string
	Port     string
}

// LoadConfig loads remote configuration from environment variables.
// MNEMON_REMOTE_HOST, MNEMON_REMOTE_USER, MNEMON_REMOTE_PASSWORD, MNEMON_REMOTE_PORT
func LoadConfig() *Config {
	host := os.Getenv("MNEMON_REMOTE_HOST")
	if host == "" {
		return nil
	}

	port := os.Getenv("MNEMON_REMOTE_PORT")
	if port == "" {
		port = "22"
	}

	return &Config{
		Host:     host,
		User:     os.Getenv("MNEMON_REMOTE_USER"),
		Password: os.Getenv("MNEMON_REMOTE_PASSWORD"),
		Port:     port,
	}
}

// IsEnabled returns true if remote mode is configured.
func IsEnabled() bool {
	return LoadConfig() != nil
}
