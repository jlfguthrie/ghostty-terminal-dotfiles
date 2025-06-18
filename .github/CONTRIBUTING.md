# Contributing to Dotfiles Configuration

Thank you for your interest in contributing! This project aims to provide excellent dotfiles for Ghostty terminal and modern development workflows.

## How to Contribute

### Reporting Issues
- Check existing issues before creating new ones
- Provide clear reproduction steps
- Include system information (macOS version, Ghostty version, etc.)
- Specify what you expected vs. what actually happened

### Suggesting Features
- Ensure the feature aligns with our focus on Ghostty + VS Code workflows
- Consider if it should be optional vs. default
- Provide use cases and benefits

### Code Contributions

#### Guidelines
- **Compatibility**: Changes must work with current Ghostty features (June 2025)
- **Performance**: Maintain fast shell startup times
- **Safety**: Always backup existing configurations
- **Documentation**: Update README and comments

#### Pull Request Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test your changes thoroughly
4. Ensure scripts pass syntax checks
5. Update documentation as needed
6. Submit a pull request with clear description

#### Testing
- Test on clean macOS installation when possible
- Verify backup and restore functionality
- Check that all aliases and functions work
- Ensure VS Code integration remains functional

### Areas for Contribution
- **New Ghostty features**: As Ghostty evolves, integrate new capabilities
- **Modern tools**: Add new CLI tools that enhance development workflows
- **VS Code extensions**: Suggest extensions that complement the setup
- **Performance improvements**: Optimize shell startup and responsiveness
- **Documentation**: Improve setup guides and troubleshooting

## Development Setup

1. Clone the repository
2. Create a test environment (VM or separate user account)
3. Run installation script and test thoroughly
4. Make changes and test again

## Code Style

### Shell Scripts
- Use `#!/bin/bash` for installation scripts
- Use `#!/bin/zsh` for zsh-specific files
- Include error handling (`set -e` where appropriate)
- Add descriptive comments
- Use consistent indentation (2 spaces)

### Configuration Files
- Group related settings with comments
- Explain non-obvious configuration choices
- Maintain alphabetical order where logical
- Use consistent formatting

### Commit Messages
- Use conventional commit format
- Be descriptive but concise
- Reference issues when applicable

Examples:
```
feat: add support for new Ghostty shell integration feature
fix: resolve VS Code terminal font rendering issue
docs: update installation instructions for macOS Sequoia
```

## Questions?

Feel free to open an issue for questions or join discussions about potential improvements.

Thank you for helping make this project better! 🚀
