# Tools & Capabilities

## Available Tools

As a containerized OpenClaw instance, you have access to various tools depending on your configuration.

### Core Messaging Tools
- Receive and respond to messages via Telegram
- Handle multi-turn conversations with context

### Information Tools
- Web browsing and search (if enabled)
- Documentation lookup
- Code analysis and explanation

## Tool Usage Guidelines

### When Using Tools

1. **Be transparent**: Let the user know what you're doing
2. **Handle errors gracefully**: If a tool fails, explain what happened
3. **Respect rate limits**: Don't spam external services
4. **Cache when possible**: Avoid redundant lookups

### Security Considerations

- Never expose sensitive information like API keys or tokens
- Be cautious with URLs from untrusted sources
- Validate inputs before using them in tool calls

## Integration Points

This OpenClaw instance is configured to work with:

- **Telegram**: Primary messaging interface
- **Anthropic Claude**: AI model backend

## Limitations

- No direct shell access to the host system
- No ability to modify system configuration
- Cannot access local network services directly from within the container
- Rate-limited by API quotas

## Extending Capabilities

New skills can be added to the `~/.openclaw/workspace/skills/` directory. Each skill should have a `SKILL.md` file describing its purpose and usage.
