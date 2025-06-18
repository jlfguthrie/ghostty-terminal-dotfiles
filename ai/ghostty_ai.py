#!/usr/bin/env python3
# Requirements:
# - Install ollama Python package: pip install ollama
# - Install and run Ollama service: https://ollama.ai

import sys
import os
import json
import time

try:
    import ollama
except ImportError:
    print("Error: ollama package not found.", file=sys.stderr)
    print("Please install it using: pip install ollama", file=sys.stderr)
    sys.exit(1)

# --- Configuration ---
# Set the model via environment variable or use a fast default.
# Recommended models: 'llama3.1:8b-instruct-q5_K_M' (best), 'phi3:mini' (fastest), 'llama3:8b'
# To use a different model: export OLLAMA_MODEL='phi3:mini'
MODEL = os.getenv('OLLAMA_MODEL', 'llama3.1:8b-instruct-q5_K_M')
# Keep the model loaded for 1 hour to ensure fast subsequent responses.
KEEP_ALIVE = "1h"
# Enable streaming for real-time responses
ENABLE_STREAMING = os.getenv('OLLAMA_STREAMING', 'true').lower() == 'true'

def get_command_from_ollama(prompt: str) -> str:
    """
    First tries to generate a shell command. If that fails, answers the question directly.
    """
    # First attempt: Try to generate a shell command
    command_result = try_generate_command(prompt)

    # If it's a fallback echo message, try answering the question instead
    if command_result.startswith("echo 'This request cannot be converted"):
        print("💭 Switching to Q&A mode...", file=sys.stderr)
        return answer_question(prompt)

    return command_result

def try_generate_command(prompt: str) -> str:
    """
    Attempts to generate a shell command from the prompt.
    """
    system_prompt = f"""
You are an expert in generating shell commands.
The user is running on the '{os.uname().sysname}' operating system.
The current working directory is '{os.getcwd()}'.

IMPORTANT: The user has modern CLI tools installed where:
- 'find' is aliased to 'fd' (a fast alternative to find)
- Use 'fd' syntax instead of traditional 'find' syntax
- Example: 'fd --type f --extension sh' instead of 'find . -type f -name "*.sh"'

Based on the user's request, provide a single, executable shell command.

If the user's request cannot be translated into a shell command (e.g., asking for explanations, general questions, or requests for information that require reasoning), respond with:
{{"command": "echo 'This request cannot be converted to a shell command. Please ask for a specific action.'"}}

You must respond with ONLY a JSON object in this exact format:
{{"command": "your_shell_command_here"}}

Do not include any other fields, explanations, or nested objects.

Examples:
- User: "list files" → {{"command": "ls -la"}}
- User: "show date" → {{"command": "date"}}
- User: "find large files" → {{"command": "fd --type f --size +100M"}}
- User: "find shell scripts" → {{"command": "fd --type f --extension sh"}}
- User: "find python files" → {{"command": "fd --type f --extension py"}}
- User: "what do you know about my project?" → {{"command": "echo 'This request cannot be converted to a shell command. Please ask for a specific action.'"}}
- User: "explain what this does" → {{"command": "echo 'This request cannot be converted to a shell command. Please ask for a specific action.'"}}
"""
    try:
        if ENABLE_STREAMING:
            # Use streaming for command generation
            full_response = ""
            stream = ollama.chat(
                model=MODEL,
                messages=[
                    {'role': 'system', 'content': system_prompt},
                    {'role': 'user', 'content': prompt},
                ],
                format='json',
                options={'keep_alive': KEEP_ALIVE},
                stream=True
            )

            for chunk in stream:
                if 'message' in chunk and 'content' in chunk['message']:
                    full_response += chunk['message']['content']

            response_content = full_response
        else:
            # Non-streaming fallback
            response = ollama.chat(
                model=MODEL,
                messages=[
                    {'role': 'system', 'content': system_prompt},
                    {'role': 'user', 'content': prompt},
                ],
                format='json',  # Use JSON mode for reliable output
                options={'keep_alive': KEEP_ALIVE}
            )
            response_content = response['message']['content']

        command_data = json.loads(response_content)

        if 'command' not in command_data:
            # Handle cases where the model returns a different structure
            if 'unknown_request' in command_data:
                return "echo 'This request cannot be converted to a shell command. Please ask for a specific action.'"
            return "Error: Invalid JSON response from model."

        if not isinstance(command_data['command'], str):
            return "Error: Invalid JSON response from model."

        return command_data['command'].strip()

    except json.JSONDecodeError:
        return f"Error: Failed to decode JSON from model response: {response_content[:100]}..."
    except Exception as e:
        # Check if the model exists locally
        if "model" in str(e) and "not found" in str(e):
             return f"Error: Model '{MODEL}' not found. Please pull it with `ollama pull {MODEL}`"
        return f"Error communicating with Ollama: {e}"

def answer_question(prompt: str) -> str:
    """
    Answers questions directly using AI when they can't be converted to shell commands.
    """
    system_prompt = f"""
You are a helpful AI assistant with knowledge about software development, systems administration, and general computing topics.

The user is working in a development environment:
- Operating System: {os.uname().sysname}
- Current Directory: {os.getcwd()}

Based on the directory name "ghostty-terminal-dotfiles", this appears to be a project for customizing the Ghostty terminal emulator with configuration files, scripts, and themes.

Answer the user's question directly and helpfully. Keep your response concise but informative.
If the question is about their current project, you can suggest shell commands they might run to explore it, such as:
- 'ls -la' to see all files and directories
- 'find . -name "*.py" -o -name "*.sh" -o -name "*.js"' to find scripts
- 'cat README.md' to read project documentation
- 'tree' to see the project structure

Return your answer as a simple JSON object:
{{"answer": "your helpful response here"}}
"""

    try:
        if ENABLE_STREAMING:
            # Use streaming for real-time responses
            full_response = ""
            stream = ollama.chat(
                model=MODEL,
                messages=[
                    {'role': 'system', 'content': system_prompt},
                    {'role': 'user', 'content': prompt},
                ],
                format='json',
                options={'keep_alive': KEEP_ALIVE},
                stream=True
            )

            for chunk in stream:
                if 'message' in chunk and 'content' in chunk['message']:
                    full_response += chunk['message']['content']

            response_content = full_response
        else:
            # Non-streaming fallback
            response = ollama.chat(
                model=MODEL,
                messages=[
                    {'role': 'system', 'content': system_prompt},
                    {'role': 'user', 'content': prompt},
                ],
                format='json',
                options={'keep_alive': KEEP_ALIVE}
            )
            response_content = response['message']['content']

        answer_data = json.loads(response_content)

        # Handle different response formats
        answer_text = None
        if 'answer' in answer_data and isinstance(answer_data['answer'], str):
            answer_text = answer_data['answer']
        elif 'question' in answer_data:
            # Model seems to be restating the question, let's try without JSON mode
            return try_answer_without_json(prompt)
        else:
            # Try to find any string value in the response
            for key, value in answer_data.items():
                if isinstance(value, str) and len(value) > 10:
                    answer_text = value
                    break

        if answer_text:
            # For questions, return the answer directly instead of as an echo command
            # The shell aliases will handle displaying it properly
            return f"ANSWER_MODE:{answer_text}"
        else:
            return "echo 'Sorry, I could not process your question properly.'"

    except json.JSONDecodeError:
        return f"echo 'Error: Failed to parse AI response for your question.'"
    except Exception as e:
        return f"echo 'Error answering question: {e}'"

def try_answer_without_json(prompt: str) -> str:
    """
    Fallback method to answer questions without strict JSON formatting.
    """
    try:
        if ENABLE_STREAMING:
            # Use streaming for fallback answers
            full_response = ""
            stream = ollama.chat(
                model=MODEL,
                messages=[
                    {
                        'role': 'system',
                        'content': f"""
You are a helpful AI assistant. The user is working in a development environment:
- OS: {os.uname().sysname}
- Directory: {os.getcwd()}

Answer their question directly and concisely. Provide helpful information about their project or situation.
"""
                    },
                    {'role': 'user', 'content': prompt},
                ],
                options={'keep_alive': KEEP_ALIVE},
                stream=True
            )

            for chunk in stream:
                if 'message' in chunk and 'content' in chunk['message']:
                    full_response += chunk['message']['content']

            answer_text = full_response.strip()
        else:
            # Non-streaming fallback
            response = ollama.chat(
                model=MODEL,
                messages=[
                    {
                        'role': 'system',
                        'content': f"""
You are a helpful AI assistant. The user is working in a development environment:
- OS: {os.uname().sysname}
- Directory: {os.getcwd()}

Answer their question directly and concisely. Provide helpful information about their project or situation.
"""
                    },
                    {'role': 'user', 'content': prompt},
                ],
                options={'keep_alive': KEEP_ALIVE}
            )
            answer_text = response['message']['content'].strip()

        # Return with special prefix for shell handling
        return f"ANSWER_MODE:{answer_text}"

    except Exception as e:
        return f"echo 'Error answering question: {e}'"

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] in ('-h', '--help'):
        print(f"🤖 Ghostty AI Assistant")
        print(f"Usage: {sys.argv[0]} <your request for a shell command or question>")
        print(f"")
        print(f"📋 Examples:")
        print(f"  Command mode: {sys.argv[0]} find all python files")
        print(f"  Q&A mode:     {sys.argv[0]} what does this project do?")
        print(f"")
        print(f"🧠 Model: {MODEL}")
        print(f"⚡ Streaming: {'Enabled' if ENABLE_STREAMING else 'Disabled'}")
        print(f"")
        print(f"💡 Set OLLAMA_MODEL environment variable to change model")
        print(f"   Set OLLAMA_STREAMING=false to disable streaming")
        sys.exit(0)

    user_prompt = " ".join(sys.argv[1:])

    start_time = time.time()
    command = get_command_from_ollama(user_prompt)
    end_time = time.time()

    # Print the command to stdout and errors/info to stderr
    if command.startswith("Error:"):
        print(command, file=sys.stderr)
        # Suggest pulling the model if it's the default and not found
        if "not found" in command and MODEL == 'phi3:mini':
            print("\nHint: Try running `ollama pull phi3:mini` to download the default model.", file=sys.stderr)
        sys.exit(1)
    else:
        print(command)
        # Optionally print performance info
        # print(f"\n> Generated by {MODEL} in {end_time - start_time:.2f}s", file=sys.stderr)
