#!/usr/bin/env python3
import ollama
import sys
import os
import json

def get_command_from_ollama(prompt):
    """
    Sends a prompt to Ollama to get a shell command.
    """
    try:
        response = ollama.chat(
            model='llama3',  # Or your preferred model
            messages=[
                {
                    'role': 'system',
                    'content': f"""
                        You are an expert in shell commands.
                        The user is running on {os.uname().sysname}.
                        The current working directory is {os.getcwd()}.
                        Based on the user's request, provide a single, executable shell command.
                        Only output the command itself, with no additional explanation.
                    """,
                },
                {
                    'role': 'user',
                    'content': prompt,
                },
            ],
        )
        return response['message']['content'].strip()
    except Exception as e:
        return f"Error communicating with Ollama: {e}"

def get_command_correction(failed_command, error_message):
    """
    Sends a failed command and its error to Ollama for a correction.
    """
    try:
        response = ollama.chat(
            model='llama3',
            messages=[
                {
                    'role': 'system',
                    'content': f"""
                        You are an expert in shell command debugging.
                        The user's command ` {failed_command} ` failed with the following error:
                        ` {error_message} `
                        Provide a corrected version of the command.
                        Only output the corrected command itself.
                    """,
                },
            ],
        )
        return response['message']['content'].strip()
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    # This is a basic implementation.
    # You can expand this to handle arguments for different functions.
    if len(sys.argv) > 1:
        user_prompt = " ".join(sys.argv[1:])
        command = get_command_from_ollama(user_prompt)
        print(command)
