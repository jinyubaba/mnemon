package cmd

import (
	"fmt"
	"os"
	"strings"

	"github.com/mnemon-dev/mnemon/internal/remote"
	"github.com/spf13/cobra"
)

// executeRemoteCommand executes a command on the remote server.
// It reconstructs the command line from the cobra command and args,
// then uses SSH to execute it remotely.
func executeRemoteCommand(cmd *cobra.Command, args []string) error {
	cfg := GetRemoteConfig()
	if cfg == nil {
		return fmt.Errorf("remote mode enabled but no configuration found")
	}

	// Build the command arguments
	cmdArgs := []string{cmd.Name()}

	// Add flags
	cmd.Flags().Visit(func(flag *cobra.Flag) {
		if flag.Changed {
			cmdArgs = append(cmdArgs, fmt.Sprintf("--%s=%s", flag.Name, flag.Value.String()))
		}
	})

	// Add positional arguments
	cmdArgs = append(cmdArgs, args...)

	// Execute remotely
	output, err := remote.ExecuteRemote(cfg, cmdArgs)
	if err != nil {
		return fmt.Errorf("remote execution failed: %w", err)
	}

	// Print the output
	fmt.Print(output)
	return nil
}

// buildRemoteArgs constructs command arguments for remote execution.
func buildRemoteArgs(cmdName string, flags map[string]string, args []string) []string {
	result := []string{cmdName}

	for k, v := range flags {
		if v != "" {
			result = append(result, fmt.Sprintf("--%s", k), v)
		}
	}

	result = append(result, args...)
	return result
}
