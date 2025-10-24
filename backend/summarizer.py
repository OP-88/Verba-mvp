"""
Transcript summarization logic - generates structured meeting notes
Uses simple rule-based NLP (no external API calls)
"""
import re
from typing import List, Dict


# Filler words to remove for cleaner summaries
FILLER_WORDS = [
    r'\buh+\b', r'\bum+\b', r'\blike\b', r'\byou know\b',
    r'\bkinda\b', r'\bsorta\b', r'\bbasically\b', r'\bactually\b',
    r'\bliterally\b', r'\byeah\b', r'\bmhm\b', r'\bhmm\b'
]


def summarize_transcript(transcript: str) -> Dict:
    """
    Convert a transcript into structured meeting notes
    
    Args:
        transcript: Full text transcript
    
    Returns:
        Dictionary with sections: key_points, decisions, action_items
    """
    if not transcript or len(transcript.strip()) == 0:
        return {
            "key_points": ["No content available"],
            "decisions": [],
            "action_items": []
        }
    
    # Clean the transcript
    cleaned_text = clean_text(transcript)
    
    # Split into sentences
    sentences = split_sentences(cleaned_text)
    
    # Extract key points (first few sentences + longer sentences)
    key_points = extract_key_points(sentences)
    
    # Extract decisions (sentences with decision keywords)
    decisions = extract_decisions(sentences)
    
    # Extract action items (sentences with action keywords)
    action_items = extract_action_items(sentences)
    
    return {
        "key_points": key_points if key_points else ["No significant points captured"],
        "decisions": decisions if decisions else [],
        "action_items": action_items if action_items else []
    }


def clean_text(text: str) -> str:
    """
    Clean filler words and normalize text for better summarization
    """
    # Remove filler words
    for filler in FILLER_WORDS:
        text = re.sub(filler, '', text, flags=re.IGNORECASE)
    
    # Normalize whitespace
    text = re.sub(r'\s+', ' ', text)
    
    return text.strip()


def split_sentences(text: str) -> List[str]:
    """
    Split text into sentences and clean them
    """
    # Split on sentence boundaries
    sentences = re.split(r'[.!?]+', text)
    
    # Clean and filter
    cleaned = []
    for s in sentences:
        s = s.strip()
        if len(s) > 10:  # Ignore very short fragments
            cleaned.append(s)
    
    return cleaned


def format_bullet(text: str, max_words: int = 20) -> str:
    """
    Format a bullet point: capitalize, shorten if needed, clean punctuation
    """
    # Capitalize first letter
    text = text[0].upper() + text[1:] if text else text
    
    # Shorten long sentences
    words = text.split()
    if len(words) > max_words:
        text = ' '.join(words[:max_words]) + '...'
    
    # Remove trailing punctuation clutter
    text = text.rstrip('.,;:')
    
    return text


def extract_key_points(sentences: List[str], max_points: int = 5) -> List[str]:
    """
    Extract key points from sentences
    Heuristic: Take first few sentences and longest sentences
    """
    if not sentences:
        return []
    
    key_points = []
    
    # Take first 2 sentences as context
    for s in sentences[:min(2, len(sentences))]:
        formatted = format_bullet(s)
        if formatted not in key_points:
            key_points.append(formatted)
    
    # Add longer sentences (likely contain more info)
    sorted_by_length = sorted(sentences, key=len, reverse=True)
    for sentence in sorted_by_length:
        if len(key_points) >= max_points:
            break
        formatted = format_bullet(sentence)
        if formatted not in key_points:
            key_points.append(formatted)
    
    return key_points[:max_points]


def extract_decisions(sentences: List[str]) -> List[str]:
    """
    Extract sentences that look like decisions
    Keywords: decided, agreed, will, going to, should, must
    """
    decision_keywords = [
        "decided", "agree", "agreed", "will", "going to", 
        "should", "must", "determined", "concluded", "commit"
    ]
    
    decisions = []
    seen = set()
    
    for sentence in sentences:
        lower = sentence.lower()
        if any(keyword in lower for keyword in decision_keywords):
            formatted = format_bullet(sentence, max_words=18)
            # Avoid duplicates
            if formatted not in seen:
                decisions.append(formatted)
                seen.add(formatted)
    
    return decisions[:5]  # Limit to 5


def extract_action_items(sentences: List[str]) -> List[str]:
    """
    Extract sentences that look like action items
    Keywords: need to, have to, will, todo, task, action, follow up
    """
    action_keywords = [
        "need to", "have to", "will", "should", "must",
        "todo", "task", "action", "follow up", "next step",
        "assign", "responsible", "deadline"
    ]
    
    action_items = []
    seen = set()
    
    for sentence in sentences:
        lower = sentence.lower()
        if any(keyword in lower for keyword in action_keywords):
            formatted = format_bullet(sentence, max_words=18)
            # Avoid duplicates
            if formatted not in seen:
                action_items.append(formatted)
                seen.add(formatted)
    
    return action_items[:5]  # Limit to 5
