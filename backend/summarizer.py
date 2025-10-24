"""
Transcript summarization logic - generates structured meeting notes
Uses simple rule-based NLP (no external API calls)
"""
import re


def summarize_transcript(transcript: str) -> dict:
    """
    Convert a transcript into structured meeting notes
    
    Args:
        transcript: Full text transcript
    
    Returns:
        Dictionary with sections: key_points, decisions, action_items
    """
    if not transcript or len(transcript.strip()) == 0:
        return {
            "key_points": ["No transcript provided"],
            "decisions": [],
            "action_items": []
        }
    
    # Split into sentences
    sentences = split_sentences(transcript)
    
    # Extract key points (first few sentences + longer sentences)
    key_points = extract_key_points(sentences)
    
    # Extract decisions (sentences with decision keywords)
    decisions = extract_decisions(sentences)
    
    # Extract action items (sentences with action keywords)
    action_items = extract_action_items(sentences)
    
    return {
        "key_points": key_points,
        "decisions": decisions,
        "action_items": action_items
    }


def split_sentences(text: str) -> list:
    """Split text into sentences"""
    # Simple sentence splitting
    sentences = re.split(r'[.!?]+', text)
    sentences = [s.strip() for s in sentences if s.strip()]
    return sentences


def extract_key_points(sentences: list, max_points: int = 5) -> list:
    """
    Extract key points from sentences
    Heuristic: Take first few sentences and longest sentences
    """
    if not sentences:
        return ["No content to summarize"]
    
    # Take first 3 sentences as context
    key_points = sentences[:min(3, len(sentences))]
    
    # Add longer sentences (likely contain more info)
    sorted_by_length = sorted(sentences, key=len, reverse=True)
    for sentence in sorted_by_length:
        if sentence not in key_points and len(key_points) < max_points:
            key_points.append(sentence)
    
    return key_points[:max_points]


def extract_decisions(sentences: list) -> list:
    """
    Extract sentences that look like decisions
    Keywords: decided, agreed, will, going to, should, must
    """
    decision_keywords = [
        "decided", "agree", "agreed", "will", "going to", 
        "should", "must", "determined", "concluded"
    ]
    
    decisions = []
    for sentence in sentences:
        lower = sentence.lower()
        if any(keyword in lower for keyword in decision_keywords):
            decisions.append(sentence)
    
    return decisions[:5]  # Limit to 5


def extract_action_items(sentences: list) -> list:
    """
    Extract sentences that look like action items
    Keywords: need to, have to, will, todo, task, action, follow up
    """
    action_keywords = [
        "need to", "have to", "will", "should", "must",
        "todo", "task", "action", "follow up", "next step"
    ]
    
    action_items = []
    for sentence in sentences:
        lower = sentence.lower()
        if any(keyword in lower for keyword in action_keywords):
            action_items.append(sentence)
    
    return action_items[:5]  # Limit to 5
