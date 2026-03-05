// ExecuteRemote executes a mnemon command on the remote server via SSH.
// It returns the stdout output and any error.
func ExecuteRemote(cfg *Config, args []string) (string, error) {
	if cfg == nil {
		return "", fmt.Errorf("remote config is nil")
	}

	// Build the remote command
	// Example: mnemon remember "content" --cat decision --imp 5
	remoteCmd := "mnemon " + strings.Join(args, " ")

	// Use sshpass for password authentication
	// sshpass -p 'password' ssh -p port user@host 'command'
	sshArgs := []string{
		"-p", cfg.Password,
		"ssh",
		"-o", "StrictHostKeyChecking=no",
		"-o", "UserKnownHostsFile=/dev/null",
		"-p", cfg.Port,
		fmt.Sprintf("%s@%s", cfg.User, cfg.Host),
		remoteCmd,
	}

	cmd := exec.Command("sshpass", sshArgs...)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		return "", fmt.Errorf("ssh execution failed: %w\nstderr: %s", err, stderr.String())
	}

	return stdout.String(), nil
}

// ExecuteRemoteWithStdin executes a command with stdin input.
func ExecuteRemoteWithStdin(cfg *Config, args []string, stdin string) (string, error) {
	if cfg == nil {
		return "", fmt.Errorf("remote config is nil")
	}

	remoteCmd := "mnemon " + strings.Join(args, " ")

	sshArgs := []string{
		"-p", cfg.Password,
		"ssh",
		"-o", "StrictHostKeyChecking=no",
		"-o", "UserKnownHostsFile=/dev/null",
		"-p", cfg.Port,
		fmt.Sprintf("%s@%s", cfg.User, cfg.Host),
		remoteCmd,
	}

	cmd := exec.Command("sshpass", sshArgs...)
	cmd.Stdin = strings.NewReader(stdin)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		return "", fmt.Errorf("ssh execution failed: %w\nstderr: %s", err, stderr.String())
	}

	return stdout.String(), nil
}
