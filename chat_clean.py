import json
import re


def clean_text(text):
    """Remove literal escape characters like \\n, \\t, \\r and other illegal characters."""
    if not isinstance(text, str):
        return text
    
    # Remove literal escape sequences (backslash followed by character)
    text = text.replace('\\n', ' ')
    text = text.replace('\\t', ' ')
    text = text.replace('\\r', ' ')
    text = text.replace('\\\\n', ' ')
    text = text.replace('\\\\t', ' ')
    text = text.replace('\\\\r', ' ')
    
    # Remove other common escape sequences
    text = text.replace('\\/', '/')
    text = text.replace('\\"', '"')
    text = text.replace("\\'", "'")
    
    # Remove multiple consecutive spaces
    text = re.sub(r' +', ' ', text)
    
    # Strip leading/trailing whitespace
    text = text.strip()
    
    return text


def clean_contexts(contexts):
    """Clean a list of context strings."""
    if not contexts:
        return []
    return [clean_text(ctx) for ctx in contexts]


def extract_assistant_data(input_file, output_file):
    """Extract content and contexts from assistant messages and save to a new file."""
    
    # Read the input JSON file
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    cleaned_data = []
    
    # Iterate through each chat session
    for session in data:
        if 'history' not in session:
            continue
        
        # Iterate through the history and find assistant messages
        for message in session['history']:
            if message.get('role') == 'assistant':
                entry = {
                    'content': clean_text(message.get('content', '')),
                    'contexts': clean_contexts(message.get('contexts', []))
                }
                cleaned_data.append(entry)
    
    # Write the cleaned data to output file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(cleaned_data, f, indent=2, ensure_ascii=False)
    
    print(f"Extracted {len(cleaned_data)} assistant messages")
    print(f"Saved cleaned data to: {output_file}")


if __name__ == '__main__':
    input_file = 'chat_sessions.json'
    output_file = 'chat_clean.json'
    extract_assistant_data(input_file, output_file)
