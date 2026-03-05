package remote

import (
	"os"
)

// Config holds remote SSH connection configuration.
type Config struct {
	Host     string
	User     string
	Password string // Optional: only used if SSH key authentication is not available
	Port     string
}

// LoadConfig loads remote configuration from environment variables.
// MNEMON_REMOTE_HOST, MNEMON_REMOTE_USER, MNEMON_REMOTE_PORT
// Note: MNEMON_REMOTE_PASSWORD is optional and not used with SSH key authentication
func LoadConfig() *Config {
	host := os.Getenv("MNEMON_REMOTE_HOST")
	if host == "" {
		return nil
	}

	port := os.Getenv("MNEMON_REMOTE_PORT")
	if port == "" {
		port = "22"
	}

	user := os.Getenv("MNEMON_REMOTE_USER")
	if user == "" {
		user = "root" // Default user
	}

	return &Config{
		Host:     host,
		User:     user,
		Password: os.Getenv("MNEMON_REMOTE_PASSWORD"), // Optional
		Port:     port,
	}
}

// IsEnabled returns true if remote mode is configured.
func IsEnabled() bool {
	return LoadConfig() != nil
}
